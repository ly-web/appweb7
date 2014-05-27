Esp-hosted Sample
===

This sample shows how to host an ESP application in Appweb.

This sample uses:

* esp-html-mvc server-side MVC application

Notes:
* This application was generated via:

    esp --name blog install esp-html-mvc
    esp generate scaffold post title:string body:text

Requirements
---
* [ESP](http://embedthis.com/downloads/esp/download.esp)

To run:
---
    appweb -v

The server listens on port 4000 for HTTP traffic and 4443 for SSL. Browse to: 
 
     http://localhost:4000/

Code:
---
* [appweb.conf](appweb.conf) - Appweb configuration file
* [cache](cache) - Directory for cached ESP pages
* [client/index.esp](client/index.esp) - Home page
* [controllers/post.c](controllers/post.c) - Controller code
* [db](db) - Database and migrations
* [layouts](layouts) - View layout pages
* [package.json](package.json) - ESP configuration file
* [paks](paks) - Extension packages

Documentation:
---
* [Apwpeb Documentation](http://embedthis.com/products/appweb/doc/index.html)
* [ESP Documentation](http://embedthis.com/products/esp/doc/index.html)
* [ESP Configuration in Appweb](http://embedthis.com/products/appweb/doc/guide/esp/users/configuration.html#directives)
* [ESP Configuration](http://embedthis.com/products/esp/doc/guide/esp/users/config.html)
* [Sandbox Limits](http://embedthis.com/products/appweb/doc/guide/appweb/users/dir/sandbox.html)
* [Security Considerations](http://embedthis.com/products/appweb/doc/guide/appweb/users/security.html)
* [User Authentication](http://embedthis.com/products/appweb/doc/guide/appweb/users/authentication.html)

See Also:
---
