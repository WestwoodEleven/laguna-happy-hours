# Laguna Beach Happy Hour Audit (Oct 6, 2026)

## Verifier errors and caveats
**Yelp verifier**
- The `evidence.date` on each "title-only" item is a crawl date, not evidence of a happy hour. All 36 no_evidence results carry no HH information, which is correct, but those dates shouldn't be read as recency.
- The 5 "contradicted" results (Rum Social, Reunion, Skyloft, Bodega, Watermarc) are closure flags. They are supported by the CLOSED listing titles.
- Useful extras: K'ya renamed to K'YA LAGUNA, Bodega at 400 S Coast Hwy, a closed second Gina's at 610 N Coast, and a new Casa Bistro at the La Casa del Camino address.

**Google verifier**
- No Google page was ever fetched. Every "google_listing" item is a Wanderlog mirror, and "confirmed" means only an undated Wanderlog blurb mentions a HH. None of the 8 "confirmed" results confirms hours.
  - Starfish is marked hours "match", but the support is an undated blurb only.
  - Coyote Grill is marked a "mismatch" (Mon-Fri) from an undated blurb. The official site says every day 3-6, so the verifier's evidence was wrong.
  - Oak's blurb ("weekday HH") supports a HH but not Tue-Fri.
  - Rumari, Wine Gallery and Hennessey's: the HH is mentioned but there are no times.
- Royal Hawaiian is the only "confirmed" result backed by dated Google reviews, labeled correctly as quoted on Wanderlog (Jan and Mar 2026). The Mar 2026 review only says the place "would make a great HH", which is not evidence of one.
- The Cliff: the Franki review from Aug 2025 is older than Oct 2025, so it was not counted as current. Franki items were correctly labeled as not Google.
- Driftwood: the mirror shows it open, but the verifier correctly treated that as lag.
- 10 entries were left unchecked because the search quota ran out.

**Compiler errors found**
- Oak: the official site now says **Mon-Fri** 3-6, not Tue-Fri.
- Piatti: listed as "daily, times unknown". The official homepage says **weekdays 3-6 at the bar**, plus half-off wine on Wednesdays.
- Greeter's Corner: "daily" was assumed. Visit Laguna gives only "4-6pm" with no days.
- 237 Ocean Ave: the source says it is closed Mondays, so the HH runs Tue-Sun. The compiler left the days empty.
- Visit Laguna HH blog (updated Feb 9, 2026): it doesn't say "daily" for The Cliff, only "3 pm to 6pm". The compiler's note slightly overstated the conflict.

## Conflicts resolved
| Entry | Resolution | Basis |
|---|---|---|
| Finney's | **Daily** 3-5, dine-in | Official page, live Oct 2026 |
| Coyote Grill | **Daily** 3-6 | Official site, live; Wanderlog Mon-Fri blurb rejected |
| Marine Room Sun HH | **Unresolved**. Sunday kept but flagged doubtful | Official fetch timed out; Visit Laguna (Mar 2026) vs Pearl and Google showing a 3pm Sunday open |
| Brussels Bistro | 4:30 start | Restaurant opens at 4:30 Mon-Thu (Google mirror + OpenTable); Visit Laguna's 4:00 rejected |
| Rumari end time | **Unresolved**. Kept 17:00 with a note | Both sources are undated OpenTable pages; official fetch timed out |
| Hennessey's | 4-7pm | Official site, live |
| Oto Sushi | **Unresolved**. Used daily 4:30-5:30 (dated Feb 2026 guide), with the OpenTable times in the note | Official fetch timed out |
| The Cliff | $2 off drinks, Mon-Fri 3-6 | Official site (days) + Visit Laguna blog Feb 2026 ($2) |
| Greeter's Thu closure | **Unresolved** | OpenTable vs Google mirror; official fetch timed out |
| Rum Social | **Closed** | Yelp (Sep 2025 and Sep 2026) + Google mirror agree |
| K'ya | Renamed **K'ya Laguna**, Tue-Sun 3-6 | Orange Coast, Jun 22 2026 (re-fetched) + Yelp rename |
| Gina's | 1100 S Coast Hwy, status changed to active | Official site lists only this location; the north store is closed |
| Bodega | 400 S Coast Hwy | Yelp snippet |

**Extras added as other_deals:**
- Royal Hawaiian: $10 Mai Tai and $10 spring rolls (Jan 2026 Google review)
- Avila's: Tuesday taco bar
- Hennessey's: Tuesday BOGO burgers
- Oak: Wine Wednesday
- Piatti: Wednesday half-off wine (official)
- Wine Gallery: Sunday industry night
- 237 Ocean: locals 15% off
- Laguna Beer Co: Taco Tuesday
- The Cliff: Taco Tuesday moved here (unconfirmed)

The unverified blurb-sourced extras are marked "unconfirmed".

## Spot-checks (WebFetch, Oct 6 2026)
**Confirmed:**
- Starfish HH menu: daily 3-6, prices match. The weekend 11am start is not on the HH page.
- Mozambique HH page: Wed-Fri 3-5, Sat-Sun 2-4, prices match.
- Las Brisas HH page: weekdays 3-6 in the cantina. Bites run up to $18.
- The Cliff: Mon-Fri 3-6.
- Finney's: daily 3-5, dine-in.
- Coyote Grill: every day 3-6.
- Hennessey's: Mon-Fri 4-7.
- Gina's: only Laguna store is 1100 S Coast; no HH on the site.
- Orange Coast K'ya article.
- Best of Laguna 237 Ocean article (2024).
- Visit Laguna directory for Rasta Taco: Tue-Fri 3-6, undated.

**Changed data:**
- Oak: official site says Mon-Fri 3-6.
- Piatti: official site says weekdays 3-6 at the bar.
- Visit Laguna HH guide (p=14044, updated Mar 3 2026) re-read: Gina's food items added, Greeter's has no days, Mozambique and Oak listings are stale.

**No HH info on the official site:** 230 Forest (award mention only), Brussels Bistro.

**Approval timed out (not retried):** Oto Sushi, Romeo Cucina, Rumari, Marine Room, Wine Gallery, Greeter's Corner.

## Final counts (41 entries)
- **Status:** active 27, unclear 7, closed 7
- **Confidence:** verified 18 (11 active + 7 closed), likely 11, needs_confirmation 12
- **Lumberyard and Romeo Cucina** are "verified" because two independent 2026 guides agree (Visit Laguna + Clara Blunk). Their official sites have no HH info or weren't fetched.

## Still needs checking
- Oto Sushi times
- Rumari end time
- Marine Room Sunday HH
- Greeter's days and Thursday closure
- Rooftop Lounge after the ownership change
- Whether Splashes' Golden Hour is discounted
- Sapphire, Selanne, Harvest and Laguna Beer Co: current HH unknown
- 237 Ocean: still the same tenant?
- Starfish: weekend 11am start
- Oak: Monday service
