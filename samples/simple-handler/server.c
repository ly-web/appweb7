/*
    server.c - Embed the AppWeb server in a simple multi-threaded C language application.
 */
 
#include    "appweb.h"

MAIN(server, int argc, char **argv, char **envp)
{
    /*
        This will create and run the web server described by the appweb.conf configuration file.
     */
    return maRunWebServer("appweb.conf");
}
