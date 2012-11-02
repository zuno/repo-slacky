
#!/bin/sh
###
# Place the Avahi init script.
###
config() {
  NEW="$1"
  OLD="`dirname $NEW`/`basename $NEW .new`"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}


config etc/rc.d/rc.avahidaemon.new
config etc/rc.d/rc.avahidnsconfd.new
config etc/avahi/avahi-daemon.conf.new
config etc/dbus-1/system.d/avahi-dbus.conf.new

###
# Create avahi user:group if they don't exist.
###
group_exists=`grep ^avahi etc/group`
if [[ "${group_exists}" == "" ]]; then
	groupadd -g 214 avahi
fi
user_exists=`grep ^avahi etc/passwd`
if [[ "${user_exists}" == "" ]]; then
	useradd -c "Avahi Daemon User" -d /dev/null -u 214 -g avahi -s /bin/false avahi
fi

# Add root to the avahi group 
usermod -a -G avahi root

###
# Use rc.local to start Avahidaemon at boot needed by Pulseaudio.
###

# if rc.avahidaemon is executable, run it on startup
run=`grep ". /etc/rc.d/rc.avahidaemon" etc/rc.d/rc.local`
if [[ "${run}" == "" ]]; then
cat << EOF >> etc/rc.d/rc.local

#Avahi
# To disable Avahi chmod rc.avahidaemon to 644
if [ -x /etc/rc.d/rc.avahidaemon ]; then
	sh /etc/rc.d/rc.avahidaemon start
fi
EOF
fi


# if rc.avahidnsconfd is executable, run it on startup
run=`grep ". /etc/rc.d/rc.avahidnsconfd" etc/rc.d/rc.local`
if [[ "${run}" == "" ]]; then
cat << EOF >> etc/rc.d/rc.local

#Avahidnsconfd
# To disable Avahi chmod rc.avahidnsconfd to 644
if [ -x /etc/rc.d/rc.avahidnsconfd ]; then
	sh /etc/rc.d/rc.avahidnsconfd start
fi
EOF
fi

