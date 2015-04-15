Deploy Appweb Sample
===

This sample demonstrates the commands to use to deploy Appweb files to a staging directory.

Requirements
---
* [Appweb](https://embedthis.com/appweb/download.html)
* [MakeMe Build Tool](https://embedthis.com/makeme/download.html)

Steps:
---

1. Appweb must be built

    me 

2. Deploy 

    me --sets core,libs,esp --deploy dir

This will copy the required Appweb files to deploy into the nominated directory.

Other sets include: 'web', 'service', 'utils', 'test', 'dev', 'doc', 'package'

Documentation:
---
* [Appweb Documentation](https://embedthis.com/appweb/doc/index.html)
* [Building Appweb with MakeMe](https://embedthis.com/appweb/doc/source/me.html)

See Also:
---
* [min-server - Minimal server configuration](../min-server/README.md)
* [simple-server - Simple one-line embedding API](../simple-server/README.md)
