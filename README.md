# My Rice

terminal font: https://www.jetbrains.com/lp/mono/

## Overview
Here you can find my configs:
| File                                                                                                    | Description                                                                                     | Project Page                                                                                     |
| ---------------                                                                                         | ----------------------------------------------------------------------------------------------- | -------------------------------------------                                                      |
| [**.bashrc**](https://github.com/WillMatthews/dotfiles/blob/master/.bashrc)                             | Bash shell configuration.                                                                       | [Bash shell](https://www.gnu.org/software/bash/)                                                 |
| [**.ghci**](https://github.com/WillMatthews/dotfiles/blob/master/.ghci)                                 | GHC interactive environment configuration.                                                      | [GHC](https://www.haskell.org/ghc/)                                                              |
| [**.profile**](https://github.com/WillMatthews/dotfiles/blob/master/.profile)                           | Initialisation script for shell sessions.                                                       | [Bash Startup Files](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html) |
| [**.tmux.conf**](https://github.com/WillMatthews/dotfiles/blob/master/.tmux.conf)                       | TMUX terminal multiplexer configuration.                                                        | [TMUX](https://github.com/tmux/tmux)                                                             |
| [**.vimrc**](https://github.com/WillMatthews/dotfiles/blob/master/.vimrc)                               | Standalone Vim config — no plugin dependencies. Use it on servers.                              | [Vim](https://www.vim.org/)                                                                      |
| [**.zshenv**](https://github.com/WillMatthews/dotfiles/blob/master/.zshenv)                             | Environment variables for Zsh.                                                                  | [Zsh](https://www.zsh.org/)                                                                      |
| [**.zshrc**](https://github.com/WillMatthews/dotfiles/blob/master/.zshrc)                               | Zsh configuration file.                                                                         | [Zsh](https://www.zsh.org/)                                                                      |
| [**.zsh_plugins.txt**](https://github.com/WillMatthews/dotfiles/blob/master/.zsh_plugins.txt)           | Plugin manifest loaded by antidote (replaces oh-my-zsh).                                        | [antidote](https://github.com/mattmc3/antidote)                                                  |
| [**.scripts/**](https://github.com/WillMatthews/dotfiles/blob/master/.scripts/)                         | Utility scripts for a variety of tasks.                                                         | [Utility scripts](https://github.com/WillMatthews/dotfiles/blob/master/.scripts/)                |
| [**.config/redshift.conf**](https://github.com/WillMatthews/dotfiles/blob/master/.config/redshift.conf) | Redshift configuration file.                                                                    | [Redshift](https://github.com/jonls/redshift)                                                    |
| [**.config/nvim/**](https://github.com/WillMatthews/dotfiles/blob/master/.config/nvim)                  | Neovim config — git submodule pointing at my kickstart.nvim fork.                               | [kickstart.nvim](https://github.com/WillMatthews/kickstart.nvim)                                 |
| [**.config/i3/config**](https://github.com/WillMatthews/dotfiles/blob/master/.config/i3/config)         | i3 window manager config. Not yet stowed — see note below.                                      | [i3](https://i3wm.org/)                                                                          |
| [**.config/sway/config**](https://github.com/WillMatthews/dotfiles/blob/master/.config/sway/config)     | Sway (Wayland) compositor config, ported from the i3 one.                                       | [sway](https://swaywm.org/)                                                                      |
| [**.config/kitty/kitty.conf**](https://github.com/WillMatthews/dotfiles/blob/master/.config/kitty/kitty.conf) | Kitty terminal — font, scrollback, keymaps, Aged Brass palette.                            | [kitty](https://sw.kovidgoyal.net/kitty/)                                                        |
| [**.config/rofi/**](https://github.com/WillMatthews/dotfiles/blob/master/.config/rofi)                  | Rofi launcher config + `aged-brass.rasi` theme. Not yet stowed — see note below.                | [rofi](https://github.com/davatorium/rofi)                                                       |
| [**.config/dunst/dunstrc**](https://github.com/WillMatthews/dotfiles/blob/master/.config/dunst/dunstrc) | Dunst notification daemon. Aged Brass palette. xfce4-notifyd is also installed; only one wins.  | [dunst](https://github.com/dunst-project/dunst)                                                  |
| [**.config/btop/btop.conf**](https://github.com/WillMatthews/dotfiles/blob/master/.config/btop/btop.conf) | btop system monitor. Not yet stowed — see note below.                                         | [btop](https://github.com/aristocratos/btop)                                                     |
| [**.config/gh/config.yml**](https://github.com/WillMatthews/dotfiles/blob/master/.config/gh/config.yml) | GitHub CLI config + aliases. `hosts.yml` (auth tokens) stays machine-local. Not yet stowed.     | [gh](https://cli.github.com/)                                                                    |
| [**.ripgreprc**](https://github.com/WillMatthews/dotfiles/blob/master/.ripgreprc)                       | Ripgrep defaults (smart-case, glob exclusions, colours). Loaded via `RIPGREP_CONFIG_PATH`.      | [ripgrep](https://github.com/BurntSushi/ripgrep)                                                 |
| [**.claude/settings.json**](https://github.com/WillMatthews/dotfiles/blob/master/.claude/settings.json) | Claude Code settings — theme + Notification BEL hook. `settings.local.json` stays machine-local. Not yet stowed. | [Claude Code](https://docs.claude.com/en/docs/claude-code)                          |
| [**.installed**](https://github.com/WillMatthews/dotfiles/blob/master/.installed)                       | Keeps track of installed applications (not fully up to date).                                   | -                                                                                                |


## The Scripts Directory

The .scripts directory contains my utility scripts, with a special emphasis on the bootstrap scripts for those who appreciate a quick and efficient setup process.

- **bootstrap.sh:** Installs all the important programs you may need. I use this whenever I deploy a new machine or vps.

## Installation

Clone this repo (recursively, to pull in the kickstart.nvim submodule):
```bash
git clone --recursive https://github.com/WillMatthews/dotfiles.git ~/dotfiles
```

If you forgot `--recursive`:
```bash
cd ~/dotfiles && git submodule update --init --recursive
```

Symlink everything into `$HOME` with [GNU stow](https://www.gnu.org/software/stow/):
```bash
cd ~
stow -t ~ dotfiles
```

That symlinks every tracked file in `~/dotfiles/` into `$HOME` (skipping the metadata files listed in `.stow-local-ignore`). To undo:
```bash
cd ~
stow -t ~ -D dotfiles
```

### Not-yet-stowed files

Some configs live in the repo as plain copies because the live file at the corresponding `$HOME` location is still a real file, not a symlink. `stow` will refuse to overlay them until the live file is removed or backed up.

- `.config/i3/config` — copied in on 2026-05-19. Before stowing, `rm ~/.config/i3/config` (or move it aside), then re-run `stow -t ~ dotfiles`.
- `.config/rofi/config.rasi` — replaces the live one-liner pointing at gruvbox. Before stowing, `rm ~/.config/rofi/config.rasi`.
- `.config/btop/btop.conf` — drafted as a verbatim copy of the live file. Either `rm ~/.config/btop/btop.conf` then stow, or `stow --adopt` (safe here since the contents match). Note: `save_config_on_exit = true` means btop will rewrite the file when you change settings via its UI — fine through a symlink.
- `.config/gh/config.yml` — adds aliases + `editor: nvim`. Before stowing, `rm ~/.config/gh/config.yml`. `~/.config/gh/hosts.yml` (auth tokens) is left alone.
- `.claude/settings.json` — adds a Notification hook that emits `BEL` (`\a`) when Claude needs your input. Audibility depends on your terminal's bell setting (in kitty: `enable_audio_bell yes` for audio, otherwise a brief visual flash). Before stowing, `rm ~/.claude/settings.json`. Machine-local permissions (`settings.local.json`) are deliberately not stowed.

### Using Scripts
The scripts within the .scripts directory are designed for direct execution. For detailed usage instructions, consult the comments within each script or execute them with `-h` or `--help` for help information (if it is present!).
Otherwise, each script will tell you what it does in a comment.

I include `.scripts` in my `$PATH`, which you can find in `.zshrc`.
If you don't want my `.zshrc` but still want to include `.scripts` in your `$PATH`, do:
```bash
export PATH=$HOME/.scripts:$PATH
```

## Modern CLI tools

`bootstrap.sh` installs these, but I haven't wired them into my aliases — they're sitting next to the classics so I can opt in per-machine. If you want them as defaults, the snippets are below.

| Tool                                        | What it replaces | Init / alias                                  |
| ------------------------------------------- | ---------------- | --------------------------------------------- |
| [eza](https://github.com/eza-community/eza) | `ls`             | `alias ls='eza'`                              |
| [bat](https://github.com/sharkdp/bat)       | `cat` (and my `ccat`) | `alias cat='bat -p'`                     |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` (frecency) | `eval "$(zoxide init zsh)"`               |
| [atuin](https://github.com/atuinsh/atuin)   | `Ctrl-R` history | `eval "$(atuin init zsh)"`                   |
| [pay-respects](https://github.com/iffse/pay-respects) | `thefuck` | `eval "$(pay-respects zsh --alias)"` (already wired in `.zshrc`) |

## Customisation
**You're encouraged to fork this repository and tweak the dotfiles and scripts to your heart's content, tailoring them to fit your own preferences and workflow.
Make them your own!**

## Contributing
Should you have any suggestions for refining these dotfiles or scripts, please do not hesitate to open an issue or submit a pull request. There are bound to be issues in here!

## Licence
This project is licensed under the MIT License - see the [LICENSE](https://github.com/WillMatthews/dotfiles/LICENSE) file for details.

The MIT License is a permissive free software license originating at the Massachusetts Institute of Technology (MIT). It permits reuse within proprietary software provided that all copies of the licensed software include a copy of the MIT License terms and notices. This license does not protect against patent claims, and it does not include express provisions for the distribution of software modifications.

## Other useful apps I use:
* entr
* [todolist](https://github.com/gammons/todolist)
