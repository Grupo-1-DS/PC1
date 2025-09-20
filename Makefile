.PHONY: build test clean help tools pack

run:
	@bash src/deploy.sh
tools:
	@bash src/check_tools.sh

build:
	@command mkdir -p out
test: build
	@echo "Comenzando pruebas ..."
	@bats tests/*.bats
clean:
	@rm -rf out/ dist/
	@echo "Limpió el directorio"
pack:
	@echo "Empaquetando en dist/"
	@mkdir -p dist
	@tar --exclude='out' --exclude='venv' --exclude='.git' \
		--exclude='dist' --exclude='*.log' --exclude='*.pid' \
		-czf dist/automatizador-despliegue.tar.gz \
		Makefile .env.example  \
		src/ docs/ tests/ miniapp_flask/ \
		|| exit 1
	@echo "Paquete creado: dist/automatizador-despliegue.tar.gz"
help:
	@echo "Comandos disponibles:"
	@echo "  make run     # Ejecuta el despliegue completo"
	@echo "  make tools   # Verifica e instala herramientas"
	@echo "  make build   # Construye artefactos /out"
	@echo "  make test    # Ejecuta chequeos HTTP y DNS"
	@echo "  make pack    # Empaqueta proyecto para distribución"
	@echo "  make clean   # Limpia artefactos (out/ y dist/)"
	@echo "  make help    # Muestra esta ayuda"