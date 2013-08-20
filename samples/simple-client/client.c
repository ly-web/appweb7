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
    int     code;
    char    *response, *err;

    /*
        This will create the Mpr and Http services. Alternatively, if you have existing
        Mpr and Http services, use httpRequest() directly (see below).
     */
    code = maRunWebClient("GET", "http://www.embedthis.com/index.html", NULL, &response, &err);
    if (code != 200) {
        mprPrintf("Server error code %d, %s\n", code, err);
        return 255;
    }
    printf("Server responded with: %s\n", response);
    return 0;
}

#if SAMPLE_CALLING_HTTP_REQUEST
PUBLIC int maRunWebClient(cchar *method, cchar *uri, cchar *data, char **response, char **err)
{
    Mpr   *mpr;
    int   code;

    if (err) {
        *err = 0;
    }
    if (response) {
        *response = 0;
    }
    if ((mpr = mprCreate(0, NULL, 0)) == 0) {
        mprError("Cannot create the MPR runtime");
        return MPR_ERR_CANT_CREATE;
    }
    if (mprStart() < 0) {
        mprError("Cannot start the web server runtime");
        return MPR_ERR_CANT_INITIALIZE;
    }
    httpCreate(HTTP_CLIENT_SIDE);
    code = httpRequest(method, uri, data, response, err);
    mprDestroy(MPR_EXIT_DEFAULT);
    return code;
#endif


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
