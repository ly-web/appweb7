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
* [simpleHandler.c](simpleHandler.c) - Simple handler
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [start.bit](start.bit) - Bit build instructions

Documentation:
---
* [Appweb Documentation](http://embedthis.com/products/appweb/doc/index.html)
* [Creating Handlers](http://embedthis.com/products/appweb/doc/guide/appweb/programmers/handlers.html)
* [Creating Modules](http://embedthis.com/products/appweb/doc/guide/appweb/programmers/modules.html)
* [API Library](http://embedthis.com/products/appweb/doc/api/native.html)
* [Configuration Directives](http://embedthis.com/products/appweb/doc/guide/appweb/users/configuration.html#directives)

See Also:
---
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
