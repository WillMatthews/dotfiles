# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=/home/will/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="gianu"

# gianu
# kphoen
# muse
# sunrise

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# PLUGINS
# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
  git
  command-not-found
  python
  pep8
  scala
  web-search
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# go to zsh config and oh my zsh easily
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"

# Add linuxbrew to path
export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"

# Miniconda3
export PATH="/home/will/miniconda3/bin:$PATH"

# setup for thefuck
eval $(thefuck --alias)

# save time on typos
alias cd..='cd ..'
alias vi='vim'

# I'm not the brightest guy around, and this is an awful hack, but I prefer to send things to the trash rather than remove completely
#alias rm=trash

# alias for starting tmux in utf8
alias tmux='tmux -u'

# fast open
alias op='xdg-open'

# alarm clock
alias alarm='alarm-clock-applet'

alias pyth='python3.6'

######### scripts
# blank the screen
alias blank='sleep 1; xset dpms force off'
alias unblank='xset -display ${DISPLAY} dpms force on'

# make matlab start the way I want to in terminal
alias tmatlab='matlab -nodesktop -nosplash'

# fuzzy find change directory, requires `fzf`
alias gt='cd $(dirname `fzf`)'

# lists the largest n files in my directory
alias listbig='du -BM | sort -n -r | head -n'

# get battery percentage
alias batt='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|to\ full|percentage"'

# crude hacky pip autoupdate (list outdated modules, use first col, cut off first two lines, pass to pip)
alias pipupdate="pip list --outdated | cut -d' ' -f1 | sed -e '1,2d' | xargs pip install --upgrade"

# sick clock bro
alias clock='tty-clock -s -B -c -C 3 -d 0.1'

# some fun stuff to say I'm in the cafe
alias cafe='hexdump -C /dev/urandom|grep "ca fe"'

# local ip obtain
alias lip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"


######## generic



# locale setting
export LANG=en_GB.UTF-8



######## functions

up (){
 for i in $(seq ${1: -1});do
   cd ../
 done
}

## the 'I hate tar' function
extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

