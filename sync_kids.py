#!/usr/bin/env python3
"""Copy the kids menus and kids deals from the Laguna Kids Eats project into data/kids.json.

The kids data is maintained in the separate repo WestwoodEleven/laguna-kids-eats (data.js).
Run this after that project's data changes, then run build.py:

    python3 sync_kids.py                      # downloads data.js from GitHub
    python3 sync_kids.py path/to/data.js      # or reads a local copy
    python3 build.py
"""
import json
import sys
import urllib.request
from pathlib import Path

SOURCE_URL = "https://raw.githubusercontent.com/WestwoodEleven/laguna-kids-eats/main/data.js"
root = Path(__file__).parent

# Kids Eats listings whose id differs from the same restaurant's id here.
ID_ALIASES = {"smalls-smash-club-laguna-beach": "smalls-smash-club"}

# Fields the happy hour site uses; everything else in the Kids Eats data stays there.
KIDS_FIELDS = ("age_limit", "includes_drink", "kids_menu_note", "kids_items", "kids_deals",
               "kids_menu_url", "confidence", "last_evidence_date", "sources")
PLACE_FIELDS = ("name", "address", "neighborhood", "website", "category", "price_level",
                "google_rating", "google_count", "google_url", "yelp_url", "lat", "lng",
                "hours", "hours_note", "hours_source", "open_status")

if len(sys.argv) > 1:
    text = Path(sys.argv[1]).read_text()
else:
    with urllib.request.urlopen(SOURCE_URL, timeout=30) as r:
        text = r.read().decode("utf-8")

start = text.index("{")
kd = json.loads(text[start:text.rindex("}") + 1])

out = {"checked": kd.get("checked"), "source": "WestwoodEleven/laguna-kids-eats", "venues": []}
for v in kd["venues"]:
    if v.get("open_status") == "closed":
        continue
    rec = {"id": ID_ALIASES.get(v["id"], v["id"])}
    rec.update({k: v.get(k) for k in KIDS_FIELDS})
    rec["place"] = {k: v.get(k) for k in PLACE_FIELDS}
    out["venues"].append(rec)

(root / "data" / "kids.json").write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n")
print(f"Wrote data/kids.json with {len(out['venues'])} kids listings (checked {out['checked']})")
