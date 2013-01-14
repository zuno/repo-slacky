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

config etc/beanstalkd.conf.new
config etc/rc.d/rc.beanstalkd.new

if ! grep -q "^beanstalkd:" etc/group; then
 if ! grep -q ":601:" etc/group; then
    chroot . groupadd -g 601 beanstalkd &>/dev/null
  else
    chroot . groupadd beanstalkd &>/dev/null
  fi  
fi
if ! grep -q "^beanstalkd:" etc/passwd; then
  if ! grep -q ":601:" etc/passwd; then
    chroot . useradd -u 601 -d /var/lib/beanstalkd -s /bin/false -c "beanstalkd user" -g beanstalkd beanstalkd &>/dev/null
  else
    chroot . useradd -d /var/lib/beanstalkd -s /bin/false -c "beanstalkd user" -g beanstalkd beanstalkd &>/dev/null
  fi  
fi
chown -R beanstalkd.beanstalkd var/lib/beanstalkd 