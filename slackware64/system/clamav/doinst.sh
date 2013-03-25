#!/bin/sh

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

config etc/clamav-milter.conf.new
config etc/clamd.conf.new
config etc/freshclam.conf.new

touch var/log/clamd.log
touch var/log/freshclam.log

###
# Create clamav:user and group if thet don't exist.
###
group_exists=`grep ^clamav etc/group`
if [[ "${group_exists}" == "" ]]; then
	groupadd -g 210 clamav
fi
user_exists=`grep ^clamav  etc/passwd`
if [[ "${user_exists}" == "" ]]; then
	useradd -c "Clamav Antivirus" -d /dev/null  -u 210  -g clamav clamav -s /bin/false
fi


chown clamav usr/sbin/clamav-milter
chmod 4700 usr/sbin/clamav-milter
chown -R clamav:clamav var/run/clamav
chmod 771 var/run/clamav
chown clamav:clamav var/log/{clamd.log,freshclam.log}
chmod 660 var/log/{clamd.log,freshclam.log}
chown -R clamav:clamav var/lib/clamav
chmod -R 770 var/lib/clamav
chmod -R 660 var/lib/clamav/*

