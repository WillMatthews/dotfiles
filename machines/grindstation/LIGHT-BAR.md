# Front "Beast" light bar

The Medion Erazer Beast 16 X1 has a front-edge RGB light strip that runs a breathing-purple animation on boot. **As of 2026-05-27 it is fully controllable from Linux** — protocol and tool below. The appendix at the end is a condensed history of the reverse-engineering trail, kept for reference.

---

## ✅ SOLVED — the strip is the ITE 8233, interface 1

The light bar is driven by the **ITE 8233** (`048d:7001`) via **8-byte HID feature reports** sent as USB control `SET_REPORT`s to **interface 1** — the *exact same transport* the working `ite8291r3-ctl` keyboard sibling uses, just with the lightbar's own command bytes.

### Transport

```
bmRequestType = 0x21   (OUT | CLASS | RECIPIENT_INTERFACE)
bRequest      = 0x09   (HID SET_REPORT)
wValue        = 0x0300 (report type = Feature, report-id = 0)
wIndex        = 1      (interface 1)
data          = 8 bytes (zero-padded)
```

Interface 1 is held by `hid-generic` (it's `/dev/hidraw1`, the hotkey/Fn channel), so libusb must **detach the kernel driver from interface 1** before sending and **reattach** afterwards. That needs root, and it briefly suspends Fn-hotkey input while the tool runs — harmless, restored on reattach. (Interface 0's declared 16-byte `0x5A` feature report is a *separate, inert* channel on this chassis — writes there do nothing. The live channel is interface 1, report-id 0, 8 bytes.)

### Confirmed commands

| Action | 8-byte payload |
|---|---|
| Set palette slot N (N=1..7) → RGB | `14 00 NN RR GG BB 00 00` |
| Apply mode @ brightness | `08 22 MM SS BB 01 DD 00` |
| Off (4-packet sequence) | `12 00 03 …` / `08 05 …` / `08 01 00 …` / `1A 00 00 00 00 00 00 01` |

In the apply packet: `MM` = mode, `SS` = speed (≈1–10), `BB` = brightness `0x00`..`0x64` (0–100, dims smoothly), `DD` = direction (`0`/`1`/`2`). The 6th byte `01` is the apply/commit byte (`08` also works identically). **All confirmed working modes** (2026-05-27):

| `MM` | mode | notes |
|---|---|---|
| `0x01` | static | uses slot 1 |
| `0x02` | breathing | single-colour pulse — reads palette slot 1 |
| `0x03` | wave | scrolls, **cycling palette slots 1–7** — the Windows scrolling rainbow |
| `0x04` | bounce | single segment, back-and-forth — reads slot 1 |
| `0x05` | marquee | scrolls, **cycling palette slots 1–7** |
| `0x06` | scan | single segment scans across — reads slot 1 |
| `0x11` | flash | **does nothing** on this chassis — re-confirmed 2026-05-28 with a full sweep (palette: slot1-only / all-7-uniform / rainbow; commit byte `0x01` and `0x08`; speed 1/5/10; direction 0/1/2). Bar stays dark in every combination. |
| `0x07`–`0x10`, `0x12`–`0x1F` | — | nothing (also re-swept 2026-05-28) |

