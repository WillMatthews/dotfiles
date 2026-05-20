
#                  __
#      ____  _____/ /_  __________
#     /_  / / ___/ __ \/ ___/ ___/
#    _ / /_(__  ) / / / /  / /__
#   (_)___/____/_/ /_/_/   \___/
#
#
#   Interactive zsh config: plugins (via antidote), prompt,
#   aliases. Env/PATH live in ~/.zshenv.


# ── History ──
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# ── Directory navigation ──
setopt AUTO_CD              # bare `Documents` cds into it
setopt AUTO_PUSHD           # cd remembers history; use `cd -1`, `cd -2`, …
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# ── Completion ──
# Hyphen-insensitive completion (replaces OMZ's HYPHEN_INSENSITIVE=true).
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'

# ── Prompt prerequisites (gianu theme needs these) ──
autoload -U colors && colors
setopt PROMPT_SUBST

# ── Plugins via antidote ──
source $HOME/.antidote/antidote.zsh
antidote load

# ── Aliases ──
# colourise ls output (from OMZ's lib/theme-and-appearance.zsh)
alias ls='ls --color=tty'

# ls shortcuts (from OMZ's lib/directories.zsh)
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias lsa='ls -lah'

# cd-up globals: `cd ...` → ../..
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# directory stack
alias -- -='cd -'
alias pu='pushd'
alias po='popd'

# typo savers
alias cd..='cd ..'
alias vi='nvim'
alias vim='nvim'
alias cim='nvim'
alias bim='nvim'
alias v='nvim'

# tmux in utf8
alias tmux='tmux -u'

# fast open
alias op='xdg-open'

# set file mtime to 1984
alias nineteeneightyfour='touch -d "1984/01/01 01:01"'

# alarm clock
alias alarm='alarm-clock-applet'

# blank the screen
alias blank='sleep 1; xset dpms force off'
alias unblank='xset -display ${DISPLAY} dpms force on'

# fuzzy-find cd (needs fzf)
alias gt='cd $(dirname `fzf`)'

# largest n files in cwd
alias listbig='du -BM | sort -n -r | head -n'

# battery percentage
alias batt='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|to\ full|percentage"'

# tty clock
alias clock='tty-clock -s -B -c -C 3 -d 0.1'

# matrix-flavoured "im in the cafe"
alias cafe='hexdump -C /dev/urandom|grep "ca fe"'

# local ip
alias lip="ip -4 -o addr show scope global | awk '{print \$4}' | cut -d/ -f1"
alias lipa="curl https://ipapi.co/json"

# todolist
alias todo="ultralist"
alias agenda="ultralist agenda"

# colour cat
alias ccat="highlight --out-format=ansi"

# pulseaudio reset
alias resetsound="pulseaudio -k && sudo alsa force-reload"

# quick edit shortcuts
alias zshconfig="$EDITOR ~/.zshrc"
alias zshenvedit="$EDITOR ~/.zshenv"
alias plugins="$EDITOR ~/.zsh_plugins.txt"

# ── Tool integrations ──
# bun completion
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# pay-respects: typo corrector (replaces the old `thefuck` integration)
if command -v pay-respects >/dev/null 2>&1; then
  eval "$(pay-respects zsh --alias)"
fi

# Work-only helpers (Antare) — file is gitignored and only present on work machines.
[ -f "$HOME/.config/antare/shell.sh" ] && . "$HOME/.config/antare/shell.sh"
