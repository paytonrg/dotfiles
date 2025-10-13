#!/usr/bin/env bash

# Configuration
folder="$HOME/Documents/Notes/"
mkdir -p "$folder"

# Auto-detect terminal for Sway/Wayland
detect_terminal() {
    if [[ -n "$TERMINAL" ]]; then
        echo "$TERMINAL"
    elif command -v kitty >/dev/null 2>&1; then
        echo "kitty"
    elif command -v foot >/dev/null 2>&1; then
        echo "foot"
    elif command -v alacritty >/dev/null 2>&1; then
        echo "alacritty"
    elif command -v wezterm >/dev/null 2>&1; then
        echo "wezterm start --"
    else
        notify-send "Notes Error" "No terminal found. Install kitty, foot, or alacritty."
        exit 1
    fi
}

# When rofi calls with no args, list options
if [[ -z "$@" ]]; then
    # Add option for timestamp note at the top
    echo "New note (timestamp)"
    cd "$folder" || exit 1
    # List existing notes
    find . -maxdepth 1 -name "*.md" -type f -printf "%f\n" 2>/dev/null | sort -r
    exit 0
fi

# Handle selection
choice="$@"
TERMINAL=$(detect_terminal)

# Special case for timestamp note
if [[ "$choice" == "New note (timestamp)" ]]; then
    name="$(date +%F_%H-%M-%S)"
    swaymsg exec "$TERMINAL nvim '$folder$name.md'" >/dev/null 2>&1
    exit 0
fi

# Check if the selected note exists (existing note)
if [[ -f "$folder$choice" ]]; then
    # Open existing note and exit immediately
    swaymsg exec "$TERMINAL nvim '$folder$choice'" >/dev/null 2>&1
    exit 0
fi

# Create new note with typed name
# Sanitize filename
name=$(echo "$choice" | tr -d '/\\' | tr ' ' '_')
name="${name%.md}"  # Remove .md if user added it

# Launch terminal with editor and exit immediately
swaymsg exec "$TERMINAL nvim '$folder$name.md'" >/dev/null 2>&1
exit 0
