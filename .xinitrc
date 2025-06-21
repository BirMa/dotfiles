#!/bin/bash

####### debug helper funcs ##################################################
_xinitrc_print_pre() {
  echo -e "xinitrc: starting $1 time: $(date +%s)/$(date)" >> ~/logs/xinitrc.log
}
_xinitrc_print_post() {
  echo -e "xinitrc: done     $1 time: $(date +%s)/$(date)" >> ~/logs/xinitrc.log
}
_xinitrc_print_msg() {
  echo -e "xinitrc: msg $1 time: $(date +%s)/$(date)" >> ~/logs/xinitrc.log
}
#############################################################################


_xinitrc_print_pre


_xinitrc_print_pre 'etc_xinitrc.d'
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi
_xinitrc_print_post 'etc_xinitrc.d'


# Merge my xresources config files
#xrdb -merge "$XDG_CONFIG_HOME/Xresources/00-main"
if test -d "$XDG_CONFIG_HOME/Xresources"; then
	for xResFile in "$XDG_CONFIG_HOME/Xresources"/*; do
    _xinitrc_print_msg "merging xresource file: $xResFile..."
		test -r "$xResFile" && xrdb -merge "$xResFile"
	done
	unset xResFile
fi

# disable beep (X-style)
xset b 0

# set the key repeat rate and delay to my fav. volumes (X-style)
xset r rate 250 30

# Prepend my personal font folders to Xorg's list of known font paths
declare -a custom_font_dirs=(
    "$XDG_DATA_HOME/fonts/truetype"
    "$XDG_DATA_HOME/fonts/type1"
)
for i in "${custom_font_dirs[@]}"
do
    if [[ ! -f "$i" ]]; then
        echo "fonts.scale and fonts.dir missing in '$i'. Generating them now..."
        mkfontscale "$i"
        mkfontdir "$i"
    fi
    xset +fp "$i"
done

####### start some useful things before the WM ##############################

#_xinitrc_print_pre 'bash' 'devmon'
#devmon --sync --exec-on-drive 'notify-send "mount %l" "<b>%f</b> => <b>%d</b>"' --exec-on-unmount 'notify-send "unmount %l" "<b>%f</b> => <b>%d</b>"' --exec-on-remove 'notify-send "remove <b>%f</b>"' &
#_xinitrc_print_post 'bash' 'devmon'


#_xinitrc_print_pre 'nvidia modprobe'
#sudo sh -c 'modprobe -r nvidia_drm ; modprobe nvidia_drm modeset=1'
#nvidia-modprobe --modeset #Maybe this does exactly the above and it's already suid root:root
#_xinitrc_print_post 'nvidia modprobe'

#############################################################################


session=${1:-awesome}

#export DESKTOP_SESSION=plasma
#exec startplasma-x11

_xinitrc_print_pre 'WM'
case $session in
    awesome           ) exec "awesome";; # exec dbus-launch --autolaunch=$(cat /var/lib/dbus/machine-id) awesome
    bspwm             ) exec "bspwm";;
    catwm             ) exec "catwm";;
    cinnamon          ) exec "cinnamon-session";;
    dwm               ) exec "dwm";;
    enlightenment     ) exec "enlightenment_start";;
    ede               ) exec "startede";;
    fluxbox           ) exec "startfluxbox";;
    gnome             ) exec "gnome-session";;
    gnome-classic     ) exec "gnome-session --session=gnome-classic";;
    i3|i3wm           ) exec "i3";;
    icewm             ) exec "icewm-session";;
    jwm               ) exec "jwm";;
    kde               ) exec "startkde";;
    mate              ) exec "mate-session";;
    monster|monsterwm ) exec "monsterwm";;
    notion            ) exec "notion";;
    openbox           ) exec "openbox-session";;
    unity             ) exec "unity";;
    xfce|xfce4        ) exec "xfce4-session";;
    xmonad            ) exec "xmonad";;
    *)
    echo -e "\\n\\nxinitrc: DEBUG: args: '$*'\\n\\n" >> ~/logs/xinitrc.log
    echo "xinitrc: ERROR: '$session' seems to be nonsense; lets try running it as a command! ..." >> ~/logs/xinitrc.log
    exec "$1"
    ;;
esac

# We'll get here in case of error.
_xinitrc_print_post 'WM'
