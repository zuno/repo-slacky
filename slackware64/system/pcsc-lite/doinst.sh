 
config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

# Keep same perms on rc.pcscd.new:
if [ -e etc/rc.d/rc.pcscd ]; then
  cp -a etc/rc.d/rc.pcscd etc/rc.d/rc.pcscd.new.incoming
  cat etc/rc.d/rc.pcscd.new > etc/rc.d/rc.pcscd.new.incoming
  mv etc/rc.d/rc.pcscd.new.incoming etc/rc.d/rc.pcscd.new
fi

config etc/rc.d/rc.pcscd.new

if ! grep -q "^pcscd:" etc/group; then
  if ! grep -q ":257:" etc/group; then
    chroot . groupadd -g 257 pcscd &>/dev/null
  else
    chroot . groupadd pcscd &>/dev/null
  fi
fi
 
if ! grep -q "^pcscd:" etc/passwd; then
  if ! grep -q ":257:" etc/passwd; then
    chroot . useradd -u 257 -s /bin/false -c "PCSC Daemon User" -g pcscd pcscd &>/dev/null
  else
    chroot . useradd -s /bin/false -c "PCSC Daemon User" -g pcscd pcscd &>/dev/null
  fi
fi
