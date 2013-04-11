ESP MVC Sample
===

This sample demonstrates an ESP MVC application. This app was generated via:

    esp generate app blog
    cd blog
    esp generate scaffold post title:string body:text
    mv * ..
    rmdir blog

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
or
    esp run

The server listens on port 4000. Browse to: 
 
     http://localhost:4000/

This then returns "Hello World" to the client.

If you modify the controller.c it will be automatically recompiled and reloaded when 
next accessed.

Code:
---
* [server.c](server.c) - Web server program
* [controller.c](controller.c) - ESP controller source
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [start.bit](start.bit) - Bit build instructions

Documentation:
---
* [Appweb Documentation](http://embedthis.com/products/appweb/doc/index.html)
* [ESP Directives](http://embedthis.com/products/appweb/doc/guide/appweb/users/dir/esp.html)
* [ESP Tour](http://embedthis.com/products/appweb/doc/guide/esp/users/tour.html)
* [ESP Controllers](http://embedthis.com/products/appweb/doc/guide/esp/users/controllers.html)
* [ESP APIs](http://embedthis.com/products/appweb/doc/api/esp.html)
* [ESP Guide](http://embedthis.com/products/appweb/doc/guide/esp/users/index.html)
* [ESP Overview](http://embedthis.com/products/appweb/doc/guide/esp/users/using.html)

See Also:
---
* [esp-controller - Creating ESP controllers](../esp-controller/README.md)
* [esp-page - Serving ESP pages](../esp-page/README.md)
* [simple-server - Simple server and embedding API](../simple-server/README.md)
* [typical-server - Fully featured server and embedding API](../typical-server/README.md)
