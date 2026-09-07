#!/usr/bin/env bash
# Instala y arranca el servicio de usuario que sirve site/ en el puerto 8080.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$UNIT_DIR"
sed "s|__ROOT__|$ROOT|g" "$ROOT/hosting/ads-site.service" > "$UNIT_DIR/ads-site.service"
systemctl --user daemon-reload
systemctl --user enable --now ads-site.service
echo
systemctl --user --no-pager status ads-site.service | head -12
echo
echo "Logs:      journalctl --user -u ads-site -f"
echo "Reiniciar: systemctl --user restart ads-site"
echo
# Sin linger, systemd mata los servicios del usuario al cerrar la sesión SSH.
if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
  echo "AVISO: falta habilitar linger o el servicio se apagará al cerrar sesión."
  echo "Corré:  sudo loginctl enable-linger $USER"
fi
