#!/usr/bin/env python3
"""Genera la portada de ads.team6017.com: la lista de sesiones publicadas.

Escanea el directorio del sitio (por defecto site/) y arma un index.html
estático a partir de las carpetas que ya tienen un build de Flutter web.
Sin dependencias externas y sin paso de build.

Uso: generate_index.py [directorio-del-sitio]
"""

import html
import os
import re
import sys

SITE_TITLE = "Mentorías Flutter"
SITE_TAGLINE = "Cada sesión es un proyecto Flutter completo. Tocá una para abrir la demo."

# Palabras que el title-case normal arruinaría ("Ui" -> "UI").
ACRONYMS = {"ui", "ux", "api", "http", "io", "sdk", "cli", "db", "ai", "ml", "qr"}

# Descripciones que trae `flutter create` y que no aportan nada en una tarjeta.
BOILERPLATE = {"a new flutter project.", "a new flutter project"}


def humanize(folder):
    """session1_i_am_rich -> ("Sesión 1", "I Am Rich")."""
    session = None
    m = re.match(r"^session[\s_-]*(\d+)[\s_-]*(.*)$", folder, re.IGNORECASE)
    if m:
        session = f"Sesión {m.group(1)}"
        folder = m.group(2)
    words = [w for w in re.split(r"[\s_-]+", folder) if w]
    title = " ".join(w.upper() if w.lower() in ACRONYMS else w.capitalize() for w in words)
    return session, title


def sort_key(folder):
    """Ordena por número de sesión cuando lo hay; el resto, alfabético al final."""
    m = re.match(r"^session[\s_-]*(\d+)", folder, re.IGNORECASE)
    return (0, int(m.group(1)), "") if m else (1, 0, folder.lower())


def description_for(repo_root, folder):
    """Lee `description:` del pubspec.yaml del proyecto, si dice algo útil."""
    path = os.path.join(repo_root, folder, "pubspec.yaml")
    try:
        with open(path, encoding="utf-8") as fh:
            for line in fh:
                m = re.match(r'^description:\s*(.+?)\s*$', line)
                if m:
                    text = m.group(1).strip().strip('"').strip("'")
                    return "" if text.lower() in BOILERPLATE else text
    except OSError:
        pass
    return ""


def discover(site_dir):
    """Carpetas del sitio que contienen un build de Flutter web."""
    out = []
    for entry in sorted(os.listdir(site_dir)):
        full = os.path.join(site_dir, entry)
        if entry.startswith(".") or not os.path.isdir(full):
            continue
        if os.path.isfile(os.path.join(full, "index.html")):
            out.append(entry)
    return sorted(out, key=sort_key)


def card(folder, index, description):
    session, title = humanize(folder)
    badge = html.escape(session) if session else f"#{index}"
    desc = (
        f'\n      <p class="desc">{html.escape(description)}</p>'
        if description else ""
    )
    return f"""    <a class="card" href="/{html.escape(folder)}/">
      <span class="badge">{badge}</span>
      <h2>{html.escape(title or folder)}</h2>{desc}
      <span class="go">Abrir demo <span aria-hidden="true">&rarr;</span></span>
    </a>"""


STYLE = """
    :root {
      color-scheme: light dark;
      --bg: #0f1115;
      --panel: #171a21;
      --panel-hover: #1d222b;
      --line: #262b36;
      --text: #e8ecf3;
      --muted: #9aa4b6;
      --accent: #f96815;
      --accent-soft: rgba(249, 104, 21, 0.14);
    }
    @media (prefers-color-scheme: light) {
      :root {
        --bg: #f6f7f9;
        --panel: #ffffff;
        --panel-hover: #ffffff;
        --line: #e3e7ee;
        --text: #14181f;
        --muted: #5c6675;
        --accent: #d9530a;
        --accent-soft: rgba(217, 83, 10, 0.10);
      }
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font: 16px/1.55 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
      -webkit-font-smoothing: antialiased;
    }
    .wrap { max-width: 900px; margin: 0 auto; padding: 72px 24px 96px; }
    header { margin-bottom: 44px; }
    h1 {
      margin: 0 0 10px;
      font-size: clamp(30px, 5vw, 42px);
      letter-spacing: -0.02em;
    }
    .tagline { margin: 0; color: var(--muted); max-width: 52ch; }
    .grid {
      display: grid;
      gap: 16px;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    }
    .card {
      display: flex;
      flex-direction: column;
      gap: 8px;
      padding: 22px;
      border: 1px solid var(--line);
      border-radius: 14px;
      background: var(--panel);
      color: inherit;
      text-decoration: none;
      transition: border-color .15s ease, transform .15s ease, background .15s ease;
    }
    .card:hover, .card:focus-visible {
      border-color: var(--accent);
      background: var(--panel-hover);
      transform: translateY(-2px);
      outline: none;
    }
    .badge {
      align-self: flex-start;
      padding: 3px 10px;
      border-radius: 999px;
      background: var(--accent-soft);
      color: var(--accent);
      font-size: 12px;
      font-weight: 600;
      letter-spacing: .02em;
    }
    .card h2 { margin: 2px 0 0; font-size: 20px; letter-spacing: -0.01em; }
    .desc { margin: 0; color: var(--muted); font-size: 14px; }
    .go { margin-top: auto; padding-top: 8px; color: var(--accent); font-size: 14px; font-weight: 600; }
    .empty {
      padding: 28px;
      border: 1px dashed var(--line);
      border-radius: 14px;
      color: var(--muted);
    }
    .empty code {
      background: var(--accent-soft);
      color: var(--accent);
      padding: 2px 6px;
      border-radius: 6px;
    }
    footer { margin-top: 56px; color: var(--muted); font-size: 13px; }
"""


def main():
    site_dir = sys.argv[1] if len(sys.argv) > 1 else "site"
    site_dir = os.path.abspath(site_dir)
    os.makedirs(site_dir, exist_ok=True)
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    folders = discover(site_dir)
    if folders:
        cards = "\n".join(
            card(f, i, description_for(repo_root, f)) for i, f in enumerate(folders, 1)
        )
        cards_html = f'  <div class="grid">\n{cards}\n  </div>'
    else:
        cards_html = (
            '  <div class="empty">Todavía no hay demos compiladas. '
            "Corré <code>./hosting/build.sh</code> para generarlas.</div>"
        )

    out = f"""<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(SITE_TITLE)}</title>
<meta name="description" content="{html.escape(SITE_TAGLINE)}">
<style>{STYLE}</style>
</head>
<body>
<div class="wrap">
  <header>
    <h1>{html.escape(SITE_TITLE)}</h1>
    <p class="tagline">{html.escape(SITE_TAGLINE)}</p>
  </header>
{cards_html}
  <footer>{len(folders)} {"sesión publicada" if len(folders) == 1 else "sesiones publicadas"}</footer>
</div>
</body>
</html>
"""
    dest = os.path.join(site_dir, "index.html")
    with open(dest, "w", encoding="utf-8") as fh:
        fh.write(out)
    print(f"index.html generado con {len(folders)} sesión(es) -> {dest}")


if __name__ == "__main__":
    main()
