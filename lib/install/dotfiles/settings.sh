# ------------------------------------------------------
# Restore ML4W Hyprland Settings app
# ------------------------------------------------------
_writeLogHeader "Settings"
_writeLog 0 "Starting restore settings"

# (Removed all ml4w waybar settings reset blocks)
# (TODO: Add custom waybar settings reset blocks)

# Replace dunst_position
if [ -f ~/.config/ml4w/settings/dunst_position.sh ]; then
    replace_value=$(cat ~/.config/ml4w/settings/dunst_position.sh)
    search_str="origin"
    replace_str="\ \ \ \ origin = $replace_value"
    _replaceLineInFileCheckpoint "$search_str" "$replace_str" "global" "$HOME/.config/dunst/dunstrc"
    _writeLog 1 "dunst_position restored"
fi

# Replace hypridle_hyprlock_timeout
if [ -f ~/.config/ml4w/settings/hypridle_hyprlock_timeout.sh ]; then
    replace_value=$(cat ~/.config/ml4w/settings/hypridle_hyprlock_timeout.sh)
    search_str="timeout"
    replace_str="\ \ \ \ timeout = $replace_value"
    _replaceLineInFileCheckpoint "$search_str" "$replace_str" "HYPRLOCK TIMEOUT" "$HOME/.config/hypr/hypridle.conf"
    _writeLog 1 "hypridle_hyprlock_timeout restored"
fi

# Replace hypridle_dpms_timeout
if [ -f ~/.config/ml4w/settings/hypridle_dpms_timeout.sh ]; then
    replace_value=$(cat ~/.config/ml4w/settings/hypridle_dpms_timeout.sh)
    search_str="timeout"
    replace_str="\ \ \ \ timeout = $replace_value"
    _replaceLineInFileCheckpoint "$search_str" "$replace_str" "DPMS TIMEOUT" "$HOME/.config/hypr/hypridle.conf"
    _writeLog 1 "hypridle_dpms_timeout restored"
fi

# Replace hypridle_suspend_timeout
if [ -f ~/.config/ml4w/settings/hypridle_suspend_timeout.sh ]; then
    replace_value=$(cat ~/.config/ml4w/settings/hypridle_suspend_timeout.sh)
    search_str="timeout"
    replace_str="\ \ \ \ timeout = $replace_value"
    _replaceLineInFileCheckpoint "$search_str" "$replace_str" "SUSPEND TIMEOUT" "$HOME/.config/hypr/hypridle.conf"
    _writeLog 1 "hypridle_suspend_timeout restored"
fi

echo