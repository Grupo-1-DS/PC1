#!/usr/bin/env bats

setup() {
  # Variables locales
  ROOT_DIR="$(pwd)"
  OUT_DIR="$ROOT_DIR/out"
  mkdir -p "$OUT_DIR"

  # Cargar variables de entorno desde .env
  if [ -f .env ]; then
    dos2unix .env
    source .env
  else
    echo "Archivo .env no encontrado."
    exit 1
  fi

}

teardown() {
  echo "Logs guardados en: $LOG_FILE"
}


@test "Prueba TLS con openssl s_client" {
  LOG_FILE="$OUT_DIR/tls_openssl.txt"

  echo "=== openssl s_client contra $DOMINIO:$PORT ===" > "$LOG_FILE"

  if command -v openssl >/dev/null 2>&1; then
    run openssl s_client -connect "$DOMINIO:$PORT" -servername "$DOMINIO" -brief -showcerts </dev/null
    echo "$output" >> "$LOG_FILE"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Protocol"
  else
    echo "openssl no disponible" >> "$LOG_FILE"
    skip "openssl no disponible"
  fi
}

@test "Prueba de encabezados HTTP sobre TLS" {
  LOG_FILE="$OUT_DIR/tls_curl_headers.txt"

  echo "=== curl -skI https://$DOMINIO ===" > "$LOG_FILE"

  if command -v curl >/dev/null 2>&1; then
    run curl -skI "https://$DOMINIO"
    echo "$output" >> "$LOG_FILE"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "HTTP/"
  else
    echo "curl no disponible" >> "$LOG_FILE"
    skip "curl no disponible"
  fi
}
