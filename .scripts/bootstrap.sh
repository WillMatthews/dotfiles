#!/bin/bash

# Bootstrap script for fresh Ubuntu installs with enhanced visual output

## TODO
# hostname setup? user setup?
#
# DECISION PENDING: i3 vs sway as the daily-driver WM. Currently this script
# still wires Print Screen via gsettings (GNOME-only). Once the WM choice is
# locked in, add the relevant package group to nonServePackages and either:
#   - i3 path:  i3 i3status rofi flameshot picom feh dunst
#   - sway path: sway swaybg swayidle swaylock wofi grim slurp wl-clipboard
#                xdg-desktop-portal-wlr feh dunst
# ...and gate / replace the gsettings Print Screen block accordingly.

# Color and formatting variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print in green with bold
print_green() {
    echo -e "${GREEN}${BOLD}$1${NC}"
}

# Function to print in red with bold
print_red() {
    echo -e "${RED}${BOLD}$1${NC}"
}

# Function to print in blue with bold
print_blue() {
    echo -e "${BLUE}${BOLD}$1${NC}"
}

# Banner
print_blue "====================="
print_blue " Ubuntu Setup Script "
print_blue "====================="

# Locate the dotfiles repo. If this script is being run from inside a clone
# (e.g. ~/coding/home/dotfiles/.scripts/bootstrap.sh) use that clone; otherwise
# clone into ~/dotfiles (recursive for kickstart.nvim submodule).
scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if git -C "${scriptDir}" rev-parse --show-toplevel >/dev/null 2>&1; then
    DOTFILES="$(git -C "${scriptDir}" rev-parse --show-toplevel)"
else
    DOTFILES="${HOME}/dotfiles"
fi
print_green "Using dotfiles repository at ${DOTFILES}..."
if [ ! -d "${DOTFILES}" ]; then
    git clone --recursive https://github.com/WillMatthews/dotfiles "${DOTFILES}"
else
    git -C "${DOTFILES}" pull
    git -C "${DOTFILES}" submodule update --init --recursive
fi

# Package lists
regolithPackages="regolith-desktop regolith-session-flashback regolith-look-lascaille"
nonServePackages="manpages groff tty-clock ghc cabal-install make firefox thunderbird filezilla flameshot kicad gnuplot handbrake texlive-full ngspice nginx obs-studio qrencode gimp inkscape suckless-tools valgrind units wireshark glances iotop iftop mc ncdu ranger python3-pip build-essential git-lfs xfce4-notifyd brightnessctl"
servePackages="git stow net-tools fastfetch htop btop ncal lm-sensors plocate samba docker.io neovim vim zsh ffmpeg whois pandoc autossh rsync sysstat jq gnupg openssh-client openssh-server tmux gzip nmap screen speedometer speedtest-cli zip unzip unrar wget curl highlight certbot ripgrep fd-find fzf bat eza zoxide vivid"
gamesAndOtherPackages="openttd steam mumble transmission"
cabalPackages="hakyll" # TODO make cabal work
removePackages="regolith-rofication"

# Snap packages (not available via apt on current Ubuntu)
nonServeSnap="freecad"
gamesAndOtherSnap="0ad"

# Function to install packages
install_packages() {
    sudo apt install -y $1
    sudo apt remove -y $removePackages || true
}

# Regolith lives in its own apt repo; only install it if that repo is configured.
if apt-cache show regolith-desktop >/dev/null 2>&1; then
    desktopExtras="${regolithPackages}"
else
    print_red "Regolith apt repo not configured; skipping Regolith packages."
    desktopExtras=""
fi

# Update and upgrade the system, then autoremove
set -e
print_green "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y


# Interactive Menu for selecting installation type
print_blue "Select Installation Type:"
echo -e "${GREEN}1. Server${NC}"
echo -e "${GREEN}2. Non-Server (desktop, work-suitable)${NC}"
echo -e "${GREEN}3. Games & Other (Non-Server + games/personal)${NC}"
read -p "$(echo -e "${BLUE}Enter choice [1-3]: ${NC}")" installType

case $installType in
    1)
        print_green "Installing Server Packages..."
        install_packages "${servePackages}"
        ;;
    2)
        print_green "Installing Non-Server Packages..."
        install_packages "${servePackages} ${nonServePackages} ${desktopExtras}"
        sudo snap install ${nonServeSnap}
        ;;
    3)
        print_green "Installing Non-Server + Games & Other Packages..."
        install_packages "${servePackages} ${nonServePackages} ${desktopExtras} ${gamesAndOtherPackages}"
        sudo snap install ${nonServeSnap} ${gamesAndOtherSnap}
        ;;
    *)
        print_red "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Add the user to the video group so brightnessctl can write
