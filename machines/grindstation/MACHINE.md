# MACHINE.md

Hardware inventory for `grindstation`, collected 2026-05-18.

## System

| | |
|---|---|
| Vendor / Model | Medion **ERAZER 16 X1** (chassis type 10 = Notebook) |
| Mainboard | Medion `X6ARxxxY-W` |
| BIOS | AMI `N.1.17MED16`, dated 2025-07-17 |
| Hostname | `grindstation` |
| OS | Ubuntu 25.10 "Questing Quokka" |
| Kernel | `6.17.0-29-generic` (x86_64) |

The "Medion Erazer 16-inch with a 5090" story checks out — both the chassis label and the internal eDP-1 panel size confirm the form factor, and the RTX 5090 (Max-Q / Mobile variant) is present on the PCI bus.

## CPU

**Intel Core Ultra 9 275HX** (Arrow Lake-HX, family 6, model 198, stepping 2)

- 24 cores / **24 threads** — Arrow Lake disables SMT, so this is 8 P-cores + 16 E-cores with one thread each
- Max turbo 5.4 GHz, base 800 MHz min
- L1d 768 KiB · L1i 1.3 MiB · L2 40 MiB · L3 36 MiB
- Driver / governor: `intel_pstate` / `powersave`
- VT-x available; eIBRS + IBPB mitigations enabled

## GPUs

| Slot | Device | Driver in use |
|---|---|---|
| `00:02.0` | Intel Arrow Lake-S iGPU `[8086:7d67]` | `i915` |
| `02:00.0` | **NVIDIA GB203M — GeForce RTX 5090 Laptop GPU** `[10de:2c18]` | **`nvidia`** (proprietary, 595.58.03-open) |

The 5090 is on the proprietary stack as of 2026-05-19: driver `595.58.03`, CUDA runtime 13.2, **24 GiB GDDR7**, max core clock 3090 MHz / mem 14001 MHz, TGP cap **175 W**, link **PCIe Gen 5 ×16**, VBIOS `98.03.5E.00.5D`. Vulkan exposes both GPUs (`vulkaninfo --summary`); OpenGL defaults to the iGPU, so the dGPU needs explicit PRIME offload:

```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <command>
```

Quick sanity check: `glmark2 --off-screen` scores ~3,980 on the iGPU vs **~51,684** on the 5090 via the PRIME-offload env (mostly API-bound at that point — glmark2 is too small to actually load Blackwell). Idle draw is ~10 W at 39 °C.

Audio devices attached: NVIDIA HDMI audio `02:00.1`, Intel HDA `80:1f.3`.

## Memory

- **30 GiB** usable RAM reported by the kernel (≈32 GiB installed; firmware-reserved overhead accounts for the gap)
- 8 GiB swap (currently 0 used)
- DIMM-level details (modules, speed, part numbers) need `sudo dmidecode -t memory` — not available without elevated privileges

## Storage

Single NVMe SSD, encrypted root:

```
nvme0n1                       1.9T  E31-2TB-PHISON-SSD-BICS8WL
├─nvme0n1p1                     1G  /boot/efi (vfat)
├─nvme0n1p2                     2G  /boot     (ext4)
└─nvme0n1p3                   1.9T  LUKS → LVM (ubuntu-vg / ubuntu-lv) → / (ext4)
```

Root filesystem: 1.8 TiB free of 1.9 TiB (1% used).

## Networking

| Interface | Type | State |
|---|---|---|
| `wlp128s20f3` | Intel **AX211** Wi-Fi (CNVi, Arrow Lake-S PCH) | UP — `172.23.9.127/24` |
| `enp131s0` | Realtek **RTL8125** 2.5 GbE | DOWN (no cable) |
| (USB) | Intel AX211 Bluetooth `8087:0033` | present |

## Display

