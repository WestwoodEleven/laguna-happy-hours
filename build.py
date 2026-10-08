#!/usr/bin/env python3
"""Build index.html from template.html and data/happy-hours.json.

Run after editing the data:  python3 build.py
"""
import json
from pathlib import Path

root = Path(__file__).parent

SITE_URL = "https://westwoodeleven.github.io/laguna-happy-hours/"
# Optional privacy-friendly visitor counts: create a free GoatCounter account
# (goatcounter.com) and put its code here, e.g. "lagunahh". Leave empty to skip.
GOATCOUNTER_CODE = ""

DESC = "Happy hours and daily deals at Laguna Beach restaurants, with prices, savings and a map."
SHARE_HEAD = (
    '<meta name="theme-color" content="#11302E">\n'
    '<link rel="manifest" href="manifest.webmanifest">\n'
    '<link rel="icon" type="image/png" sizes="32x32" href="assets/favicon-32.png">\n'
    '<link rel="apple-touch-icon" href="assets/apple-touch-icon.png">\n'
    '<meta name="apple-mobile-web-app-capable" content="yes">\n'
    '<meta name="apple-mobile-web-app-title" content="Happy Hours">\n'
    '<meta property="og:type" content="website">\n'
    '<meta property="og:title" content="Laguna Happy Hours">\n'
    f'<meta property="og:description" content="{DESC}">\n'
    f'<meta property="og:url" content="{SITE_URL}">\n'
    f'<meta property="og:image" content="{SITE_URL}assets/og-image.png">\n'
    '<meta property="og:image:width" content="1200"><meta property="og:image:height" content="630">\n'
    '<meta name="twitter:card" content="summary_large_image">\n'
    + (f'<script data-goatcounter="https://{GOATCOUNTER_CODE}.goatcounter.com/count" async src="https://gc.zgo.at/count.js"></script>\n' if GOATCOUNTER_CODE else '')
)
data = json.loads((root / "data" / "happy-hours.json").read_text())
template = (root / "template.html").read_text()
assert "__DATA__" in template, "template.html is missing the __DATA__ placeholder"
blob = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
page = template.replace("__DATA__", blob, 1)
# The template starts with <title> and font links, then the page; GitHub Pages
# needs a full document, so move those into <head>. (The Claude artifact host
# adds this wrapper itself.)
head, body = page.split("<style>", 1)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
        '<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n'
        '<meta name="description" content="Happy hours and daily deals at Laguna Beach restaurants, with prices, savings and a map.">\n'
        + SHARE_HEAD
        + head.strip() + '\n'
        # Real street map for the web version (Leaflet + OpenStreetMap tiles).
        # The Claude artifact can't load map tiles, so it keeps the drawn map.
        '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">\n'
        '<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>\n'
        # Shared features (sign-in, confirmations, ratings, notes, photos) for the web version.
        '<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.js"></script>\n'
        '<style>:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}'
        'body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>\n'
        '<style>' + body.split("</style>", 1)[0] + '</style>\n</head>\n<body>\n'
        + body.split("</style>", 1)[1].strip() + '\n</body>\n</html>\n')
(root / "index.html").write_text(page)
print(f"Built index.html with {len(data['venues'])} listings")
