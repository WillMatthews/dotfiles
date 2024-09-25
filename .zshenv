
#                  __                   
#      ____  _____/ /_  ___  ____ _   __
#     /_  / / ___/ __ \/ _ \/ __ \ | / /
#    _ / /_(__  ) / / /  __/ / / / |/ / 
#   (_)___/____/_/ /_/\___/_/ /_/|___/  
#


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"



##### ALIASES

# save time on typos
alias cd..='cd ..'
alias vi='vim'
alias cim='vim'
alias bim='vim'

alias pia="/opt/pia/run.sh"

# alias for starting tmux in utf8
alias tmux='tmux -u'

# fast open
alias op='xdg-open'

# set 1984
alias nineteeneightyfour='touch -d "1984/01/01 01:01"'

# alarm clock
alias alarm='alarm-clock-applet'

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

# get all ip data
alias lipa="curl https://ipapi.co/json"

# todolist
alias todo="ultralist"

# color cat
alias ccat="highlight --out-format=ansi" # Color cat - print file with syntax highlighting.

alias resetsound="pulseaudio -k && sudo alsa force-reload"

alias rdp-home="ssh -L 5091:localhost:5091 -C -N -l matthews matthews-srv1.local"

alias rdp-lab="ssh -L 5902:localhost:5902 lab"

alias minestat="watch -c -n 60 'curl -s https://api.ethermine.org/miner/:0x7557c19e40bc82189D63805A97d6De15B48F97C5/currentStats | jq -C  .'"

alias tsk="task -t /home/will/coding/beyond"

alias updatego="go get -d -u -t ./... && go mod tidy"

##### FUNCTIONS
#this should probably be in 'scripts'?


## Weather forecast for whatever location you like
weather () {
    curl "wttr.in/$1"
}

## the 'dota sometimes breaks on linux and it makes me sad' function
killall (){
  ps -axu | grep "$1" | awk '{print $2}' | xargs kill -9
}


## the 'I hate typing' function
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


### the 'I'm too lazy to remember compile settings' function
smartcompile () {
  name=${1%.*}
  top=$(head -n 1 $1)

  if [ -f $1 ] ; then
      case $1 in
          *.tex)       pdflatex --shell-escape $1         ;;
          *.ms)        groff -ms $1 -T pdf > $name.pdf  ;;
          *.hs)        ghc -o $name $1     ;;
          *.c)         gcc  $1 -o $name    ;;
          *.cpp)       g++  --std=c++17 $1 -o $name    ;;
          *)           echo "don't know how to compile '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}


### the 'make vim open things nicely' function
smartopen () {
  name=${1%.*}
  if [ -f $1 ] ; then
      case $1 in
          *.tex)     xdg-open "$name.pdf" ;;
          *.ms)      xdg-open "$name.pdf" ;;
          *.py)      "python3 $name"      ;;
          *.cpp)     "./$name"            ;;
          *)         xdg-open $1          ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}


### the 'run programs in a way that keeps me sane' function
smartrun () {
  name=${1%.*}
  if [ -f $1 ] ; then
      case $1 in
          *.tex)     echo ".tex files can't be run" ;;
          *.pdf)     echo ".pdf files can't be run" ;;
          *.txt)     echo ".txt files can't be run" ;;
          *.txt)     echo ".txt files can't be run" ;;
          *.c)       ./$name ;;
          *.py)      chmod +x $1; ./$1 ;;
          *.js)      ./$1 ;;
          *)         xdg-open $1          ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}


eulerpy () {
    FILE=$1.py
    echo $FILE
    header=$(curl https://projecteuler.net/minimal=$1)
    header2=$(echo $header | sed -E 's/<(|\/)p>//g' | sed -E 's/<br(| )\/>//g' | sed -E 's/^/# /g')
    if [[ -f "$FILE" ]]; then
        echo "$FILE exists. Doing nothing."
    else
        echo $header2 >> $FILE
    fi
}


newcpp () {
    touch $1.cpp

    echo "#include <bits/stdc++.h>

using namespace std;

using ll = long long;
#define ar array


int main(int argc, char *argv[]){
    ios::sync_with_stdio(1);
    cin.tie(0);


    return EXIT_SUCCESS;
}" >> $1.cpp
    

}


### show all colours
showcols () {
  for i in {0..255}; do
      printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
  done
}


### sci hub download
shdl() {
  curl -O $(curl -s http://sci-hub.tw/"$@" | grep location.href | grep -o http.*pdf);
}

. "$HOME/.cargo/env"