- Internal panel `eDP-1` at **3840 × 2400** (16:10, matches the 16" Erazer spec)
- No external monitors connected

## Power / Battery

- Battery `BAT0`: Li-ion, 6.4 Ah design capacity, OEM "standard"
- Status at collection time: **Charging, 69%**
- AC adapter `AC0` present

## Attached USB peripherals

- Logitech **G102/G203 LIGHTSYNC** gaming mouse (`046d:c092`)
- **Keychron V6** keyboard (`3434:0363`)
- Kingcome FHD WebCam (`2b7e:c906`, integrated)
- ITE 8233 / 8291 devices (`048d:7001`, `048d:600b`) — internal keyboard / RGB controller
- Genesys Logic USB hubs (internal)

## RGB lighting

Four independent RGB systems are present on this setup. They live on completely separate control stacks — there is **no** unified Linux tool that drives all of them.

DMI reports the chassis family as "**Beast**" (SKU `ML-210015 30039609`) — i.e. this is the Erazer Beast 16 X1, which has both the keyboard backlight and a front "Beast Light Bar".

### 1. Laptop keyboard backlight — ITE 8291  ✅ working

Internal USB device:

```
ITE Device(8291)   USB 048d:600b   rev 0.03   firmware 34.3.0.0
                                  →  /dev/hidraw4 + /dev/bus/usb/003/006
```

Not exposed under `/sys/class/leds`, so standard desktop brightness controls do nothing. The kernel binds it to `hid-generic` only; control is via vendor HID feature reports written from userspace. A sibling chip, **ITE 8233** (`048d:7001`, `/dev/hidraw1`), is the keyboard's HID/hotkey interface and handles the Fn-combo built-in effect cycling when no software is driving it.

Verified controllable end-to-end via [`ite8291r3-ctl`](https://github.com/pobrn/ite8291r3-ctl), installed at `/home/wam/.local/bin/ite8291r3-ctl` (pipx venv at `~/.local/share/pipx/venvs/ite8291r3-ctl/`).

**Two local modifications were needed to make it work:**

1. **Udev rule** at `/etc/udev/rules.d/99-ite8291.rules`:
   ```
   SUBSYSTEM=="usb", ATTRS{idVendor}=="048d", ATTRS{idProduct}=="600b", MODE="0666"
   ```
   (After install, `sudo udevadm control --reload && sudo udevadm trigger`.) Lets the tool talk to the device without sudo.

2. **PID patch** to the installed library — upstream `ite8291r3-ctl 0.4` only knows PIDs `0x6004, 0x6006, 0xCE00`; our device is `0x600B`. Patched in:
   `~/.local/share/pipx/venvs/ite8291r3-ctl/lib/python3.13/site-packages/ite8291r3_ctl/ite8291r3.py`, line 9 — added `0x600B` to `PRODUCT_IDS`. **A `pipx upgrade` or `pipx reinstall` will revert this and the tool will stop working.** Until upstream merges the new PID, either skip upgrades or re-apply the patch.

**Quick reference**:

```bash
ite8291r3-ctl query --fw-version          # firmware version
ite8291r3-ctl query --brightness          # current brightness 0..50
ite8291r3-ctl monocolor --rgb 255,0,255 -b 30   # solid color
ite8291r3-ctl effect rainbow -b 30        # built-in effect
ite8291r3-ctl off                         # turn off
```

**Keyboard matrix** (empirically mapped, useful for `anim` per-cell scripts): 6 rows × 21 columns. Cols **0–15** are the main keyboard area, cols **16–20** are the numpad block plus the down-arrow. (Confirmed by lighting cols 16–20 green and watching the numpad / down-arrow change.)

### 2. Front "Beast Light Bar" — ITE 8233, controllable  ✅ working (since 2026-05-27)

The front strip is the **ITE 8233** (`048d:7001`, interface 1), driven by 8-byte HID feature reports over a USB control `SET_REPORT` — the same transport as the ITE 8291 keyboard. Control it with **`sudo lightbar color R G B [-b 0..100]`** / `sudo lightbar off`. Full protocol, transport, and the year-long reverse-engineering trail are in **LIGHT-BAR.md** (see the SOLVED section at the top).

It is **not** on the ITE 8291 keyboard controller (setting the keyboard to solid green leaves the strip unchanged), not on any host I²C/SMBus, and the `uniwill-laptop` kernel driver binds but writes to dead EC offsets — see LIGHT-BAR.md for why each of those dead-ended.

What it is *not*:
- Not a separate USB device — `lsusb` lists nothing else with RGB-capable interfaces.
- Not on the ITE 8291 matrix — every (row,col) in the 6×21 matrix has been accounted for (16×6 main keys + 5×6 numpad area).
- Not exposed under `/sys/class/leds`.
- Not detected by OpenRGB 0.9 (only the Logitech mouse is recognized as RGB).
- No kernel module mentions a "lightbar" / "lbar" / "aura" / "lightstrip" in `dmesg`.

What it most likely *is*: an ACPI/WMI-controlled LED zone driven through the embedded controller (the ITE 8233). Windows had a working pattern, so the firmware-level interface exists — it's just that no public Linux driver implements it for the Erazer Beast platform yet. `asus_wmi` loads but binds to no LED interface (chassis isn't actually ASUS), and no dedicated `medion-*` / `erazer-*` kernel module exists.

**Status: cannot be controlled from Linux today without reverse engineering.** Practical paths if it matters:

- Dump and disassemble the DSDT (`sudo cp /sys/firmware/acpi/tables/DSDT /tmp/dsdt.aml && iasl -d /tmp/dsdt.aml`) and look for WMI methods or EC writes that touch a light-bar register.
- Run Wireshark/USBPcap on Windows, capture lighting changes from the vendor app, replicate the byte stream against `/dev/hidraw1` (the ITE 8233) on Linux.
- Watch [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) issues / `tuxedo-drivers` for upstream support of the Erazer Beast / Tongfang platform variant.

### 3. Logitech G203 LIGHTSYNC mouse  ✅ host-independent

```
Logitech G203   USB 046d:c092   →  /dev/hidraw2, /dev/hidraw3
```

Single RGB zone (palm). Detected by OpenRGB out of the box (modes: Off / Static / Cycle / Breathing / Wave / Colormixing). Also controllable via **[libratbag](https://github.com/libratbag/libratbag)** + the **Piper** GUI (`sudo apt install piper`). Settings persist on the mouse itself.

### 4. Keychron V6 keyboard  ✅ host-independent

```
Keychron V6   USB 3434:0363   →  /dev/hidraw5,6,7
```

Per-key RGB driven by the keyboard's **QMK/VIA firmware** — the laptop only sees it as a normal HID keyboard. Configure via **[VIA](https://usevia.app/)** in a browser (WebHID) or VIAL. No daemon needed.

### Quick "what changes RGB" reference

| Lighting | Control today | Notes |
|---|---|---|
| Laptop keyboard | `ite8291r3-ctl` (installed, working) | PID patch + udev rule applied |
| Front Beast Light Bar | `sudo lightbar …` (installed, working) | ITE 8233 HID; static colour + brightness + off. See LIGHT-BAR.md |
| G203 mouse | OpenRGB *or* Piper | Settings stored on mouse |
| Keychron V6 | VIA / VIAL (browser) | Settings stored on keyboard |

## Keyboard quirks (firmware / hotkeys)

- **Windows key is firmware-lockable.** `Fn+F2` toggles the Super/Win key on and off at the keyboard firmware level — when off, the key produces **no event at all** (not even visible in `wev`/`evtest`). This is a "gaming" feature on the Erazer chassis to prevent accidental Win presses mid-game. If sway/i3 mod bindings suddenly stop working but `swaymsg workspace number 2` still does, the Win key is locked — press `Fn+F2`. Has bitten this machine once (2026-05-20).
- **Function row defaults** (Fn+Fn): F1 sleep · F2 Win-lock · F3 display mirror · F4 airplane mode · F5 trackpad disable · F6/F7 keyboard backlight · F8 mute · F9/F10 volume · F11/F12 brightness · ScrLk camera enable/disable.

## Things worth following up on

1. **Memory module detail** is unknown without `sudo`. Re-run `sudo dmidecode -t memory` if module speed / vendor matters.
2. **lm-sensors not configured** — no temperature readings available. Run `sudo sensors-detect` to enable.
3. The CPU is parked on the `powersave` governor; for sustained workloads consider `performance` (`sudo cpupower frequency-set -g performance`).
4. **Front Beast Light Bar is solved** (2026-05-27) — ITE 8233 HID, `sudo lightbar`. Remaining: hardware effects (rainbow/breathing) and rootless use. See LIGHT-BAR.md "Still open".
5. **`ite8291r3-ctl` PID patch is fragile** — any `pipx upgrade ite8291r3-ctl` reverts the local edit that added PID `0x600B` and the keyboard will stop responding. Either pin the version or maintain a local fork.
6. **No CUDA toolkit installed**, only the driver. `nvcc`, CUDA samples, and PyTorch are absent — install `nvidia-cuda-toolkit` or `pip install torch` if you want to actually run compute on the 5090.
