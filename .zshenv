
#                  __
#      ____  _____/ /_  ___  ____ _   __
#     /_  / / ___/ __ \/ _ \/ __ \ | / /
#    _ / /_(__  ) / / /  __/ / / / |/ /
#   (_)___/____/_/ /_/\___/_/ /_/|___/
#
#
#   A collection of aliases for my shell





#### Aliases

# save time on typos
alias cd..='cd ..'
alias vi='nvim'
alias vim='nvim'
alias cim='nvim'
alias bim='nvim'
alias v='nvim'

# private internet access vpn
alias pia="/opt/pia/run.sh"

# alias for starting tmux in utf8
alias tmux='tmux -u'

# fast open
alias op='xdg-open'

# set file modified times to 1984 101
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

# lock over ssh (BROKEN)
#alias lock ='gnome-screensaver-command -l'

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

# kill pulseaudio and restart alsa
alias resetsound="pulseaudio -k && sudo alsa force-reload"

# rdp to my home server
alias rdp-home="ssh -L 5091:localhost:5091 -C -N -l matthews matthews-srv1.local"

# rdp to lab (DEPRECATED. RIP lab computer)
# alias rdp-lab="ssh -L 5902:localhost:5902 lab"
