# MACHINE.md

Hardware inventory for `overtime`, collected 2026-09-25.

## System

| | |
|---|---|
| Vendor / Model | Lenovo **ThinkPad X1 Carbon Gen 9** (chassis type 10 = Notebook) |
| Machine type | `20XW` — product `20XW004YUK` (UK SKU) |
| Mainboard | Lenovo `20XW004YUK` |
| BIOS | Lenovo `N32ET84W (1.60)`, dated 2025-04-05 (firmware ~3.5 yr old) |
| Hostname | `overtime` |
| OS | Ubuntu 26.04.1 LTS |
| Kernel | `7.0.0-34-generic` (x86_64) |
| Desktop | **sway** (Wayland) — same shared config + unified Aged Brass theme as every host |

This is the classic 14" ThinkPad X1 Carbon (Tiger Lake generation) — Intel-only
graphics, no discrete GPU. It runs the **same sway/wlroots setup and unified
theme as `grindstation`** (both come from the shared stow tree at the repo root).
What differs is only the hardware: overtime has none of grindstation's RGB
keyboard, front light bar, or NVIDIA GPU, so those *hardware* docs (COLOUR /
LIGHT-BAR / SCREEN) have no counterpart here — but the theme (THEMES.md) is
shared, not host-specific.

At the time of collection the machine was still on GDM/GNOME (the stock Ubuntu
install); sway is the intended daily driver via the shared config.

## CPU

**11th Gen Intel Core i5-1135G7** (Tiger Lake-LP, family 6, model 140, stepping 1)

- 4 cores / **8 threads** (SMT enabled: 4 cores × 2 threads)
- Max turbo 4.2 GHz, base 2.4 GHz, min 400 MHz
- L1d 192 KiB · L1i 128 KiB · L2 5 MiB · L3 8 MiB
- Driver / governor: `intel_pstate` / `powersave`
- VT-x available; enhanced IBRS + IBPB mitigations enabled
- AVX-512 present (Tiger Lake still shipped it): `avx512f/dq/bw/vl/vnni/vbmi/vbmi2` etc.

**Mitigation note:** `gather_data_sampling` reports **Vulnerable** on this
kernel/microcode; everything else is mitigated or Not affected. A microcode
update (`intel-microcode`) or newer kernel would be the fix if GDS matters.

## GPU

| Slot | Device | Driver in use |
|---|---|---|
| `00:02.0` | Intel **TigerLake-LP GT2 [Iris Xe Graphics]** `[8086:9a49]` (rev 01) | `i915` |

Single integrated GPU — no discrete/NVIDIA card, so no PRIME offload and none of
the hybrid-wiring / cursor-plane trouble that dogs grindstation. Subsystem is
Lenovo `[17aa:22d5]`. The `xe` kernel module is also present (`i915, xe` listed)
but `i915` is the driver in use.

## Memory

- **~14 GiB** usable RAM (`MemTotal` 15,560,376 kB ≈ 16 GiB installed LPDDR4x,
  minus firmware/iGPU-reserved overhead)
- 4 GiB swap
- RAM is **soldered LPDDR4x** on this chassis — not upgradable. DIMM-level detail
  (`sudo dmidecode -t memory`) needs elevated privileges and was not collected.

## Storage

Single NVMe SSD, encrypted root:

```
nvme0n1                       477G  SAMSUNG MZVL2512HCJQ-00BL7 (PM9A1, 512 GB) fw EL2QGXA7
├─nvme0n1p1                     1G  /boot/efi (vfat)
├─nvme0n1p2                     2G  /boot     (ext4)
└─nvme0n1p3                   474G  LUKS → LVM (ubuntu-vg / ubuntu-lv) → / (ext4)
```

Root filesystem: **406 GiB free of 466 GiB (9% used)**. Same LUKS→LVM→ext4 layout
as grindstation.

