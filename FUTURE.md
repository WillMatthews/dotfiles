# FUTURE.md

A running list of modernisation ideas, ordered roughly by effort-to-payoff.
Nothing here is urgent — the current setup works fine. Pick off as appetite
allows.

The repo was modernised in May 2026 (oh-my-zsh → antidote, ls colours via
vivid, cleaner `.zshenv` / `.zshrc` split). What's below is the next round.

---

## Tier 1 — already installed, just need wiring

`bootstrap.sh` installs these but `.zshrc` doesn't activate any of them. One
line each. The README's "Modern CLI tools" table has the snippets.

- **zoxide** — frecency-based `cd`. `eval "$(zoxide init zsh)"`. Then `z foo`
  jumps to the most-used dir matching "foo". Pairs with `zi` for interactive
  fuzzy jump if fzf is loaded.
- **atuin** — searchable, syncable shell history. `eval "$(atuin init zsh)"`.
  Rebinds Ctrl-R to a TUI that searches across hosts. Optional sync server.
- **eza** — `ls` replacement. Drop-in for the existing aliases:
  `alias l='eza -lah --git'`, `alias ll='eza -lh --git'`. Adds tree mode
  (`eza -T`), git status column, icons (needs Nerd Font).
- **bat** — `cat` with syntax highlighting + paging. Could replace the
  existing `ccat` alias entirely: `alias ccat='bat -p'`. Leave plain `cat`
  alone — too many scripts depend on its behaviour.

The interesting question is *which* of these to make defaults vs leave behind
their original names. I lean toward: alias `cd` → nothing (zoxide adds `z`,
keep `cd`), `ls` → eza (safe), `cat` → leave alone, replace `ccat`.

## Tier 2 — Starship prompt

Discussed but skipped. Replaces the gianu theme with a cross-shell,
language-aware prompt. Shows git status, language version (auto-detected per
project), command duration, exit code. Configured in
`~/.config/starship.toml`.

Prerequisites:
1. A Nerd Font in the terminal (e.g. JetBrainsMono Nerd Font — already noted
   in the README). The default starship glyphs assume one.
2. `starship` binary installed (cargo install or download).

Migration:
- `eval "$(starship init zsh)"` in `.zshrc`
- Drop the gianu theme + its OMZ git library dep from `.zsh_plugins.txt`
- Drop the `autoload colors; setopt PROMPT_SUBST` lines (starship handles it)
- Pick a preset: `plain-text-symbols` if no Nerd Font, `gruvbox-rainbow` or
  `tokyo-night` if you want it dressed up.

If/when you do this, also remove the OMZ git_prompt_info dependency from
`.zsh_plugins.txt` — starship calls git directly.

## Tier 3 — fuzzy completion: fzf-tab

The single highest-value zsh plugin I haven't installed for you. Replaces
zsh's default completion menu with an fzf-powered interactive picker.

`git checkout <Tab>` becomes a fuzzy search over branches with a preview
window showing the latest commit. `kill <Tab>` becomes a fuzzy process list.
Everything that already has zsh completions gets the fzf treatment for free.

Add to `.zsh_plugins.txt`:
```
Aloxaf/fzf-tab
```
Must be loaded **before** fast-syntax-highlighting and **after**
zsh-autosuggestions. Needs fzf (already installed).

## Tier 4 — more Rust replacements

Diminishing returns past here. None are essential.

- **delta** — `git diff` with syntax highlighting, side-by-side, line
  numbers. Wired via `~/.gitconfig`, not shell.
- **dust** — `du` replacement, better tree view. Replaces my `listbig`
  alias.
- **procs** — `ps` with colours, tree view, search.
- **bottom** (`btm`) — `htop` / `btop` alternative, less busy UI.
- **hyperfine** — benchmark CLI for `time foo` style comparisons.
- **sd** — `sed` for the common cases (literal-by-default, sane regex).
- **xh** — `curl` / `httpie` alternative, faster startup than httpie.
- **tealdeer** (`tldr`) — example-driven man pages.
- **difftastic** — syntactic diffs (parses AST, shows logical changes).
  Pairs with delta or replaces it for code diffs.

## Tier 5 — beyond the shell

Bigger lifts. Mention here so we don't forget.

- **mise** (formerly rtx) — language version manager. Replaces nvm + pyenv
  + ghcup + similar. Per-project `.tool-versions` file.
- **direnv** — per-directory env vars (`use_flake`, `layout python`, etc.).
  Loads/unloads automatically on `cd`.
