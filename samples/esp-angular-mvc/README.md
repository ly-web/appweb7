ESP Angular MVC Sample
===

This sample demonstrates an Angular ESP MVC application. This is an ESP MVC application that uses the
AngularJS client-side Javascript framework.

The app is a trivial blogging application. Posts with a title and body can be created, listed and deleted.

The app contains:
* blog database with post table
* post controller to manage posts
* post views to create, list and display posts
* master view layout under the layouts directory

This app was generated, then edited for simplicity via:

    esp generate app blog angular-mvc
    cd blog
    esp generate scaffold post title:string body:text
    cd ..
    cp -r blog/* esp-angular-mvc

Requirements
---
* [Appweb](http://embedthis.com/downloads/appweb/download.ejs)
* [Bit Build Tool](http://embedthis.com/downloads/bit/download.ejs)

To build:
---
    bit 
or

    esp compile

To run:
---
    bit run
or

    esp run

The server listens on port 8080. Browse to: 
 
     http://localhost:8080/

This will run the application in debug mode which will individually load HTML views, script and Less stylesheets
as required. If you change the "debug" property in esp.config to "release" and restart the server, the application 
will run in release mode and will use this aggregate files: all*.min.css, all*.js. In release mode, the HTML pages are
compiled into scripts and included in all*.js.

Notes:
---
If you modify the controller.c it will be automatically recompiled and reloaded when next accessed.

Code:
---
* [controllers](controllers/post.c) - Post controller
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [cache](cache) - Directory of compiled ESP modules
* [client](client) - Client-side public web content
* [db](db) - Database directory for the blog application
* [db/blog.mdb](db/blog.mdb) - Blog database 
* [db/migrations](db/migrations) - Database base migrations to create / destroy the database schema
* [esp.json](esp.json) - ESP configuration file
* [hosted.conf](hosted.conf) - Appweb configuration file to host application inside a web site
* [start.bit](start.bit) - Bit build instructions
* [templates](templates) - ESP generator application templates

Documentation:
---
* [ESP Angular Support](http://embedthis.com/products/appweb/doc/guide/esp/users/angular.html)
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
* [esp-hosted-mvc - Appweb hosted MVC sample](../esp-hosted-mvc/README.md)
* [esp-html-mvc - ESP MVC](../esp-html-mvc/README.md)
* [esp-page - Serving ESP pages](../esp-page/README.md)
* [secure-server - Secure server](../secure-server/README.md)
* [simple-server - Simple server and embedding API](../simple-server/README.md)
* [typical-server - Fully featured server and embedding API](../typical-server/README.md)
