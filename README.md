# dotfiles

Development environment setup: Zsh + Git + Tmux

## Install

```bash
git clone https://github.com/n0ss4/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

## Stack

- Oh My Zsh (Agnoster)
- zsh-autosuggestions, zsh-syntax-highlighting
- Git Delta, Tmux TPM
- eza, bat, fzf, ripgrep

## Commands

```bash
make install          # full setup
make install-minimal  # zsh only
make status          # check state
make test            # validate config
```

## Aliases

```bash
# git
gs gaa gc gp gl gco gcb gd

# docker
dps dcu dcd dlogs

# pnpm
pnd pnb pni

# nav
ll la .. ... reload
```

## Functions

```bash
mkcd <dir>           # mkdir + cd
sysinfo              # system info
backup <file>        # timestamped backup
note [msg]           # quick notes
jswitch <version>    # java version switch
```

## Troubleshoot

```bash
# broken oh-my-zsh
rm -rf ~/.oh-my-zsh && ./install.sh

# reload
source ~/.zshrc
```

## Structure

```
configs/     # .gitconfig, .tmux.conf
zsh/         # modular zsh config
  config/    # exports, aliases, functions, plugins
scripts/     # setup utilities
```

## License

MIT
