#!/bin/sh

here=$(pwd)
dest="$here/Clean.app"
rm -Rf $dest

# Test mode: displays a window and keeps running
# /usr/local/bin/platypus -a Clean -c clean.sh -o 'Text Window' -i clean.icns -p /bin/sh -V 1.0 -u "Jean-Olivier Irisson" -D -R -T 'fold' $dest

# Production mode: progress bar only which quits after the command is completed
/usr/local/bin/platypus -a Clean -c clean.sh -o 'Progress Bar' -i clean.icns -p /bin/sh -V 1.0 -u "Jean-Olivier Irisson" -D -T 'fold' $dest

exit 0