# /sys/class/backlight/*/brightness without sudo. Required for the
# sway/i3 brightness keybindings to do anything. Takes effect on next login.
print_green "Adding ${USER} to the video group..."
sudo usermod -aG video "${USER}"

# Bind `flameshot gui` to print screen key (Non-Server and Games & Other)
if [ "$installType" = "2" ] || [ "$installType" = "3" ]; then
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot '[]'
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'flameshot'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'flameshot gui'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding 'Print'
fi

# Stow the dotfiles into $HOME
print_green "Stowing dotfiles into \$HOME..."
# .claude/settings.json is skipped: it's machine-specific (hooks, model pin) and
# Claude Code will already have written its own copy.
stow -d "$(dirname "${DOTFILES}")" -t "${HOME}" --ignore='\.claude/settings\.json' "$(basename "${DOTFILES}")"

# Install antidote (zsh plugin manager — replaces oh-my-zsh).
# Plugins listed in ~/.zsh_plugins.txt are cloned lazily on first shell start.
print_green "Installing antidote..."
if [ ! -d "${HOME}/.antidote" ]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "${HOME}/.antidote"
fi

# Install TPM (Tmux Plugin Manager)
print_green "Installing TPM (Tmux Plugin Manager)..."
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

# Install Rust via rustup. --no-modify-path: the dotfiles already source ~/.cargo/env.
print_green "Installing Rust (rustup)..."
if [ ! -x "${HOME}/.cargo/bin/rustup" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
. "${HOME}/.cargo/env"

# Install pay-respects (typo corrector, replaces thefuck). Not in apt.
print_green "Installing pay-respects..."
if ! command -v pay-respects >/dev/null 2>&1; then
    cargo install pay-respects || print_red "pay-respects failed to build (needs a C linker: build-essential)."
fi

# Install atuin (history sync / search)
print_green "Installing atuin..."
if ! command -v atuin >/dev/null 2>&1; then
    bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
fi

# Install Golang
print_green "Installing Golang..."
sudo apt install -y golang


# TODO: SSH Configuration

# TODO: Automatic backup with rsync

# TODO: iptell bootstrapping

# TODO: k8s bootstrapping

# autoremove
print_green "Cleaning Up..."
sudo apt autoremove -y
## END

## Notes.
# I am thinking about these packages. I am not fully sure if I want them,
# so I am leaving them here for now.
# hugo, letsencrypt, clamav, cowsay, cmatrix, ftp??, virtualhub??


## TODO:
# mumble server & setup, create systemd service too.

# wget https://github.com/mumble-voip/mumble/releases/download/1.3.4/murmur-static_x86-1.3.4.tar.bz2
# sudo mkdir /usr/local/murmur
# sudo cp -r ./murmur-static_x86-1.3.4/* /usr/local/murmur/
# sudo cp ./murmur-static_x86-1.3.4/murmur.ini /etc/murmur.ini
# sudo groupadd -r murmur
# sudo useradd -r -g murmur -m -d /var/lib/murmur -s /sbin/nologin murmur
# sudo mkdir /var/log/murmur
# sudo chown murmur:murmur /var/log/murmur
# sudo chmod 0770 /var/log/murmur
# echo "/var/log/murmur/*log {
#  su murmur murmur
#  dateext
#  rotate 4
#  missingok
#  notifempty
#  sharedscripts
#  delaycompress
#  postrotate
#  /bin/systemctl reload murmur.service > /dev/null 2>/dev/null || true
# endscript
# }" | sudo tee -a /etc/logrotate.d/murmur
#
# # edit /etc/murmur.ini
#
# echo "[Unit]
# Description=Mumble Server (Murmur)
# Requires=network-online.target
# After=network-online.target mariadb.service time-sync.target
#
# [Service]
# User=murmur
# Type=forking
# ExecStart=/usr/local/murmur/murmur.x86 -ini /etc/murmur.ini
# PIDFile=/var/run/murmur/murmur.pid
# ExecReload=/bin/kill -s HUP \$MAINPID
#
# [Install]
# WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/murmur.service
#
# sudo ufw allow 64738/tcp
# sudo ufw allow 64738/udp
#
# sudo systemctl start murmur.service



## Taskfile

# is_installed() {
#   if [ -x "$(command -v $1)" ]; then
#     return 0
#   else
#     return 1
#   fi
# }
#
# if ! is_installed "task"; then
#   if ! -d ~/.local/bin; then
#     mkdir -p ~/.local/bin
#   fi
#   sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
# fi
#
