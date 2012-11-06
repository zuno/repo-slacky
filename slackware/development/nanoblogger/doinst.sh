#!/bin/sh
echo '#!/bin/sh
cd /usr/share/nanoblogger && exec ./nb $*' > /usr/bin/nb
chmod 755 /usr/bin/nb
