config() {
  NEW="$1"
  OLD="`dirname $NEW`/`basename $NEW .new`"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then # toss the redundant
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

config etc/rc.d/rc.postgresql.new


###
# Create postgres home
###
mkdir -p /var/lib/pgsql/data


###
# Create postgres user:group if they don't exist.
###
group_exists=`grep ^postgres etc/group`
if [[ "${group_exists}" == "" ]]; then
	groupadd -g 209 postgres
fi
user_exists=`grep ^postgres etc/passwd`
if [[ "${user_exists}" == "" ]]; then
	useradd -c "PostgreSQL ORDBMS" -d /var/lib/pgsql -u 209 -g 209 -s "/bin/bash" postgres
fi

chown -R postgres:postgres /var/lib/pgsql
chmod -R 700 /var/lib/pgsql

