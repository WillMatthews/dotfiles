# Themes

All built around the keyboard's daily-driver **golden yellow** `#FFC332` (RGB 255,195,50). Aesthetic target: the "papery / warm-cream" look used by Anthropic, Stripe, Linear's lighter surfaces — modern, low-glare, slightly editorial, never neon. Each theme below shares the same accent so they all read as part of one family; what changes is the surface temperature and the contrast level.

To preview them in the terminal:
```
python3 ~/.local/bin/show-themes
```

To pick one: skim the rendered swatches, note the name, and tell future-you / Claude which to apply where (terminal, GTK, i3bar, rofi).

---

## 1. Parchment (warm light, low contrast)

Cream paper, warm sepia ink, gold accent. The closest match to the "Anthropic homepage" feel — easy on the eyes for long sessions, no harsh whites.

| Role        | Hex       | Notes                                  |
| ----------- | --------- | -------------------------------------- |
| bg          | `#F4EFE3` | cream paper                            |
| bg_alt      | `#EAE3D2` | sidebar / inactive surface             |
| fg          | `#2A211B` | deep warm sepia, primary text          |
| fg_dim      | `#6E6256` | comments, secondary text               |
| accent      | `#FFC332` | golden yellow — highlights, links      |
| accent_dim  | `#C99529` | hover / pressed state                  |
| success     | `#5A7548` | muted sage                             |
| warning     | `#C66B1B` | burnt amber                            |
| error       | `#A53C2C` | terracotta                             |
| border      | `#D6CDB7` | hairline dividers                      |

---

## 2. Honey & Ink (light, high contrast)

Like Parchment but cranked up: paler honey-white background, near-black ink. Editorial / typographic feel; better when you want the page to feel crisp rather than mellow.

| Role        | Hex       | Notes                                  |
| ----------- | --------- | -------------------------------------- |
| bg          | `#FBF7EE` | pale honey-white                       |
| bg_alt      | `#F0EAD8` | secondary surface                      |
| fg          | `#1A1814` | near-black with warm undertone         |
| fg_dim      | `#5E5A50` | secondary text                         |
| accent      | `#FFC332` | golden yellow                          |
| accent_dim  | `#B88523` |                                        |
| success     | `#486F3F` |                                        |
| warning     | `#B26B16` |                                        |
| error       | `#8E3826` |                                        |
| border      | `#DBD4C0` |                                        |

---

## 3. Sunlit Linen (warm light, more saturation)

Warmer than Parchment, slightly more colour in the functional roles. Reads like afternoon sun on a linen tablecloth. Good if Parchment feels too grey.

| Role        | Hex       | Notes                                  |
| ----------- | --------- | -------------------------------------- |
| bg          | `#FAF3E1` | sunlit linen                           |
| bg_alt      | `#F0E4C7` |                                        |
| fg          | `#36281E` | rich espresso                          |
| fg_dim      | `#715F4E` |                                        |
| accent      | `#FFC332` | golden yellow                          |
| accent_dim  | `#C99219` |                                        |
| success     | `#6B8B3D` | warm olive                             |
| warning     | `#D4761C` | pumpkin                                |
| error       | `#B23F2A` |                                        |
| border      | `#DCCFAA` |                                        |

---

## 4. Aged Brass (warm dark)

Tobacco-brown background, cream text, gold pops. Library / leather-armchair energy. Comfortable for night use without being clinical like a pure dark theme.

| Role        | Hex       | Notes                                  |
| ----------- | --------- | -------------------------------------- |
| bg          | `#2A211B` | warm dark brown                        |
| bg_alt      | `#3A2E25` |                                        |
| fg          | `#EFE3CE` | cream text                             |
| fg_dim      | `#A89880` |                                        |
| accent      | `#FFC332` | golden yellow                          |
| accent_dim  | `#D6A12A` |                                        |
| success     | `#8FA672` |                                        |
| warning     | `#E9994A` |                                        |
| error       | `#D26653` |                                        |
| border      | `#4E3F32` |                                        |

---

## 5. Midnight Gold (true dark)

Almost-black background with a warm undertone, gold accent jumps off the page. The most contrast of the dark themes; closest to a conventional "dark mode" but kept off neutral grey so the gold still reads as warm rather than alarmist.

| Role        | Hex       | Notes                                  |
| ----------- | --------- | -------------------------------------- |
| bg          | `#11100E` | near-black, warm undertone             |
| bg_alt      | `#1B1A16` |                                        |
| fg          | `#E8E0CC` |                                        |
| fg_dim      | `#8E8474` |                                        |
| accent      | `#FFC332` | golden yellow                          |
| accent_dim  | `#BE8C1F` |                                        |
| success     | `#7FA672` |                                        |
| warning     | `#E69955` |                                        |
| error       | `#CE5F4D` |                                        |
| border      | `#2C2922` |                                        |

---

## Notes on consistency

Across all five themes:
- `accent` is identical (`#FFC332`). This is the keyboard tie-in — every surface uses the same gold.
- `success` / `warning` / `error` are tuned per theme for legibility against that theme's bg, but they all sit in a sage-amber-terracotta family rather than the usual green-yellow-red — keeps the warm character intact.
- Light themes use bg-alt as a slightly darker cream; dark themes use bg-alt as slightly lighter than bg. Either way, bg-alt is for sidebars, status lines, and inactive panes.

## Applying a chosen theme

Once you pick one, the order to roll it out is usually:
1. **Terminal** (kitty) — `~/.config/kitty/kitty.conf` colour block.
2. **i3 client colours** — replace the block in `~/.config/i3/config` (currently white-on-grey).
3. **i3bar** — `bar { colors { ... } }` block in `~/.config/i3/config`.
4. **rofi** — `~/.config/rofi/config.rasi` plus a `.rasi` theme.
5. **GTK** — pick or generate a GTK theme that approximates the palette (this affects Firefox's title bar, file dialogs, etc.). The hardest step; the rest is text files.
