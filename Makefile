.PHONY: install install-minimal update clean backup test help status tools sync

help:
	@echo "Installation:"
	@echo "  install         - Full installation (interactive)"
	@echo "  install-minimal - Install only Zsh configuration"
	@echo "  install-force   - Force installation (no prompts)"
	@echo ""
	@echo "Maintenance:"
	@echo "  update          - Update dotfiles from repository"
	@echo "  sync            - Pull changes and reload configs"
	@echo "  clean           - Remove broken symlinks"
	@echo "  backup          - Backup current configurations"
	@echo ""
	@echo "Development:"
	@echo "  test            - Test configurations"
	@echo "  status          - Show installation status"
	@echo "  tools           - Install development tools only"
	@echo ""
	@echo "Git:"
	@echo "  push            - Add, commit and push changes"
	@echo "  pull            - Pull latest changes"

install:
	@echo "🔧 Starting full dotfiles installation..."
	@chmod +x install.sh
	@./install.sh

install-minimal:
	@echo "🔧 Starting minimal installation..."
	@chmod +x install.sh
	@./install.sh --minimal

install-force:
	@echo "🔧 Starting forced installation..."
	@chmod +x install.sh
	@./install.sh --force

tools:
	@echo "🛠️ Installing development tools..."
	@if [ -f scripts/setup-tools.sh ]; then \
		chmod +x scripts/setup-tools.sh; \
		./scripts/setup-tools.sh; \
	else \
		echo "❌ setup-tools.sh not found"; \
	fi

update:
	@echo "📥 Updating dotfiles repository..."
	@git pull origin main
	@echo "✅ Dotfiles updated successfully"
	@echo "💡 Restart your terminal or run 'source ~/.zshrc' to apply changes"

sync: update
	@echo "🔄 Reloading configurations..."
	@if [ -n "$$ZSH_VERSION" ]; then \
		echo "Reloading Zsh..."; \
		exec zsh; \
	fi
	@echo "✅ Sync completed"

clean:
	@echo "🧹 Cleaning broken symlinks..."
	@find ~ -maxdepth 1 -name ".*" -type l ! -exec test -e {} \; -delete 2>/dev/null || true
	@find ~/.config -maxdepth 2 -name "*.zsh" -type l ! -exec test -e {} \; -delete 2>/dev/null || true
	@echo "✅ Broken symlinks cleaned"

backup:
	@echo "💾 Creating backup..."
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@cp ~/.zshrc backups/$(shell date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@cp ~/.gitconfig backups/$(shell date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@cp ~/.tmux.conf backups/$(shell date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@cp -r ~/.config/zsh backups/$(shell date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@echo "✅ Backup created in backups/$(shell date +%Y%m%d_%H%M%S)"

test:
	@echo "🧪 Testing configurations..."
	@echo "Testing Zsh syntax..."
	@if [ -f zsh/zshrc ]; then \
		zsh -n zsh/zshrc && echo "✅ Zsh config syntax OK"; \
	else \
		echo "❌ zsh/zshrc not found"; \
	fi
	@echo "Testing symlinks..."
	@if [ -L ~/.zshrc ]; then \
		echo "✅ ~/.zshrc symlink exists"; \
	else \
		echo "❌ ~/.zshrc symlink missing"; \
	fi
	@if [ -L ~/.gitconfig ]; then \
		echo "✅ ~/.gitconfig symlink exists"; \
	else \
		echo "❌ ~/.gitconfig symlink missing"; \
	fi
	@if [ -L ~/.tmux.conf ]; then \
		echo "✅ ~/.tmux.conf symlink exists"; \
	else \
		echo "❌ ~/.tmux.conf symlink missing"; \
	fi

status:
	@echo "Core configurations:"
	@if [ -L ~/.zshrc ]; then \
		echo "✅ Zsh configuration: $(shell readlink ~/.zshrc)"; \
	else \
		echo "❌ Zsh configuration: Not linked"; \
	fi
	@if [ -L ~/.gitconfig ]; then \
		echo "✅ Git configuration: $(shell readlink ~/.gitconfig)"; \
	else \
		echo "❌ Git configuration: Not linked"; \
	fi
	@if [ -L ~/.tmux.conf ]; then \
		echo "✅ Tmux configuration: $(shell readlink ~/.tmux.conf)"; \
	else \
		echo "❌ Tmux configuration: Not linked"; \
	fi
	@echo ""
	@echo "Zsh plugins:"
	@if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then \
		echo "✅ zsh-autosuggestions"; \
	else \
		echo "❌ zsh-autosuggestions"; \
	fi
	@if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then \
		echo "✅ zsh-syntax-highlighting"; \
	else \
		echo "❌ zsh-syntax-highlighting"; \
	fi
	@echo ""
	@echo "Tools:"
	@if command -v git >/dev/null 2>&1; then \
		echo "✅ Git: $(shell git --version)"; \
	else \
		echo "❌ Git: Not installed"; \
	fi
	@if command -v tmux >/dev/null 2>&1; then \
		echo "✅ Tmux: $(shell tmux -V)"; \
	else \
		echo "❌ Tmux: Not installed"; \
	fi
	@if command -v delta >/dev/null 2>&1; then \
		echo "✅ Delta: $(shell delta --version)"; \
	else \
		echo "❌ Delta: Not installed"; \
	fi

push:
	@echo "📤 Pushing changes to repository..."
	@git add .
	@read -p "Enter commit message: " msg; \
	git commit -m "$$msg"
	@git push origin main
	@echo "✅ Changes pushed successfully"

pull:
	@echo "📥 Pulling latest changes..."
	@git pull origin main
	@echo "✅ Repository updated"

uninstall:
	@echo "🗑️ Uninstalling dotfiles..."
	@echo "⚠️ This will remove all symlinks but keep backups"
	@read -p "Are you sure? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -f ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.gitignore_global; \
		rm -rf ~/.config/zsh; \
		echo "✅ Dotfiles uninstalled"; \
		echo "💡 Your original files are in backup folders"; \
	else \
		echo "❌ Uninstall cancelled"; \
	fi

edit-zsh:
	@$(EDITOR) zsh/zshrc

edit-git:
	@$(EDITOR) configs/.gitconfig

edit-tmux:
	@$(EDITOR) configs/.tmux.conf

info:
	@echo "📁 Repository Information"
	@echo "========================"
	@echo "Location: $(PWD)"
	@echo "Remote: $(shell git remote get-url origin 2>/dev/null || echo 'Not a git repository')"
	@echo "Branch: $(shell git branch --show-current 2>/dev/null || echo 'Unknown')"
	@echo "Last commit: $(shell git log -1 --pretty=format:'%h - %s (%cr)' 2>/dev/null || echo 'No commits')"
	@echo "Files tracked: $(shell find . -name '*.zsh' -o -name '.gitconfig' -o -name '.tmux.conf' | wc -l)"