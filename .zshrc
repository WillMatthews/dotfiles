
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
export ZSH=~/.oh-my-zsh

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
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# go to zsh config and oh my zsh easily
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"

# Bash aliases
if [ -f ~/.zshenv ]; then
   source ~/.zshenv
fi

# alias thefuck
eval $(thefuck --alias)

# ssh keyfile
export SSH_KEY_PATH="~/.ssh/rsa_id"

# locale setting
export LANG=en_GB.UTF-8

# update PATH (scripts, go and MATLAB)
export PATH=$HOME/.scripts:$PATH
export PATH=$HOME/.cabal/bin:$PATH

# Go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# MATLAB
export PATH="$PATH:/usr/local/MATLAB/R2019b/bin" #R2022b/bin for alt ver.
export PATH="$PATH:/home/will/.local/bin" # python scripts

# Cuda
export LD_LIBRARY_PATH=/usr/lib/nvidia-cuda-toolkit/libdevice:$LD_LIBRARY_PATH
export PATH=/usr/lib/nvidia-cuda-toolkit/bin:$PATH

# GPG pin entry from terminal (!important)
GPG_TTY=$(tty)
export GPG_TTY

# brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

#. /home/will/torch/install/bin/torch-activate

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "/home/will/.bun/_bun" ] && source "/home/will/.bun/_bun"

[ -f "/home/will/.ghcup/env" ] && source "/home/will/.ghcup/env" # ghcup-env

export HF_HOME="/home/will/coding/ml/.huggingface"

source ~/.tokens
