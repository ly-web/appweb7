## Static Linking with ESP

If you are using building Appweb using static linking with ESP, then you must take 
extra steps to initialize your ESP pages and applications. We generally advise to 
use dynamic linking when building Appweb as static linking implies significant limitations:

* Modules cannot be dynamically loaded and must be statically linked
* Reloading ESP applications without restarting the server is not possible

### Creating ESP Initializers

When using static linking, ESP controllers must be initialized when building Appweb.
Use the following command to create a static initializer function that can will be invoked by the Appweb main program.

```
 me genslink
```

or manually via:

```
 appesp --static --genlink slink.c compile</pre>
```

This command will regenerate the slink.c file that contains the ESP initialization routine. This function <em>appwebStaticInitialize()</em> will invoke the necessary ESP controller initializers. Appweb contains a reference to this function in the Appweb main program, appweb.c.
