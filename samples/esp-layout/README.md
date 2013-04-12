ESP Layout Sample
===

This sample shows how to use ESP layout pages with stand-alone ESP pages.

The page to be served, index.esp specifies the desired layout page, layout.esp.
It does this with the <%@ layout "file" %> directive.

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

Code:
---
* [server.c](server.c) - Web server program
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [index.esp](index.esp) - ESP page to serve. Uses layout.esp as a template.
* [layout.esp](index.esp) - ESP layout template
* [start.bit](start.bit) - Bit build instructions
* [cache](cache) - Compiled ESP modules 

Documentation:
---
* [Appweb Documentation](http://embedthis.com/products/appweb/doc/index.html)
* [ESP Directives](http://embedthis.com/products/appweb/doc/guide/appweb/users/dir/esp.html)
* [ESP APIs](http://embedthis.com/products/appweb/doc/api/esp.html)
* [ESP Guide](http://embedthis.com/products/appweb/doc/guide/esp/users/index.html)
* [ESP Overview](http://embedthis.com/products/appweb/doc/guide/esp/users/using.html)

See Also:
---
* [esp-mvc - ESP MVC Application](../esp-mvc/README.md)
* [esp-page - ESP Page](../esp-page/README.md)
* [secure-server - Secure server](../secure-server/README.md)
* [simple-server - Simple server and embedding API](../simple-server/README.md)
* [typical-server - Fully featured server and embedding API](../typical-server/README.md)
