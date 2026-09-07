#!/usr/bin/env bash
# Compila cada sesión a Flutter web y arma el sitio estático que sirve
# hosting/server.py. No requiere el SDK de Flutter instalado en el host: todo
# corre dentro de una imagen Docker.
#
#   ./hosting/build.sh                        # compila todas las sesiones
#   ./hosting/build.sh session2_scouting_counter   # solo una (el resto queda como estaba)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SITE="${SITE_DIR:-$ROOT/site}"
IMAGE="${FLUTTER_IMAGE:-ghcr.io/cirruslabs/flutter:stable}"
# Carpetas con pubspec.yaml que NO son una demo publicable.
EXCLUDE_DIRS="${EXCLUDE_DIRS:-template shared packages}"
# Volumen persistente para el pub cache: la segunda compilación es mucho más rápida.
PUB_VOLUME="${PUB_VOLUME:-ads-pub-cache}"

# --- 1) Descubrir proyectos -------------------------------------------------
# Un proyecto = cualquier carpeta con pubspec.yaml. Igual que antes, no hay
# nombres hardcodeados: agregar una sesión no requiere tocar este script.
discover() {
  local found=() projects=() dir ex keep skip
  mapfile -t found < <(
    cd "$ROOT" && find . -name .git -prune -o -path ./site -prune -o \
      -mindepth 2 -name pubspec.yaml -print \
      | sed 's|^\./||; s|/pubspec\.yaml$||' | sort
  )
  for dir in "${found[@]}"; do
    skip=false
    for ex in $EXCLUDE_DIRS; do
      if [ "$dir" = "$ex" ] || [[ "$dir" == "$ex"/* ]]; then skip=true; fi
    done
    # Descartar proyectos anidados dentro de otro ya detectado.
    for keep in "${projects[@]:-}"; do
      if [[ "$dir" == "$keep"/* ]]; then skip=true; fi
    done
    if [ "$skip" = false ]; then projects+=("$dir"); fi
  done
  printf '%s\n' "${projects[@]:-}"
}

if [ $# -gt 0 ]; then
  PROJECTS=("$@")
else
  mapfile -t PROJECTS < <(discover)
fi

if [ ${#PROJECTS[@]} -eq 0 ] || [ -z "${PROJECTS[0]}" ]; then
  echo "error: no se encontró ningún proyecto Flutter (carpeta con pubspec.yaml)." >&2
  exit 1
fi

echo "Proyectos a compilar:"
printf '  - %s\n' "${PROJECTS[@]}"
docker volume create "$PUB_VOLUME" >/dev/null

# --- 2) Compilar cada uno dentro del contenedor -----------------------------
failed=()
for dir in "${PROJECTS[@]}"; do
  [ -f "$ROOT/$dir/pubspec.yaml" ] || { echo "error: '$dir' no tiene pubspec.yaml." >&2; exit 1; }
  echo
  echo "=== $dir ==="

  # El contenedor corre como root (el SDK necesita escribir en su propio cache)
  # y al final devuelve la propiedad de los archivos al usuario del host, para
  # que build/ y .dart_tool/ no queden como root dentro del repo.
  #
  # base-href debe coincidir con la URL donde se sirve la app:
  # https://ads.team6017.com/<carpeta>/
  #
  # --no-web-resources-cdn: por defecto Flutter carga CanvasKit (el motor de
  # render, ~7 MB de wasm) desde https://www.gstatic.com. Los bloqueadores de
  # anuncios y extensiones de privacidad bloquean ese dominio, y el resultado es
  # una pantalla en blanco con ERR_BLOCKED_BY_CLIENT en la consola. Con este
  # flag el build usa la copia local que ya viene en build/web/canvaskit/, así
  # que la demo no depende de ningún dominio externo.
  if docker run --rm \
      -v "$ROOT:/work" \
      -v "$PUB_VOLUME:/pub-cache" \
      -e PUB_CACHE=/pub-cache \
      -w "/work/$dir" \
      "$IMAGE" \
      bash -c "
        set -euo pipefail
        git config --global --add safe.directory '*'
        if [ ! -d web ]; then
          echo '-> sin carpeta web/; agregándola con flutter create'
          flutter create . --platforms=web
        fi
        flutter pub get
        flutter build web --release --no-web-resources-cdn --base-href '/$dir/'
        chown -R $(id -u):$(id -g) /work/$dir
      "; then
    rm -rf "${SITE:?}/$dir"
    mkdir -p "$SITE/$dir"
    cp -r "$ROOT/$dir/build/web/." "$SITE/$dir/"
    echo "-> site/$dir/"
  else
    echo "!! '$dir' no compiló; se conserva la versión anterior del sitio (si existía)." >&2
    failed+=("$dir")
  fi
done

# --- 3) Landing page --------------------------------------------------------
echo
python3 "$ROOT/hosting/generate_index.py" "$SITE"

if [ ${#failed[@]} -gt 0 ]; then
  echo
  echo "Terminó con errores. No compilaron: ${failed[*]}" >&2
  exit 1
fi
echo
echo "Listo. Sitio en $SITE"
