SimpleModule Sample
===

This sample shows how to create an Appweb loadable module.  A module may provide an Appweb handler, filter, 
custom configuration directives or any functionality you wish to integrate into Appweb. Appweb modules are 
compiled into shared libraries and are dynamically loaded in response to appweb.conf LoadModule directives. 
If your main program is statically linked, the same module, without change may be included in the main
program executable link, provided the module entry point is manually invoked from the main program.

Requirements
---
* [Appweb](http://embedthis.com/downloads/appweb/download.ejs)
* [Bit Build Tool](http://embedthis.com/downloads/bit/download.ejs)

To build:
---
    bit

To run:
---
    bit run

Code:
---
* [server.c](server.c) - Main program
* [simple.c](simple.c) - Simple module
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [start.bit](start.bit) - Bit build instructions


See Also:
---
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
