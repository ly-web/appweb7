cppHandler Sample
===

This sample shows how to create an Appweb handler module. Handlers receive to client requests and
generate responses.

Requirements
---
* [Appweb](https://embedthis.com/appweb/download.html)
* [MakeMe Build Tool](https://embedthis.com/makeme/download.html)

To build:
---
    me

To run:
---
    me run

Appweb listens on port 8080. Browse to: 
 
     http://localhost:8080/

To send data to the handler, use:
    http --form 'name=john' 8080

Code:
---
* [cppHandler.c](cppHandler.c) - Simple handler
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [start.me](start.me) - MakeMe build instructions

Documentation:
---
* [Appweb Documentation](https://embedthis.com/appweb/doc/index.html)
* [Creating Handlers](https://embedthis.com/appweb/doc/developers/handlers.html)
* [Creating Modules](https://embedthis.com/appweb/doc/developers/modules.html)
* [API Library](https://embedthis.com/appweb/doc/ref/native.html)

See Also:
---
* [simple-handler - C-Language handler](../simple-handler/README.md)
