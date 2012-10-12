#!/bin/sh
###
# Use rc.local to start Timidity++ at boot.
###

# if rc.timidity is executable, run it on startup
run=`grep ". /etc/rc.d/rc.timidity" etc/rc.d/rc.local`
if [[ "${run}" == "" ]]; then
cat << EOF >> etc/rc.d/rc.local

#Timidity++
# To disable Timidity++ chmod rc.timidity to 644
if [ -x /etc/rc.d/rc.timidity ]; then
	sh /etc/rc.d/rc.timidity start
fi
EOF
fi




