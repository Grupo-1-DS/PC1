.PHONY: build test clean help tools

tools:
	@bash src/check_tools.sh
build:
	@mkdir -p out
run:
	@bash src/deploy.sh
test: build
	@echo "Comenzando pruebas ..."
	@bash bats tests/
clean:
	@rm -rf out/
pack:
	@echo "Empaquetando en dist/"
	@mkdir -p dist
	@tar -czf dist/automatizador-despliegue.tar.gz README.md Makefile src docs tests || exit 1
	@echo "Paquete creado: dist/automatizador-despliegue.tar.gz"
help:
	@echo "Comandos disponibles:"
	@echo "  make build   # Construye artefactos /out"
	@echo "  make test    # Ejecuta chequeos HTTP y DNS"
	@echo "  make clean   # Limpia los artefactos out/"
	@echo "  make help    # Muestra esta ayuda"