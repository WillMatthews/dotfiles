
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
alias agenda="ultralist agenda"

# color cat
alias ccat="highlight --out-format=ansi" # Color cat - print file with syntax highlighting.

# kill pulseaudio and restart alsa
alias resetsound="pulseaudio -k && sudo alsa force-reload"

