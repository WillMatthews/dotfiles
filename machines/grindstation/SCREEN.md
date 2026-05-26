# SCREEN.md

Investigation log for the eDP cursor stutter on **grindstation**. Started
2026-05-21, two-day debugging session. Not solved; this is the dossier
for whoever picks it back up.

## Hardware in play

See [MACHINE.md](MACHINE.md) for full inventory. The relevant facts:

- **Internal panel**: `eDP-2`, BOE NE160QDM-NM9, 16" 16:10, advertises
  `2560x1600 @ 60.001 / 240 / 300 Hz` (300 Hz requires DSC).
- **External monitor in test**: `HDMI-A-1`, MSI MAG 274QRFW, `2560x1440 @ 60 Hz`.
- **Hybrid GPU wiring (counterintuitive)**:
  - `card1 → nvidia` drives **HDMI-A-1** (RTX 5090 Laptop)
  - `card2 → i915` drives **eDP-2** (Arrow Lake-HX iGPU `[8086:7d67]`)
  - Verified via `/sys/class/drm/card*/device/driver`.

So the laptop screen runs through the **Intel** iGPU, not NVIDIA. HDMI
audio attaches to the 5090 (PCI `02:00.1`) and corroborates the wiring.

## Symptom

Cursor on **eDP-2** visibly stutters — freezes for fractions of a second,
several times per second. **Only the cursor**, not whole-screen content.
**Only on the laptop panel** — HDMI is butter-smooth in the same session.
Most severe at the panel's preferred mode (`2560x1600 @ 300 Hz`); reduces
or disappears at `2560x1600 @ 60 Hz`.

Accompanying signature in the journal:

```
wlr:  [backend/drm/drm.c:1129]   Failed to pick cursor plane format
wlr:  [backend/drm/atomic.c:81]  connector eDP-2: Atomic commit failed: Device or resource busy
sway: [desktop/output.c:300]     Page-flip failed on output eDP-2
```

Sway sits at 20–35% CPU at idle while these errors fire (cursor-move
retries in a tight loop). nvidia-smi shows the dGPU pinned at `pstate=P5`
~35 W instead of dropping to `P8` ~10 W.

## Root cause (current best understanding)

`wlroots` cannot negotiate a hardware cursor plane format on the eDP-2
output regardless of which kernel driver or which renderer is in use.
The cursor plane on this panel advertises a format / modifier set
(probably DRM modifiers for tiled/compressed framebuffers) that
wlroots's cursor-plane format picker rejects. wlroots then falls back
to software cursor, every cursor move triggers a full-framebuffer
atomic commit, and at 300 Hz the commit pipeline saturates → cursor
freezes.

Confirmed 2026-05-22 that this is **not** specific to one component:

- Same `Failed to pick cursor plane format` errors fire on **both `i915`
  and `xe`** kernel drivers.
- Same errors fire on **both GLES2 and Vulkan** wlroots renderers.
- **Mutter** (the GDM greeter on the same machine, same panel, same
  mode) handles it cleanly. So the panel itself is fine; this is
  squarely a wlroots-side format-negotiation limitation.

The asymmetry between eDP and HDMI is fully explained by the wiring:
HDMI's commits flow through NVIDIA, which has no cursor-plane format
issues here.

### Leading hypothesis: Panel Self Refresh (PSR)

