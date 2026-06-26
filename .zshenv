
#                  __
#      ____  _____/ /_  ___  ____ _   __
#     /_  / / ___/ __ \/ _ \/ __ \ | / /
#    _ / /_(__  ) / / /  __/ / / / |/ /
#   (_)___/____/_/ /_/\___/_/ /_/|___/
#
#
#   Environment + PATH. Sourced for EVERY zsh invocation
#   (including non-interactive scripts), so keep aliases and
#   prompt config out of here — those live in ~/.zshrc.


# ── Editor / locale ──
export EDITOR='nvim'
export TERMINAL='kitty'
export LANG=en_GB.UTF-8

# ── ripgrep ──
[ -f "$HOME/.ripgreprc" ] && export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# ── Secrets / keys ──
export GPG_TTY=$(tty 2>/dev/null)   # GPG pinentry from terminal

# ── Language toolchains ──
export GOPATH=$HOME/go
export BUN_INSTALL="$HOME/.bun"
export HF_HOME="$HOME/coding/ml/.huggingface"

# ── antare local-build cgroup ──
# Routes antare's test/build containers into the antare.slice cgroup (resource
# walls — see antare/ci/core-builder-local/README.md). Guarded on the unit file,
# not the runtime cgroup dir: the dir only exists while the slice is active, but
# Docker's systemd cgroup driver instantiates the slice (with its limits) on
# first use, so guarding on the unit keeps this safe to sync yet always armed.
[ -f /etc/systemd/system/antare.slice ] && export ANTARE_CGROUP=antare.slice

# ── PATH ──
# `typeset -U` dedupes entries automatically (zsh keeps `path` and
# `PATH` in sync, so we manipulate the array form).
typeset -U path PATH
path=(
  $HOME/.scripts
  $HOME/.cabal/bin
  $HOME/.local/bin
  $BUN_INSTALL/bin
  $path
  /usr/local/go/bin
  $GOPATH/bin
)

# ── LS_COLORS via vivid (theme: molokai, harmonises with gianu prompt) ──
if command -v vivid >/dev/null 2>&1; then
  export LS_COLORS="$(vivid generate molokai)"
fi

# ── fzf — Aged Brass palette (see ~/Documents/THEMES.md) ──
export FZF_DEFAULT_OPTS="
  --color=bg:#2A211B,bg+:#3A2E25,fg:#A89880,fg+:#EFE3CE
  --color=hl:#D6A12A,hl+:#FFC332,gutter:#2A211B
  --color=prompt:#FFC332,pointer:#FFC332,marker:#E9994A,spinner:#D6A12A
  --color=info:#8FA672,header:#A89880,border:#4E3F32,label:#A89880"

# ── Linuxbrew (only if installed) ──
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ── ghcup ──
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# ── API tokens etc. ──
[ -f "$HOME/.tokens" ] && source "$HOME/.tokens"
