#!/usr/bin/env bash
# check_tools.sh - Verifica que las herramientas requeridas estén instaladas

set -euo pipefail


for cmd in curl dig ss nc bats dos2unix; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[INFO] Instalando $cmd..."
    sudo apt-get update
    sudo apt-get install -y "$cmd"
  fi
done
