# machines/grindstation/

Host-specific reference docs for **grindstation** (Medion Erazer 16 X1).
Lives outside the stow tree — files here are not symlinked into `$HOME` by
`stow`, but each one *is* symlinked manually into `~/Documents/` so the
references in `~/CLAUDE.md` (`Documents/MACHINE.md`, etc.) keep resolving.

| File | What it covers |
|---|---|
| [MACHINE.md](MACHINE.md) | Hardware inventory + per-device quirks (Fn+F2 Win-lock, hybrid backlight, RGB control surfaces) |
| [THEMES.md](THEMES.md) | Golden-yellow palette family (Parchment / Honey & Ink / Sunlit Linen / **Aged Brass** / Midnight Gold) |
| [COLOUR.md](COLOUR.md) | RGB keyboard control reference |
| [LIGHT-BAR.md](LIGHT-BAR.md) | Front Beast Light Bar — current status: no Linux driver |

## Adding a new host

```
mkdir machines/<hostname>
mv ~/Documents/*.md machines/<hostname>/
for f in machines/<hostname>/*.md; do
    ln -s "$(realpath "$f")" "$HOME/Documents/$(basename "$f")"
done
```

Then add `machines/<hostname>/` to this README family if it's worth
finding from the top level.
