if [ -x /usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database 1> /dev/null 2> /dev/null
fi

if [ -x /usr/bin/gtk-update-icon-cache ]; then
  /usr/bin/gtk-update-icon-cache  -f -q /usr/share/icons/hicolor 1> /dev/null 2> /dev/null
fi
