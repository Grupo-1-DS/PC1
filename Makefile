.PHONY: build test clean help tools

run:
	@bash src/deploy.sh
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
pack:
	@echo "Empaquetando en dist/"
	@mkdir -p dist
	@tar -czf dist/automatizador-despliegue.tar.gz README.md Makefile src docs tests || exit 1
	@echo "Paquete creado: dist/automatizador-despliegue.tar.gz"
help:
	@echo "Comandos disponibles:"
	@echo "  make build   # Construye artefactos /out y /dist"
	@echo "  make test    # Ejecuta chequeos HTTP y DNS"
	@echo "  make clean   # Limpia los artefactos out/"
	@echo "  make help    # Muestra esta ayuda"