Maximum Config Server Sample
===

This sample shows nearly all of the possible Appweb directives in the appweb.conf configuration file.
You are encouraged to see the other typical appweb.conf samples:
* [min-server - Minimal configuration server](../min-server/README.md)
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
* [typical-server - Typical server](../typical-server/README.md)

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

The server listens on port 80. Browse to: 
 
     http://localhost/

Code:
---
* [server.c](server.c) - Main program
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [auth.conf](auth.conf) - User/Password/Role authorization file
* [esp.conf](esp.conf) - ESP compiler rules
* [index.html](index.html) - web page to serve
* [web](web) - Web content to serve
* [start.bit](start.bit) - Bit build instructions


See Also:
---
* [min-server - Minimal configuration server](../min-server/README.md)
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
* [typical-server - Typical server](../typical-server/README.md)
