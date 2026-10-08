#!/usr/bin/env python3
"""Build index.html from template.html and data/happy-hours.json.

Run after editing the data:  python3 build.py
"""
import json
from pathlib import Path

root = Path(__file__).parent
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
        + head.strip() + '\n'
        # Real street map for the web version (Leaflet + CARTO/OpenStreetMap tiles).
        # The Claude artifact can't load map tiles, so it keeps the drawn map.
        '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">\n'
        '<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>\n'
        '<style>:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}'
        'body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>\n'
        '<style>' + body.split("</style>", 1)[0] + '</style>\n</head>\n<body>\n'
        + body.split("</style>", 1)[1].strip() + '\n</body>\n</html>\n')
(root / "index.html").write_text(page)
print(f"Built index.html with {len(data['venues'])} listings")
