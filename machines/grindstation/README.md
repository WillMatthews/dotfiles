# machines/grindstation/

Host-specific reference docs for **grindstation** (Medion Erazer 16 X1).
Lives outside the stow tree — files here are not symlinked into `$HOME` by
`stow`, but each one *is* symlinked manually into `~/Documents/` so the
references in `~/CLAUDE.md` (`Documents/MACHINE.md`, etc.) keep resolving.

| File | Symlinked to | What it covers |
|---|---|---|
| [CLAUDE.md](CLAUDE.md) | `~/CLAUDE.md` | Top-level instructions Claude reads at session start (doc index, gh auth juggle, per-host conventions) |
| [MACHINE.md](MACHINE.md) | `~/Documents/MACHINE.md` | Hardware inventory + per-device quirks (Fn+F2 Win-lock, hybrid backlight, RGB control surfaces) |
| [THEMES.md](THEMES.md) | `~/Documents/THEMES.md` | Golden-yellow palette family (Parchment / Honey & Ink / Sunlit Linen / **Aged Brass** / Midnight Gold) |
| [COLOUR.md](COLOUR.md) | `~/Documents/COLOUR.md` | RGB keyboard control reference |
| [LIGHT-BAR.md](LIGHT-BAR.md) | `~/Documents/LIGHT-BAR.md` | Front Beast Light Bar — current status: no Linux driver |

## Adding a new host

```
mkdir machines/<hostname>
mv ~/CLAUDE.md           machines/<hostname>/CLAUDE.md
mv ~/Documents/*.md      machines/<hostname>/
ln -s "$(realpath machines/<hostname>/CLAUDE.md)" "$HOME/CLAUDE.md"
for f in machines/<hostname>/*.md; do
    [ "$(basename "$f")" = CLAUDE.md ] && continue
    [ "$(basename "$f")" = README.md ] && continue
    ln -s "$(realpath "$f")" "$HOME/Documents/$(basename "$f")"
done
```

Then add `machines/<hostname>/` to this README family if it's worth
finding from the top level.
