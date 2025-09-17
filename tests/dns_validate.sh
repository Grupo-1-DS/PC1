#!/usr/bin/env bash
# dns_validate.sh - Verifica el DNS resuelva la IP 

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/out"

getent hosts localhost | awk '{print $1}' > "$OUT_DIR/dns_response.txt"