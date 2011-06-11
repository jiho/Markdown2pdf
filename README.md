
# Convert Markdown documents to PDF

The script (`markdown2pdf.sh`) calls [Multimarkdown](http://fletcherpenney.net/multimarkdown/ "MultiMarkdown") to convert from Markdown to HTML. Then the HTML is rendered into a PDF through webkit by [wkpdf](http://plessl.github.com/wkpdf/ "wkpdf &mdash; a command line HTML to PDF converter for Mac OS X"). It uses a default CSS which resembles the one used on Apple Developer Documentation, but if a css style is specified in Markdown, the script honors it instead.

The script is packaged into a droppable application thanks to [platypus](http://www.sveinbjorn.org/platypus "Platypus | Sveinbjorn Thordarson").

## Installation

Get the code

	git clone git://github.com/jiho/Markdown2pdf.git
	cd Markdown2pdf
	git submodule init
	git submodule update

Install [platypus](http://www.sveinbjorn.org/platypus "Platypus | Sveinbjorn Thordarson").

Open Platypus' preferences and install the command line tool.

Create the app (on your desktop)

	./createApp.sh

Move the app wherever yo want. I recommend then adding it to your Finder's title bar for easy drag and drop access.

## Update

	cd Markdown2pdf
	git pull
	git submodule update

	./createApp.sh

## Usage

Just drag and drop documents with extension `md`, `markdown`, `txt`, `text`, `mdown` on the application. The resulting PDF should appear next to the markdown document.

Beware, if a PDF exists already, it will be silently overwritten

--

(c) Copyright 2011 JiHO
    GNU General Public License v3
