/*
    convenience.c -- High level convenience API

    This module provides simple high-level APIs.
    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "appweb.h"

/************************************ Code ************************************/

static int runServer(cchar *configFile, cchar *ip, int port, cchar *home, cchar *documents)
{
    if (mprStart() < 0) {
        mprLog("error appweb", 0, "Cannot start the web server runtime");
        return MPR_ERR_CANT_CREATE;
    }
    if (httpCreate(HTTP_CLIENT_SIDE | HTTP_SERVER_SIDE) == 0) {
        mprLog("error http", 0, "Cannot create http services");
        return MPR_ERR_CANT_CREATE;
    }
    if (maConfigureServer(configFile, home, documents, ip, port) < 0) {
        mprLog("error appweb", 0, "Cannot create the web server");
        return MPR_ERR_BAD_STATE;
    }
    if (httpStartEndpoints() < 0) {
        mprLog("error appweb", 0, "Cannot start the web server");
        return MPR_ERR_CANT_COMPLETE;
    }
    mprServiceEvents(-1, 0);
    httpStopEndpoints();
    return 0;
}


/*  
    Create a web server described by a config file. 
 */
PUBLIC int maRunWebServer(cchar *configFile)
{
    Mpr         *mpr;
    int         rc;

    if ((mpr = mprCreate(0, NULL, MPR_USER_EVENTS_THREAD)) == 0) {
        mprLog("error appweb", 0, "Cannot create the web server runtime");
        return MPR_ERR_CANT_CREATE;
    }
    rc = runServer(configFile, 0, 0, 0, 0);
    mprDestroy();
    return rc;
}


/*
    Run a web server not based on a config file.
 */
PUBLIC int maRunSimpleWebServer(cchar *ip, int port, cchar *home, cchar *documents)
{
    Mpr         *mpr;
    int         rc;

    if ((mpr = mprCreate(0, NULL, MPR_USER_EVENTS_THREAD)) == 0) {
        mprLog("error appweb", 0, "Cannot create the web server runtime");
        return MPR_ERR_CANT_CREATE;
    }
    rc = runServer(0, ip, port, home, documents);
    mprDestroy();
    return rc;
}


/*  
    Run the web client to retrieve a URI
    This will create the MPR and Http service on demand. As such, it is not the most
    efficient way to run a web request.
    @return HTTP status code or negative MPR error code. Returns a malloc string in response.
 */
PUBLIC int maRunWebClient(cchar *method, cchar *uri, cchar *data, char **response, char **err)
{
    Mpr         *mpr;
    HttpConn    *conn;
    int         status;

    if (err) {
        *err = 0;
    }
    if (response) {
        *response = 0;
    }
    if ((mpr = mprCreate(0, NULL, 0)) == 0) {
        mprLog("error appweb", 0, "Cannot create the MPR runtime");
        return MPR_ERR_CANT_CREATE;
    }
    if (mprStart() < 0) {
        mprLog("error appweb", 0, "Cannot start the web server runtime");
        return MPR_ERR_CANT_INITIALIZE;
    }
    if (httpCreate(HTTP_CLIENT_SIDE) < 0) {
        mprLog("error appweb", 0, "Cannot create HTTP services");
        return MPR_ERR_CANT_INITIALIZE;
    }
    if ((conn = httpRequest(method, uri, data, err)) == 0) {
        mprLog("error appweb", 0, "Cannot create connection");
        return MPR_ERR_CANT_INITIALIZE;
    }
    status = httpGetStatus(conn);
    if (response) {
        *response = httpReadString(conn);
    }
    mprDestroy();
    return status;
}

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2014. All Rights Reserved.

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
