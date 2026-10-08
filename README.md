# Laguna Happy Hours

Happy hours and daily deals at Laguna Beach, California restaurants: hours, drink and food prices, savings against regular menu prices, a map, and distance from where you are.

**Live site:** https://westwoodeleven.github.io/laguna-happy-hours/

## What's in it

- 49 listings (41 open) checked in October 2026, out of a roster of 155 Laguna Beach restaurants and bars
- Drink and food prices with "Save %" where the regular price for the same item is published
- Daily deals (Taco Tuesday, Wine Wednesday, 2-for-1 burgers and more)
- "Happening now" filter, day filter, search, sort by savings, rating or distance
- Street map (OpenStreetMap tiles via Leaflet) with pins, **Use my location**, tap-to-set your spot, landmarks, distance on every listing and directions links
- Confidence labels (Verified / Likely / Needs confirmation) that age: a listing not checked in 90 days drops a level, a visitor confirmation in the last 30 days lifts it, and two "No longer running" reports mark it ended
- "Ends in 15 min" / "Starts in 20 min" timing, with places sorted by time left and a "Next up today" list when nothing is on
- Compact cards (best 3 deals up front, "Full menu" for the rest), ocean view filter, seating notes, tap-to-call and share links
- Link previews, an app icon and install-to-home-screen support
- Today's sunset time, with ocean-view cards tagged "Runs past sunset" or "Ends N min before sunset"
- ★ My spots favorites (saved on the visitor's device) and a "Needs a local's check" filter, stalest first
- Per-deal "Still running?" confirmations and tap-a-price corrections ("Local says $11")
- "Is this your place?" messages from restaurants (private to you), and an "Owner-confirmed" badge once you verify by phone (set `owner_confirmed` to the date in the data)
- "No longer running" reports show a neutral "Being re-checked"; nothing is marked ended automatically
- Each listing shows a neutral `public_note`; internal research notes (`audit_note` etc.) stay in the JSON and are stripped from the page

Signed-in visitors can confirm a deal is still running, report that it ended, rate it 0–5 stars, post notes and photos, and report posts (3 reports hide a post until the admin restores it). These are stored in Supabase (see below). Menu-photo reading is still only in the [Claude version](https://claude.ai/artifact/GhzNP9fe9LD2c3QqsrsDZS).

## Files

| Path | What it is |
|---|---|
| `index.html` | The web app (built; don't edit by hand) |
| `template.html` | Page source with a `__DATA__` placeholder |
| `data/happy-hours.json` | The database: listings, map geometry, restaurants checked with no deals |
| `data/restaurant-roster.json` | Every Laguna Beach restaurant and bar that was checked |
| `build.py` | Rebuilds `index.html` from the template and data |
| `supabase/schema.sql` | Database tables, access rules and photo storage for the shared features |
| `docs/` | Audit reports from the verification passes |

## Updating

Edit `data/happy-hours.json` (or `template.html`), then run:

```
python3 build.py
```

and commit the rebuilt `index.html`.

## Shared features (Supabase)

The page talks to a Supabase project using its URL and publishable key (set as `SB_URL` and `SB_KEY` in `template.html`; both are designed to be public). Setup, once:

1. In Supabase, open **SQL Editor**, paste all of `supabase/schema.sql`, and click **Run**.
2. In **Authentication → URL Configuration**, set **Site URL** to `https://westwoodeleven.github.io/laguna-happy-hours/` and add the same address under **Redirect URLs**.
3. Sign in on the site once with your email, then run the last statement in `schema.sql` (with your email filled in) to make yourself admin, so you can delete anyone's posts.

Sign-in is by emailed magic link. Supabase's built-in email sender only sends a few emails per hour; connect your own SMTP service (Authentication → Emails) if more people start signing in. Anyone can read confirmations, ratings and posts; people can only change their own, and each person can post at most 20 times an hour. Photos can only be uploaded for a post the person just made, so uploads share that limit.

After pulling an update that changes `supabase/schema.sql`, run the whole file again in the SQL Editor (it's safe to re-run).

## Automatic checks

Two Claude scheduled tasks open pull requests with proposed data changes for you to review and merge:

- **Monthly re-check** (1st of each month): rechecks official happy hour pages and uncertain listings, and every quarter looks for new places in the restaurant roster.
- **Daily report check** (mornings): alerts you only when there are new "No longer running" reports or restaurant messages.
- **Weekly visitor review** (Mondays): reads the week's "No longer running" reports, confirmations, notes and photos from Supabase and proposes updates.

## Visitor counts (optional)

Create a free [GoatCounter](https://www.goatcounter.com) account, put its code in `GOATCOUNTER_CODE` in `build.py`, and rebuild.

## Map tiles

The web version uses [Leaflet](https://leafletjs.com) with OpenStreetMap's standard tiles (dark mode inverts them). No API key is needed, but OpenStreetMap's [tile usage policy](https://operations.osmfoundation.org/policies/tiles/) only allows light use and requires the attribution shown on the map. If traffic grows, switch to a tile provider with a free key (MapTiler, Stadia Maps, Thunderforest) by changing `tileLayer()` in `template.html`. The Claude version can't load outside map tiles, so it keeps a simplified drawn map.

## Accuracy

Deals change often. Each listing shows when it was last confirmed and where the information came from; call ahead before you go.
