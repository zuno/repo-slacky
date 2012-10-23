###
# Create usbmux user if don't exist.
###
user_exists=`grep ^usbmux etc/passwd`
if [[ "${user_exists}" == "" ]]; then
	useradd -c "Usbmux Daemon User" -d /dev/null -u 233 -g plugdev -s /bin/false usbmux
fi


chroot . /etc/rc.d/rc.udev reload
