/*
    spyFilter.c - Eavesdrop on input data

    This sample filter examines form data for name/password fields. If the name and password match
    an AUTH variable is defined. Form data is passed onto the handler.
  
    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************* Includes ***********************************/

#include    "http.h"

/*********************************** Code *************************************/

static int matchSpy(HttpConn *conn, HttpRoute *route, int dir)
{
    return (conn->rx->form && strncmp(conn->rx->pathInfo, "/", 1) == 0);
}


static void incomingSpy(HttpQueue *q, HttpPacket *packet)
{
    cchar   *name, *password;
    
    if (packet->content == 0) {
        /*
            Create form vars for all the input data
         */
        name = httpGetParam(q->conn, "name", 0);
        password = httpGetParam(q->conn, "password", 0);
        if (name && password && smatch(name, "admin") && smatch(password, "secret")) {
            httpSetHeader(q->conn, "AUTH", "authorized");
        }
        if (q->first) {
            httpPutPacketToNext(q, q->first);
        }
        httpPutPacketToNext(q, packet);
    } else {
        httpJoinPacketForService(q, packet, 0);
    }
}


MprModule *SpyFilterInit(Http *http, MprModule *module)
{
    HttpStage     *filter;

    if ((filter = httpCreateFilter(http, "spyFilter", module)) == 0) {
        return 0;
    }
    filter->match = matchSpy; 
    filter->incoming = incomingSpy; 
    return module;
}

/*
    @copy   default
    
    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.
    Copyright (c) Michael O'Brien, 1993-2013. All Rights Reserved.
    
    This software is distributed under commercial and open source licenses.
    You may use the GPL open source license described below or you may acquire 
    a commercial license from Embedthis Software. You agree to be fully bound 
    by the terms of either license. Consult the LICENSE.md distributed with 
    this software for full details.
    
    This software is open source; you can redistribute it and/or modify it 
    under the terms of the GNU General Public License as published by the 
    Free Software Foundation; either version 2 of the License, or (at your 
    option) any later version. See the GNU General Public License for more 
    details at: http://www.embedthis.com/downloads/gplLicense.html
    
    This program is distributed WITHOUT ANY WARRANTY; without even the 
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    
    This GPL license does NOT permit incorporating this software into 
    proprietary programs. If you are unable to comply with the GPL, you must
    acquire a commercial license to use this software. Commercial licenses 
    for this software and support services are available from Embedthis 
    Software at http://www.embedthis.com 
    
    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
