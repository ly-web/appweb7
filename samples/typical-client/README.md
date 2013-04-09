Typical Client Sample
===

This sample shows how to efficiently use the Mpr and Http library to issue Http client requests.
This is a fuller sample suitable for applications that need to issue multiple HTTP requests.
If you only need to issue one HTTP request, consult the simple-client sample.

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

The client retrieves:
 
     http://www.embedthis.com/index.html

Code:
---
* [client.c](client.c) - Main program
* [start.bit](start.bit) - Bit build instructions

See Also:
---
* [simple-client - Simple client and embedding API](../simple-client/README.md)