**Only `wave` and `marquee` cycle the full palette** (→ scrolling rainbow when slots 1–7 are a rainbow). `breathing`, `scan`, and `bounce` are **single-colour** — they read slot 1 only, so set it (or pass the tool's `-c R G B`). A **solid colour** = set slot 1, apply mode `0x01`. All verified end-to-end.

**Flashing from userspace** (since `0x11` is dead): re-issue mode `0x01` with alternating brightness values, e.g. 100 / 10 every ~250 ms. Brightness changes apply instantly between packets so the effect is a hard strobe between bright and dim of the same colour. Verified 2026-05-28 with a red flash at ~2 Hz — looks good. This is the only way to get a flash on this chassis.

### Tool

`~/.local/bin/lightbar` → `bin/lightbar` in this repo. Runs as the **normal user** — no sudo required on grindstation (a udev rule grants access to the ITE 8233 + permits the kernel-driver detach on interface 1).

```
lightbar color 255 170 0              # solid golden-yellow, full brightness
lightbar color 0 0 255 -b 40          # dim blue
lightbar rainbow                      # scrolling rainbow (wave); also: rainbow marquee
lightbar effect scan -c 0 180 255     # single-colour blue scan (scan/bounce/breathing = 1 colour)
lightbar effect breathing -c 255 170 0 -b 80   # breathing golden-yellow
lightbar effect wave -s 8             # scrolling rainbow (slower — see speed note below)
lightbar off
lightbar demo                          # full showcase: colours, brightness ramp, every effect
lightbar raw "08 22 03 05 32 01 00 00" # send an arbitrary 8-byte packet (experiments)
```

**Speed (`-s`) is inverted — the byte is a period, not a rate.** `-s 1` is the **fast** end, `-s 10` is the **slow** end. Verified 2026-05-28 on breathing mode.

### Credit

Command IDs came from the **keyRGB** project's `ite8233` backend (`github.com/Rainexn0b/keyRGB`, `src/core/backends/ite8233/`) — note its backend is a *scaffold* that (a) sent the command byte as a report-id via `HIDIOCSFEATURE` and (b) targeted the wrong interface, so the tool itself doesn't work as-is; only its command-byte table was right. The working transport was lifted from `ite8291r3-ctl`.

### Still open (optional polish, not blocking)

- **Persistence across reboot:** the EC resets to breathing-purple on boot. To keep a chosen look, run `lightbar` from a login hook (sway `exec`, a systemd user service, or `@reboot`). The 6th apply byte has an alternate value `0x08` that might be "save to EC" — untested; worth checking if you want it to survive a reboot without a hook.
- **Direction (`-d` / `DD` byte) semantics:** accepted across 0–2 but the exact mapping (scroll direction) wasn't characterised — tweak and see. (Speed is now characterised — `-s 1` fast, `-s 10` slow.)

---

## Rear Medion logo LED — hardwired, not controllable (researched 2026-05-27)

Separate from the front bar: the illuminated **Medion logo on the back of the lid** is a **fixed single-colour blue LED** (blue filter over a white/blue LED), lit whenever the laptop is powered. Testing showed it does **not** follow the LCD backlight (`brightnessctl set 0`) or panel power (DPMS off) — it's on the **system-power rail**, i.e. a dedicated always-on indicator, not the screen-spillover type.

**Conclusion: there is no software/BIOS control for it, on Linux or Windows.** Confirmed by a wide search:
- The in-tree `uniwill-laptop` driver registers exactly **one** LED (`uniwill:multicolor:status`, the front bar) and no logo/lid device. `tuxedo-drivers` has zero `logo`/`lid`/`badge` matches. The only Linux kernel drivers with a real lid-logo LED are for **Fujitsu** (`logolamp`) and **Lenovo ThinkPad** (`tpacpi::lid_logo_dot`) — not Uniwill/Tongfang.
- The Medion Beast 16 X1 manual + reviews list only keyboard + front bar as adjustable; the logo is described as a fixed blue badge.
- No ITE-controller project (ite8291r3-ctl, keyRGB, TongFangRGB, tongfang-control, ITE 8910 RE) has ever found a logo zone.
- Community consensus: Medion/Tongfang lid logos are hardwired; only physical removal (unplug the LED ribbon in a teardown, or an opaque skin) turns them off.

### Potential future lead (untried, low priority)

The upstream `uniwill-laptop` source (`drivers/platform/x86/uniwill/uniwill-acpi.c`) defines a constant **`#define RGB_LOGO_EFFECT BIT(6)`** in the EC `EC_ADDR_TRIGGER` register map — but it is **defined and never referenced** (dead code). It hints the Uniwill EC firmware *may* have a logo-effect bit nobody has wired up. If we ever want to chase it:
- Reinstall `acpi-call` (MOK already enrolled), find `EC_ADDR_TRIGGER`'s offset in the uniwill source, and try toggling bit `0x40` there via the `\_SB.AMW0.WMBC` method.
- Caveats: our earlier EC-RAM poking on this chassis showed that channel doesn't reach the real lightbar control registers (writes landed on dead scratchpad), so this may be inert too; and a wrong EC write can hang the controller. Low payoff (one blue LED) for real risk — only worth it as a curiosity.

---

## Appendix — the reverse-engineering trail (historical)

Kept for reference; all of this is **superseded by the SOLVED section above**. The bar runs breathing-purple from boot, driven entirely by the EC/firmware (it shows before any OS boots), which sent the search down several wrong paths before the ITE 8233 HID channel turned out to be the answer.

**Chassis context.** DMI family `Beast`, product `ERAZER 16 X1`, SKU `ML-210015 30039609`, board `X6ARxxxY-W`. ASUS-OEM'd firmware (ASUS-style `AMW0`/`AWMI` WMI block, an `EC0` device with KBC command/data fields).

**Ruled out, in order:**

- **ITE 8291 keyboard controller (`048d:600b`).** Drives the 6×21 key matrix only. `monocolor`, `set_key_colors` (full matrix + gradients), all built-in effects, probing "extra" row indices 6–15, and a `0x80`..`0xFF` GET-opcode sweep — none moved the strip. (`0x87` returns a hardcoded `FF 00 FF` that *looks* like the breathing purple but is coincidence, not the live colour.)
- **ACPI/WMI.** DSDT + all SSDTs disassembled (`iasl -d`) and grepped for `light`/`lbar`/`aura`/`rgb`/`strip`/`beast`/`medion`/`erazer`/`tongfang`/`clevo` — no match anywhere. The WMI devices (`AWMI`, `AMW0`, `WFDE`, `WFTE`) expose only keyboard brightness and a generic EC pass-through; `AMW0.WMBC`'s `OEMG`/`SAC1` dispatch has no lightbar branch. The 64 EC `_Qxx` handlers are all lid/brightness/AC/thermal/CPPC events.
- **OpenRGB 0.9** detected only the external Logitech G203 mouse.

**The Uniwill / EC-offset detour (the big wrong turn).** Tuxedo's `tuxedo-drivers` source pointed at a Uniwill-platform lightbar at EC offsets `0x0748–0x074B`, writable via the `\_SB.AMW0.WMBC` method-4 (`WKBC`/`RKBC`) pass-through. We installed `acpi-call-dkms` (MOK-enrolled for Secure Boot) and proved the read/write path works end-to-end (`0xAA`→`0x0749`→reads back `0xAA`) — but:

- `0x0748–0x074B` are **dead scratchpad** on this chassis: writes land, strip unaffected.
- The breathing colour is *mirrored* at `0x0701/0x0703`, but writing there does nothing — the EC animation engine overwrites it faster than the writes land.
- A full EC-RAM scan `0x0000–0x0FFF` found **no** other RGB-shaped control register — only config/thermal/ROM-ID data. The strip's source data isn't in WMI-reachable EC RAM.
- On kernel 7.0 (Ubuntu 26.04) the in-tree **`uniwill-laptop`** driver binds with `modprobe uniwill_laptop force=1` and creates `/sys/class/leds/uniwill:multicolor:status` + a `rainbow_animation` toggle — but a write-and-read-back test proved it just scribbles those same dead offsets: sysfs retains the values, strip never moves. Right device family, wrong transport for this chassis.

**The pivot that worked.** The Windows app showed a *per-LED scrolling rainbow* → a packet-based controller, not a single-zone register. A scan of every host I²C/SMBus bus (i2c-0..10) found only sensors, DDR5 SPD, and the touchpad — so the controller hangs off the EC and is commanded over the **ITE 8233 USB HID** (`048d:7001`), the one interface that had never been probed. Modelling the probe on the working ITE 8291 transport + keyRGB's command bytes cracked it on the first hit — see SOLVED above.

**Tooling installed during the investigation:** `acpica-tools` (iasl), `acpi-call-dkms` (`/proc/acpi/call`, module signed with the local MOK at `/var/lib/shim-signed/mok/MOK.der`), `i2c-tools`, `python3-usb`.
