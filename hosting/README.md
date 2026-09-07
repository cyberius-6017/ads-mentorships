# Hosting propio (ads.team6017.com)

Las demos se compilan y se sirven **desde este servidor**, en el puerto 8080,
detrás del proxy externo que ya termina TLS para `ads.team6017.com`.

```
site/                        <- generado, no se versiona
├── index.html               <- portada con la lista de sesiones
├── session1_i_am_rich/      <- build de Flutter web, servido en /session1_i_am_rich/
└── session2_scouting_counter/
```

## Compilar

```bash
./hosting/build.sh                        # todas las sesiones
./hosting/build.sh session2_scouting_counter   # solo una
```

No hace falta tener Flutter instalado: cada build corre dentro de la imagen
`ghcr.io/cirruslabs/flutter:stable`. El script descubre los proyectos buscando
carpetas con `pubspec.yaml` (agregar una sesión no requiere tocar nada) y compila
con `--base-href /<carpeta>/`, que es lo que hace que la app funcione servida
desde una subruta. Si una sesión no compila, las demás igual se publican y la
versión anterior de la que falló se conserva en `site/`.

Al terminar regenera `site/index.html` con `generate_index.py`. Las tarjetas salen
del nombre de la carpeta (`session3_lo_que_sea` → "Sesión 3 · Lo Que Sea", y el
número decide el orden) y el subtítulo sale de `description:` del `pubspec.yaml`
de cada proyecto — si sigue siendo el `"A new Flutter project."` que pone
`flutter create`, la tarjeta simplemente no muestra descripción.

Se compila con `--no-web-resources-cdn`. Por defecto Flutter carga CanvasKit (el
motor de render, ~7 MB de wasm) desde `www.gstatic.com`; los bloqueadores de
anuncios y extensiones de privacidad bloquean ese dominio y la demo queda en
**pantalla en blanco** con `ERR_BLOCKED_BY_CLIENT` en la consola. Con el flag se
usa la copia local de `canvaskit/` y el sitio no depende de ningún dominio
externo. Si alguna vez volvés a ver una pantalla en blanco, lo primero que hay
que mirar es si el `flutter_bootstrap.js` del build trae
`"useLocalCanvasKit":true`.

`flutter pub get` dentro del contenedor puede actualizar los `pubspec.lock` si la
versión de Flutter de la imagen es más nueva que la que los generó. Es esperable:
revisá `git status` después de compilar y decidí si te quedás con el cambio.

## Servicio

Corre como servicio de usuario de systemd (`hosting/server.py`, solo biblioteca
estándar de Python).

```bash
./hosting/install-service.sh          # instalar/arrancar (idempotente)
systemctl --user status ads-site
systemctl --user restart ads-site     # después de recompilar no hace falta:
                                      # los archivos se leen de disco en cada request
journalctl --user -u ads-site -f      # logs de acceso
```

Para que sobreviva al cierre de sesión SSH y al reboot hay que habilitar linger
una sola vez:

```bash
sudo loginctl enable-linger $USER
```

El servidor agrega sobre `http.server` los tipos MIME que Flutter web necesita
(`.wasm`, `.mjs`, fuentes) y `Cache-Control: no-cache`, porque los builds de
Flutter reusan los mismos nombres de archivo y cachear a ciegas dejaría demos
viejas pegadas en el navegador.
