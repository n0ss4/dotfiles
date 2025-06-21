#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

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

install_package_manager() {
    case $OS in
        "macos")
            if ! command -v brew >/dev/null 2>&1; then
                print_step "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                print_success "Homebrew installed"
            fi
            ;;
        "linux")
            print_success "Using system package manager"
            ;;
    esac
}

install_tools() {
    print_step "Installing essential development tools..."
    
    case $OS in
        "macos")
            brew install git curl wget tree htop neovim fzf bat eza fd ripgrep
            ;;
        "linux")
            if command -v apt >/dev/null 2>&1; then
                sudo apt update
                sudo apt install -y git curl wget tree htop neovim fzf bat fd-find ripgrep
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y git curl wget tree htop neovim fzf bat fd-find ripgrep
            fi
            ;;
    esac
    
    print_success "Essential tools installed"
}

install_node_tools() {
    print_step "Installing Node.js tools..."
    
    if ! command -v pnpm >/dev/null 2>&1; then
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        print_success "PNPM installed"
    fi
    
    if ! command -v volta >/dev/null 2>&1; then
        curl https://get.volta.sh | bash
        print_success "Volta installed"
    fi
}

install_java_tools() {
    print_step "Installing Java tools..."
    
    if [[ ! -d "$HOME/.sdkman" ]]; then
        curl -s "https://get.sdkman.io" | bash
        print_success "SDKMAN installed"
    fi
}

install_git_tools() {
    print_step "Installing Git tools..."
    
    case $OS in
        "macos")
            brew install git delta
            ;;
        "linux")
            if command -v apt >/dev/null 2>&1; then
                sudo apt install -y git
                wget https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-gnu.tar.gz
                tar -xzf delta-0.16.5-x86_64-unknown-linux-gnu.tar.gz
                sudo mv delta-0.16.5-x86_64-unknown-linux-gnu/delta /usr/local/bin/
            fi
            ;;
    esac
    
    print_success "Git tools installed"
}

install_tmux() {
    print_step "Installing Tmux..."
    
    case $OS in
        "macos")
            brew install tmux
            ;;
        "linux")
            if command -v apt >/dev/null 2>&1; then
                sudo apt install -y tmux
            fi
            ;;
    esac
    
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        print_success "TPM (Tmux Plugin Manager) installed"
    fi
    
    print_success "Tmux installed"
}

main() {
    print_step "Setting up development tools for $OS..."
    
    install_package_manager
    install_tools
    install_git_tools
    install_tmux
    install_node_tools
    install_java_tools
    
    print_success "Development tools setup completed!"
    print_step "Please restart your terminal to use the new tools"
}

echo "What would you like to install?"
echo "1) Essential tools only"
echo "2) Essential + Node.js tools"
echo "3) Essential + Java tools"
echo "4) Everything"
read -p "Choose option (1-4): " choice

case $choice in
    1)
        install_package_manager
        install_tools
        install_git_tools
        install_tmux
        ;;
    2)
        install_package_manager
        install_tools
        install_git_tools
        install_tmux
        install_node_tools
        ;;
    3)
        install_package_manager
        install_tools
        install_git_tools
        install_tmux
        install_java_tools
        ;;
    4)
        main
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac