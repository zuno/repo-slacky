#!/bin/sh

function config() {
	NEW="$1"
	OLD="`dirname $NEW`/`basename $NEW .new`"

	# If there's no config file by that name, mv it over:
	if [ ! -r $OLD ]; then
		echo "--- Renaming $NEW to $OLD"
		mv $NEW $OLD
	elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then
		# toss the redundant copy
		echo "--- Deleting $NEW"
		rm $NEW
	else
		# Otherwise, we leave the .new copy for the admin to consider...
		echo "--- Leaving $NEW for you to replace $OLD"
	fi
	

}

for i in /etc/psiconv/psiconv.conf.new

do
	if [ -f $i ]
	then
		config $i
	fi
done
