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

  BASE_URL="https://$IP:$PORT"
}

teardown() {
  echo "Logs guardados en: $LOG_FILE"
}

@test "Prueba de metodo GET en /" {
  LOG_FILE="$OUT_DIR/http_get.log"

  echo "=== GET $BASE_URL/ ===" > "$LOG_FILE"
  curl -sk -i "$BASE_URL/" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"

  http_code=$(curl -sk -o /dev/null -w "%{http_code}" "$BASE_URL/")
  [ "$http_code" -eq 200 ]
}

@test "Prueba de metodo GET en /items" {
  LOG_FILE="$OUT_DIR/http_get_items.log"

  echo "=== GET $BASE_URL/items ===" > "$LOG_FILE"
  response=$(curl -sk -i "$BASE_URL/items")
  echo "$response" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"

  http_code=$(curl -sk -o /dev/null -w "%{http_code}" "$BASE_URL/items")
  [ "$http_code" -eq 200 ]
  echo "$response" | grep -q "Content-Type: application/json"
  echo "$response" | grep -q '"id": 1'
}

@test "Prueba de metodo PUT en /items/99" {
  LOG_FILE="$OUT_DIR/http_put_item.log"

  echo "=== PUT $BASE_URL/items/99 ===" > "$LOG_FILE"
  curl -sk -i -X PUT "$BASE_URL/items/99" \
    -H "Content-Type: application/json" \
    -d '{"nombre":"nuevo"}' >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"

  http_code=$(curl -sk -o /dev/null -w "%{http_code}" \
    -X PUT "$BASE_URL/items/99" \
    -H "Content-Type: application/json" \
    -d '{"nombre":"nuevo"}')
  [ "$http_code" -eq 404 ]
}

@test "Prueba de metodo DELETE en /items/99" {
  LOG_FILE="$OUT_DIR/http_delete_item.log"

  echo "=== DELETE $BASE_URL/items/99 ===" > "$LOG_FILE"
  curl -sk -i -X DELETE "$BASE_URL/items/99" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"

  http_code=$(curl -sk -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/items/99")
  [ "$http_code" -eq 404 ]
}
