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
import shutil
import sys

SITE_TITLE = "Mentorías Flutter"
SITE_TAGLINE = "Cada sesión es un proyecto Flutter completo. Toca una para abrir la demo, o lee el README para entender qué enseña."

# Palabras que el title-case normal arruinaría ("Ui" -> "UI").
ACRONYMS = {"ui", "ux", "api", "http", "io", "sdk", "cli", "db", "ai", "ml", "qr"}

# Descripciones que trae `flutter create` y que no aportan nada en una tarjeta.
BOILERPLATE = {"a new flutter project.", "a new flutter project"}

ASSETS_SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")


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


def readme_for(repo_root, folder):
    """Lee el README.md del proyecto, si existe."""
    path = os.path.join(repo_root, folder, "README.md")
    try:
        with open(path, encoding="utf-8") as fh:
            return fh.read()
    except OSError:
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


# --- Mini-conversor de Markdown -> HTML -------------------------------------
# No hay red ni pip en el servidor: alcanza y sobra con soportar el subconjunto
# de Markdown que usamos en los README (encabezados, párrafos, bloques de
# código, listas, negritas/cursivas, código inline y enlaces).

def _inline(text):
    text = html.escape(text)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<em>\1</em>", text)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2" target="_blank" rel="noopener">\1</a>', text)
    return text


def markdown_to_html(text):
    lines = text.replace("\r\n", "\n").split("\n")
    out = []
    i = 0
    in_list = False
    while i < len(lines):
        line = lines[i]

        if line.strip().startswith("```"):
            i += 1
            code_lines = []
            while i < len(lines) and not lines[i].strip().startswith("```"):
                code_lines.append(lines[i])
                i += 1
            i += 1
            if in_list:
                out.append("</ul>")
                in_list = False
            out.append(f"<pre><code>{html.escape(chr(10).join(code_lines))}</code></pre>")
            continue

        heading = re.match(r"^(#{1,6})\s+(.*)$", line)
        if heading:
            if in_list:
                out.append("</ul>")
                in_list = False
            level = min(len(heading.group(1)) + 2, 6)  # el h1 del README no debe pisar el h1 de la página
            out.append(f"<h{level}>{_inline(heading.group(2).strip())}</h{level}>")
            i += 1
            continue

        item = re.match(r"^\s*[-*]\s+(.*)$", line)
        if item:
            if not in_list:
                out.append("<ul>")
                in_list = True
            out.append(f"<li>{_inline(item.group(1))}</li>")
            i += 1
            continue

        if in_list:
            out.append("</ul>")
            in_list = False

        if not line.strip():
            i += 1
            continue

        # Junta líneas consecutivas de texto en un solo párrafo.
        para = [line.strip()]
        i += 1
        while i < len(lines) and lines[i].strip() and not re.match(r"^(#{1,6})\s+", lines[i]) \
                and not lines[i].strip().startswith("```") and not re.match(r"^\s*[-*]\s+", lines[i]):
            para.append(lines[i].strip())
            i += 1
        out.append(f"<p>{_inline(' '.join(para))}</p>")

    if in_list:
        out.append("</ul>")

    return "\n".join(out)


def card(folder, index, description, readme_html):
    session, title = humanize(folder)
    badge = html.escape(session) if session else f"#{index}"
    desc = (
        f'\n      <p class="desc">{html.escape(description)}</p>'
        if description else ""
    )
    panel_id = f"readme-{index}"
    readme_block = ""
    if readme_html:
        readme_block = f"""
    <div class="readme" id="{panel_id}" hidden>
      <div class="readme-inner">{readme_html}</div>
    </div>"""
    more_button = (
        f'<button type="button" class="more" data-target="{panel_id}" aria-expanded="false">'
        f'Ver más <span aria-hidden="true">&darr;</span></button>'
        if readme_html else ""
    )
    return f"""  <article class="card">
    <a class="card-link" href="/{html.escape(folder)}/">
      <span class="badge">{badge}</span>
      <h2>{html.escape(title or folder)}</h2>{desc}
      <span class="go">Abrir demo <span aria-hidden="true">&rarr;</span></span>
    </a>
    <div class="card-actions">{more_button}</div>{readme_block}
  </article>"""


