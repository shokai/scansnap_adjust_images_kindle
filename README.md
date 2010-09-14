Scansnap Adjust Image Kindle
============================
adjust images for scansnap to read on kindle

Require
=======

* OpenCV 1.0 or higher
* Boost 1.3.8 or higher

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


Install dependencies
====================

    # for Mac
    % sudo port install boost opencv

    # for Ubuntu
    % sudo apt-get install boost-build bjam libboost-dev libboost-dbg libboost-program-options-dev libboost-filesystem-dev
    % sudo apt-get install libcv-dev libcv1 libcvaux-dev libcvaux1 libhighgui-dev libhighgui1

Make
======

    % cd kindlize_images
    % make -f Makefile.macosx


Adjust Images
=============

use kindlize_images.

    % mkdir ~/tmp/mybook_kindle
    % ./kindlize_images --help
    % ./kindlize_images -i ~/tmp/mybook/ -o ~/tmp/mybook_kindle/ -t 190 -w 1200 -h 1600 --cleft 120 --cright 120 --ctop 150 --cbottom 150


Make a PDF file from adjusted Images
====================================

use images2pdf.app in this repository.

you can edit pdf by Preview.app.