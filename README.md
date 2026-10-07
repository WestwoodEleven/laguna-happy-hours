# Laguna Happy Hours

Happy hours and daily deals at Laguna Beach, California restaurants: hours, drink and food prices, savings against regular menu prices, a map, and distance from where you are.

**Live site:** https://westwoodeleven.github.io/laguna-happy-hours/

## What's in it

- 49 listings (41 open) checked in October 2026, out of a roster of 155 Laguna Beach restaurants and bars
- Drink and food prices with "Save %" where the regular price for the same item is published
- Daily deals (Taco Tuesday, Wine Wednesday, 2-for-1 burgers and more)
- "Happening now" filter, day filter, search, sort by savings, rating or distance
- Map with pins, **Use my location**, tap-to-set your spot, landmarks, distance on every listing and directions links
- Confidence labels (Verified / Likely / Needs confirmation) and the sources behind every listing

Confirming a deal, star ratings, visitor notes and photos, and menu-photo updates live in the [Claude version](https://claude.ai/artifact/GhzNP9fe9LD2c3QqsrsDZS), since they need shared storage.

## Files

| Path | What it is |
|---|---|
| `index.html` | The web app (built; don't edit by hand) |
| `template.html` | Page source with a `__DATA__` placeholder |
| `data/happy-hours.json` | The database: listings, map geometry, restaurants checked with no deals |
| `data/restaurant-roster.json` | Every Laguna Beach restaurant and bar that was checked |
| `build.py` | Rebuilds `index.html` from the template and data |
| `docs/` | Audit reports from the verification passes |

## Updating

Edit `data/happy-hours.json` (or `template.html`), then run:

```
python3 build.py
```

and commit the rebuilt `index.html`.

## Accuracy

Deals change often. Each listing shows when it was last confirmed and where the information came from; call ahead before you go.
