Scansnap Adjust Image Kindle
============================
adjust images for scansnap to read on kindle

Require
=======

* Java 1.5 or higher
* JRuby 1.5 or higher


Extract image files from PDF
=========================

on Mac OSX or Ubuntu Linux, use pdfimages.

    # for Mac
    % sudo port install pdfX

    # for Ubuntu
    % sudo apt-get install xpdf-utils

    # extract images
    % mkdir -p ~/tmp/mybook
    % pdfimages -j ~/Documents/book/mybook.pdf ~/tmp/mybook/


Others, buy Adobe Acrobat Pro to extract.


Adjust Images
=============

use kindlize_images.rb in this repository.

    % jruby kindlize_images.rb -help
    % jruby kindlize_images.rb -i ~/tmp/mybook/ -o ~/tmp/mybook_kindle/ -w 1200 -h 1600 -cl 150 -cr 150 -ct 120 -cb 180 -t 240


Make a PDF file from adjusted Images
====================================

use images2pdf.app in this repository.

you can edit pdf by Preview.app.