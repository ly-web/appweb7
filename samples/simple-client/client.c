/*
    client.c - Simple client using the GET method to retrieve a web page.
  
    This sample demonstrates retrieving content using the HTTP GET method.
  
    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */
/***************************** Includes *******************************/

#include    "appweb.h"

/********************************* Code *******************************/

MAIN(simpleClient, int argc, char **argv, char **envp)
{
    Http        *http;
    HttpConn    *conn;
    cchar       *content;
    int         code;

    /* 
       Create the Multithreaded Portable Runtime and start it.
     */
    mprCreate(argc, argv, 0);
    mprStart();

    /* 
       Get a client http object to work with. We can issue multiple requests with this one object.
       Add the conn as a root object so the GC won't collect it while we are using it.
     */
    http = httpCreate(HTTP_CLIENT_SIDE);
    conn = httpCreateConn(http, NULL, NULL);
    mprAddRoot(conn);

    /* 
       Open a connection to issue the GET. Then finalize the request output - this forces the request out.
     */
    if (httpConnect(conn, "GET", "http://www.embedthis.com/index.html", NULL) < 0) {
        mprError("Can't get URL");
        exit(2);
    }
    httpFinalizeOutput(conn);

    /*
        Wait for a response
     */
    if (httpWait(conn, HTTP_STATE_PARSED, 10000) < 0) {
        mprError("No response");
        exit(2);
    }

    /* 
       Examine the HTTP response HTTP code. 200 is success.
     */
    code = httpGetStatus(conn);
    if (code != 200) {
        mprError("Server responded with code %d\n", code);
        exit(1);
    } 

    /* 
       Get the actual response content
     */
    content = httpReadString(conn);
    if (content) {
        mprPrintf("Server responded with: %s\n", content);
    }
    mprDestroy(MPR_EXIT_DEFAULT);
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
