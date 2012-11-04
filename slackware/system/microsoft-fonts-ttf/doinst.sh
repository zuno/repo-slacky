# Accept terms of EULA:
echo
echo 'By using this package you must accept the End User License Agreement'
echo 'for Microsoft Software (EULA), which has been installed in'
echo '/usr/doc/microsoft-fonts-ttf-_VERSION_/EULA'
echo
more usr/doc/microsoft-fonts-ttf-_VERSION_/EULA
echo
echo "Do you accept terms? [y/N]"
read ACCEPT
if [ "$ACCEPT" != "y" ];then
  echo "Aborting installation"
  removepkg microsoft-fonts-ttf
  exit 1
fi

# Extract the fonts with cabextract:
for i in `echo tmp/microsoft-fonts-ttf/*.exe` ; do
  cabextract -L -d 'usr/share/fonts/TTF' -F '*.ttf' $i
done

# Hence original *.exe files are no longer useful, remove them:
rm -rf tmp/ms-fonts-ttf

# Update font cache:
fc-cache -f > dev/null
mkfontscale usr/share/fonts/TTF
mkfontdir usr/share/fonts/TTF

