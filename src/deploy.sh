#!/bin/bash

# Logging con journalctl (Admin)
log_deploy() {
    local message="$1"
    local priority="${2:-info}"
    echo "$message"
    # Si está systemd, loggear al journal
    if command -v systemd-cat >/dev/null 2>&1; then
        echo "DEPLOY[${RELEASE:-PC1}]: $message" | systemd-cat -t "pc1-deploy" -p "$priority"
    fi
}

# Validar que el .env esté bien (Toolkit)
validate_config() {
    log_deploy "Validando configuración..." "info"
    
    # Buscar PORT en .env
    if ! grep -q "^PORT=" .env 2>/dev/null; then
        log_deploy "ERROR: PORT no encontrado en .env" "err"
        return 1
    fi
    
    # Sacar el puerto y validar rango
    local port_value=$(grep "^PORT=" .env | cut -d'=' -f2)
    if [ "$port_value" -lt 1024 ] || [ "$port_value" -gt 65535 ]; then
        log_deploy "ERROR: Puerto inválido: $port_value" "err"
        return 1
    fi
    
    # Verificar formato de IP
    local ip_value=$(grep "^IP=" .env | cut -d'=' -f2)
    if ! echo "$ip_value" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
        log_deploy "ERROR: IP inválida: $ip_value" "err"
        return 1
    fi
    
    log_deploy "Configuración válida: Puerto=$port_value, IP=$ip_value" "info"
    return 0
}

# Revisar permisos antes de empezar (Admin)
check_permissions() {
    log_deploy "Verificando permisos del sistema..." "info"
    
    # Ver si podemos usar sudo
    if ! sudo -n true 2>/dev/null; then
        log_deploy "ADVERTENCIA: Se necesitarán permisos sudo para modificar /etc/hosts" "warning"
    fi
    
    # Mostrar grupos del usuario
    local user_groups=$(groups)
    log_deploy "Usuario actual en grupos: $user_groups" "info"
    
    # Verificar que podemos crear certificados
    if [ ! -w "$(dirname "$CERT_DIR")" ]; then
        log_deploy "ERROR: Sin permisos de escritura para certificados" "err"
        return 1
    fi
    
    return 0
}

# Verificar si un proceso está vivo
monitor_process() {
    local pid="$1"
    local service_name="$2"
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if kill -0 "$pid" 2>/dev/null; then
            log_deploy "$service_name ejecutándose correctamente (PID: $pid)" "info"
            return 0
        fi
        log_deploy "Intento $attempt/$max_attempts: Esperando a $service_name..." "info"
        sleep 1
        ((attempt++))
    done
    
    log_deploy "ERROR: $service_name no se inició correctamente" "err"
    return 1
}

# Empezar el despliegue
log_deploy "Iniciando despliegue PC1..." "info"

# Cargar el .env primero
if [ -f .env ]; then
    dos2unix .env > /dev/null 2>&1
    source .env
    log_deploy "Variables de entorno cargadas desde .env" "info"
else
    log_deploy "ERROR: Archivo .env no encontrado" "err"
    exit 1
fi

# Setup del venv
if [ ! -d "venv" ]; then
    log_deploy "Creando entorno virtual..." "info"
    python3 -m venv venv
    if [ $? -eq 0 ]; then
        log_deploy "Entorno virtual creado exitosamente" "info"
    else
        log_deploy "ERROR: No se pudo crear el entorno virtual" "err"
        exit 1
    fi
fi

log_deploy "Activando entorno virtual..." "info"
source venv/bin/activate
if [ $? -eq 0 ]; then
    log_deploy "Entorno virtual activado" "info"
else
    log_deploy "ERROR: No se pudo activar el entorno virtual" "err"
    exit 1
fi

# Instalar dependencias de la aplicacion
log_deploy "Instalando dependencias..." "info"
pip install -r miniapp_flask/requirements.txt > /dev/null 2>&1
if [ $? -eq 0 ]; then
    log_deploy "Dependencias instaladas exitosamente" "info"
else
    log_deploy "ERROR: No se pudieron instalar las dependencias" "err"
    exit 1
fi

# Muestra la versión del despliegue
echo "DESPLIEGUE $RELEASE"


# Si no existe, genera un certificado TLS autofirmado para HTTPS local
CERT_DIR="miniapp_flask/certs"
CERT_KEY="$CERT_DIR/server.key"
CERT_CRT="$CERT_DIR/server.crt"

# Validar que todo esté bien
if ! validate_config; then
    log_deploy "ERROR: Validación de configuración falló" "err"
    exit 1
fi

# Revisar permisos
if ! check_permissions; then
    log_deploy "ERROR: Verificación de permisos falló" "err"
    exit 1
fi

log_deploy "DESPLIEGUE $RELEASE" "info"

# Crear certificados si no existen
if [ ! -f "$CERT_KEY" ] || [ ! -f "$CERT_CRT" ]; then
    log_deploy "Generando certificado TLS autofirmado en $CERT_DIR..." "info"
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERT_KEY" -out "$CERT_CRT" \
        -subj "/CN=localhost"
    log_deploy "Certificado TLS generado correctamente" "info"
fi

# Levantar Flask
log_deploy "Iniciando miniapp Flask en $IP:$PORT con nohup..." "info"
APP_LOG="flask.log"
nohup python3 miniapp_flask/app.py > "$APP_LOG" 2>&1 &
FLASK_PID=$!
echo $FLASK_PID > flask_app.pid
sleep 3

# Verificar que Flask arrancó bien
if ! monitor_process "$FLASK_PID" "Flask App"; then
    log_deploy "ERROR: Flask no se inició correctamente" "err"
    exit 1
fi

# Agregar dominio a /etc/hosts
log_deploy "Asignando $DOMINIO a localhost:$PORT en /etc/hosts (sudo)" "info"
if echo "$IP $DOMINIO" | sudo tee -a /etc/hosts > /dev/null; then
    log_deploy "Dominio $DOMINIO asignado correctamente" "info"
else
    log_deploy "ERROR: No se pudo asignar el dominio" "err"
    kill $FLASK_PID 2>/dev/null
    exit 1
fi


sleep 2

# Ejecuta los tests automáticos (HTTP, DNS, TLS)
for test_file in tests/*.bats; do
    bats "$test_file"
    TEST_STATUS=$?
    if [ $TEST_STATUS -ne 0 ]; then
        log_deploy "El test $test_file falló :(. Deteniendo la aplicación Flask..." "warning"
        kill $FLASK_PID
        sudo sed -i "/$IP $DOMINIO/d" /etc/hosts
        exit 1  
    fi
done

log_deploy "Todos los tests ejecutados exitosamente" "info"


# Esperar al usuario
read -p "Despliegue completado. Presiona Enter para finalizar y detener la app..."

# Limpiar todo
log_deploy "Finalizando despliegue..." "info"
if kill $FLASK_PID 2>/dev/null; then
    log_deploy "Flask App detenida (PID: $FLASK_PID)" "info"
else
    log_deploy "ADVERTENCIA: No se pudo detener Flask App" "warning"
fi

if sudo sed -i "/$IP $DOMINIO/d" /etc/hosts; then
    log_deploy "Entrada de /etc/hosts eliminada" "info"
else
    log_deploy "ADVERTENCIA: No se pudo limpiar /etc/hosts" "warning"
fi

log_deploy "Despliegue finalizado correctamente" "info"