Strongly suggested by research on 2026-05-22:
**[Launchpad bug #2103981](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/2103981)**
reports cursor "flashing/vanishing" on Lunar Lake (same `xe` driver
family as Arrow Lake) traced to PSR interactions; **fixed in kernel
6.14**, but the documented workaround until that lands is the kernel
cmdline arg **`xe.enable_psr=0`**. PSR is the eDP power-saving feature
where the panel caches its own framebuffer; high-frequency cursor
commits interact badly with PSR state transitions and can cause exactly
the saturation pattern observed here. Mutter being fine is consistent
with PSR-aware frame scheduling. **First thing to try next session.**

## What was tried

### 1. `WLR_NO_HARDWARE_CURSORS=1`  →  worked at low refresh, broke at 300 Hz

Forces wlroots to render the cursor into the main framebuffer instead of
using a hardware cursor plane. Bypasses the broken plane.

- At **60 Hz**: smooth cursor, page-flip failure rate drops by ~30× to
  ~1/sec (and those happen on `vblank` cadence, below perception).
- At **300 Hz**: software cursor commits a full `2560x1600` framebuffer
  on every cursor-move event. With a 1000 Hz mouse polling rate, that's
  >3 commits per frame. Kernel commit pipeline saturates, most cursor
  commits are rejected as `EBUSY`. Cursor visibly lags input even though
  screen content stays smooth.

Conclusion: useful as a "make 60 Hz usable" workaround, **not a fix for
the 300 Hz target**.

### 2. `WLR_DRM_NO_MODIFIERS=1`  →  BLACK SCREEN AT LOGIN, do not re-enable blindly

Hypothesis: telling wlroots to use only linear (non-modified) framebuffer
formats would let the i915 cursor plane format-picker succeed, restoring
hardware cursor and freeing the commit pipeline at any refresh.

In practice it produced a **black screen at the GDM-launched sway
session**. wlroots's renderer fell over with:

```
wlr:  render/gles2/renderer.c:114      Failed to create FBO
wlr:  backend/drm/renderer.c:121       Failed to begin render pass with multi-GPU destination buffer
sway: config/output.c:936              Backend commit failed
```

i.e. wlroots couldn't build the cross-GPU buffer hand-off needed to
composite for HDMI (NVIDIA) from a buffer rendered on Intel without
modifiers. NVIDIA's GBM probably won't accept linear-only allocations
for the scanout buffer it needs to import.

**Recovery procedure (verified):**

1. `Ctrl+Alt+F3` to a TTY.
2. Edit `~/.config/environment.d/wlr.conf`, comment out the
   `WLR_DRM_NO_MODIFIERS=1` line, restore `WLR_NO_HARDWARE_CURSORS=1`.
3. Switch back to graphical TTY (`Ctrl+Alt+F1`) and log into sway.

Do not re-enable `WLR_DRM_NO_MODIFIERS` on this machine without first
either (a) switching to a driver/compositor that doesn't trip this code
path or (b) accepting you'll be debugging from a TTY again.

### 3. Lower refresh via `swaymsg output eDP-2 mode 2560x1600@60.001Hz`  →  works as a relief valve

Reversible runtime change. Doesn't persist across logins because
`wdisplays` writes nothing to disk. Useful as an emergency knob; not a
long-term solution.

### 4. DPMS off→on toggle (`swaymsg output eDP-2 dpms off/on`)  →  occasional last-resort tool

Used 2026-05-21 when the eDP panel went dark after a lock/unlock cycle
and didn't come back. Outcome: kernel WARN
`i915: pipe_off wait timed out` in
`intel_disable_transcoder+0x350/0x400`, but sway and HDMI both survived
the toggle. Whether the panel relit was unverified at the time. Worth
remembering as a try-before-rebooting option for the same failure mode.

### 5. iGPU driver switch `i915 → xe` (2026-05-22)  →  partial improvement, did NOT fix

Persisted by appending to `GRUB_CMDLINE_LINUX_DEFAULT` in
`/etc/default/grub`:

```
i915.force_probe=!7d67 xe.force_probe=7d67
```

Then `sudo update-grub` and reboot. Verify via
`lspci -nnk -s 00:02.0` (should show `Kernel driver in use: xe`).

Result: page-flip failure rate at 300 Hz dropped ~60% (32/min → 13/min),
sway idle CPU dropped (~30% → ~17%), HDMI auto-negotiated 144 Hz instead
of 60 Hz. **But the wlroots cursor-plane format-picker still fails**
with the identical journal signature, so the cursor-stutter symptom
persists, just less severely. Keep `xe` regardless — it's a strict
improvement, and the kernel cmdline edit also adds the **GRUB menu
visibility** change (`GRUB_TIMEOUT_STYLE=menu`, `GRUB_TIMEOUT=5`) made
in the same session so future cmdline edits are reachable via the
GRUB menu (hold Shift on boot).

### 6. `WLR_RENDERER=vulkan` (2026-05-22)  →  largest perceived improvement, still not a fix

Hypothesis was that Vulkan's cursor-format support might intersect with
what the cursor plane offers where GLES2's doesn't. Both GPUs expose
Vulkan 1.4 and libwlroots-0.19 is linked against libvulkan.

Result: cursor "stutter" perception is **largely gone**, but
`Failed to pick cursor plane format` errors still fire (in fact more
often than under GLES2 — ~278/min vs prior rates). Hardware cursor is
still **not** engaged; what changed is that Vulkan renders the software
cursor sprite fast enough that most commits succeed before the pipeline
saturates. Atomic-commit failures still occur ~34/min on eDP-2, felt
as occasional brief freezes. GPU utilisation goes up materially
(~25 % on NVIDIA at idle vs near-zero before, P8 retained but doing
real work) because Vulkan is genuinely rendering the cursor each move.

Net: traded constant lag for occasional freezes plus higher idle GPU
draw. Improvement on every axis except battery life, but not the
end-state we want.

## Adjacent issues observed (not yet investigated)

These showed up during the same debugging session. Probably symptoms of
the same Arrow Lake i915 brokenness, but each is a separate thread.

### Multi-GPU FBO failure  (transient, recovered on its own)

Once on 2026-05-22 after a hard power-cycle, sway booted into the
`Failed to create FBO` / `multi-GPU destination buffer` error pattern
above and landed at a black screen, **without** the
`WLR_DRM_NO_MODIFIERS` change. Resolved without intervention after the
stale GDM sessions cleared and a fresh login was attempted. So: not
purely a config bug — also a transient hardware/driver state issue.
Worth checking `loginctl list-sessions` for stale entries if this
recurs.

### i915 link-training failures on lock/unlock

Observed 2026-05-21 after locking + unlocking with swaylock:

```
i915 0000:00:02.0: [drm] *ERROR* Failed to bring PHY A to idle
i915 0000:00:02.0: [drm] *ERROR* PHY A Read/Write 0c70 failed after 3 retries
i915 0000:00:02.0: [drm] *ERROR* Timeout waiting for DDI BUF A to get active
i915 0000:00:02.0: [drm] *ERROR* Timed out waiting for DP idle patterns
WARNING ... vblank wait timed out on crtc 0/1
  intel_dp_retrain_link → intel_modeset_commit_pipes → ...
```

i.e. the DisplayPort PHY couldn't be brought out of idle on resume from
DPMS-off, so the link couldn't be retrained, and the panel stayed dark
while wlroots still thought it was on (`active=true, dpms=on`). This is
separate from the cursor issue but lives in the same i915 corner of
hell on Arrow Lake.

### NVRM platform-handler assertions (low priority)

```
NVRM: GPU0 nvAssertOkFailedNoLog: ... failed to get target temp from SBIOS
NVRM: GPU0 nvAssertOkFailedNoLog: ... failed to get platform power mode from SBIOS
```

NVIDIA's PlatformRequestHandler can't query SBIOS for thermal / power
mode. Probably affects dynamic clock decisions, doesn't obviously break
rendering. File and forget unless thermals look wrong.

### wdisplays doesn't persist

By design — wdisplays only calls `swaymsg output ...` for the current
session. Any output config we want to survive logins has to go in
`~/.config/sway/config` directly, or be managed by **kanshi**
(per-output-arrangement daemon). Not yet set up.

## Open threads (paths not yet explored)

In order of expected payoff, after the 2026-05-22 research dump:

1. **Disable PSR** — kernel cmdline `xe.enable_psr=0`. The leading
   hypothesis (see "Root cause" section). Edit
   `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`, add
   `xe.enable_psr=0`, `sudo update-grub`, reboot. Recovery via GRUB
   menu (Shift on boot, `e` to edit, remove the arg). Single param,
   single reboot, fully reversible.

2. **`WLR_SCENE_DISABLE_DIRECT_SCANOUT=1`** (or equivalently
   `sway -Dnoscanout` at the sway invocation) — skips direct-scanout
   commits. Directly targets pipeline saturation during the software-
   cursor fallback regardless of why hw cursor isn't engaging. Pure
   env-var change, no reboot.

3. **`WLR_DRM_DEVICES=<intel>:<nvidia>`** — pin Intel iGPU primary
   explicitly, then retry `WLR_DRM_NO_MODIFIERS=1`. The
   `WLR_DRM_NO_MODIFIERS` failure may have been about device ordering
   rather than the modifier setting itself. Use full DRM device paths
   (`/dev/dri/card1`, `/dev/dri/card2` — note the wiring section
   above).

4. **wdisplays output-reconfigure trick** —
   [swaywm/sway #7194](https://github.com/swaywm/sway/issues/7194) was
   closed with: "open wdisplays, change something trivial, apply.
   Sometimes shakes loose a working cursor format." Pure runtime test,
   no reboot, costs ~30 seconds.

5. **`WLR_RENDERER=pixman`** — pure software renderer, bypasses GBM
   allocator entirely on the render side. Diagnostic: if cursor errors
   disappear, the failure is buffer-allocator-side, not KMS-side. Tells
   us where to push upstream.

6. **Mouse polling rate** — `ratbagctl <device> rate set 500` (or 125)
   for the G203. Halves/eighths cursor-commit pressure. Setting
   persists on-mouse, no reboot, stacks with everything else. Easy win
   regardless of which other fix lands. Confirmed working command
   structure:

   ```
   ratbagctl list                          # find device short-name
   ratbagctl <name> rate get-all           # supported rates
   ratbagctl <name> rate set 500           # apply
   ```

7. **Smaller `XCURSOR_SIZE`** — reduces software-cursor blit cost on
   each commit. Marginal but free; set in `~/.config/environment.d/`.

8. **File a wlroots upstream issue** with concrete data: drm_info dump
   of eDP-2's cursor plane formats (the IN_FORMATS blob), plus the
   Mutter-vs-wlroots-on-same-mode comparison. The closest existing
   issue is
   [wlroots gitlab !3733](https://gitlab.freedesktop.org/wlroots/wlroots/-/issues/3733)
   (Intel xe + wlroots cursor) but it has no patch and no concrete
   data. No other public report ties **this exact panel** (BOE
   NE160QDM-NM9) to the failure. **We may genuinely be the first to
   characterise this**; an upstream issue with comparison data would
   be novel and actionable.

9. **kanshi** for output persistence — independent of the cursor issue
   but overdue. Lets you encode "when HDMI-A-1 is connected, eDP-2
   sits at *this* mode and at *this* position" once.

10. **Different compositor as last resort** — Hyprland is wlroots-based
    so will likely hit the same cursor-plane bug (community search
    confirmed no Hyprland-specific fix exists). KWin (KDE) has very
    different cursor / multi-GPU handling and is reported good on
    similar hardware. GNOME (Mutter) on Wayland is the proven-safe
    baseline — confirmed working on the exact same panel in the GDM
    greeter on this machine.

11. **Track upstream** — wlroots and `xe` are moving targets. The
    cursor-plane format-picker code in `wlroots/backend/drm/drm.c`
    near line 1129 has had no fallback-path change since 0.18; the
    next refactor or `xe` driver update could quietly fix this. Keep
    `apt upgrade` cadence brisk.

### Research notes (other env vars worth knowing about)

From the 2026-05-22 research dump, env vars that exist but I haven't
tried yet:

- `WLR_SCENE_DEBUG_DAMAGE=rerender` — repaint entire output on every
  commit (kills damage tracking). Diagnostic: confirms whether the
  cursor specifically is what's flooding commits.
- `WLR_DRM_FORCE_LIBLIFTOFF=1` — force the libliftoff atomic plane
  allocator (vs wlroots' built-in). Sometimes assigns planes
  differently.
- `WLR_DRM_NO_MULTIGPU=1` — disables multi-GPU buffer import; pins
  each output to its own card. Could change which renderer touches
  eDP path.
- `SWAY_DISABLE_FRAME_SCHEDULER=1` — bypass sway's frame scheduler
  timing. Useful if the stutter is scheduler-driven rather than
  plane-driven.
- `INTEL_DEBUG=norbc` — disable render-buffer compression at the
  Mesa level. Plausibly relevant.

## Current state at end of session 2026-05-22

- iGPU on `xe` driver, persisted via `/etc/default/grub` cmdline
  (`i915.force_probe=!7d67 xe.force_probe=7d67`). GRUB menu now visible
  for 5 s on boot (`GRUB_TIMEOUT_STYLE=menu`, `GRUB_TIMEOUT=5`) so
  future cmdline edits are reachable. Backup of original at
  `/etc/default/grub.bak.<ts>`.
- Symlink `~/.config/environment.d/wlr.conf` **restored**, currently
  sets **`WLR_RENDERER=vulkan`** only. Software cursor is still active
  (wlroots format-picker still fails) but cursor *perception* is
  significantly better; occasional brief freezes remain.
- Dotfiles commits `6f7e6ad` and `ff981b3` on master, plus uncommitted
  edits to `wlr.conf` and `SCREEN.md`. Not pushed.
- The mystery "WLR_NO_HARDWARE_CURSORS=1 still set after symlink removal
  and reboot" from earlier in the session **cleared** on the xe-switch
  reboot; not seen since.
- Symptom now: occasional brief freezes on eDP at 300 Hz (a few per
  minute). Acceptable for short sessions, not for sustained work.

**Next session — do this first:** boot with `xe.enable_psr=0` (either
transient via GRUB menu or persist in `/etc/default/grub`) and re-check
the journal error counts + cursor feel. If the `Failed to pick cursor
plane format` count drops to near zero, PSR was the culprit. If it
doesn't, descend the Open threads list from #2.
