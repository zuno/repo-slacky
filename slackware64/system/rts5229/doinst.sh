#!/bin/sh

depmod -a

echo
echo "Remember to add this line in the Realtek section"
echo 'DRIVERS=="rts5229", ENV{ID_DRIVE_FLASH_SD}="1"'
echo "in the following files:"
echo "/lib/udev/rules.d/80-udisks.rules"
echo "/lib/udev/rules.d/80-udisks2.rules"
echo "to manage the mount of the SD/MMC devices"
echo 
