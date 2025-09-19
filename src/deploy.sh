#!/bin/bash


# Carga las variables de entorno desde .env
if [ -f .env ]; then
    source .env
else
    echo "Archivo .env no encontrado."
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
        -subj "/CN=localhost"
fi



# Arranca la miniapp Flask en segundo plano y guarda el PID
echo "Iniciando miniapp Flask en $IP:$PORT con nohup..."
APP_LOG="flask.log"
nohup python miniapp_flask/app.py > "$APP_LOG" 2>&1 &
FLASK_PID=$!
echo $FLASK_PID > flask_app.pid
sleep 2



# Asigna el dominio personalizado al localhost en /etc/hosts (requiere sudo)
echo "Asignando $DOMINIO a localhost:$PORT en /etc/hosts (sudo)"
echo "$IP $DOMINIO" | sudo tee -a /etc/hosts




# Ejecuta los tests automáticos (HTTP, DNS, TLS)
bats tests/



# Espera a que el usuario decida terminar para limpiar todo
read -p "Presiona Enter para finalizar y detener la app..."


# Detiene la app Flask y limpia la entrada en /etc/hosts
kill $FLASK_PID
sudo sed -i "/$IP $DOMINIO/d" /etc/hosts


echo "Despliegue finalizado."
