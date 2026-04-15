# Configuracion de servidor para CRUD de galeria

Este proyecto ahora intenta dos modos de escritura para la galeria:

1. API HTTP de galeria (primero)
2. WebDAV (fallback)

Pantalla usada:
- lib/features/museum/screens/images_screen.dart

## Endpoints API esperados

Base URL esperada:
- http://64.23.168.72/api/gallery
- https://64.23.168.72/api/gallery

Operaciones llamadas por la app:

1. Crear carpeta
- POST /folders/create
- Body JSON: {"path":"Galeria/NuevaCarpeta"}

2. Renombrar carpeta
- POST /folders/rename
- Body JSON: {"from":"Galeria/A","to":"Galeria/B"}

3. Eliminar carpeta
- POST /folders/delete
- Body JSON: {"path":"Galeria/A"}

4. Subir imagen
- POST /files/upload (multipart/form-data)
- Campo texto: path
- Campo archivo: file

5. Renombrar imagen
- POST /files/rename
- Body JSON: {"from":"Galeria/A/foto1.jpg","to":"Galeria/A/foto2.jpg"}

6. Eliminar imagen
- POST /files/delete
- Body JSON: {"path":"Galeria/A/foto1.jpg"}

Respuesta recomendada para todos:
- HTTP 200-299 cuando la operacion fue exitosa
- JSON opcional: {"ok":true}

## API simple lista para usar (PHP)

Ya se incluyo una API simple en:

- server/gallery-api/index.php
- server/gallery-api/.htaccess

### Que hace esta API

- Crea, renombra y elimina carpetas
- Sube, renombra y elimina imagenes
- Sanitiza rutas para evitar `..` y caracteres peligrosos
- Limita extensiones a: jpg, jpeg, png, webp

### Despliegue rapido en Apache

1. Copia el contenido de `server/gallery-api/` a tu servidor en:
    - `/var/www/html/api/gallery/`
2. Asegurate de tener `AllowOverride All` para que `.htaccess` funcione.
3. Define variable de entorno `GALLERY_ROOT` apuntando a la carpeta real de galeria.
    - Ejemplo: `/var/www/media/Galeria`
4. Reinicia Apache.

### Ejemplo de VirtualHost (opcional)

```
SetEnv GALLERY_ROOT /var/www/media/Galeria

<Directory /var/www/html/api/gallery>
     AllowOverride All
     Require all granted
</Directory>
```

### Prueba manual rapida

```
curl -X POST http://TU_IP/api/gallery/folders/create \
  -H "Content-Type: application/json" \
  -d '{"path":"PruebaCarpeta"}'
```

## Seguridad recomendada

- Validar JWT Bearer en backend.
- Revisar rol admin desde base de datos antes de permitir escritura.
- Rechazar toda ruta con .. o rutas absolutas.
- Limitar extensiones permitidas: .jpg .jpeg .png .webp
- Limitar tamano de archivo (por ejemplo 10 MB).
- Registrar auditoria: usuario, accion, fecha, ruta.

## Fallback WebDAV

Si API no responde, la app usa WebDAV:
- MKCOL para crear carpeta
- MOVE para renombrar
- DELETE para eliminar
- PUT para subir/reemplazar

Servidor debe permitir esos metodos en rutas de galeria.

## Ejemplo rapido de Apache (referencia)

```
# Requiere mod_dav y mod_dav_fs habilitados
DavLockDB /var/lib/dav/lockdb

Alias /media /var/www/media

<Directory /var/www/media>
    Dav On
    Options Indexes FollowSymLinks
    AllowOverride None

    # Solo ejemplo: reemplazar por autenticacion JWT en proxy/API
    Require all granted

    <LimitExcept GET HEAD OPTIONS>
        Require all granted
    </LimitExcept>
</Directory>
```

## Ejemplo rapido de Nginx (referencia)

```
location /media/ {
    root /var/www;
    autoindex on;

    dav_methods PUT DELETE MKCOL COPY MOVE;
    create_full_put_path on;
    dav_access user:rw group:rw all:r;

    client_max_body_size 10m;
}
```

## Recomendacion de despliegue

Para mayor control, priorizar API propia con validacion de rol admin y dejar WebDAV solo como fallback interno o desactivarlo en produccion.