STYLE = """
    @font-face {
      font-family: 'Hatton';
      src: url('/assets/hatton-medium.woff') format('woff');
      font-weight: 500;
      font-style: normal;
      font-display: swap;
    }
    @font-face {
      font-family: 'Hatton';
      src: url('/assets/hatton-bold.woff') format('woff');
      font-weight: 700;
      font-style: normal;
      font-display: swap;
    }
    @font-face {
      font-family: 'Avenir';
      src: url('/assets/avenir-regular.woff') format('woff');
      font-weight: 400;
      font-style: normal;
      font-display: swap;
    }
    :root {
      color-scheme: light;
      --cy-blue-main: #8DC8E8;
      --cy-blue-light: #C9EDFF;
      --cy-blue-bright: #4FC3FF;
      --cy-blue-dark: #006EB6;
      --cy-orange: #F96815;
      --cy-grey: #F2F2F2;
      --panel: rgba(255, 255, 255, 0.82);
      --panel-solid: #ffffff;
      --line: rgba(0, 110, 182, 0.28);
      --font-heading: 'Hatton', Georgia, serif;
      --font-body: 'Avenir', 'Inter', system-ui, sans-serif;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--cy-blue-light);
      color: var(--cy-blue-dark);
      font: 16px/1.6 var(--font-body);
      -webkit-font-smoothing: antialiased;
      overflow-x: hidden;
    }
    h1, h2, h3, h4 { font-family: var(--font-heading); }

    /* ── Decoraciones flotantes (mismos doodles de la webpage) ── */
    .doodle {
      position: absolute;
      pointer-events: none;
      user-select: none;
      object-fit: contain;
      animation: drift ease-in-out infinite;
    }
    @keyframes drift {
      0%, 100% { transform: translate(0, 0) rotate(var(--rot, 0deg)); }
      50% { transform: translate(var(--dx, 14px), var(--dy, -18px)) rotate(calc(var(--rot, 0deg) + 6deg)); }
    }
    @media (prefers-reduced-motion: reduce) {
      .doodle { animation: none; }
    }

    /* ── Hero ── */
    .hero {
      position: relative;
      background: var(--cy-blue-main);
      padding: 76px 24px 132px;
      text-align: center;
      overflow: visible;
    }
    .hero-decor { position: absolute; inset: 0; overflow: hidden; z-index: 0; }
    .hero-inner { position: relative; z-index: 1; max-width: 640px; margin: 0 auto; }
    .hero-logo {
      width: 100%;
      max-width: 320px;
      height: auto;
      margin: 0 auto 36px;
      display: block;
      filter: drop-shadow(0 8px 20px rgba(0, 40, 70, 0.18));
    }
    .hero h1 {
      margin: 0 0 14px;
      font-weight: 700;
      color: #ffffff;
      font-size: clamp(28px, 4.6vw, 42px);
      letter-spacing: -0.01em;
    }
    .hero .tagline {
      margin: 0 auto;
      color: rgba(255,255,255,0.92);
      max-width: 52ch;
      font-size: 16px;
    }
    .hero-mascot {
      position: absolute;
      z-index: 5;
      right: 6%;
      bottom: -58px;
      width: clamp(120px, 14vw, 190px);
      height: auto;
      transform: rotate(-6deg);
      filter: drop-shadow(0 10px 18px rgba(0, 40, 70, 0.28));
      animation: bob 5s ease-in-out infinite;
    }
    @media (prefers-reduced-motion: reduce) { .hero-mascot { animation: none; } }
    @keyframes bob {
      0%, 100% { transform: rotate(-6deg) translateY(0); }
      50% { transform: rotate(-3deg) translateY(-10px); }
    }
    @media (max-width: 560px) {
      .hero-mascot { right: 50%; transform: translateX(50%) rotate(-4deg); bottom: -40px; }
      @keyframes bob { 0%, 100% { transform: translateX(50%) rotate(-4deg) translateY(0); } 50% { transform: translateX(50%) rotate(-2deg) translateY(-8px); } }
    }

    /* ── Contenido ── */
    .content { position: relative; overflow: hidden; }
    .content-decor { position: absolute; inset: 0; overflow: hidden; z-index: 0; }
    .wrap { max-width: 980px; margin: 0 auto; padding: 108px 24px 96px; position: relative; z-index: 1; }
    .grid {
      display: grid;
      gap: 20px;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    }
    .card {
      display: flex;
      flex-direction: column;
      border: 1px solid var(--line);
      border-radius: 18px;
      background: var(--panel);
      backdrop-filter: blur(10px);
      box-shadow: 0 10px 28px rgba(0, 60, 100, 0.14);
      overflow: hidden;
      transition: transform .15s ease, box-shadow .15s ease, border-color .15s ease;
    }
    .card:hover {
      transform: translateY(-3px);
      box-shadow: 0 16px 34px rgba(0, 60, 100, 0.20);
      border-color: var(--cy-blue-dark);
    }
    .card-link {
      display: flex;
      flex-direction: column;
      gap: 8px;
      padding: 24px 24px 8px;
      color: inherit;
      text-decoration: none;
    }
    .badge {
      align-self: flex-start;
      padding: 3px 12px;
      border-radius: 999px;
      background: var(--cy-orange);
      color: #fff;
      font-size: 12px;
      font-weight: 700;
      letter-spacing: .03em;
    }
    .card h2 { margin: 4px 0 0; font-size: 21px; font-weight: 700; color: var(--cy-blue-dark); }
    .desc { margin: 0; color: #35597a; font-size: 14px; }
    .go { margin-top: 6px; color: var(--cy-orange); font-size: 14px; font-weight: 700; }
    .card-actions { padding: 4px 24px 20px; }
    .more {
      appearance: none;
      border: none;
      background: none;
      color: var(--cy-blue-dark);
      font: inherit;
      font-weight: 700;
      font-size: 13px;
      cursor: pointer;
      padding: 6px 0;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }
    .more:hover { color: var(--cy-orange); }
    .more[aria-expanded="true"] span { transform: rotate(180deg); }
    .more span { display: inline-block; transition: transform .15s ease; }
    .readme {
      border-top: 1px solid var(--line);
      background: var(--panel-solid);
      max-height: 60vh;
      overflow-y: auto;
    }
    .readme-inner { padding: 20px 24px 28px; font-size: 14.5px; color: #1f2d3a; }
    .readme-inner h3, .readme-inner h4, .readme-inner h5, .readme-inner h6 {
      color: var(--cy-blue-dark);
      margin: 20px 0 8px;
    }
    .readme-inner h3:first-child { margin-top: 0; }
    .readme-inner p { margin: 0 0 12px; line-height: 1.65; }
    .readme-inner ul { margin: 0 0 12px; padding-left: 22px; }
    .readme-inner li { margin-bottom: 6px; }
    .readme-inner code {
      background: var(--cy-grey);
      color: #b3450d;
      padding: 2px 6px;
      border-radius: 5px;
      font-size: 13px;
    }
    .readme-inner pre {
      background: #10202f;
      color: #e8ecf3;
      padding: 14px 16px;
      border-radius: 10px;
      overflow-x: auto;
      margin: 0 0 14px;
    }
    .readme-inner pre code { background: none; color: inherit; padding: 0; }
    .readme-inner a { color: var(--cy-orange); }
    .empty {
      padding: 28px;
      border: 1px dashed var(--line);
      border-radius: 14px;
      color: var(--cy-blue-dark);
      background: rgba(255,255,255,0.5);
    }
    .empty code {
      background: rgba(0, 110, 182, 0.12);
      color: var(--cy-blue-dark);
      padding: 2px 6px;
      border-radius: 6px;
    }
    footer {
      position: relative;
      z-index: 1;
      margin-top: 40px;
      padding: 32px 24px;
      background: #001a2e;
      color: rgba(255,255,255,0.7);
      font-size: 13px;
      text-align: center;
    }
    footer strong { color: #fff; font-family: var(--font-heading); }
"""

