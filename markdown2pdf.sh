#!/bin/sh
#
#     Creates a PDF from a (multi) markdown file using
#     predefined style sheets if none is provided
#
# (c) Copyright 2011 JiHO
#     GNU General Public License v3
#
#------------------------------------------------------------

# Default paper size
paper="a4"
# paper="letter"

# Use a safe prefix to create temp files in the same directory
# We need to keep everything in the same directory for links to work
tmpPrefix=$$
# wkpdf requires a path without spaces as output, hence create a temp dir
tmpDir="/tmp/${tmpPrefix}-md2pdf"
mkdir $tmpDir

# Resources dir inside the app
# Contains MultiMarkdown and wkpdf
rscDir=$(cd ${0%/*} && echo $PWD)
# NB: this gets the absolute path, unlike dirname which gets the relative path
# echo "$rscDir"

# Process one dropped file at a time
while [ "$1" != "" ]; do
   echo "--> Processing $1"

   # Split the file name
   fileExtension=$(echo "$1" | awk -F "." '{print $NF}')
   dirName=$(dirname "$1")
   dirName=$(cd "$dirName" && echo $PWD)    # absolute path
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
   echo "  dir      = $dirName"
   echo "  file     = $fileName"
   echo "  ext      = $fileExtension"
   echo ""
   echo "  md       = $mdFile"
   echo "  css      = $cssFile"
   echo "  html     = $htmlFile"
   echo "  html     = $htmlAddress"
   echo "  temp pdf = $tmpPdfFile"
   echo "  pdf      = $pdfFile"

   # Copy the MarkDown file to a temporary file to work on it
   cp "$1" "$mdFile"

   # Add css info to the Markdown file if there isn't one already
   echo "CSS detection"
   css=$(grep -e "^css:" "$1")

   if [[ $css = "" ]]; then
      echo "  The file does not specify a CSS stylesheet"
      echo "  Prepending the default CSS style"
      # prepend css info to the markdown file
      cat "$mdFile" | pbcopy && echo "css: ${tmpPrefix}-${fileName}.css" > "$mdFile" && pbpaste >> "$mdFile"
      # show it
      cssSpec=$(head -n 1 "$mdFile")
      echo "    $cssSpec"
      # copy default css file from the resources dir
      cp "${rscDir}/adc.css" "$cssFile"

   else
      echo "  The file specifies a CSS stylesheet"
      echo "    $css"
      cssName=$(echo "$css" | awk -F ": " '{print $NF}')
      # echo $cssName
      if [[ -e "${dirName}/${cssName}" ]]; then
         # if the file exists (the user created it) then use this
         echo "  Using user-provided definition"
      else
         # if the file does not exist, try to match it against the ones provided with the app
         # when it matches, copy the one from the app bundle to the temporary css name and modify the md file to point to it
         # when it does not, we don't know what to do
         case $cssName in
            adc.css | serif.css)
               # copy the css file to the temporary one
               cp "${rscDir}/${cssName}" "$cssFile"
               # change the css specification to point to it
               cssSpec="${tmpPrefix}-${fileName}.css"
               sed -i "" -e s/${cssName}/${cssSpec}/ "$mdFile"
               ;;
            * )
               echo "Unknown stylesheet" 1>&2
               rm -f "$mdFile" "$cssFile" "$htmlFile" "$tmpPdfFile"
               exit 1
         esac

      fi
   fi

   # Convert to HTML using MultiMarkdown
   echo "Conversion"
   "$rscDir"/MultiMarkdown/bin/mmd2XHTML.pl < "$mdFile" > "$htmlFile"

   # Print HTML into a PDF file
   "$rscDir"/wkpdf/bin/wkpdf --source "$htmlAddress" --output "$tmpPdfFile" --paper "$paper" --print-background
   cp -f "$tmpPdfFile" "$pdfFile"

   # Cleanup
   rm -f "$mdFile" "$cssFile" "$htmlFile" "$tmpPdfFile"

   echo ""
   shift 1
done

echo "Done"

exit 0

