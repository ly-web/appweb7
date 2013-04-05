Tyical Server Sample
===

This sample shows how to embed Appweb using the full embedding API.

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
* server.c - Main program
* appweb.conf - Appweb server configuration file
* auth.conf - User/Password/Role authorization file
* esp.conf - ESP compiler rules
* index.html - web page to serve
* cache - Cached content directory
* web - Web content to serve

See Also:
---
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
