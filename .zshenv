# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

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

gencompile () {
  name=${1%.*}
  if [ -f $1 ] ; then
      case $1 in
          *.tex)       pdflatex $1         ;;
          *.hs)        ghc -o $name $1     ;;
          *.c)         gcc  $1 -o $name    ;;
          *.cpp)       g++  $1 -o $name    ;;
          *)           echo "don't know how to compile '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

