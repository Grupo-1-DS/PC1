#!/usr/bin/env bats

setup() {
  # Variables locales
  ROOT_DIR="$(pwd)"
  OUT_DIR="$ROOT_DIR/out"
  mkdir -p "$OUT_DIR"

  # Cargar las variables de entorno desde .env
  if [ -f .env ]; then
    dos2unix .env
    source .env
  else
    echo "Archivo de variables de entorno (.env) no encontrado."
    exit 1
  fi
}

teardown() {
  echo "Respuestas guardadas en: $LOG_FILE"
}

@test "Resolución DNS - registro A" {
  LOG_FILE="$OUT_DIR/dns_a.txt"

  echo "=== Prueba con registro A ===" > "$LOG_FILE"

  run getent hosts "$DOMINIO"
  echo "$output" >> "$LOG_FILE"

  [ "$status" -eq 0 ]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "Resolución DNS - registro CNAME" {
  LOG_FILE="$OUT_DIR/dns_cname.txt"

  echo "=== Prueba con CNAME ===" > "$LOG_FILE"
  run dig +noall +answer "$DOMINIO" CNAME
  echo "$output" >> "$LOG_FILE"

  [ "$status" -eq 0 ]
}

