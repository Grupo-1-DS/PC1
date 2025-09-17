#!/usr/bin/env bash
# check_tools.sh - Verifica que las herramientas requeridas estén instaladas

set -euo pipefail

missing=()
for cmd in curl dig ss nc; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing+=("$cmd")
  fi
done

if [ ${#missing[@]} -eq 0 ]; then
  echo "[OK] Todas las herramientas requeridas están instaladas: curl, dig, ss, nc"
  exit 0
else
  echo "[ERROR] Faltan las siguientes herramientas: ${missing[*]}" >&2
  exit 1
fi
