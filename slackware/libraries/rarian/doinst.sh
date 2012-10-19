# Make a symlink to /var/rarian since some
# packages may use this instead of /var/lib/rarian
if [ -L var/lib/rarian ]; then
  ( cd var ; rm -rf lib/rarian )
fi

( cd var ; mkdir -p lib/rarian )

if [ -d var/rarian -a ! -L var/rarian ]; then
  ( cd var ; mv rarian/* lib/rarian )
fi

( cd var ; rm -rf rarian )
( cd var ; ln -sf lib/rarian rarian )

