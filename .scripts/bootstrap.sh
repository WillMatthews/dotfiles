#!/bin/bash

# Bootstrap script for fresh Ubuntu installs with enhanced visual output

## TODO
# hostname setup? user setup?

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

# Clone dotfiles repository (recursive for kickstart.nvim submodule) and stow it
print_green "Cloning dotfiles repository..."
if [ ! -d "${HOME}/dotfiles" ]; then
    git clone --recursive https://github.com/WillMatthews/dotfiles "${HOME}/dotfiles"
else
    git -C "${HOME}/dotfiles" pull
    git -C "${HOME}/dotfiles" submodule update --init --recursive
fi

# Package lists
regolithPackages="regolith-desktop regolith-session-flashback regolith-look-lascaille"
nonServePackages="manpages groff tty-clock ghci cabal-install make firefox thunderbird filezilla vlc ansiweather flameshot freecad kicad gnuplot handbrake texlive-full ngspice nginx obs-studio qrencode gimp inkscape suckless-tools valgrind units wireshark glances iotop iftop ufw fail2ban mc ncdu ranger python3-pip build-essential git-lfs xfce4-notifyd gnome-tweaks"
servePackages="git stow net-tools neofetch htop btop lm-sensors plocate samba docker.io neovim vim zsh ffmpeg whois pandoc autossh rsync sysstat nethogs jq gnupg openssh-client openssh-server tmux gzip nmap screen speedometer speedtest-cli zip unzip unrar wget curl highlight certbot ripgrep fd-find fzf bat eza zoxide"
gamesAndOtherPackages="openttd steam mumble transmission"
cabalPackages="hakyll" # TODO make cabal work
removePackages="regolith-rofication"

# Snap packages for games-and-other setup
gamesAndOtherSnap="0ad"

# Function to install packages
install_packages() {
    sudo apt install -y $1
    sudo apt remove -y $removePackages
}

# Update and upgrade the system, then autoremove
set -e
print_green "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y


# Interactive Menu for selecting installation type
print_blue "Select Installation Type:"
echo -e "${GREEN}1. Server${NC}"
echo -e "${GREEN}2. Non-Server (desktop, work-suitable)${NC}"
echo -e "${GREEN}3. Games & Other (Non-Server + games/personal)${NC}"
read -p "${BLUE}Enter choice [1-3]: ${NC}" installType

case $installType in
    1)
        print_green "Installing Server Packages..."
        install_packages "${servePackages}"
        ;;
    2)
        print_green "Installing Non-Server Packages..."
        install_packages "${servePackages} ${nonServePackages} ${regolithPackages}"
        ;;
    3)
        print_green "Installing Non-Server + Games & Other Packages..."
        install_packages "${servePackages} ${nonServePackages} ${regolithPackages} ${gamesAndOtherPackages}"
        snap install ${gamesAndOtherSnap}
        ;;
    *)
        print_red "Invalid choice. Exiting."
        exit 1
        ;;
esac

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
cd "${HOME}"
stow -t "${HOME}" dotfiles

# Install oh-my-zsh
print_green "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install TPM (Tmux Plugin Manager)
print_green "Installing TPM (Tmux Plugin Manager)..."
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

# Install zsh-autosuggestions and zsh-syntax-highlighting
print_green "Installing zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

# Install pay-respects (typo corrector, replaces thefuck). Not in apt.
print_green "Installing pay-respects..."
if ! command -v pay-respects >/dev/null 2>&1; then
    if command -v cargo >/dev/null 2>&1; then
        cargo install pay-respects
    else
        print_red "Skipping pay-respects: cargo not found. Install rustup, then 'cargo install pay-respects'."
    fi
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
