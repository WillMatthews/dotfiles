
#                          _____ __
#        ____  _________  / __(_) /__
#       / __ \/ ___/ __ \/ /_/ / / _ \
#    _ / /_/ / /  / /_/ / __/ / /  __/
#   (_) .___/_/   \____/_/ /_/_/\___/
#    /_/
#
#   Executed on login shells

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.scripts" ] ; then
    PATH="$HOME/.scripts:$PATH"
fi

export EDITOR="nvim"
export BROWSER="firefox"
export FILE="ranger"
