if [ -x usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database -q usr/share/applications/kde
fi

if [ -r usr/share/icons/hicolor/icon-theme.cache ]; then
  /usr/bin/gtk-update-icon-cache -t -f -q usr/share/icons/hicolor
fi

if [ -x /usr/bin/update-mime-database ]; then
  /usr/bin/update-mime-database /usr/share/mime &> /dev/null
fi


