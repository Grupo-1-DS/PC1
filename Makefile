.PHONY: build test clean help tools
tools:
	@bash src/check_tools.sh

build:
	@echo "No hay pasos de build definidos aún."

test:
	@echo "No hay pasos de test definidos aún."

clean:
	@rm -rf out/*

help:
	@echo "Comandos disponibles:"
	@echo "  make build   # Construye artefactos "
	@echo "  make test    # Ejecuta chequeos HTTP y DNS"
	@echo "  make clean   # Limpia la carpeta out/"
	@echo "  make help    # Muestra esta ayuda"