#!/bin/sh

here=$(pwd)
appName="Markdown2PDF"
# dest="$here"/"$appName".app
dest=~/Desktop/"$appName".app
rm -Rf $dest

# debug options
# -o "Text Window" -R \
# build options
# -o "Progress Bar" \

/usr/local/bin/platypus -a "$appName" -c markdown2pdf.sh \
   -o "Progress Bar" \
   -p /bin/sh -V 1.0 -u "Jean-Olivier Irisson" -D -X "md|markdown|txt|text|mdown" -f MultiMarkdown -f style.css -f wkpdf $dest

exit 0