SCRIPT = """
    document.querySelectorAll('.more').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var panel = document.getElementById(btn.dataset.target);
        if (!panel) return;
        var open = panel.hasAttribute('hidden') === false;
        panel.hidden = open;
        btn.setAttribute('aria-expanded', String(!open));
        btn.firstChild.textContent = open ? 'Ver más ' : 'Ver menos ';
      });
    });
"""


# Doodles disponibles en hosting/assets/, reciclados de la webpage principal.
DOODLES = ["doodle-1.png", "doodle-2.png", "doodle-3.png", "doodle-4.png"]

# (archivo, top%, left%, size-px, rotate-deg, dx-px, dy-px, duration-s, opacity)
HERO_DECOR = [
    ("doodle-1.png", 6, 6, 130, 8, 16, -14, 9, 0.16),
    ("doodle-3.png", 12, 78, 110, -18, -14, 16, 11, 0.14),
    ("doodle-2.png", 68, 88, 120, 20, 14, -12, 10, 0.13),
    ("doodle-4.png", 70, 3, 100, -10, -12, 14, 8, 0.15),
]
CONTENT_DECOR = [
    ("doodle-2.png", 2, 4, 150, -12, 16, -18, 12, 0.10),
    ("doodle-4.png", 18, 84, 120, 15, -18, 14, 10, 0.09),
    ("doodle-1.png", 55, 90, 140, -8, 14, -16, 13, 0.09),
    ("doodle-3.png", 62, 2, 110, 10, -16, 18, 11, 0.10),
    ("doodle-2.png", 88, 70, 100, -20, 12, -14, 9, 0.08),
]


