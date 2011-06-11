#!/bin/sh
#
#	  Creates a PDF from a (multi) markdown file using a predefined style sheet if none is provided
#
# (c) Copyright 2011 JiHO
#     GNU General Public License v3
#
#------------------------------------------------------------

# Use a safe prefix to create temp files in the same directory
# We need to keep everything in the same directory for links to work
tmpPrefix=$$
# wkpdf requires a path without spaces as output, hence create a temp dir
tmpDir="/tmp/tempPrefix-md2pdf"
mkdir $tmpDir

# Resources dir inside the app
# Contains MultiMarkdown and wkpdf
rscDir=$(dirname $0)
echo "$rscDir"

# Process one droped file at a time
while [ "$1" != "" ]; do
   echo "--> Processing $1"

   # Split the file name
   fileExtension=$(echo "$1" | awk -F "." '{print $NF}')
   dirName=$(dirname "$1")
   fileName=$(basename -s .$fileExtension "$1")

   # Prepare temporary names
   mdFile="${dirName}/${tmpPrefix}-${fileName}.md"
   cssFile="${dirName}/${tmpPrefix}-${fileName}.css"
   htmlFile="${dirName}/${tmpPrefix}-${fileName}.html"
   htmlAddress=$(echo "file://$htmlFile" |sed 's/\ /%20/g')

   # Prepare output PDF file name
   tmpPdfFile="${tmpDir}/pdf.pdf"
   pdfFile="${dirName}/${fileName}.pdf"

   echo "Names"
   echo "  dir=$dirName"
   echo "  file=$fileName"
   echo "  ext=$fileExtension"
   echo ""
   echo "  md=$mdFile"
   echo "  css=$cssFile"
   echo "  html=$htmlFile"
   echo "  html=$htmlAddress"
   echo "  pdf=$tmpPdfFile"
   echo "  pdf=$pdfFile"
   echo ""

   # Copy the MarkDown file to a temporary file to work on it
   cp "$1" "$mdFile"

   # Add css info to the Markdown file if there isn't one already
   echo "CSS detection"
   css=$(grep -e "^css:" "$1")

   if [[ $? -eq 0 ]]; then
      echo "  the file already has css"
      # copy the css file to the temp directory
      css=$(echo $css | awk -F ": " '{print $NF}')
      echo "    css=$css"
   else
      echo "  the file does not have css. Prepending:"
      # prepend css info to the markdown file
      cat "$mdFile" | pbcopy && echo "css: ${tmpPrefix}-${fileName}.css" > "$mdFile" && pbpaste >> "$mdFile"
      head -n 3 "$mdFile"
      # copy css file in the resources dir
      cp "$rscDir"/style.css "$cssFile"
   fi

   # Convert to HTML using MultiMarkdown
   echo "Conversion"
   "$rscDir"/MultiMarkdown/bin/mmd2XHTML.pl < "$mdFile" > "$htmlFile"

   # Print HTML into a PDF file
   echo "$htmlFile"
   "$rscDir"/wkpdf/bin/wkpdf --source "$htmlAddress" --output "$tmpPdfFile" --format A4 --print-background yes
   cp -f "$tmpPdfFile" "$pdfFile"

   # Cleanup
   rm -f "$mdFile" "$cssFile" "$htmlFile" "$tmpPdfFile"

   echo ""
   shift 1
done

echo "Done"

exit 0

