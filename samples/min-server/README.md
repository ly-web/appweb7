Minimum Config Server Sample
===

This sample shows a minimal set of configuration directives. This server supports the file and ESP handlers.
CGI, PHP, Ejscript and SSL are not configured.

The purpose of this sample is to show the minimal appweb.conf for serving static and ESP content. You
are encouraged to read the [typical-server - Typical server](../typical-server/README.md) sample to see what
other appweb.conf directives are available.

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

The server listens on port 8080. Browse to: 
 
     http://localhost:8080/

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
* [max-server - Maximum server configuration](../max-server/README.md)
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
* [typical-server - Typical server](../typical-server/README.md)