**`/tmp` is on disk, not RAM.** Ubuntu's stock `tmp.mount` (a tmpfs capped at
half the RAM, with per-user quotas) is masked (`sudo systemctl mask tmp.mount`),
so `/tmp` is a plain folder on the root filesystem. Large builds and agent
scratch files filled the tmpfs quota and broke tools mid-run. systemd still
deletes files in `/tmp` that have gone unused for 10 days; it no longer empties
on reboot. Undo: `sudo systemctl unmask tmp.mount` and reboot.

## Networking

| Interface | Type | State |
|---|---|---|
| `wlp0s20f3` | Intel **Wi-Fi 6 AX201** (CNVi) `[8086:a0f0]`, `iwlwifi` | UP — `10.3.5.151/24` |
| `wwan0` | Quectel **EM120R-GL** LTE-A WWAN modem (ModemManager sees it) | DOWN (no SIM/connection) |
| `tailscale0` | Tailscale WireGuard tunnel | UP — `100.79.132.22` |
| `docker0` | Docker bridge | DOWN |
| (USB) | Intel **AX201 Bluetooth** `8087:0026` | present |

At collection time the AX201 was associated to SSID **`AntareEng`** on 5 GHz
(5180 MHz), signal −40 dBm, Wi-Fi 6 (HE), rx ~459 Mbit/s. The **WWAN** slot is
populated (Quectel EM120R-GL) — usable via ModemManager once a SIM is inserted.

## Display

- Internal panel `eDP-1`, **AUO** (PNP `AUO`, product `0xd291`), at **1920 × 1200**
  (16:10, the 14" X1 Carbon Gen 9 WUXGA panel)
- No external monitors connected at collection time
- Two **Thunderbolt 4** domains present (`domain0` + `domain1`) — full USB-C/TB4
  docking is available (external displays would attach through these)

## Power / Battery

- Battery `BAT0`: SMP `5B10W13973`, Li-polymer
- Design capacity **57.05 Wh**, current full charge **47.57 Wh** → **~83% health**
- Cycle count **150**
- Status at collection time: **pending-charge, 80%**
- Dual USB-C Power Delivery: two UCSI source ports (`USBC000:001`, `USBC000:002`);
  one was actively charging

## Thermals

`lm-sensors` **is** configured here (`coretemp-isa-0000`):

- Package ~78 °C, cores 75–78 °C at collection time (light load, fans spun up)
- **Two fans** reporting ~6,578 RPM each
- ACPI/x86_pkg thermal zones present (`x86_pkg_temp` ~82 °C, `SEN1/2/5`, `TCPU`,
  `iwlwifi_1` ~40 °C)

## Attached USB peripherals

- Synaptics **Prometheus Fingerprint Reader** (`06cb:00fc`) — power-button/side reader
- Syntek **Integrated Camera** (`174f:2454`)
- Intel **AX201 Bluetooth** (`8087:0026`)
- (WWAN modem enumerates via the CNVi/USB stack; internal)

No external RGB peripherals, keyboards, or mice were attached (this machine has
none of grindstation's RGB stack — the ThinkPad backlight is a plain 2-level
white keyboard light, not an addressable device).

## Keyboard notes

Standard ThinkPad layout. The keyboard backlight is a simple two-level white
light toggled with **Fn+Space** at the firmware/EC level (exposed under
`/sys/class/leds` as a `platform::kbd_backlight`, driven by the
`thinkpad_acpi` module) — nothing like grindstation's per-key ITE RGB matrix.

## Things worth following up on

1. **`gather_data_sampling` is Vulnerable** — update `intel-microcode` and/or move
   to a newer kernel if the GDS mitigation matters for this machine's workload.
2. **Memory module detail** is unknown without `sudo`. RAM is soldered, so this is
   informational only — run `sudo dmidecode -t memory` if speed/rank matters.
3. **BIOS is ~3.5 years old** (`1.60`, 2025-04-05). `fwupdmgr get-updates` (LVFS)
   would show whether a newer Lenovo UEFI is available.
4. **WWAN is present but idle** — Quectel EM120R-GL. Insert a SIM and use
   ModemManager / GNOME's mobile-broadband settings to bring `wwan0` up.
5. **Battery at ~83% health** after 150 cycles — normal wear; no action needed,
   noted for baseline.
