#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/usr/lib/X11/xinit/.Xresources
sysmodmap=/usr/lib/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f $userresources ]; then
    xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

# Start the window manager:
if [ -x /usr/bin/ck-launch-session ]; then
	LAUNCH="ck-launch-session"
else
	LAUNCH=""
fi
if [ -x /usr/bin/dbus-launch ]; then
	LAUNCH="$LAUNCH dbus-launch"
fi
exec $LAUNCH /usr/bin/mate-session
