mkcd() {
    mkdir -p "$1" && cd "$1"
}

jswitch() {
    if [ -z "$1" ]; then
        echo "Usage: jswitch <version>"
        echo "📋 Installed versions:"
        sdk list java | grep "installed" 2>/dev/null
    else
        if sdk use java "$1" 2>/dev/null; then
            echo "✅ Switched to Java $1"
            java -version 2>&1 | head -n 1
        else
            echo "❌ Java version '$1' not found"
        fi
    fi
}

pnpm-info() {
    echo "📦 PNPM Information:"
    if command -v pnpm >/dev/null 2>&1; then
        echo "  Version: $(pnpm --version)"
        echo "  Store path: $(pnpm store path 2>/dev/null || echo 'N/A')"
    else
        echo "  ❌ PNPM not installed"
    fi
}

sysinfo() {
    echo "🖥️  System Information:"
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Shell: $SHELL"
    if command -v node >/dev/null 2>&1; then
        echo "  Node.js: $(node --version)"
    fi
}

backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    cp "$1" "$1.backup.$timestamp"
    echo "✅ Backup created: $1.backup.$timestamp"
}

note() {
    local note_file="$HOME/notes.txt"
    
    case "$1" in
        "")
            [[ -f "$note_file" ]] && cat "$note_file" || echo "📝 No notes found."
            ;;
        "--clear" | "-c")
            > "$note_file" && echo "🗑️ All notes cleared"
            ;;
        *)
            echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$note_file"
            echo "✅ Note added"
            ;;
    esac
}