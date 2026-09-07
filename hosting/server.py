#!/usr/bin/env python3
"""Servidor estático del sitio (ads.team6017.com).

Solo biblioteca estándar. Sirve el directorio site/ en el puerto 8080 detrás
del proxy externo que ya termina TLS. Sobre http.server agrega lo que Flutter
web necesita para funcionar bien:

  * tipos MIME correctos (.wasm, .mjs, .json, fuentes) — sin esto el
    navegador rechaza los módulos y CanvasKit no carga;
  * `Cache-Control: no-cache`, es decir: el navegador puede guardar el archivo
    pero debe revalidar. Los builds de Flutter reusan los mismos nombres
    (main.dart.js), así que cachear a ciegas dejaría demos viejas pegadas;
  * logs en una línea hacia stdout, que journald recoge.

Variables de entorno: SITE_DIR (default: ../site), HOST (0.0.0.0), PORT (8080).
"""

import functools
import mimetypes
import os
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE_DIR = os.environ.get("SITE_DIR") or os.path.join(ROOT, "site")
HOST = os.environ.get("HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", "8080"))

# mimetypes no siempre conoce estos, y el sistema puede mapear .js mal.
for ext, ctype in {
    ".js": "text/javascript",
    ".mjs": "text/javascript",
    ".wasm": "application/wasm",
    ".json": "application/json",
    ".otf": "font/otf",
    ".ttf": "font/ttf",
    ".woff": "font/woff",
    ".woff2": "font/woff2",
    ".svg": "image/svg+xml",
    ".webmanifest": "application/manifest+json",
    ".symbols": "text/plain",
}.items():
    mimetypes.add_type(ctype, ext)


class SiteServer(ThreadingHTTPServer):
    daemon_threads = True
    # El default de la stdlib es 5; corto para un proxy que abre varias
    # conexiones en paralelo al cargar una app Flutter.
    request_queue_size = 128
    allow_reuse_address = True


class SiteHandler(SimpleHTTPRequestHandler):
    server_version = "ads-site"
    sys_version = ""

    def end_headers(self):
        # Revalidar siempre: los nombres de archivo de Flutter no llevan hash.
        self.send_header("Cache-Control", "no-cache")
        self.send_header("X-Content-Type-Options", "nosniff")
        super().end_headers()

    def log_message(self, fmt, *args):
        sys.stdout.write(
            "%s %s\n" % (self.address_string(), fmt % args)
        )
        sys.stdout.flush()


def main():
    if not os.path.isdir(SITE_DIR):
        sys.exit(
            f"error: no existe {SITE_DIR}. Corré ./hosting/build.sh primero."
        )
    handler = functools.partial(SiteHandler, directory=SITE_DIR)
    httpd = SiteServer((HOST, PORT), handler)
    print(f"sirviendo {SITE_DIR} en http://{HOST}:{PORT}", flush=True)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("detenido", flush=True)


if __name__ == "__main__":
    main()
