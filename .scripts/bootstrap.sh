#!/bin/bash

# Bootstrap script for fresh Ubuntu installs with enhanced visual output

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

# Clone dotfiles repository into the home directory
print_green "Cloning dotfiles repository..."
git clone --recursive https://github.com/WillMatthews/dotfiles "${HOME}/dotfiles"
# Copy all files, including hidden ones and the git directory, from dotfiles to home directory
cp -r ${HOME}/dotfiles/. ${HOME}/

# Package lists
regolithPackages="regolith-desktop regolith-session-flashback regolith-look-lascaille"
nonServePackages="manpages groff tty-clock ghci cabal-install make firefox thunderbird filezilla vlc ansiweather flameshot mumble freecad kicad gnuplot handbrake texlive-full ngspice nginx obs-studio openttd qrencode gimp inkscape steam suckless-tools valgrind units transmission wireshark glances ripgrep iotop iftop ufw fail2ban mc ncdu ranger python3-pip build-essential git-lfs"
servePackages="git net-tools neofetch htop btop lm-sensors plocate samba docker.io neovim zsh thefuck ffmpeg whois pandoc autossh rsync sysstat nethogs jq gnupg openssh-client openssh-server tmux gzip nmap screen speedometer speedtest-cli zip unzip unrar wget curl highlight"

# Snap packages for non-server setup
snapNonServe="0ad"

# Function to install packages
install_packages() {
    sudo apt install $1
}

# Update and upgrade the system, then autoremove
set -e
print_green "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade && sudo apt autoremove

# Interactive Menu for selecting installation type
print_blue "Select Installation Type:"
echo -e "${GREEN}1. Server${NC}"
echo -e "${GREEN}2. Non-Server${NC}"
read -p "${BLUE}Enter choice [1-2]: ${NC}" installType

case $installType in
    1)
        print_green "Installing Server Packages..."
        install_packages "${servePackages}"
        ;;
    2)
        print_green "Installing Non-Server Packages..."
        install_packages "${servePackages} ${nonServePackages} ${regolithPackages}"
        snap install ${snapNonServe}

        # TODO: Bind `flameshot gui` to print screen
        ;;
    *)
        print_red "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Install oh-my-zsh
print_green "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Vundle for Vim
print_green "Installing Vundle for Vim..."
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install TPM (Tmux Plugin Manager)
print_green "Installing TPM (Tmux Plugin Manager)..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install zsh-autosuggestions and zsh-syntax-highlighting
print_green "Installing zsh plugins..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install Golang
print_green "Installing Golang..."
sudo apt install -y golang


# TODO: SSH Configuration

# TODO: Automatic backup with rsync

# TODO: iptell bootstrapping

# TODO: k8s bootstrapping

# autoremove
print_green "Cleaning Up..."
sudo apt autoremove
## END

## Notes.
# I am thinking about these packages. I am not fully sure if I want them,
# so I am leaving them here for now.
# hugo, letsencrypt, clamav, cowsay, cmatrix, ftp??, virtualhub??

