# Colours

## Keyboard backlight

### Region scheme

Each key colored by its functional region — letters white, digits yellow, F-keys magenta, punctuation+numpad-operators cyan, modifiers orange, arrows red, space green, specials blue.

Apply: `ite8291r3-ctl anim --file ~/.config/kb-patterns/regions.anim`

### Earthy amber-yellow

RGB `(255, 200, 80)` — warm, slightly orange-toned yellow. Reads as a deeper "aged paper" or candlelit gold; not lemon.

Apply: `ite8291r3-ctl monocolor --rgb 255,200,80 -b 35`

### Golden yellow ⭐ (favourite / daily driver)

RGB `(255, 195, 50)` — yellower than the amber above, less orange, still warm. Reads like rich honey / school-bus gold.

Apply: `ite8291r3-ctl monocolor --rgb 255,195,50 -b 35`

### Cyber plasma (show-off loop)

Rotating rainbow base (hue varies by column/row/time) with a bright-white radial pulse expanding outward from the spacebar, plus a horizontal scanline sweeping top→bottom. ~25 FPS, 2.4 s loop, brightness 50. Generator at `/tmp/gen_plasma.py` (regenerate with `python3 /tmp/gen_plasma.py > ~/.config/kb-patterns/cyber-plasma.anim`).

Apply: `ite8291r3-ctl anim --file ~/.config/kb-patterns/cyber-plasma.anim --loop 999999 &`

Stop: `pkill -f 'ite8291r3-ctl anim'` then restore a static colour (e.g. golden yellow above).

**Note:** always pass an explicit count to `--loop` (not bare `--loop`). Bare `--loop` triggers a bug in ite8291r3-ctl 0.4: argparse sets `args.loop=True`, but `True == 1` in Python, so the code takes a single-use-iterator branch that exhausts after one cycle, then spins the outer `while` at 100% CPU with no work. An explicit integer takes the list-materialising branch and loops correctly.

### Aurora (show-off loop, calmer variant)

Aurora-borealis hues only (green → teal → cyan → purple → magenta — no red/yellow). Three overlapping "curtains" of light drift left→right at different speeds, with per-row warp so each curtain undulates like a hanging drape. Dim sky-gradient base, 6 s loop, ~25 FPS, brightness 50. Generator at `/tmp/gen_aurora.py`.

Apply: `ite8291r3-ctl anim --file ~/.config/kb-patterns/aurora.anim --loop 999999 &`

### Live CPU + GPU bars

`kb-stat-bars` (in `~/.local/bin/`) drives the top two rows as live usage meters: F-key row (Esc→End, 20 segments) = CPU, number row (`` ` ``→`=`, 13 segments) = GPU. Green→yellow→red gradient across each row by position; unfilled segments stay dim. Other keys are held to a flat base colour (golden yellow `(255,195,50)` at brightness 35 by default — matches daily driver). Updates at 10Hz by default by streaming frames into a single long-running `ite8291r3-ctl anim` process. GPU reads come from NVML via `libnvidia-ml.so` (ctypes, no pip deps); falls back to CPU-only if NVML init fails. On exit it restores the base via `ite8291r3-ctl monocolor`.

Run: `kb-stat-bars` (foreground, Ctrl+C to stop) or `kb-stat-bars &`. Flags: `--interval`, `--dim`, `--base-color R,G,B`, `--brightness`, `--no-gpu`, `--gpu-index`, `--no-restore`.

## Keyboard matrix mapping

Empirically determined for this ITE 8291 device. Matrix is 6 rows × 21 columns. Row 0 is the **bottom** physical row; row 5 is the **top**.

| Matrix row | Physical row |
|---|---|
| 0 | Bottom row: Ctrl/Fn/Win/Alt/Space/Alt/Ctrl, arrow keys, numpad `0` and `.` |
| 1 | Shift row: L-Shift → R-Shift, numpad `1`/`2`/`3`/Enter |
| 2 | Home row: Caps → `#`, numpad `4`/`5`/`6` |
| 3 | QWERTY row: Tab → Enter, numpad `7`/`8`/`9`/`+` |
| 4 | Number row: `` ` `` `1`…`0` `-` `=` Backspace |
| 5 | Top row: Esc, F1…F12, PrtSc, Del, … |

Columns 0–18 hold keys on row 3 (Tab/QWERTY); cols 19–20 are unused on this row. Numpad block lives at cols 15–18 on row 3. Per-row column mapping below.

### Full per-key mapping

UK ISO layout; keys marked *(empty)* are matrix cells with no LED on this device. Wide/tall keys (Tab, Shift, Enter, Space, numpad `+`, numpad Enter) have a single LED at the position shown.

| Col | Row 5 (F-keys)   | Row 4 (numbers)  | Row 3 (QWERTY) | Row 2 (home)   | Row 1 (shift)  | Row 0 (bottom)   |
|----:|------------------|------------------|----------------|----------------|----------------|------------------|
|  0  | Esc              | `` ` ``          | Tab            | Caps Lock      | *(empty)*      | L-Ctrl           |
|  1  | F1               | 1                | *(empty)*      | *(empty)*      | L-Shift        | *(empty)*        |
|  2  | F2               | 2                | Q              | A              | `\`            | Fn               |
|  3  | F3               | 3                | W              | S              | Z              | Win              |
|  4  | F4               | 4                | E              | D              | X              | L-Alt            |
|  5  | F5               | 5                | R              | F              | C              | *(empty)*        |
|  6  | F6               | 6                | T              | G              | V              | *(empty)*        |
|  7  | F7               | 7                | Y              | H              | B              | **Space**        |
|  8  | F8               | 8                | U              | J              | N              | *(empty)*        |
|  9  | F9               | 9                | I              | K              | M              | *(empty)*        |
| 10  | F10              | 0                | O              | L              | `,`            | AltGr            |
| 11  | F11              | `-`              | P              | `;`            | `.`            | *(empty)*        |
| 12  | F12              | `=`              | `[`            | `'`            | `/`            | Copilot          |
| 13  | ScrollLock       | *(empty)*        | `]`            | `#`            | *(empty)*      | ← Left           |
| 14  | PrtSc            | Backspace        | Enter (top)    | *(empty)*      | R-Shift        | ↑ Up             |
| 15  | Delete           | NumLock          | Numpad 7       | Numpad 4       | Numpad 1       | → Right          |
| 16  | Home             | Numpad `/`       | Numpad 8       | Numpad 5       | Numpad 2       | Numpad 0         |
| 17  | PgUp             | Numpad `*`       | Numpad 9       | Numpad 6       | Numpad 3       | Numpad `.`       |
| 18  | PgDn             | Numpad `-`       | Numpad `+`     | *(empty)*      | Numpad Enter   | ↓ Down           |
| 19  | End              | *(empty)*        | *(empty)*      | *(empty)*      | *(empty)*      | *(empty)*        |
| 20  | *(empty)*        | *(empty)*        | *(empty)*      | *(empty)*      | *(empty)*      | *(empty)*        |

Notes:
- ISO Enter (L-shape) lights only its top half at `(3, 14)` — the bottom-half cell `(2, 14)` is empty.
- Numpad `+` lights only its top half at `(3, 18)` — `(2, 18)` is empty.
- Spacebar is a single LED at `(0, 7)`; the rest of the spacebar's width is dark.
- Column 20 is entirely unused across all rows; column 19 only carries End on row 5.
- Arrow cluster is non-contiguous: Left=(0,13), Up=(0,14), Right=(0,15), Down=(0,18).
- All *(empty)* cells above were directly verified dark via a white-only probe.