- **lazygit** — TUI for git. Faster than memorising porcelain.
- **yazi** — terminal file manager (Rust, async, image previews).
- **just** — Makefile replacement for project task runners.
- **helix** — modal editor with builtin LSP. Worth a look but moving off
  neovim is a big ask given the existing kickstart.nvim config.

## Smaller polish, not its own tier

- **Antidote turbo-load** — add `zsh-users/zsh-defer` and tag
  fast-syntax-highlighting / autosuggestions with `kind:defer` to load them
  after first prompt. Shaves ~10-20ms off startup. Not noticeable on this
  machine; useful on slower hardware.
- **zsh completion caching** — add `zstyle ':completion:*' use-cache on` and
  `zstyle ':completion:*' cache-path ~/.cache/zsh-compcache`. Speeds up
  completions for tools with slow `--help` parsers (kubectl, gcloud, etc.).
- **`.bashrc` is also untouched** — same kind of cleanup if you ever boot
  into bash on a server. Lower priority since zsh is the daily driver.
- **Split `.zshrc` into files** — once it grows past ~150 lines, consider
  splitting into `.config/zsh/{aliases,plugins,prompt}.zsh` sourced from
  `.zshrc`. Not needed yet.

## Shell choice — is zsh still the right pick?

Short answer: **yes, keep zsh**, but it's worth knowing the landscape.

The serious 2026 contenders:

**zsh (incumbent).** POSIX-compatible, infinitely customisable, biggest plugin
ecosystem. The "default-on-modern-Linux" choice. Now that this config is
modernised (antidote, fast-syntax-highlighting, vivid), the main historical
complaints — slow, byzantine config, OMZ overhead — no longer apply. The one
thing zsh genuinely doesn't have out of the box that newer shells do is a
*good interactive experience by default*. We've added that via plugins.

**fish.** Best out-of-the-box UX: autosuggestions, syntax highlighting,
abbreviations, web-based config, all built in. Friendly to newcomers. Two
costs: (1) not POSIX, so its scripting syntax is different from bash/zsh —
you'd have to learn `set -gx FOO bar` instead of `export FOO=bar`, etc.
Shell scripts on disk still run under bash/sh, but anything in `~/.config/fish`
is fish-syntax. (2) The gap between fish and a modernised zsh is much
narrower than the gap between fish and vanilla bash. The win is biggest
for people who never bothered configuring their shell.

**nushell.** Paradigm shift. Pipes carry structured data (tables, records,
lists) instead of bytes, so `ls | where size > 10mb | sort-by modified`
works like SQL. Brilliant for data work, log munging, JSON wrangling.
Costs: not POSIX, smaller plugin ecosystem, your muscle memory for
`grep`/`awk`/`sed` pipelines doesn't transfer (you use nushell's own verbs).
Worth keeping as a **side shell** for data tasks even if you stay on zsh
as the daily driver — they coexist fine.

**bash.** Universal, simple, on every server you'll ever ssh to. Worth
keeping `~/.bashrc` tidy so the experience is reasonable when you land on
a fresh box. Don't switch *to* it for interactive use — you'd lose ground.

**Others worth knowing exist but I wouldn't switch to:**
- **xonsh** — Python + shell. Nice if you live in Python all day. Niche.
- **elvish** — structured-data shell like nushell. Smaller community.
- **murex** — POSIX-ish with structured types. Smaller still.

### Recommendation

Stay on zsh as the daily driver. The recent modernisation closed most of
the gap with fish. If you want to *experiment*, install nushell alongside
and use it for data-heavy sessions (`nu` from inside zsh, exit back). That
gives you the new paradigm without burning down the existing config.

A practical migration to fish would mean rewriting `.zshrc` aliases in
fish syntax (`alias` works, but functions and exports don't), reconfiguring
antidote → fisher, and accepting that any zsh-specific completions you
rely on won't transfer. Probably 2–4 hours of work, and the daily QoL
delta is small now.

---

## Decisions deferred

These came up in conversation and got punted on purpose:

- Whether `cd` should be replaced or kept (zoxide adds `z`, doesn't have
  to take over `cd`).
- Whether to alias `cat → bat` globally (risks confusing script behaviour;
  recommended scope was just `ccat`).
- Which vivid theme to pick if the prompt changes — molokai was chosen to
  harmonise with gianu specifically; a Starship preset might call for a
  different LS_COLORS theme (gruvbox-dark, nord, etc.).
