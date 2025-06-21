#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${PURPLE}ℹ${NC} $1"
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

backup_file() {
    local file="$1"
    if [[ -f "$file" || -L "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$file" "$backup"
        print_warning "Backed up existing $file to $backup"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    local target_dir="$(dirname "$target")"
    
    [[ ! -d "$target_dir" ]] && mkdir -p "$target_dir"
    
    backup_file "$target"
    
    ln -sf "$source" "$target"
    print_success "Linked $source -> $target"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_oh_my_zsh() {
    print_step "Setting up Oh My Zsh..."
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_success "Oh My Zsh already installed"
    fi
    
    print_info "Installing Zsh plugins..."
    
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "Installed zsh-autosuggestions"
    fi
    
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "Installed zsh-syntax-highlighting"
    fi
    
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
        print_success "Installed zsh-completions"
    fi
}

setup_zsh_config() {
    print_step "Setting up Zsh configuration..."
    
    mkdir -p "$HOME/.config/zsh/config"
    mkdir -p "$HOME/.config/zsh/local"
    
    create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
    
    for config_file in "$DOTFILES_DIR/zsh/config"/*.zsh; do
        if [[ -f "$config_file" ]]; then
            filename="$(basename "$config_file")"
            create_symlink "$config_file" "$HOME/.config/zsh/config/$filename"
        fi
    done
    
    print_success "Zsh configuration linked"
}

setup_git_config() {
    print_step "Setting up Git configuration..."
    
    if [[ -f "$DOTFILES_DIR/configs/.gitconfig" ]]; then
        create_symlink "$DOTFILES_DIR/configs/.gitconfig" "$HOME/.gitconfig"
    fi
    
    if [[ -f "$DOTFILES_DIR/configs/.gitignore_global" ]]; then
        create_symlink "$DOTFILES_DIR/configs/.gitignore_global" "$HOME/.gitignore_global"
    fi
    
    if ! git config --global user.name >/dev/null 2>&1; then
        print_warning "Git user.name not configured"
        read -p "Enter your full name: " git_name
        git config --global user.name "$git_name"
    fi
    
    if ! git config --global user.email >/dev/null 2>&1; then
        print_warning "Git user.email not configured"
        read -p "Enter your email: " git_email
        git config --global user.email "$git_email"
    fi
    
    print_success "Git configuration completed"
}

setup_tmux_config() {
    print_step "Setting up Tmux configuration..."
    
    if [[ -f "$DOTFILES_DIR/configs/.tmux.conf" ]]; then
        create_symlink "$DOTFILES_DIR/configs/.tmux.conf" "$HOME/.tmux.conf"
    fi
    
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        print_success "TPM installed"
        print_info "Run 'tmux' and press Prefix + I to install plugins"
    else
        print_success "TPM already installed"
    fi
    
    print_success "Tmux configuration completed"
}

install_essential_tools() {
    print_step "Installing essential tools..."
    
    case $OS in
        "macos")
            if ! command_exists brew; then
                print_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                if [[ -f "/opt/homebrew/bin/brew" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            fi
            
            print_info "Installing tools via Homebrew..."
            brew install git curl wget tree htop neovim fzf bat eza fd ripgrep tmux git-delta
            ;;
        "linux")
            print_info "Installing tools via package manager..."
            if command_exists apt; then
                sudo apt update
                sudo apt install -y git curl wget tree htop neovim fzf bat fd-find ripgrep tmux
                
                if ! command_exists delta; then
                    print_info "Installing delta..."
                    DELTA_VERSION="0.16.5"
                    wget "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
                    tar -xzf "delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
                    sudo mv "delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu/delta" /usr/local/bin/
                    rm -rf "delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu"*
                    print_success "Delta installed"
                fi
                
                if ! command_exists eza; then
                    print_info "Installing eza..."
                    wget -c https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O - | tar xz
                    sudo mv eza /usr/local/bin/
                    print_success "Eza installed"
                fi
            elif command_exists yum; then
                sudo yum install -y git curl wget tree htop neovim fzf ripgrep tmux
            elif command_exists pacman; then
                sudo pacman -S --noconfirm git curl wget tree htop neovim fzf bat eza fd ripgrep tmux
            fi
            ;;
    esac
    
    print_success "Essential tools installed"
}

set_default_shell() {
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_step "Setting Zsh as default shell..."
        if command_exists zsh; then
            if ! grep -q "$(which zsh)" /etc/shells; then
                echo "$(which zsh)" | sudo tee -a /etc/shells
            fi
            sudo chsh -s "$(which zsh)" "$USER"
            print_success "Default shell changed to Zsh"
            print_warning "Please restart your terminal for changes to take effect"
        else
            print_error "Zsh not found. Please install Zsh first."
            return 1
        fi
    else
        print_success "Zsh is already the default shell"
    fi
}

show_completion_message() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}🚀 Dotfiles installation completed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. For Tmux: run 'tmux' and press Ctrl+a I to install plugins"
    echo "3. For Git: verify your configuration with 'git config --list'"
    echo
    echo -e "${BLUE}Useful commands:${NC}"
    echo "• git lg          - Beautiful git log"
    echo "• git summary     - Repository overview"
    echo "• sysinfo         - System information"
    echo "• pnpm-info       - PNPM details"
    echo "• jswitch <ver>   - Switch Java versions"
    echo
    echo -e "${BLUE}Tmux shortcuts (Prefix = Ctrl+a):${NC}"
    echo "• Ctrl+a |        - Split horizontally"
    echo "• Ctrl+a -        - Split vertically"
    echo "• Ctrl+a r        - Reload config"
    echo
    echo -e "${YELLOW}💡 Run 'make help' for more commands${NC}"
}

main() {
    echo -e "${PURPLE}🔧 Starting dotfiles installation...${NC}"
    echo -e "${PURPLE}OS detected: $OS${NC}"
    echo
    
    install_oh_my_zsh
    setup_zsh_config
    setup_git_config
    setup_tmux_config
    
    echo
    read -p "Install essential development tools? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_essential_tools
    fi
    
    echo
    read -p "Install additional development tools (Node.js, Java, Docker)? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ -f "$DOTFILES_DIR/scripts/setup-tools.sh" ]]; then
            bash "$DOTFILES_DIR/scripts/setup-tools.sh"
        else
            print_warning "setup-tools.sh not found, skipping additional tools"
        fi
    fi
    
    set_default_shell
    
    show_completion_message
}

usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --minimal      Install only Zsh configuration"
    echo "  --no-tools     Skip tool installation"
    echo "  --force        Force installation (skip confirmations)"
}

MINIMAL=false
NO_TOOLS=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --minimal)
            MINIMAL=true
            shift
            ;;
        --no-tools)
            NO_TOOLS=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [[ "$MINIMAL" == true ]]; then
    print_info "Running minimal installation (Zsh only)..."
    install_oh_my_zsh
    setup_zsh_config
    set_default_shell
    show_completion_message
elif [[ "$NO_TOOLS" == true ]]; then
    print_info "Installing configurations without tools..."
    install_oh_my_zsh
    setup_zsh_config
    setup_git_config
    setup_tmux_config
    set_default_shell
    show_completion_message
else
    main
fi