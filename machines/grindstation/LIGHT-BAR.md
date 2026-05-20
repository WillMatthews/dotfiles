# Front "Beast" light bar — reverse engineering log

The Medion Erazer Beast 16 X1 has a front-edge RGB light strip that runs a breathing-purple animation on boot and is **not yet controllable from Linux**. This file collects everything that's been tried and what remains.

## What we know

- DMI family `Beast`, product `ERAZER 16 X1`, SKU `ML-210015 30039609`.
- The chassis is OEM'd by ASUS for Medion — the firmware contains an ASUS-style `AMW0` / `AWMI` WMI block, an `EC0` device with KBC command/data fields (`LDAT/HDAT/CMDL/CMDH/RFLG/WFLG/DRDY`), and ASUS-style brightness routines.
- The strip's default pattern (breathing purple) is driven entirely by the EC/firmware — it shows up before any OS is booted and persists across reboots without any host-side software running.

## What we've eliminated

### Not on USB

`lsusb` lists only:
- `048d:7001` ITE 8233 (keyboard / hotkey HID)
- `048d:600b` ITE 8291 (keyboard RGB)
- internal hubs / webcam / Bluetooth / external mouse / external Keychron

No other RGB-capable device. The strip is internal and not exposed as a USB endpoint we can see.

### Not on the ITE 8291 (keyboard backlight controller)

Tested extensively. The 8291 controls the keyboard's 6×21 key matrix; the strip is on a different system. Specifically:

| Attempt | Result |
|---|---|
| `monocolor` (`set_color`) — solid colours red, green, magenta | Keyboard changes. Strip stays breathing purple. |
| `set_key_colors` — full 6×21 matrix mapped, both uniform and gradients | Keyboard changes per-cell. Strip stays breathing purple. |
| Row indices 0–5 (documented keyboard rows) | Keyboard cells light. Strip unchanged. |
| Row indices 6–15 (probing "extra rows") | Firmware silently accepts them but they corrupt the keyboard (most keys turned mildly purple-white, leftmost column unaffected). Strip unchanged. Pattern suggests these row indices alias to something internal — not extra strip zones. |
| Built-in effects `rainbow`, `aurora`, `fireworks`, `wave`, custom plasma | All effects only apply to the keyboard. |
| GET opcode sweep `0x80`..`0xFF` | Confirmed `0x80` (firmware) and `0x88` (effect). Two extra opcodes return non-sentinel data: `0x87` → `[135, 255, 0, 255, 255, 255, 255, 255]` and `0x92` → `[146, 0, 0, 8, 0, 0, 0, 0]`. All others return the "unknown" sentinel `[0xAA, 0x12, 0x34, 0x56, 0x78, 0x90, 0xFA, 0xFA]`. |
| Hypothesis: `0x07` is the SET counterpart of `0x87` (since `FF 00 FF` matches the strip's purple) | Tried 15 different payload layouts (R/G/B in bytes 1–3, with various leading mode bytes, with FF padding, all-zero, all-FF). **No visible change to the strip at any point.** Conclusion: the `FF 00 FF` returned by `0x87` is most likely a hardcoded firmware constant, not the live strip colour — its match with the strip is coincidence. |

### Not in ACPI/WMI

Disassembled DSDT (`/sys/firmware/acpi/tables/DSDT`, 596 KB) + all SSDTs via `iasl -d`. Searched for: `light`, `lbar`, `lbr`, `aura`, `rgb`, `strip`, `glow`, `lamp`, `beast`, `medion`, `erazer`, `tongfang`, `clevo`.

**No string match anywhere.** The DSDT genuinely has no named symbol that looks like a lightbar.

WMI devices present:

| Device | _UID | Method | What it does |
|---|---|---|---|
| `AWMI` (`PNP0C14`) | `0x00` | `WMAA` | Keyboard backlight brightness only (cases 1 & 2; manipulates `EC0.BLLV` and `EC0.BLSC`). |
| `AMW0` (`PNP0C14`) | `1` | `WMBA/WMBB/WMBC` | Generic EC pass-through. `WMBC` method 4 calls `OEMG` which dispatches `WKBC/RKBC/SCMD` based on a 32-bit `SAC1` selector. Documented branches: `0, 1, 0x100, 0x200, 0x300, 0x400, 0x500` — none are a lightbar branch. |
| `WFDE` (`PNP0C14`) | `DSarDev` | `WMDE` | Intel "Diagnostic Sar Device" telemetry — not lighting. |
| `WFTE` (`PNP0C14`) | `TestDev` | `WMDE` | Intel test interface — not lighting. |

`asus_wmi` loads but doesn't bind any keyboard-backlight LED class node — the GUIDs differ from upstream ROG / Aura GUIDs.

### Not in EC `_Qxx` events

64 EC query handlers (`_Q06`..`_QFF`) — all handle generic events: lid open/close, brightness up/down, AC plug/unplug, thermal threshold, CPPC performance levels (`_Q40`..`_Q47`). None toggle a light or call out to a lightbar method.

### Not found by OpenRGB 0.9

`openrgb --verbose --list-devices` — only detects the external Logitech G203 mouse. No I2C/SMBus controller, no recognised vendor light bar device. (The ITE 8291 isn't recognised either, since its product ID `0x600B` isn't in OpenRGB's database — same problem `ite8291r3-ctl` had.)

## What's still untried

1. **ITE 8233 (`048d:7001`, `/dev/hidraw1`).** This is the keyboard's EC-side HID/hotkey controller. We've never sent vendor feature reports to it. On many Tongfang/Clevo chassis the second ITE chip handles auxiliary lighting (light bar, dragon logo, etc.). Risk: this chip processes keystrokes — bad writes could temporarily break keyboard input until reboot. Requires a udev rule for `/dev/hidraw1` (currently root-only).

2. **EC scratchpad probing.** With `acpi_call` (or `ec_sys write_support=1`), we could try writing to unnamed EC offsets. Risk: writing to wrong EC offset can hang the EC; sometimes recoverable only by removing battery. Not recommended without a known register.

3. **Captured USB / EC traffic from the Windows side.** The user's Windows install is gone, so this would require booting a Windows live USB and running the Medion vendor app while sniffing with USBPcap / SimpleECMonitor. This is the gold-standard approach.

4. **Web search for any other person who has reverse-engineered this exact chassis.** The Medion Erazer Beast 16 X1 (Tongfang GM7TG7H-derived ASUS-shared chassis with ITE 8291 fw 34.3.0.0) is a 2024–2025 product. Linux support typically lags 6–18 months.

## Misc facts collected

- ITE 8291 firmware: **34.3.0.0**
- ITE 8291 product ID: **`0x600B`** (newer than upstream `ite8291r3-ctl` 0.4 knows about — required a local patch to recognise; documented in `MACHINE.md`).
- Strip behaviour without any host software: slow breathing purple (R≈255, G=0, B≈255), period ~3–4 s.
- Strip ignores all `set_key_colors`, `monocolor`, `effect`, `brightness`, `off` commands sent to the ITE 8291.

## Wishlist for next time

- A live working sample of the Windows lightbar app (`Medion Erazer Center` or similar) under `usbmon` capture.
- The ACPI _SB.AMW0 OEMG branch list from a slightly different OEM variant of this chassis — might reveal an undocumented `SAC1` selector.
- The Tongfang clevo-related repos that started supporting per-key + light-bar control circa 2024-2025.

---

## 🟢 Breakthrough — protocol identified (May 2026)

The strip is a **Uniwill-platform RGB lightbar**, addressed not via USB at all but via **EC RAM writes through a WMI pass-through method**. Confirmed via Tuxedo Computers' open-source `tuxedo-drivers` source:
[`uniwill_keyboard.h`](https://github.com/tuxedocomputers/tuxedo-keyboard/blob/master/src/uniwill_keyboard.h) +
[`uniwill_wmi.c`](https://gitlab.timmertech.nl/linux/ubuntu/clevo-keyboard/-/blob/master/src/uniwill_wmi.c).

### EC register map (Uniwill lightbar)

| Offset | Purpose | Range |
|---|---|---|
| `0x0748` | animation bits (bit `0x80` = animation on) | bitfield |
| `0x0749` | red intensity   | 0..`0x24` (= 36) |
| `0x074A` | green intensity | 0..`0x24` |
| `0x074B` | blue intensity  | 0..`0x24` |

(Brightness range is `0..0x24` — the same `0x24` that turns up in `UNIWILL_LIGHTBAR_LED_MAX_BRIGHTNESS`.)

### How to write those registers from Linux

The EC addresses are >0xFF, so they're outside the standard ACPI EC range. The Uniwill EC firmware exposes a 16-bit read/write interface via a WMI method:

- **WMI GUID**: `ABBC0F6F-8EA1-11D1-00A0-C90629100000` (also visible in `/sys/bus/wmi/devices/`)
- **ACPI path**: `\_SB.PC00.AMW0.WMBC`
- **Method**: 4 (when called with `Arg1 == 4`, dispatches to `OEMG` which dispatches on `SAC1`)
- **Buffer layout** (16 bytes, only first 8 used):

  | byte | value |
  |---|---|
  | 0 | EC address low byte (`0x49`/`0x4A`/`0x4B`/`0x48`) |
  | 1 | EC address high byte (`0x07`) |
  | 2 | data low byte (the colour intensity) |
  | 3 | data high byte (`0`) |
  | 4 | `0` |
  | 5 | function — `0` for WRITE, `1` for READ |
  | 6, 7 | `0` |

The DSDT's `OEMG` method dispatches exactly on this layout:
`SAC1 == 0` → `WKBC(SA00, SA01, SA02, SA03)` writes data (`SA02`,`SA03`) to EC address (`SA00`,`SA01`);
`SAC1 == 0x100` → `RKBC(SA00, SA01)` reads from EC address.

### Tooling that should "just work" (once installed)

1. **`acpi_call`** kernel module (`acpi-call-dkms` on Debian/Ubuntu) — lets us invoke `\_SB.PC00.AMW0.WMBC` from `/proc/acpi/call` and is the smallest possible footprint.
2. **`tuxedo-drivers`** DKMS package — full support, but its DMI allow-list does not currently include the Erazer Beast 16 X1 (`Beast` / `X6ARxxxY-W` / SKU `ML-210015 30039609`). Would need a DMI override patch to opt in. Tuxedo's drivers also enable other things like keyboard region colour, fan curves, etc. that may or may not match this chassis cleanly.
3. **Mainline kernel ≥ 6.19** — has the upstreamed `uniwill-laptop` driver. Our current kernel is 6.17; once Ubuntu ships 6.19+, it may bind natively.

### Single concrete test

To set the strip to maximum red as a one-shot test (with `acpi_call` loaded):

```
# red = 0x24, green = 0, blue = 0
echo '\_SB.PC00.AMW0.WMBC 0 4 {0x49,0x07,0x24,0x00,0,0,0,0,0,0,0,0,0,0,0,0}' | sudo tee /proc/acpi/call
echo '\_SB.PC00.AMW0.WMBC 0 4 {0x4A,0x07,0x00,0x00,0,0,0,0,0,0,0,0,0,0,0,0}' | sudo tee /proc/acpi/call
echo '\_SB.PC00.AMW0.WMBC 0 4 {0x4B,0x07,0x00,0x00,0,0,0,0,0,0,0,0,0,0,0,0}' | sudo tee /proc/acpi/call
# disable the breathing animation so a static colour sticks
echo '\_SB.PC00.AMW0.WMBC 0 4 {0x48,0x07,0x00,0x00,0,0,0,0,0,0,0,0,0,0,0,0}' | sudo tee /proc/acpi/call
```

This has not yet been run — pending `acpi_call` install.

### Caveats

- Writing to EC offsets can hang or brick the EC if you hit the wrong register. The four offsets above are documented in Tuxedo's open-source code as the lightbar's registers across an entire generation of Uniwill chassis, so they're as safe as anything userspace can do here — but they have not yet been verified specifically on the Erazer Beast 16 X1.
- All three colour values must be in `0..0x24` (= 36). Higher values will be either clamped or undefined.
- If the strip remains in breathing mode, static writes to 0x0749–0x074B may be overridden by the EC's animation engine — `0x0748` bit `0x80` must be cleared first.

---

## 🟡 Verified on this chassis (Erazer Beast 16 X1): write/read works, but offsets don't match

After installing `acpi-call-dkms` and enrolling the local MOK key so the module loads under Secure Boot, we can invoke the AMW0 WMBC method end-to-end. Confirmed the protocol works:

- **ACPI path**: `\_SB.AMW0.WMBC` (no `PC00` intermediate — different from what the OEMG Linux source led us to expect; the iasl-output comment paths were correct: `\_SB_.AMW0.…`).
- **Write proof**: wrote `0xAA` to EC `0x0749`, read it back as `0xAA` → both write and read paths function.
- **Read returns *two consecutive bytes*** (`CMDL` = byte at `addr`, `CMDH` = byte at `addr+1`), so each `RKBC` call effectively dumps two EC bytes for the price of one.

But **Uniwill's documented offsets `0x0748–0x074B` are just unused scratchpad on this chassis** — writes land there but the strip is unaffected.

### What we did find

Scanning EC `0x0700–0x07FF` while the strip was breathing purple revealed:

- **`0x0701` and `0x0703` oscillate** in roughly the right range (`0x4C…0x80`) with G fixed at `0` — strongly purple-shaped, matching the strip's breathing.
- But **writing to `0x0701–0x0703` produces no visible change** — the EC's animation engine over-writes them faster than our writes land. No flicker, no transient.
- Zeroing all of `0x0700–0x070A` (including the obvious `enable=0x40` and `effect=0x05`-shaped bytes) also produced **no change** to the strip.
- A second purple-shaped block at `0x0727–0x0729` (`80 00 80`) and a possible effect/brightness block at `0x072B–0x072E` (`01 09 26 05`) — overwriting those also did nothing.

**Conclusion: `0x0701/0x0703` appear to be a *mirror* of the strip's state, not control registers.** The actual command channel is somewhere else — most likely a separate MCU on the strip itself, polled by the EC firmware and reflected into EC RAM for ACPI introspection.

### Remaining avenues (in order of plausibility)

1. **Different EC RAM region.** We only scanned `0x0700–0x07FF`. The Beast 16 X1 is a 2024-2025 chassis newer than anything Tuxedo has DMI-registered; its registers may live at `0x0800+` or `0x06xx`. Worth dumping `0x0000–0x06FF` and `0x0800–0x0FFF` and looking for command-shaped patterns.
2. **The battery-mode lightbar offsets** `0x07E2–0x07E5` — upstream `uniwill-laptop` uses these when on battery (paired with `0x0748` on AC). We've only tested AC offsets so far. Worth a quick check even though the laptop is on AC, since the EC firmware on this chassis might use the BAT bank regardless.
3. **I2C/SMBus directly.** The I801 SMBus controller is exposed at `/dev/i2c-6`. The strip's MCU could be there.
4. **ITE 8233 (`/dev/hidraw1`).** Never sent a vendor HID feature report to it. Risk: it's the keyboard's HID/hotkey controller, so a bad write can break input until reboot.

### Mainline kernel / Ubuntu 26.04 status

Researched on 2026-05-18:

- **Linux 6.19** (Feb 2026) merged the **`uniwill-laptop`** driver upstream — author Armin Wolf (`Wer-Wolf` on GitHub), repo [Wer-Wolf/uniwill-laptop](https://github.com/Wer-Wolf/uniwill-laptop).
- **Ubuntu 26.04 LTS "Resolute Reindeer"** (April 2026) ships **Linux 7.0** — so the driver is in-tree there.
- Features the driver exposes: RGB lightbar, hwmon, hotkeys, battery charge limiting, USB-C power priority.
- Sysfs surface: multicolor LED `uniwill:multicolor:status` + per-toggle attrs `rainbow_animation` and `breathing_in_suspend` under `/sys/bus/platform/devices/INOU0000:XX/`.
- **DMI whitelist required** for autoload — Beast 16 X1 not listed. Can be bypassed with `modprobe uniwill_laptop force=1` (driver prints `"Loading on a potentially unsupported device"`).
- **Brightness range is `0..200`** (not `0..0x24` as Tuxedo's older driver had). This matches the values we saw mirrored at `0x0701/0x0703` here (`0x4C..0x80` ≈ 76..128, well within `0..200`) — strong corroboration that this *is* a Uniwill-family lightbar.

### The catch with upgrading to Ubuntu 26.04

The upstream driver writes only to `0x0748-0x074B` (AC) and `0x07E2-0x07E5` (battery), which are the **same** offsets we've already disproven (or haven't yet checked, in the battery case). So unless the battery bank `0x07E2-0x07E5` happens to drive the strip on this chassis, the in-tree driver won't help — it'll just silently scribble on dead bytes. The right long-term fix is to upstream a chassis-specific patch with the correct offsets, which means we have to find them first.

---

## Full EC RAM scan results (May 2026)

Scanned all of EC RAM 0x0000–0x0FFF via `\_SB.AMW0.WMBC` method-4 reads (two bytes per call, all-zero rows suppressed). The strip is breathing purple throughout the scan.

### What we expected to find

A second `XX 00 XX` purple-shaped triple somewhere outside `0x0701-0x0703` — that would be the *source* register the EC firmware reads to drive the strip. Then writing there would let us control colour.

### What we actually found

**Nothing.** No other purple-shaped triples anywhere in 0x0000–0x06FF or 0x0800–0x0FFF. The only place RGB-shaped breathing values live is at `0x0701-0x0703`, and those are the mirror values we already disproved as controls.

The rest of EC RAM is reasonable-looking laptop firmware state:

| Region | Content |
|---|---|
| `0x0200-0x025F` | ROM ID region (mostly `0xFF`) with embedded ASCII serial `1D05300FY22001000` at `0x0250` |
| `0x0300`, `0x0320` | ASCII `GF-GF` chassis code, mirrored |
| `0x0370-0x03FF` | Thermal monitoring tables (sensor pairs) |
| `0x0500-0x05FF` | Configuration mirror — fan curves, doubled pairs |
| `0x0600-0x0610` | 16-bit values, likely battery / temperature readouts |
| `0x06B0` | Block of `0xB2` brightness-shaped values, but uniform (not RGB) |
| `0x0800-0x08FF` | Mixed config and live values, fan/thermal flavoured |
| `0x0900-0x0970` | Calibration lookup table — `0x0219` repeated many times |
| `0x0990-0x09BF` | Effect-engine config — `b2 e5 b0 e0 b1` near-repeat |
| `0x0D00-0x0DFF` | Second mirror copy of the ROM-ID region from `0x0200` |

### What this means

The strip's source data is **not in EC RAM** that this WMI method can reach. The breathing animation must originate from one of:

1. **A separate MCU on the strip itself**, addressed via SMBus (Intel I801 controller at `/dev/i2c-6`) or some other bus. The EC firmware would poll that MCU and reflect its state into `0x0701-0x0703` for software introspection. Plausible because the values *do* update in EC RAM, but our writes there don't propagate.
2. **An internal EC firmware variable** that lives in CPU registers / SRAM that's not exposed in the WMI-accessible EC RAM window. Writing to the mirror does nothing because the firmware recomputes the value next loop iteration. To control it we'd need a firmware command — probably one of the lightbar branches the Uniwill driver's `uniwill_led_brightness_set()` invokes, but at *some other ACPI method / EC command* than the simple `WKBC` path we've been using.
3. **A vendor HID feature report on the ITE 8233** (`/dev/hidraw1`) that hasn't been probed.

### CRITICAL UPDATE — the strip is per-LED addressable

User confirmed: on Windows the strip displayed a **scrolling rainbow** pattern. That means the strip is not a single-zone RGB device — it has many **individually addressable LEDs** (WS2812 / SK6812 / APA102-style or similar).

Consequences:

- Tuxedo's `uniwill-laptop` driver — and the whole `0x0748-0x074B` / `0x07E2-0x07E5` 4-byte register convention — was designed for **single-zone** lightbars. It physically cannot encode a per-LED pixel array. So even with `force=1` on kernel 6.19+/Ubuntu 26.04, the in-tree driver almost certainly **cannot drive this strip**, no matter what offsets it targets.
- The protocol the Beast 16 X1 uses is **packet/buffer-based**, not register-based. The Windows app must send either:
  - A buffer of per-pixel RGB triples (raw streaming mode), and/or
  - Mode commands like "rainbow scroll", "breathing", "solid colour" with their own parameters, processed by the strip's controller.
- That kind of protocol lives on a **dedicated LED controller chip**, reached over one of:
  - SMBus / I2C (the Intel I801 SMBus at `/dev/i2c-6` is the prime suspect)
  - A vendor HID feature report on the **ITE 8233** (`048d:7001`, `/dev/hidraw1`) — this is the most "ASUS / Tongfang / ITE EC" style for newer chassis
  - A dedicated MCU on a private SPI / GPIO that's only reachable through an EC firmware command we haven't found

This means the work plan shifts:

1. **`uniwill_laptop force=1` is much less likely to help than first thought** — its 4-byte API can't express per-LED control. Still worth a 30-second test on 26.04 in case the strip falls back to a "solid colour" mode when given a single RGB triple.
2. **SMBus scan** (`i2cdetect -y 6`) becomes the highest-value experiment. A WS2812-style LED strip would not show up directly, but an LED *controller* chip (a small MCU) on the SMBus likely would.
3. **ITE 8233 vendor HID probing** is a strong second candidate. The chip has 64-byte HID Output and Input reports that could carry per-pixel packets.
4. **Windows USB capture** becomes the highest-leverage long-term investment — booting Windows from a USB stick, running the Erazer Center, and capturing USB / EC / SMBus traffic would crack this cleanly. Worth doing once and saving the trace.

### Two remaining concrete experiments

These are the next two things to try before giving up:

#### A. Try `uniwill-laptop force=1` on kernel 6.19+ (Ubuntu 26.04)

```
sudo modprobe uniwill_laptop force=1
dmesg | tail -20                              # see what features the driver claims
ls /sys/class/leds/                           # look for uniwill:multicolor:status
ls /sys/bus/platform/devices/INOU*/           # look for lightbar attrs
```

If `uniwill:multicolor:status` appears, try:

```
echo 0 0 200 > /sys/class/leds/uniwill\:multicolor\:status/multi_intensity
echo 255 > /sys/class/leds/uniwill\:multicolor\:status/brightness
```

This will write `R=0, G=0, B=200` to whatever offsets the driver believes are the lightbar. If the strip turns blue → win. If it stays purple → driver is hitting the wrong offsets (as we suspect) and we move to (B).

#### B. SMBus enumeration

```
sudo apt install -y i2c-tools
sudo i2cdetect -l                             # list buses; SMBus is i2c-6
sudo i2cdetect -y 6                           # scan SMBus for devices
```

Any address that responds is a candidate for the strip's MCU. Bus 6 is the Intel I801 SMBus; the lightbar MCU on Uniwill chassis is commonly addressed there.

### Files / scripts left on disk

Will be wiped by the dist-upgrade. For reference, the working test scripts were:

- `/tmp/lb_test.sh` — write `0xAA` to EC `0x0749`, read back. Confirms protocol.
- `/tmp/lb_dump.sh` — dump `0x0700-0x07FF`, 16 bytes/row.
- `/tmp/lb_wide_dump.sh` — wide dump `0x0000-0x06FF` and `0x0800-0x0FFF`, all-zero rows suppressed.
- `/tmp/lb_mode.sh`, `/tmp/lb_blank.sh`, `/tmp/lb_set_green.sh` — failed write-experiments.

### Resuming after the 26.04 upgrade

1. Install proprietary NVIDIA driver first (`sudo ubuntu-drivers install`) — reboot.
2. `sudo apt install -y acpi-call-dkms` again (will rebuild against kernel 7.0; signed by the already-enrolled MOK).
3. `sudo modprobe uniwill_laptop force=1` — see (A) above.

### Tooling installed during this investigation

- `acpica-tools` (iasl) — DSDT/SSDT disassembler.
- `acpi-call-dkms` — provides `/proc/acpi/call`; module is built and signed with the local MOK.
- MOK enrolled at `/var/lib/shim-signed/mok/MOK.der` so future DKMS modules signed by the same key will load under Secure Boot.

### Two scripts left on disk that produced the results above

- `/tmp/lb_test.sh` — write `0xAA` to `0x0749` then read back. Proves the protocol works.
- `/tmp/lb_dump.sh` — dumps EC `0x0700–0x07FF` as a 16-byte-per-row hex grid.
- `/tmp/lb_mode.sh` — writes target RGB to `0x0727-0x0729` and effect ID to `0x072C`. No effect.
- `/tmp/lb_blank.sh` — zeros `0x0700–0x070A` to test the obvious enable-candidates. No effect.
