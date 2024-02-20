# My Rice

## Overview
Here you can find my configs:
| File          | Description                                                                                   | Project Page                              |
|---------------|-----------------------------------------------------------------------------------------------|-------------------------------------------|
| [**.bashrc**](https://github.com/WillMatthews/dotfiles/.bashrc) | Bash shell configuration. | [Bash shell](https://www.gnu.org/software/bash/) |
| [**.ghci**](https://github.com/WillMatthews/dotfiles/.ghci) | GHC interactive environment configuration. | [GHC](https://www.haskell.org/ghc/) |
| [**.profile**](https://github.com/WillMatthews/dotfiles/.profile) | Initialisation script for shell sessions. | [Bash Startup Files](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html) |
| [**.tmux.conf**](https://github.com/WillMatthews/dotfiles/.tmux.conf) | TMUX terminal multiplexer configuration. | [TMUX](https://github.com/tmux/tmux) |
| [**.vimrc**](https://github.com/WillMatthews/dotfiles/.vimrc) | Vim text editor configuration. | [Vim](https://www.vim.org/), moving to [Neovim](https://neovim.io/) |
| [**.xbashrc**](https://github.com/WillMatthews/dotfiles/.xbashrc) | Bash configuration for specific scenarios. | [Bash shell](https://www.gnu.org/software/bash/) |
| [**.zshenv**](https://github.com/WillMatthews/dotfiles/.zshenv) | Environment variables for Zsh. | [Zsh](https://www.zsh.org/) |
| [**.zshrc**](https://github.com/WillMatthews/dotfiles/.zshrc) | Zsh configuration file. | [Zsh](https://www.zsh.org/) |
| [**.scripts/**](https://github.com/WillMatthews/dotfiles/.scripts/) | Utility scripts for a variety of tasks. | [Utility scripts](https://github.com/WillMatthews/dotfiles/.scripts/) |
| [**.installed**](https://github.com/WillMatthews/dotfiles/.installed) | Keeps track of installed applications (not fully up to date). | - |





## The Scripts Directory

The .scripts directory contains my utility scripts, with a special emphasis on the bootstrap scripts for those who appreciate a quick and efficient setup process.

- **bootstrap.sh:** Installs all the important programs you may need. I use this whenever I deploy a new machine or vps.

## Installation

Clone this repo to your local machine:
```bash
git clone https://github.com/WillMatthews/dotfiles.git
cd dotfiles
```

Symlink the dotfiles you wish to adopt into your home directory. For instance, to use the .vimrc:
```bash
ln -s $(pwd)/.vimrc ~/.vimrc
```

In my use, I just `mv` everything into my home directory. The .gitignore only includes the files in this repo, so it's easy to manage them. Other files in your home directory will not interfere.
```bash
cd dotfiles
mv * ~/
mv .* ~/
```


### Using Scripts
The scripts within the .scripts directory are designed for direct execution. For detailed usage instructions, consult the comments within each script or execute them with `-h` or `--help` for help information (if it is present!). 
Otherwise, each script will tell you what it does in a comment.

I include `.scripts` in my `$PATH`, which you can find in `.zshrc`.
If you don't want my `.zshrc` but still want to include `.scripts` in your `$PATH`, do:
```bash
export PATH=$HOME/.scripts:$PATH 
```

## Customisation
**You’re encouraged to fork this repository and tweak the dotfiles and scripts to your heart's content, tailoring them to fit your own preferences and workflow.
Make them your own!**

## Contributing
Should you have any suggestions for refining these dotfiles or scripts, please do not hesitate to open an issue or submit a pull request. There are bound to be issues in here!

## Licence
This project is licensed under the MIT License - see the [LICENSE](https://github.com/WillMatthews/dotfiles/LICENSE) file for details.

The MIT License is a permissive free software license originating at the Massachusetts Institute of Technology (MIT). It permits reuse within proprietary software provided that all copies of the licensed software include a copy of the MIT License terms and notices. This license does not protect against patent claims, and it does not include express provisions for the distribution of software modifications.

## Other useful apps I use:
* entr
* [todolist](https://github.com/gammons/todolist)
