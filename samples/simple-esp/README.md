ESP Sample
===

This sample shows how to configure Appweb to serve ESP pages.

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
 
     http://localhost:8080/index.esp
     http://localhost:8080/

Code:
---
* [server.c](server.c) - Web server program
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [index.esp](index.esp) - ESP page to serve
* [start.bit](start.bit) - Bit build instructions

See Also:
---
* [simple-server - Simple server and embedding API](../simple-server/README.md)
* [typical-server - Fully featured server and embedding API](../typical-server/README.md)
