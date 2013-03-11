/*
    simpleEgi.c - Demonstrate the use of the Embedded Gateway Interface (EGI) 
        in a simple multi-threaded application.
  
    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */
 
/******************************* Includes *****************************/

#include    "appweb.h"

#error "This has not been updated for Appweb 4"

/********************************* Code *******************************/
/*
    This method is run when the EGI form is called from the web
    page. Rq is the request context. URI is the bare URL minus query.
    Query is the string after a "?" in the URL. Post data is posted
    HTTP form data.
 */

static void myEgi(HttpQueue *q)
{
    HttpConn    *conn;

    conn = q->conn;
    httpWrite(q, "<HTML><TITLE>simpleEgi</TITLE><BODY>\r\n");
    httpWrite(q, "<p>Name: %s</p>\n", httpGetFormVar(conn, "name", "-"));
    httpWrite(q, "<p>Address: %s</p>\n", httpGetFormVar(conn, "address", "-"));
    httpWrite(q, "</BODY></HTML>\r\n");

#if POSSIBLE || 1
    /*
     *  Useful things to do in egi forms
     */
    httpSetStatus(conn, 200);
    httpSetMimeType(conn, "text/plain");
    httpDontCache(conn);
    httpRedirect(conn, 302, "/myURl");
    httpError(conn, 409, "My message : %d", 5);
#endif
}


/*
    Create a simple stand-alone web server
 */
MAIN(simpleEgi, int argc, char **argv, char **envp)
{
    MaServer    *server;

    if ((server = maCreateWebServer("simpleEgi.conf")) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    /*  
        Define our EGI form
     */
    maDefineEgiForm(server->http, "/myEgi.egi", myEgi);
    if (maServiceWebServer(server) < 0) {
        return MPR_ERR_CANT_CREATE;
    }
    mprFree(server->http);
    return 0;
}


/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
