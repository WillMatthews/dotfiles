# machines/overtime/

Host-specific reference docs **and host-only config** for **overtime**
(Lenovo ThinkPad X1 Carbon Gen 9). Lives outside the stow tree — nothing here is
symlinked by `stow`. Docs are symlinked manually into `~/Documents/` so the
references in `~/CLAUDE.md` keep resolving; any host-only config files would
mirror their real `~/.config/...` path inside `.config/` here and be symlinked
manually the same way.

## Docs

| File | Symlinked to | What it covers |
|---|---|---|
| [CLAUDE.md](CLAUDE.md) | `~/CLAUDE.md`, `~/.claude/CLAUDE.md` | Host references, working dir, GitHub auth juggle for `~/coding/home/` |
| [MACHINE.md](MACHINE.md) | `~/Documents/MACHINE.md` | Hardware inventory + per-device notes (Intel-only graphics, WWAN, TB4, battery health) |

overtime runs the **same shared sway/Wayland config and unified Aged Brass theme**
as every other host (from the stow tree at the repo root). The only host-specific
docs are the hardware inventory above — overtime has **no** RGB keyboard, light
bar, or NVIDIA GPU, so grindstation's COLOUR / LIGHT-BAR / SCREEN hardware docs
have no counterpart here. **THEMES.md is shared, not per-host** — see the repo
root, and `~/Documents/THEMES.md` resolves to the same unified copy on every
machine.

## Host-only config

| File | Symlinked to | What it covers |
|---|---|---|
| [.local/bin/idle-displays.sh](.local/bin/idle-displays.sh) | `~/.local/bin/idle-displays.sh` | swayidle DPMS hook — powers off *all* outputs (grindstation's copy skips eDP for a Meteor Lake bug overtime doesn't have) |

Also symlinked from grindstation (generic, not host-specific): `~/.local/bin/sway-keys`
→ `machines/grindstation/bin/sway-keys`. The wallpaper is generated with
`aged-brass-wallpaper 1920x1200`; JetBrainsMono Nerd Font lives in
`~/.local/share/fonts/JetBrainsMonoNerd/` (from the nerd-fonts GitHub release).

If another config file becomes correct
*only* on overtime, mirror its `~/.config/...` path under `.config/` here and
symlink it manually (same convention as grindstation).

## Adding a new host

See the top-level pattern in [`../grindstation/README.md`](../grindstation/README.md).
In short: `mkdir machines/<hostname>`, move the host's `MACHINE.md` (and any
host-only docs) in, then symlink each doc into `~/Documents/` and the agent
instruction file into `~/CLAUDE.md` / `~/.claude/CLAUDE.md`.
