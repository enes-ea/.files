#!/usr/bin/env bash
# Rofi keybind search — clean lines, no table syntax
set -euo pipefail

MD="$HOME/.files/keybinds/KEYBINDS.md"
[ -f "$MD" ] || MD="$(dirname "$0")/KEYBINDS.md"
[ -f "$MD" ] || { notify-send "keybinds" "KEYBINDS.md not found"; exit 1; }

# Build awk script with embedded emoji as shell vars, then pass via -v
KITTY=Kitty
NEOVIM=Neovim
MANGO=Mango
FISH=Fish

selected=$(
  gawk -F'|' -v kitty="$KITTY" -v neovim="$NEOVIM" -v mango="$MANGO" -v fish="$FISH" '
    function clean(s) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
      gsub(/\*\*/, "", s)
      gsub(/^`|`$/, "", s)
      return s
    }
    BEGIN { section = "" }
    /^## / {
      section = $0
      gsub(/^## +([0-9]+\. +)?/, "", section)
      gsub(/ +$/, "", section)
      sec9 = (section ~ /Layout/) ? 1 : 0
    }
    /^\| `[^`]+` \|/ && section !~ /^(Legend|Conflict|Modifier)/ && section != "Shell Commands (Fish)" {
      shortcut = clean($2)
      if (shortcut ~ /^-+$|^(Shortcut|Command)$/) next
      if (sec9) {
        val = clean($3)
        if (val ~ /[[:alnum:]]/) print mango ": " shortcut "  \u2192  " val
      } else {
        for (i = 3; i <= 6; i++) {
          ico = (i==3 ? kitty : i==4 ? neovim : i==5 ? mango : fish)
          val = clean($i)
          if (val ~ /[[:alnum:]]/) print ico " " shortcut "  \u2192  " val
        }
      }
    }
    /^\| `[^`]+` \|/ && section == "Shell Commands (Fish)" {
      cmd  = clean($2)
      typ  = clean($3)
      xval = clean($4)
      notes = clean($5)
      if (cmd ~ /^-+$|^(Command)$/) next
      desc = typ ? "[" typ "] " xval : xval
      if (notes) desc = desc "  (" notes ")"
      print fish " " cmd "  \u2192  " desc
    }
  ' "$MD" | rofi -dmenu -p "keybinds" -theme-str 'prompt { text-color: #be95ff; }' -i -width 100 -no-custom
)

if [ -n "$selected" ]; then
  notify-send "Keybind" "$selected"
fi
