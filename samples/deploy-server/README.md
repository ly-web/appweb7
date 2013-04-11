Deploy Appweb Sample
===

This sample demonstrates the commands to use to deploy Appweb files to a staging directory.

Requirements
---
* [Appweb](http://embedthis.com/downloads/appweb/download.ejs)
* [Bit Build Tool](http://embedthis.com/downloads/bit/download.ejs)

Steps:
---

1. Appweb must be built

    bit 

2. Deploy 

    bit --sets core --deploy dir

This will copy the required Appweb files to deploy into the nominated directory.

Documentation:
---
* [Appweb Documentation](http://embedthis.com/products/appweb/doc/index.html)
* [Building Appweb with Bit](http://embedthis.com/products/appweb/doc/guide/appweb/source/bit.html)

See Also:
---
* [min-server - Minimal server configuration](../min-server/README.md)
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
