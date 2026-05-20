You are currently working at /home/wam which is owned by William Matthews.

For information on:
- hardware see Documents/MACHINE.md
- The RGB keyboard see Documents/COLOUR.md
- The light bar see Documents/LIGHT-BAR.md
- Themes (golden-yellow palette family) see Documents/THEMES.md

These docs (and this CLAUDE.md itself) live in the dotfiles repo at
`~/coding/home/dotfiles/machines/grindstation/` and are symlinked into
`~/Documents/` (and `~/` for CLAUDE.md). **Any new reference document must
follow the same convention**: create it under `machines/<hostname>/`,
symlink it into `~/Documents/`, and add a line to the list above so future
sessions can find it.

## GitHub auth: ~/coding/home/

Two GitHub accounts are signed into `gh`: `will_antare` (work, default-active) and `WillMatthews` (personal). Repos under `~/coding/home/` (dotfiles, personal projects) are owned by `WillMatthews`. Pushing while `will_antare` is active returns HTTP 403.

To push from `~/coding/home/`, do the juggle:

```
gh auth switch -u WillMatthews
git push
gh auth switch -u will_antare
```

Always switch back to `will_antare` after — that's the working default for everything else.