def decor_layer(items, css_class):
    imgs = "\n".join(
        f'    <img class="doodle" src="/assets/{name}" alt="" '
        f'style="top:{top}%; left:{left}%; width:{size}px; '
        f'--rot:{rot}deg; --dx:{dx}px; --dy:{dy}px; '
        f'animation-duration:{dur}s; opacity:{op};">'
        for name, top, left, size, rot, dx, dy, dur, op in items
    )
    return f'  <div class="{css_class}" aria-hidden="true">\n{imgs}\n  </div>'


def copy_assets(site_dir):
    dest = os.path.join(site_dir, "assets")
    if os.path.isdir(ASSETS_SRC):
        os.makedirs(dest, exist_ok=True)
        for name in os.listdir(ASSETS_SRC):
            shutil.copy2(os.path.join(ASSETS_SRC, name), os.path.join(dest, name))


def main():
    site_dir = sys.argv[1] if len(sys.argv) > 1 else "site"
    site_dir = os.path.abspath(site_dir)
    os.makedirs(site_dir, exist_ok=True)
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    copy_assets(site_dir)

    folders = discover(site_dir)
    if folders:
        rendered = []
        for i, f in enumerate(folders, 1):
            readme_text = readme_for(repo_root, f)
            readme_html = markdown_to_html(readme_text) if readme_text else ""
            rendered.append(card(f, i, description_for(repo_root, f), readme_html))
        cards = "\n".join(rendered)
        cards_html = f'<div class="grid">\n{cards}\n</div>'
    else:
        cards_html = (
            '<div class="empty">Todavía no hay demos compiladas. '
            "Corre <code>./hosting/build.sh</code> para generarlas.</div>"
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
<section class="hero">
{decor_layer(HERO_DECOR, "hero-decor")}
  <div class="hero-inner">
    <img class="hero-logo" src="/assets/logo-hero.png" width="480" height="158" alt="Cyberius 6017 — Dare to Be Exceptional">
    <h1>{html.escape(SITE_TITLE)}</h1>
    <p class="tagline">{html.escape(SITE_TAGLINE)}</p>
  </div>
  <img class="hero-mascot" src="/assets/pixel.png" alt="" aria-hidden="true">
</section>
<div class="content">
{decor_layer(CONTENT_DECOR, "content-decor")}
  <div class="wrap">
{cards_html}
  </div>
</div>
<footer>{len(folders)} {"sesión publicada" if len(folders) == 1 else "sesiones publicadas"} · <strong>Cyberius 6017</strong></footer>
</div>
<script>{SCRIPT}</script>
</body>
</html>
"""
    dest = os.path.join(site_dir, "index.html")
    with open(dest, "w", encoding="utf-8") as fh:
        fh.write(out)
    print(f"index.html generado con {len(folders)} sesión(es) -> {dest}")


if __name__ == "__main__":
    main()
