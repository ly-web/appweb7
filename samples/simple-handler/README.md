SimpleHandler Sample
===

This sample shows how to create an Appweb handler module. Handlers receive to client requests and
generate responses.

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
* [simpleHandler.c](simpleHandler.c) - Simple handler
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [start.bit](start.bit) - Bit build instructions

See Also:
---
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
