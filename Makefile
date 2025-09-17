.PHONY: build test clean help tools

tools:
	@bash src/check_tools.sh

build:
	@command mkdir -p out
	
test: build
	@echo "Comenzando pruebas ..."
	@python3 -m http.server 8080 > /dev/null 2>&1 &
	@command sleep 1
	@command ss -ltn | grep :8080 || echo "No hay servidor"
	@command bats tests/
	@command fuser -k 8080/tcp || true
clean:
	@rm -rf out/

help:
	@echo "Comandos disponibles:"
	@echo "  make build   # Construye artefactos /out y /dist"
	@echo "  make test    # Ejecuta chequeos HTTP y DNS"
	@echo "  make clean   # Limpia los artefactos out/"
	@echo "  make help    # Muestra esta ayuda"