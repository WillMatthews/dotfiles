
#                  __             
#      ____  _____/ /_  __________
#     /_  / / ___/ __ \/ ___/ ___/
#    _ / /_(__  ) / / / /  / /__  
#   (_)___/____/_/ /_/_/   \___/  
#                              






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


###### PLUGINS
# Plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins can be added to ~/.oh-my-zsh/custom/plugins/
    plugins=(
      git
      command-not-found
      python
      pep8
      web-search
      zsh-autosuggestions
    )

    source $ZSH/oh-my-zsh.sh


###### CUSTOM CONFIG
# Preferred editor for local and remote sessions
    if [[ -n $SSH_CONNECTION ]]; then
      export EDITOR='vim'
    else
      export EDITOR='vim'
    fi

# Compilation flags
    # export ARCHFLAGS="-arch x86_64"

# go to zsh config and oh my zsh easily
    alias zshconfig="mate ~/.zshrc"
    alias ohmyzsh="mate ~/.oh-my-zsh"

# Add bash aliases.
    if [ -f ~/.zshenv ]; then
       source ~/.zshenv
    fi

# setup for thefuck
    eval $(thefuck --alias)

# ssh keyfile
    export SSH_KEY_PATH="~/.ssh/rsa_id"

# locale setting
    export LANG=en_GB.UTF-8

# update PATH (scripts, go and MATLAB)
    export PATH="$PATH:$HOME/go/bin"
    export PATH="$PATH:/usr/local/go/bin"
    export PATH="$PATH:/usr/local/MATLAB/R2018b/bin"
