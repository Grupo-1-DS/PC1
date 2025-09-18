#!/usr/bin/env bash
# http_validate.sh - Verifica el http

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/out"
PORT="${PORT:-8080}"

curl -s -o "$OUT_DIR/http_response.txt" -w "%{http_code}" "http://127.0.0.1:$PORT/" > "$OUT_DIR/http_code.txt"