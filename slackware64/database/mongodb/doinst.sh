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

config etc/mongodb/mongodb.conf.new
config etc/rc.d/rc.mongod.new

if ! grep -q "^mongodb:" etc/group; then
 if ! grep -q ":600:" etc/group; then
    chroot . groupadd -g 600 mongodb &>/dev/null
  else
    chroot . groupadd mongodb &>/dev/null
  fi  
fi
if ! grep -q "^mongodb:" etc/passwd; then
  if ! grep -q ":600:" etc/passwd; then
    chroot . useradd -u 600 -d /var/lib/mongodb -s /bin/false -c "MongoDb user" -g mongodb mongodb &>/dev/null
  else
    chroot . useradd -d /var/lib/mongodb -s /bin/false -c "MongoDb user" -g mongodb mongodb &>/dev/null
  fi  
fi
chown -R mongodb.mongodb var/lib/mongodb var/log/mongodb

