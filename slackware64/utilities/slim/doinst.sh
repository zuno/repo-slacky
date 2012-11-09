#!/bin/sh
cat /etc/rc.d/rc.4 > /etc/rc.d/rc.4.before_slim
cat << EOF > /etc/rc.d/rc.4
#!/bin/sh
#
# rc.4		This file is executed by init(8) when the system is being
#		initialized for run level 4 (XDM)
#
# Version:	@(#)/etc/rc.d/rc.4	2.01	07/01/06
#
# Author:	Fred N. van Kempen, <waltje@uwalt.nl.mugnet.org>
# At least 47% rewritten by:  Patrick J. Volkerding <volkerdi@slackware.com>
# Modified (0.1%) by: Sergio Perticone <gallows@tiscali.it>
#

# Tell the viewers what's going to happen...
echo "Starting up X11 session manager..."

# Ok, slim should starts now:
if [ -x /usr/bin/slim ]; then
  exec /usr/bin/slim
fi

# Try to use GNOME's gdm session manager:
if [ -x /usr/bin/gdm ]; then
  exec /usr/bin/gdm -nodaemon
fi

# Not there?  OK, try to use KDE's kdm session manager:
if [ -x /opt/kde/bin/kdm ]; then
  exec /opt/kde/bin/kdm -nodaemon
fi

# If all you have is XDM, I guess it will have to do:
if [ -x /usr/X11R6/bin/xdm ]; then
  exec /usr/X11R6/bin/xdm -nodaemon
fi

# error
echo
echo "Hey, you don't have KDM, GDM, or XDM.  Can't use runlevel 4 without"
echo "one of those installed."
sleep 30

# All done.

EOF
