
## Variables de entorno

El archivo `.env` centraliza la configuración para el despliegue y la miniapp Flask.

| Nombre      | Descripción                                                        | Ejemplo                      |
|-------------|--------------------------------------------------------------------|------------------------------|
| PORT        | Puerto donde se expone la miniapp Flask                            | 60000                        |
| IP          | Dirección IP de escucha (usualmente para pruebas locales)          | 127.0.0.1                    |
| MESSAGE     | Mensaje de despliegue que puede mostrar la app                     | Despliegue                   |
| RELEASE     | Versión del despliegue                                             | 1.0.0                        |
| DNS_SERVER  | Servidor DNS a usar en pruebas                                     | 8.8.8.8                      |
| DOMINIO     | Dominio personalizado que se asigna a localhost para pruebas       | pc1-desarrollo.com           |

#### Ejemplo de uso y salida

Si en `.env` tienes:

```env
DOMINIO=pc1-desarrollo.com
```

Y ejecutas en bash:

```sh
echo $DOMINIO
```

La salida será:

![alt text](image-2.png)
