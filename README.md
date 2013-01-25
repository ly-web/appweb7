Embedthis Appweb 4.X
===

The fast, little web server for embedded applications. 

Licensing
---
See LICENSE.md for details.

### To Read Documentation:

  See http://appwebserver.org/products/appweb/doc/product/index.html

### Building
    You can build with make or with Bit. Bit is quicker and more flexible.
    If building with Bit, download Bit from http://embedthis.com/downloads/bit/download.ejs

    Images are built into */bin. The build configuration is saved in */inc/bit.h.

### To Build with make:

    make

### To Build with nmake on Windows:

    WinMake

### To Build with Bit:

    ./configure
    bit

### To Run

    cd src/server
    ../../*/bin/appweb -v 

    or

    bit run

### To Test:

    bit test

### To Install:

    sudo bit install

Resources
---
  - [Appweb web site](http://appwebserver.org/)
  - [Appweb GitHub repository](http://github.com/embedthis/appweb-4)
  - [Appweb Mailing list](http://groups.google.com/groups/appweb)
  - [Embedthis web site](http://embedthis.com/)
