#!/usr/bin/env bash

folder="$HOME/Documents/Notes/"
mkdir -p "$folder"

# Auto-detect terminal
if [[ -z "$TERMINAL" ]]; then
    if command -v kitty >/dev/null 2>&1; then
        TERMINAL="kitty"
    elif command -v alacritty >/dev/null 2>&1; then
        TERMINAL="alacritty -e"
    elif command -v foot >/dev/null 2>&1; then
        TERMINAL="foot"
    elif command -v wezterm >/dev/null 2>&1; then
        TERMINAL="wezterm start --"
    else
        notify-send "Error" "No terminal found. Install kitty, alacritty, or foot."
        exit 1
    fi
fi

# Get existing notes
cd "$folder" || exit 1
notes=$(find . -name "*.md" -type f -printf "%f\n" 2>/dev/null | sort -r)

# Build menu options
if [[ -n "$notes" ]]; then
    options="New Note\n$notes"
else
    options="New Note"
fi

# Show menu - uses your default rofi theme from config.rasi
choice=$(echo -e "$options" | rofi -dmenu -i -p "Notes:" -l 10)

case "$choice" in
    "New Note"|"")
        name=$(rofi -dmenu -p "Note name (optional):")
        [[ -z "$name" ]] && name="$(date +%F_%H-%M-%S)"
        name="${name%.md}"  # Remove .md if user added it
        $TERMINAL nvim "$folder$name.md" &
        ;;
    *.md)
        $TERMINAL nvim "$folder$choice" &
        ;;
esac
