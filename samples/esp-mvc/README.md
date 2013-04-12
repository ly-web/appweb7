ESP MVC Sample
===

This sample demonstrates an ESP MVC application. The app is a trivial blogging
application. Posts with a title and body can be created, listed and deleted.

The app contains:
* blog database with post table
* post controller to manage posts
* post views to create, list and display posts
* master view layout under the layouts directory

This app was generated, then edited for simplicity via:

    esp generate app blog
    cd blog
    esp generate scaffold post title:string body:text
    cd ..
    cp -r blog/* esp-mvc

If you require an ESP MVC application hosted inside Appweb, see the esp-hosted-mvc sample:

* [esp-hosted-mvc](esp-hosted-mvc)

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
 
     http://localhost:8080/post/

Notes:
---
If you modify the controller.c it will be automatically recompiled and reloaded when next accessed.

Code:
---
* [controllers](controllers/post.c) - Post controller
* [appweb.conf](appweb.conf) - Appweb server configuration file
* [cache](cache) - Directory of compiled ESP modules
* [db](db) - Database directory for the blog application
* [db/blog.mdb](db/blog.mdb) - Blog database 
* [db/migrations](db/migrations) - Database base migrations to create / destroy the database schema
* [layouts](layouts) - Master view layout templates 
* [static](static) - Static web content
* [start.bit](start.bit) - Bit build instructions
* [views](views) - Web views

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
* [esp-hosted-mvc - Appweb hosted MVC sample](../esp-hosted-mvc/README.md)
* [esp-page - Serving ESP pages](../esp-page/README.md)
* [secure-server - Secure server](../secure-server/README.md)
* [simple-server - Simple server and embedding API](../simple-server/README.md)
* [typical-server - Fully featured server and embedding API](../typical-server/README.md)
