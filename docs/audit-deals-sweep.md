# Audit of data_v2.json (Oct 7, 2026)

Output: `data_v2_audited.json`. It has the same structure, with 47 listed venues (down from 49) and 108 in checked_none (up from 106). 27 venues have a new or updated `audit_note`.

## 1. Savings math
- I recomputed every dollar/dollar pair. No arithmetic errors turned up.
- 5 items had a null `save_pct` where the HH price equals the regular price. I set them to 0: Mozambique seasoned fries and sweet potato fries, Oto Chef's Roll and oysters, AhbA house lager.
- I removed four price pairings because they compare different items:
  - **Chelas, 2 fish tacos.** The listing showed $7 vs $15.99 (56%), but $15.99 is a plate with rice and beans. The item's own note already said so, yet the pairing had been kept.
  - **Starfish, Korean Tacos.** The dinner order is 3 tacos for $17, and the HH count isn't stated.
  - **Starfish, Chili Fire Wontons.** The dinner order is 7 pieces, and the HH count isn't stated.
  - **Mozambique, $10 to-go pie.** It was paired with the $25 dine-in pie, but the to-go deal excludes sides.

## 2. Deal validity
- **Moved to checked_none:**
  - **Splashes Restaurant.** Its only "deals" were a $150+ tasting menu and a weekend feature series ("The Cut & The Catch"). Neither is a discount, and the HH isn't confirmed.
  - **McClain Cellars (Canyon).** The only entry was weekend live music, and this location is no longer on the official site.
- **Biryani Hunter:** removed the $50 Indian High Tea, which is a set-price service. The venue stays listed as needs_confirmation because OpenTable mentions a happy hour.
- **Wine Gallery:** removed Wine Tasting Tuesday, which is a paid biweekly event. Industry Night and Wine Wednesday are kept but marked as appearing only on OpenTable.
- **The Cliff:** removed Taco Tuesday. It isn't on the official site or the Visit Laguna page.
- **Royal Hawaiian:** marked Tiki Thursday as unconfirmed because it isn't on the official site.
- **237 Ocean Ave:** set to closed. El Matatan, which is open, now operates at that address. The 2024 HH and locals discount were dropped.
- **Chain or multi-location promos where Laguna isn't named:**

  | Venue | Confidence change |
  |---|---|
  | O Fine | likely → needs_confirmation (official site advertises the HH for Irvine only) |
  | Chelas | verified → likely |
  | AhbA | verified → likely |
  | Active Culture | verified → likely |
  | Ruby's Diner | stays needs_confirmation (limited-time promo at "participating locations" only) |

## 3. Spot-checks (official or cited sources fetched Oct 7, 2026)

| Venue | Result |
|---|---|
| Chelas | HH Mon/Wed/Fri 3pm–close and all prices match. Taco Tuesday and Thirsty Thursday ($5 beer, 2 tacos $6.50) match. Laguna isn't named anywhere. |
| AhbA | HH Mon–Fri 16–18, dine-in. All 13 prices and the regular pairs match. The location isn't specified. |
| The Seahorse | OpenTable confirms Taco Tuesday ($3 tacos, 14–21) and hours of 7am–10pm daily. HH is mentioned with no details. The Visit Laguna source is a Feb 2024 nightlife guide; I relabeled it. |
| Active Culture | Fri 15–17, 50% off matches. The site doesn't list participating locations or hours, and Visit Laguna has no HH. |
| Coyote Grill | Every HH price matches (daily 15–18, no to-go). Taco Tuesday 3pm–close is confirmed with no prices. |
| Mozambique | HH times, items and both weekly specials match. Steak & Wine Wednesday is labeled limited-time. |
| Hennessey's | Laguna page and chain HH page agree: Mon–Fri 16–19, $8 snacks, AYCE ribs $24 on Mon, margarita flight $25 on Wed, football deals. |
| Wine Gallery | Official site confirms HH Tue–Sat 16:30–17:30 with no prices. Industry Night and Wine Wednesday are on OpenTable only. |
| O Fine | HH Mon–Thu 17:00–18:30, up to 20% off, is listed under Irvine only. Laguna is unconfirmed. |
| Starfish | Daily 15–18 HH confirmed. The homepage shows an all-day weekend HH Sat–Sun 11am–6pm, so I updated the note. |
| Lumberyard | Well drinks corrected from "$7–$10" to $6. Added Retro Old Fashioned at $10. |
| Las Brisas, Rooftop, Rumari, Sapphire, Piatti, Royal Hawaiian, The Cliff | Schedules and prices match. The Cliff's Visit Laguna "$22 off beverages" is flagged as a probable typo for $2. |

## 4. Consistency
- **Downgraded to needs_confirmation:**
  - Rasta Taco: one undated directory source.
  - C'est La Vie: Visit Laguna shows the weekly specials but no HH.
  - Brussels Bistro: the start time conflicts between sources.
- **Times and days:** all times are valid 24h HH:MM, and day lists are sorted. Greeter's Corner keeps an empty day list on purpose because the source doesn't state days.
- **Status values:** no closed venue is marked active. Kya Bistro, Laguna Beer Co. and Laguna Feast stay "unclear".

## 5. Re-check next
These were marked "Nothing published" because the search quota ran out or a page was unreadable, not because there was evidence of no HH:
- **GU Ramen Taps & Tapas:** Visit Laguna lists HH as an amenity, but the menu images were unreadable.
- **The Drake:** Visit Laguna lists HH as an amenity.
- **Lost Pier Café:** the site's meta text mentions "Happy Hour".
- **Carmelita's Kitchen de Mexico:** has an HH at its Dana Point location; Laguna not checked.
- **Broadway by Amar Santana:** has a bar; the cocktail menu wasn't reviewed.
- **Selanne Steak Tavern:** had an HH historically.
- **Seabutter:** menu page returned 429.
- **Noble Ace:** menus page returned 404.
- **Oliver's Osteria:** reopened; the site timed out.
- **Wahoo's Fish Taco:** the chain's Taco Tuesday is not checked for Laguna.
- **Saigon Beach:** the site timed out.
- **The Saloon**
- **Slice Pizza & Beer**
- **Taco Stand**
- **Papa's Tacos**
- **Peony Chinese Kitchen**
- **Heidelberg Cafe:** content was unreadable.
- **Pinafini:** shares 480 S Coast Hwy with McClain's tasting room.
- **McClain Cellars 480 S Coast Hwy:** confirm whether the Visit Laguna HH (Mon–Fri 3–5) belongs to this location.
- **Amorelia Cocina Artesanal:** the cantina is newly open.
- **Bianchi Winery:** has a new food program.
- **El Matatan:** took over the 237 Ocean Ave space, whose previous tenant ran a daily HH.

Also worth confirming by phone: O Fine, Chelas, AhbA and Active Culture (whether the Laguna location takes part), and The Cliff's beverage discount amount.
