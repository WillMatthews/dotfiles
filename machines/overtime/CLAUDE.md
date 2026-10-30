You are currently working at /home/wam which is owned by William Matthews.

This machine is **overtime**, a Lenovo ThinkPad X1 Carbon Gen 9 running Ubuntu
26.04. It runs the **same sway/Wayland setup and unified Aged Brass theme as
every other host** — that config comes from the shared stow tree at the repo
root (`.config/sway/`, `.config/waybar/`, etc.), not from here. (As of
2026-09-25 the box is still on the stock GDM/GNOME install; sway is the intended
daily driver — `sway`, `waybar`, `rofi`, `kitty` still need installing.)

For information on:
- hardware see Documents/MACHINE.md
- the unified theme family see Documents/THEMES.md

This machine has no discrete GPU, no RGB keyboard, and no light bar, so the
grindstation *hardware* references (COLOUR / LIGHT-BAR / SCREEN) have no
counterpart here. The theme (THEMES.md) is shared across all hosts.

These docs (and this CLAUDE.md itself) live in the dotfiles repo at
`~/coding/home/dotfiles/machines/overtime/` and are symlinked into
`~/Documents/` (and `~/` + `~/.claude/` for CLAUDE.md). **Any new reference
document must follow the same convention**: create it under
`machines/<hostname>/`, symlink it into `~/Documents/`, and add a line to the
list above so future sessions can find it.

## GitHub auth: ~/coding/home/

Two GitHub accounts are signed into `gh`: `will_antare` (work, default-active) and `WillMatthews` (personal). Repos under `~/coding/home/` (dotfiles, personal projects) are owned by `WillMatthews`. Pushing while `will_antare` is active returns HTTP 403.

To push from `~/coding/home/`, do the juggle:

```
gh auth switch -u WillMatthews
git push
gh auth switch -u will_antare
```

Always switch back to `will_antare` after — that's the working default for everything else.
