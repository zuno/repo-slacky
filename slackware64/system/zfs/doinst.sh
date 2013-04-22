#!/bin/sh

depmod -a

cat << EOF >> /etc/rc.d/rc.local

# Start zfs service
# If you do not wish this to be executed here then comment it out,
# and the init system will skip it next time.
if [ -x /etc/rc.d/rc.zfs ]; then
    /etc/rc.d/rc.zfs start
fi

EOF
