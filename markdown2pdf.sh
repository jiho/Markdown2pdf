#!/bin/sh
#
#	Creates a PDF from a (multi) markdown file using a specific style sheet if none is provided
#
#	(c) Jean-Olivier Irisson <irisson@normalesup.org>.
#	GNU General Public License http://www.gnu.org/copyleft/gpl.html
#

# Prepare a temporary directory where the work will be done
tmpDir=$(mktemp -d /tmp/md2pdf.XXX)
echo $tmpDir

rscDir=$(dirname $0)
echo "$rscDir"

# Process one file at a time
while [ "$1" != "" ]; do
   echo "--> Processing $1"

   # Create output file name
   fileExtension=$(echo "$1" | awk -F "." '{print $NF}')
   dirName=$(dirname "$1")
   fileName=$(basename -s .$fileExtension "$1")
   outFile="$dirName"/"$fileName".pdf
   echo "Names"
   echo "  dir=$dirName"
   echo "  file=$fileName"
   echo "  ext=$fileExtension"
   echo "  out=$outFile"


   # Copy the file to the temp dir to work on it
   cp "$1" $tmpDir/input.md

   # Add css info to the Markdown file if there isn't one already
   echo "CSS detection"
   css=$(grep -e "^css:" "$1")

   if [[ $? -eq 0 ]]; then
      echo "  the file already has css"
      # copy the css file to the temp directory
      css=$(echo $css | awk -F ": " '{print $NF}')
      echo "    css=$css"
      cp "$dirName"/"$css" $tmpDir
   else
      echo "  the file does not have css. Prepending:"
      # prepend css info to the markdown file
      cat $tmpDir/input.md | pbcopy && echo "css: style.css" > $tmpDir/input.md && pbpaste >> $tmpDir/input.md
      head -n 3 $tmpDir/input.md
      # copy css file in the resources dir
      cp "$rscDir"/style.css $tmpDir
   fi

   # Convert to HTML using MultiMarkdown
   echo "Conversion"
   "$rscDir"/MultiMarkdown/bin/mmd2XHTML.pl < $tmpDir/input.md > $tmpDir/output.html

   # Print HTML into a PDF file
   "$rscDir"/wkpdf/bin/wkpdf --source $tmpDir/output.html --output $tmpDir/output.pdf --format A4 --print-background yes
   cp $tmpDir/output.pdf "$outFile"

   echo ""
	shift 1
done

echo "Done"

exit 0

