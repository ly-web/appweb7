/*
    convenience.c -- High level convenience API
    This module provides simple, high-level APIs for creating servers.
    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "appweb.h"

/************************************ Code ************************************/

static int runServer(cchar *configFile, cchar *ip, int port, cchar *home, cchar *documents)
{
    MaAppweb    *appweb;
    MaServer    *server;

    if (mprStart() < 0) {
        mprLog("error appweb", 0, "Cannot start the web server runtime");
        return MPR_ERR_CANT_CREATE;
    }
    if ((appweb = maCreateAppweb()) == 0) {
        mprLog("error appweb", 0, "Cannot create appweb object");
        return MPR_ERR_CANT_CREATE;
    }
    mprAddRoot(appweb);
    if ((server = maCreateServer(appweb, 0)) == 0) {
        mprLog("error appweb", 0, "Cannot create the web server");
        mprRemoveRoot(appweb);
        return MPR_ERR_CANT_CREATE;
    }
    if (home) {
        if (maConfigureServer(server, 0, home, documents, ip, port, 0) < 0) {
            mprLog("error appweb", 0, "Cannot create the web server");
            mprRemoveRoot(appweb);
            return MPR_ERR_BAD_STATE;
        }
    } else {
        if (maParseConfig(server, configFile, 0) < 0) {
            mprLog("error appweb", 0, "Cannot parse the config file %s", configFile);
            mprRemoveRoot(appweb);
            return MPR_ERR_CANT_READ;
        }
    }
    if (maStartServer(server) < 0) {
        mprLog("error appweb", 0, "Cannot start the web server");
        mprRemoveRoot(appweb);
        return MPR_ERR_CANT_COMPLETE;
    }
    mprServiceEvents(-1, 0);
    maStopServer(server);
    mprRemoveRoot(appweb);
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


//  TODO: REFACTOR with an inner function
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
    This will restart the default server on a new IP:PORT. It will stop listening on the default endpoint on 
    the default server, optionally modify the IP:PORT and resume listening. NOTE: running requests will be
    unaffected.  WARNING: this is demonstration code and has no error checking.
 */
PUBLIC void maRestartServer(cchar *ip, int port)
{
    MaAppweb        *appweb;
    MaServer        *server;
    HttpEndpoint    *endpoint;

    appweb = MPR->appwebService;
    server = mprGetFirstItem(appweb->servers);
    lock(appweb->servers);
    endpoint = mprGetFirstItem(server->endpoints);
    httpStopEndpoint(endpoint);

    if (port) {
        endpoint->port = port;
    }
    if (ip) {
        endpoint->ip = sclone(ip);
    }
    httpStartEndpoint(endpoint);
    unlock(appweb->servers);
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
    httpCreate(HTTP_CLIENT_SIDE);
    conn = httpRequest(method, uri, data, err);
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
