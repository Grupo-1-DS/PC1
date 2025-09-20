#!/bin/bash


# Carga las variables de entorno desde .env
if [ -f .env ]; then
    dos2unix .env > /dev/null 2>&1
    source .env
else
    echo "Archivo .env no encontrado."
    exit 1
fi

# Crea y activa el entorno virtual (si no existe)
if [ ! -d "venv" ]; then
    echo "Creando entorno virtual..."
    python3 -m venv venv
    if [ $? -eq 0 ]; then
        echo "Entorno virtual creado exitosamente."
    else
        echo "Error: No se pudo crear el entorno virtual."
        exit 1
    fi
fi

echo "Activando entorno virtual..."
source venv/bin/activate
if [ $? -eq 0 ]; then
    echo "Entorno virtual activado."
else
    echo "Error: No se pudo activar el entorno virtual."
    exit 1
fi

# Instala las dependencias de la aplicación
echo "Instalando dependencias..."
pip install -r miniapp_flask/requirements.txt > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Dependencias instaladas exitosamente."
else
    echo "Error: No se pudieron instalar las dependencias."
    exit 1
fi

# Muestra la versión del despliegue
echo "DESPLIEGUE $RELEASE"


# Si no existe, genera un certificado TLS autofirmado para HTTPS local
CERT_DIR="miniapp_flask/certs"
CERT_KEY="$CERT_DIR/server.key"
CERT_CRT="$CERT_DIR/server.crt"
if [ ! -f "$CERT_KEY" ] || [ ! -f "$CERT_CRT" ]; then
    echo "Generando certificado TLS autofirmado en $CERT_DIR..."
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERT_KEY" -out "$CERT_CRT" \
        -subj "/CN=localhost" > /dev/null 2>&1
fi



# Arranca la miniapp Flask en segundo plano y guarda el PID
echo "Iniciando miniapp Flask en $IP:$PORT con nohup..."
APP_LOG="flask.log"
nohup python3 miniapp_flask/app.py > "$APP_LOG" 2>&1 &
FLASK_PID=$!
echo $FLASK_PID > flask_app.pid
sleep 2



# Asigna el dominio personalizado al localhost en /etc/hosts (requiere sudo)
echo "Asignando $DOMINIO a localhost:$PORT en /etc/hosts (sudo)"
echo "$IP $DOMINIO" | sudo tee -a /etc/hosts




# Ejecuta los tests automáticos (HTTP, DNS, TLS)
for test_file in tests/*.bats; do
    bats "$test_file"
    TEST_STATUS=$?
    if [ $TEST_STATUS -ne 0 ]; then
        echo "El test $test_file falló :(. Deteniendo la aplicación Flask..."
        kill $FLASK_PID
        sudo sed -i "/$IP $DOMINIO/d" /etc/hosts
        exit 1
    fi
done

# Espera a que el usuario decida terminar para limpiar todo
read -p "Presiona Enter para finalizar y detener la app..."


# Detiene la app Flask y limpia la entrada en /etc/hosts
kill $FLASK_PID
sudo sed -i "/$IP $DOMINIO/d" /etc/hosts


echo "Despliegue finalizado."
