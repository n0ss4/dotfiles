export ZSH="$HOME/.oh-my-zsh"

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

export EDITOR='nvim'
export VISUAL='nvim'

export LESS='-R --use-color'
export LESSHISTFILE='-'

export SDKMAN_DIR="$HOME/.sdkman"
export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/.local/share/pnpm"
export VOLTA_HOME="$HOME/.volta"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$VOLTA_HOME/bin:$PATH"

if command -v fzf > /dev/null; then
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f 2>/dev/null'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if command -v bat > /dev/null; then
    export BAT_THEME="Dracula"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi