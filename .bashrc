#! /usr/bin/bash
# user specific (bash) interactive stuff

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

askStartX

false && [[ -s /usr/share/blesh/ble.sh ]] && {
  source /usr/share/blesh/ble.sh
  bleopt exec_errexit_mark=
  # TODO - need to unbind C-r, fzf search is better
}

[[ -s /etc/profile.d/autojump.sh ]] && source /etc/profile.d/autojump.sh

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION

[[ -s "$XDG_CONFIG_HOME/broot/launcher/bash/br" ]] && source "$XDG_CONFIG_HOME/broot/launcher/bash/br"

if which starship &>/dev/null; then eval "$(starship init bash)"; fi

# user specific aliases
alias v='$HOME/bin/_vid'
alias heroes_3_shell_with_prefix='export WINEPREFIX="$HOME/.local/share/Lutris_Games/gog/heroes-of-might-and-magic-iii" && cd "$WINEPREFIX/drive_c/GOG Games/HoMM 3 Complete"'

function walk {
  cd "$(/usr/bin/walk "$@")" || echo "cd failed"
}

echo -e "\e[7m░░░░░░░░░░░░░░░░░░░░░░░\e[0m"
echo -e "\e[7m░░▄▀▄▀▀▀▀▄▀▄░░░░░░░░░░░\e[0m"
echo -e "\e[7m░░█░░░░░░░░▀▄░░░░░░▄░░░\e[0m"
echo -e "\e[7m░█░░▀░░▀░░░░░▀▄▄░░█░█░░\e[0m"
echo -e "\e[7m░█░▄░█▀░▄░░░░░░░▀▀░░█░░\e[0m"
echo -e "\e[7m░█░░▀▀▀▀░░░░░░░░░░░░█░░\e[0m"
echo -e "\e[7m░█░░░░░░░░░░░░░░░░░░█░░\e[0m"
echo -e "\e[7m░█░░░░░░░░░░░░░░░░░░█░░\e[0m"
echo -e "\e[7m░░█░░▄▄░░▄▄▄▄░░▄▄░░█░░░\e[0m"
echo -e "\e[7m░░█░▄▀█░▄▀░░█░▄▀█░▄▀░░░\e[0m"
echo -e "\e[7m░░░▀░░░▀░░░░░▀░░░▀░░░░░\e[0m"
echo -e "\e[7m░░░░░░░░░░░░░░░░░░░░░░░\e[0m"
echo "The dog has infected your terminal."
