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
    echo "Archivo .env no encontrado."
    exit 1
  fi
}

teardown() {
  echo "Respuestas guardadas en: $LOG_FILE"
}

@test "Resolución DNS - registro A" {
  LOG_FILE="$OUT_DIR/dns_a.txt"

  echo "=== Registro A de $DOMINIO ===" > "$LOG_FILE"
  run dig +noall +answer "$DOMINIO" A
  echo "$output" >> "$LOG_FILE"

  [ "$status" -eq 0 ]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "Resolución DNS - registro CNAME" {
  LOG_FILE="$OUT_DIR/dns_cname.txt"

  echo "=== Registro CNAME de $DOMINIO ===" > "$LOG_FILE"
  run dig +noall +answer "$DOMINIO" CNAME
  echo "$output" >> "$LOG_FILE"

  [ "$status" -eq 0 ]
}

@test "Parseo de TTL" {
  LOG_FILE="$OUT_DIR/dns_ttl.txt"

  echo "=== TTL de $DOMINIO ===" > "$LOG_FILE"
  run dig +noall +answer "$DOMINIO" A
  echo "$output" >> "$LOG_FILE"

  ttl=$(echo "$output" | awk '{print $2}' | head -n1)
  echo "TTL: $ttl" >> "$LOG_FILE"

  [ -n "$ttl" ]
  [[ "$ttl" =~ ^[0-9]+$ ]]
}
