
#                  __
#      ____  _____/ /_  __________
#     /_  / / ___/ __ \/ ___/ ___/
#    _ / /_(__  ) / / / /  / /__
#   (_)___/____/_/ /_/_/   \___/
#
#
#   zsh & omz config, path and env




#### omz settings

# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Theme
ZSH_THEME="gianu"   # gianu, kphoen, muse, sunrise

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Hyphen-insensitive completion. Case sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Enable command auto-correction.
# ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Disable marking untracked files under VCS as dirty.
# This makes repository status check for large repositories much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"


#### omz plugins
# Plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins can be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
  git
  command-not-found
  python
  pep8
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  task
)

source $ZSH/oh-my-zsh.sh


#### env variables
# Preferred editor for local and remote sessions
export EDITOR='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# go to zsh config and oh my zsh easily
alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"

# Bash aliases
if [ -f ~/.zshenv ]; then
   source ~/.zshenv
fi

# pay-respects: typo corrector (replaces the old `thefuck` integration)
if command -v pay-respects >/dev/null 2>&1; then
   eval "$(pay-respects zsh --alias)"
fi

# ssh keyfile
export SSH_KEY_PATH="$HOME/.ssh/rsa_id"

# locale setting
export LANG=en_GB.UTF-8

# update PATH (scripts and cabal)
export PATH=$HOME/.scripts:$PATH
export PATH=$HOME/.cabal/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

# Go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# GPG pin entry from terminal (!important)
GPG_TTY=$(tty)
export GPG_TTY

# brew
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
   eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ghcup
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

export HF_HOME="$HOME/coding/ml/.huggingface"

[ -f "$HOME/.tokens" ] && source "$HOME/.tokens"
