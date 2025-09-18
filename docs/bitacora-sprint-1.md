
# Bitácora Sprint 1

Durante los primeros días, el equipo se enfocó en dejar lista la estructura básica del proyecto para que ambos pudieran avanzar de forma ordenada y sin bloqueos.

### ¿Para qué sirve cada comando del Makefile?

- `make build`: Por ahora solo muestra un mensaje, pero la idea es que aquí se agreguen los pasos previos necesarios antes de desplegar o probar.

- `make test`: Corre los chequeos principales (HTTP y DNS) usando el script. Así se valida que lo básico funciona y que no se rompe nada importante al hacer cambios.

- `make clean`: Borra todo lo que se haya generado en `out/`. Es útil para empezar de cero y evitar que archivos viejos generen confusiones en las pruebas.

- `make help`: Muestra la lista de comandos y para qué sirve cada uno. Así, cualquier persona que se una al proyecto puede entender rápidamente cómo usarlo.

- `make tools`: Llama a `check_tools.sh` para revisar que estén instaladas las herramientas clave (curl, dig, ss, nc). Si falta alguna, avisa y no deja seguir, evitando errores inesperados después.

- `make pack`: Empaqueta el proyecto entero en un archivo comprimido ubicado en `dist` asegurando que el programa sea reproducible

### Decisiones y aprendizajes

- Se priorizó automatizar todo lo posible desde el inicio, para que nadie tenga que hacer pasos manuales innecesarios.
- Se documentó cada comando para que cualquier integrante del equipo entienda rápido cómo usar el proyecto.
- Se sentaron las bases para que después sea fácil agregar más pruebas y que todo sea reproducible.
