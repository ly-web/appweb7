/*
    espFramework.c -- ESP Web Framework API

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "esp.h"

#if BIT_PACK_ESP

/************************************* Code ***********************************/
/*  
    Add a http header if not already defined
 */
PUBLIC void espAddHeader(HttpConn *conn, cchar *key, cchar *fmt, ...)
{
    va_list     vargs;

    assure(key && *key);
    assure(fmt && *fmt);

    va_start(vargs, fmt);
    httpAddHeaderString(conn, key, sfmt(fmt, vargs));
    va_end(vargs);
}


/*
    Add a header string if not already defined
 */
PUBLIC void espAddHeaderString(HttpConn *conn, cchar *key, cchar *value)
{
    httpAddHeaderString(conn, key, value);
}


/* 
   Append a header. If already defined, the value is catenated to the pre-existing value after a ", " separator.
   As per the HTTP/1.1 spec.
 */
PUBLIC void espAppendHeader(HttpConn *conn, cchar *key, cchar *fmt, ...)
{
    va_list     vargs;

    assure(key && *key);
    assure(fmt && *fmt);

    va_start(vargs, fmt);
    httpAppendHeaderString(conn, key, sfmt(fmt, vargs));
    va_end(vargs);
}


/* 
   Append a header string. If already defined, the value is catenated to the pre-existing value after a ", " separator.
   As per the HTTP/1.1 spec.
 */
PUBLIC void espAppendHeaderString(HttpConn *conn, cchar *key, cchar *value)
{
    httpAppendHeaderString(conn, key, value);
}


PUBLIC void espAutoFinalize(HttpConn *conn) 
{
    EspReq  *req;

    req = conn->data;
    if (req->autoFinalize) {
        httpFinalize(conn);
    }
}


//  MOB
PUBLIC void espManageAction(EspAction *ap, int flags)
{
}


PUBLIC int espCache(HttpRoute *route, cchar *uri, int lifesecs, int flags)
{
    httpAddCache(route, NULL, uri, NULL, NULL, 0, lifesecs * MPR_TICKS_PER_SEC, flags);
    return 0;
}


PUBLIC bool espCheckSecurityToken(HttpConn *conn) 
{
    HttpRx  *rx;
    cchar   *securityToken, *sessionToken;

    rx = conn->rx;
    if (!(rx->flags & HTTP_POST)) {
        return 1;
    }
    if (rx->securityToken == 0) {
        sessionToken = rx->securityToken = sclone(httpGetSessionVar(conn, ESP_SECURITY_TOKEN_NAME, ""));
#if UNUSED && KEEP
        securityTokenName = espGetParam(conn, "SecurityTokenName", "");
#endif
        securityToken = espGetParam(conn, ESP_SECURITY_TOKEN_NAME, "");
        if (!smatch(sessionToken, securityToken)) {
            httpError(conn, HTTP_CODE_NOT_ACCEPTABLE, 
                "Security token does not match. Potential CSRF attack. Denying request");
            return 0;
        }
    }
    return 1;
}


PUBLIC EdiRec *espCreateRec(HttpConn *conn, cchar *tableName, MprHash *params)
{
    Edi         *edi;
    EdiRec      *rec;

    edi = espGetDatabase(conn);
    if ((rec = ediCreateRec(edi, tableName)) == 0) {
        return 0;
    }
    ediSetFields(rec, params);
    return espSetRec(conn, rec);
}


PUBLIC void espDefineAction(HttpRoute *route, cchar *target, void *actionProc)
{
    EspAction   *action;
    EspRoute    *eroute;
    Esp         *esp;

    assure(route);
    assure(target && *target);
    assure(actionProc);

    esp = MPR->espService;
    if ((action = mprAllocObj(EspAction, espManageAction)) == 0) {
        return;
    }
    action->actionProc = actionProc;
    if (target) {
        eroute = route->eroute;
        mprAddKey(esp->actions, mprJoinPath(eroute->controllersDir, target), action);
    }
}


/*
    The base procedure is invoked prior to calling any and all actions
 */
PUBLIC void espDefineBase(HttpRoute *route, EspProc baseProc)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    eroute->controllerBase = baseProc;
}


/*
    Path should be an app-relative path to the view file (relative-path.esp)
 */
PUBLIC void espDefineView(HttpRoute *route, cchar *path, void *view)
{
    Esp         *esp;

    assure(path && *path);
    assure(view);

    esp = MPR->espService;
	path = mprGetPortablePath(mprJoinPath(route->dir, path));
    mprAddKey(esp->views, path, view);
}


PUBLIC void espFinalize(HttpConn *conn) 
{
    httpFinalize(conn);
}


PUBLIC void espFlush(HttpConn *conn) 
{
    httpFlush(conn);
}


//  MOB - confusing vs ediGetColumns
PUBLIC MprList *espGetColumns(HttpConn *conn, EdiRec *rec)
{
    if (rec == 0) {
        rec = conn->record;
    }
    if (rec) {
        return ediGetColumns(espGetDatabase(conn), rec->tableName);
    }
    return mprCreateList(0, 0);
}


PUBLIC MprOff espGetContentLength(HttpConn *conn)
{
    return httpGetContentLength(conn);
}


PUBLIC cchar *espGetContentType(HttpConn *conn)
{
    return conn->rx->mimeType;
}


//  MOB - need an API to parse these into a hash
PUBLIC cchar *espGetCookies(HttpConn *conn) 
{
    return httpGetCookies(conn);
}


PUBLIC Edi *espGetDatabase(HttpConn *conn)
{
    EspRoute    *eroute;
    EspReq      *req;

    req = conn->data;
    if (req == 0) {
        return 0;
    }
    eroute = req->eroute;
    if (eroute == 0 || eroute->edi == 0) {
        httpError(conn, 0, "Cannot get database instance");
        return 0;
    }
    return eroute->edi;
}


PUBLIC EspRoute *espGetEspRoute(HttpConn *conn)
{
    EspReq      *req;

    if ((req = conn->data) == 0) {
        return 0;
    }
    return req->eroute;
}


PUBLIC cchar *espGetDir(HttpConn *conn)
{   
    return conn->rx->route->dir;
}


//  MOB - rethink name espGetFlash
PUBLIC cchar *espGetFlashMessage(HttpConn *conn, cchar *kind)
{
    EspReq      *req;
    MprKey      *kp;
    cchar       *msg;
   
    req = conn->data;
    if (kind == 0 || req->flash == 0 || mprGetHashLength(req->flash) == 0) {
        return 0;
    }
    for (kp = 0; (kp = mprGetNextKey(req->flash, kp)) != 0; ) {
        msg = kp->data;
        if (smatch(kind, kp->key) || smatch(kind, "all")) {
            return msg;
        }
    }
    return 0;
}


PUBLIC EdiGrid *espGetGrid(HttpConn *conn)
{           
    return conn->grid;
}

    
PUBLIC cchar *espGetHeader(HttpConn *conn, cchar *key)
{
    return httpGetHeader(conn, key);
}


PUBLIC MprHash *espGetHeaderHash(HttpConn *conn)
{
    return httpGetHeaderHash(conn);
}


PUBLIC char *espGetHeaders(HttpConn *conn)
{
    return httpGetHeaders(conn);
}

            
PUBLIC cchar *espGetMethod(HttpConn *conn)
{   
    return conn->rx->method;
} 


PUBLIC cchar *espGetParam(HttpConn *conn, cchar *var, cchar *defaultValue)
{
    return httpGetParam(conn, var, defaultValue);
}


PUBLIC MprHash *espGetParams(HttpConn *conn)
{
    return httpGetParams(conn);
}


PUBLIC int espGetIntParam(HttpConn *conn, cchar *var, int defaultValue)
{
    return httpGetIntParam(conn, var, defaultValue);
}


PUBLIC cchar *espGetQueryString(HttpConn *conn)
{
    return httpGetQueryString(conn);
}


PUBLIC char *espGetReferrer(HttpConn *conn)
{
    if (conn->rx->referrer) {
        return conn->rx->referrer;
    }
    return espGetTop(conn);
}


PUBLIC Edi *espGetRouteDatabase(EspRoute *eroute)
{
    if (eroute == 0 || eroute->edi == 0) {
        return 0;
    }
    return eroute->edi;
}


PUBLIC int espGetStatus(HttpConn *conn)
{
    return httpGetStatus(conn);
}


PUBLIC char *espGetStatusMessage(HttpConn *conn)
{
    return httpGetStatusMessage(conn);
}


PUBLIC char *espGetTop(HttpConn *conn)
{
    return httpLink(conn, "~", NULL);
}


PUBLIC MprHash *espGetUploads(HttpConn *conn)
{
    return conn->rx->files;
}


PUBLIC cchar *espGetUri(HttpConn *conn)
{
    return conn->rx->uri;
}


PUBLIC bool espHasGrid(HttpConn *conn)
{
    return conn->grid != 0;
}


PUBLIC bool espHasRec(HttpConn *conn)
{
    EdiRec  *rec;

    rec = conn->record;
    return (rec && rec->id) ? 1 : 0;
}


PUBLIC bool espIsEof(HttpConn *conn)
{
    return httpIsEof(conn);
}


PUBLIC bool espIsFinalized(HttpConn *conn) 
{
    return httpIsFinalized(conn);
}


PUBLIC bool espIsSecure(HttpConn *conn)
{
    return conn->secure;
}


/*
    grid = makeGrid("[ \
        { id: '1', country: 'Australia' }, \
        { id: '2', country: 'China' }, \
    ]");
 */
PUBLIC EdiGrid *espMakeGrid(cchar *contents)
{
    return ediMakeGrid(contents);
}


PUBLIC MprHash *espMakeHash(cchar *fmt, ...)
{
    va_list     args;
    cchar       *str;

    va_start(args, fmt);
    str = sfmtv(fmt, args);
    va_end(args);
    return mprDeserialize(str);
}


/*
    rec = makeRec("{ id: 1, title: 'Message One', body: 'Line one' }");
 */
PUBLIC EdiRec *espMakeRec(cchar *contents)
{
    return ediMakeRec(contents);
}


PUBLIC bool espMatchParam(HttpConn *conn, cchar *var, cchar *value)
{
    return httpMatchParam(conn, var, value);
}


/*
    Test if a module has been updated (is stale).
    This will unload the module if it is stale and loaded 
 */
PUBLIC bool espModuleIsStale(cchar *source, cchar *module, int *recompile)
{
    MprModule   *mp;
    MprPath     sinfo, minfo;

    *recompile = 0;
    mprGetPathInfo(module, &minfo);
    if (!minfo.valid) {
        *recompile = 1;
        if ((mp = mprLookupModule(source)) != 0) {
            if (!espUnloadModule(source, 0)) {
                mprError("Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
        }
        return 1;
    }
    mprGetPathInfo(source, &sinfo);
    /*
        Use >= to ensure we reload. This may cause redundant reloads as mtime has a 1 sec granularity.
     */
    if (sinfo.valid && sinfo.mtime >= minfo.mtime) {
        if ((mp = mprLookupModule(source)) != 0) {
            if (!espUnloadModule(source, 0)) {
                mprError("Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
        }
        *recompile = 1;
        return 1;
    }
    if ((mp = mprLookupModule(source)) != 0) {
        if (minfo.mtime > mp->modified) {
            /* Module file has been updated */
            if (!espUnloadModule(source, 0)) {
                mprError("Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
            return 1;
        }
    }
    /* Loaded module is current */
    return 0;
}


PUBLIC ssize espReceive(HttpConn *conn, char *buf, ssize len)
{
    return httpRead(conn, buf, len);
}


PUBLIC EdiRec *espReadRecWhere(HttpConn *conn, cchar *tableName, cchar *fieldName, cchar *operation, cchar *value)
{
    return espSetRec(conn, ediReadOneWhere(espGetDatabase(conn), tableName, fieldName, operation, value));
}


PUBLIC EdiRec *espReadRec(HttpConn *conn, cchar *tableName)
{
    return espSetRec(conn, ediReadRec(espGetDatabase(conn), tableName, espGetParam(conn, "id", NULL)));
}


PUBLIC EdiRec *espReadRecByKey(HttpConn *conn, cchar *tableName, cchar *key)
{
    return espSetRec(conn, ediReadRec(espGetDatabase(conn), tableName, key));
}


PUBLIC EdiGrid *espReadRecsWhere(HttpConn *conn, cchar *tableName, cchar *fieldName, cchar *operation, cchar *value)
{
    //  MOB - where else should call espSetGrid
    return espSetGrid(conn, ediReadWhere(espGetDatabase(conn), tableName, fieldName, operation, value));
}


PUBLIC EdiGrid *espReadTable(HttpConn *conn, cchar *tableName)
{
    EdiGrid *grid;
    
    grid = ediReadWhere(espGetDatabase(conn), tableName, 0, 0, 0);
    espSetGrid(conn, grid);
    return grid;
}


PUBLIC void espRedirect(HttpConn *conn, int status, cchar *target)
{
    //  MOB - should this httpLink be pushed into httpRedirect?
    httpRedirect(conn, status, httpLink(conn, target, NULL));
}


PUBLIC void espRedirectBack(HttpConn *conn)
{
    if (conn->rx->referrer) {
        espRedirect(conn, HTTP_CODE_MOVED_TEMPORARILY, conn->rx->referrer); 
    }
}


PUBLIC bool espRemoveRec(HttpConn *conn, cchar *tableName, cchar *key)
{
    if (ediDeleteRow(espGetDatabase(conn), tableName, key) < 0) {
        return 0;
    }
    return 1;
}

PUBLIC ssize espRender(HttpConn *conn, cchar *fmt, ...)
{
    va_list     vargs;
    char        *buf;

    va_start(vargs, fmt);
    buf = sfmtv(fmt, vargs);
    va_end(vargs);
    return espRenderString(conn, buf);
}
    

PUBLIC ssize espRenderBlock(HttpConn *conn, cchar *buf, ssize size)
{
    /*
        Cannot use HTTP_BLOCK here has it will yield for GC.
        This is too onerous for callers to secure all memory
     */
    return httpWriteBlock(conn->writeq, buf, size, HTTP_BUFFER);
}


//  MOB - need a renderCached(), updateCache()
PUBLIC ssize espRenderCached(HttpConn *conn)
{
    return httpWriteCached(conn);
}


PUBLIC ssize espRenderError(HttpConn *conn, int status, cchar *fmt, ...)
{
    va_list     args;
    HttpRx      *rx;
    EspReq      *req;
    EspRoute    *eroute;
    ssize       written;
    cchar       *msg, *title, *text;

    va_start(args, fmt);    

    rx = conn->rx;
    req = conn->data;
    eroute = req->eroute;
    written = 0;

    if (!httpIsFinalized(conn)) {
        if (status == 0) {
            status = HTTP_CODE_INTERNAL_SERVER_ERROR;
        }
        title = sfmt("Request Error for \"%s\"", rx->pathInfo);
        msg = mprEscapeHtml(sfmtv(fmt, args));
        if (eroute->showErrors) {
            text = sfmt(\
                "<!DOCTYPE html>\r\n<html>\r\n<head><title>%s</title></head>\r\n" \
                "<body>\r\n<h1>%s</h1>\r\n" \
                "    <pre>%s</pre>\r\n" \
                "    <p>To prevent errors being displayed in the browser, " \
                "       set <b>log.showErrors</b> to false in the ejsrc file.</p>\r\n", \
                "</body>\r\n</html>\r\n", title, title, msg);
            httpSetHeader(conn, "Content-Type", "text/html");
            written += espRenderString(conn, text);
            espFinalize(conn);
            mprLog(4, "Request error (%d) for: \"%s\"", status, rx->pathInfo);
        }
    }
    va_end(args);    
    return written;
}


PUBLIC ssize espRenderFile(HttpConn *conn, cchar *path)
{
    MprFile     *from;
    ssize       count, written, nbytes;
    char        buf[BIT_MAX_BUFFER];

    if ((from = mprOpenFile(path, O_RDONLY | O_BINARY, 0)) == 0) {
        return MPR_ERR_CANT_OPEN;
    }
    written = 0;
    while ((count = mprReadFile(from, buf, sizeof(buf))) > 0) {
        if ((nbytes = espRenderBlock(conn, buf, count)) < 0) {
            return nbytes;
        }
        written += nbytes;
    }
    mprCloseFile(from);
    return written;
}


PUBLIC ssize espRenderSafeString(HttpConn *conn, cchar *s)
{
    s = mprEscapeHtml(s);
    return espRenderBlock(conn, s, slen(s));
}


PUBLIC ssize espRenderString(HttpConn *conn, cchar *s)
{
    return espRenderBlock(conn, s, slen(s));
}


/*
    Render a request variable. If a param by the given name is not found, consult the session.
 */
PUBLIC ssize espRenderVar(HttpConn *conn, cchar *name)
{
    cchar   *value;

    if ((value = espGetParam(conn, name, 0)) == 0) {
        value = httpGetSessionVar(conn, name, "");
    }
    return espRenderSafeString(conn, value);
}


PUBLIC int espRemoveHeader(HttpConn *conn, cchar *key)
{
    assure(key && *key);
    if (conn->tx == 0) {
        return MPR_ERR_CANT_ACCESS;
    }
    return mprRemoveKey(conn->tx->headers, key);
}


PUBLIC bool espSetAutoFinalizing(HttpConn *conn, bool on) 
{
    EspReq  *req;
    bool    old;

    req = conn->data;
    old = req->autoFinalize;
    req->autoFinalize = on;
    return old;
}


PUBLIC void espSetContentLength(HttpConn *conn, MprOff length)
{
    httpSetContentLength(conn, length);
}


PUBLIC void espSetCookie(HttpConn *conn, cchar *name, cchar *value, cchar *path, cchar *cookieDomain, MprTicks lifespan, 
        bool isSecure)
{
    httpSetCookie(conn, name, value, path, cookieDomain, lifespan, isSecure);
}


PUBLIC void espSetContentType(HttpConn *conn, cchar *mimeType)
{
    httpSetContentType(conn, mimeType);
}


PUBLIC EdiRec *espSetField(EdiRec *rec, cchar *fieldName, cchar *value)
{
    return ediSetField(rec, fieldName, value);
}


PUBLIC EdiRec *espSetFields(EdiRec *rec, MprHash *params)
{
    return ediSetFields(rec, params);
}


PUBLIC void espSetFlash(HttpConn *conn, cchar *kind, cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFlashv(conn, kind, fmt, args);
    va_end(args);
}


PUBLIC void espSetFlashv(HttpConn *conn, cchar *kind, cchar *fmt, va_list args)
{
    EspReq      *req;
    MprKey      *kp;
    cchar       *prior, *msg;

    req = conn->data;
    msg = sfmtv(fmt, args);

    if (req->flash == 0) {
        req->flash = mprCreateHash(0, 0);
        httpGetSession(conn, 1);
    }
    if ((prior = mprLookupKey(req->flash, kind)) != 0) {
        kp = mprAddKey(req->flash, kind, sjoin(prior, "\n", msg, NULL));
    } else {
        kp = mprAddKey(req->flash, kind, sclone(msg));
    }
    if (kp) {
        kp->type = MPR_JSON_STRING;
    }
}


/*
    Set the default grid for a request
 */
PUBLIC EdiGrid *espSetGrid(HttpConn *conn, EdiGrid *grid)
{
    conn->grid = grid;
    return grid;
}


/*  
    Set a http header. Overwrite if present.
 */
PUBLIC void espSetHeader(HttpConn *conn, cchar *key, cchar *fmt, ...)
{
    va_list     vargs;

    assure(key && *key);
    assure(fmt && *fmt);

    va_start(vargs, fmt);
    httpSetHeader(conn, key, sfmt(fmt, vargs));
    va_end(vargs);
}


PUBLIC void espSetHeaderString(HttpConn *conn, cchar *key, cchar *value)
{
    httpSetHeaderString(conn, key, value);
}


PUBLIC void espSetIntParam(HttpConn *conn, cchar *var, int value) 
{
    httpSetIntParam(conn, var, value);
}


PUBLIC void espSetParam(HttpConn *conn, cchar *var, cchar *value) 
{
    httpSetParam(conn, var, value);
}


/*
    Set the default record for a request
 */
PUBLIC EdiRec *espSetRec(HttpConn *conn, EdiRec *rec)
{
    return conn->record = rec;
}


PUBLIC void espSetStatus(HttpConn *conn, int status)
{
    httpSetStatus(conn, status);
}


/*
    Convert queue data in key / value pairs
    MOB - should be able to remove this and use standard form parsing
 */
static int getParams(char ***keys, char *buf, int len)
{
    char**  keyList;
    char    *eq, *cp, *pp, *tok;
    int     i, keyCount;

    *keys = 0;

    /*
        Change all plus signs back to spaces
     */
    keyCount = (len > 0) ? 1 : 0;
    for (cp = buf; cp < &buf[len]; cp++) {
        if (*cp == '+') {
            *cp = ' ';
        } else if (*cp == '&' && (cp > buf && cp < &buf[len - 1])) {
            keyCount++;
        }
    }
    if (keyCount == 0) {
        return 0;
    }

    /*
        Crack the input into name/value pairs 
     */
    keyList = mprAlloc((keyCount * 2) * sizeof(char**));
    i = 0;
    tok = 0;
    for (pp = stok(buf, "&", &tok); pp; pp = stok(0, "&", &tok)) {
        if ((eq = strchr(pp, '=')) != 0) {
            *eq++ = '\0';
            pp = mprUriDecode(pp);
            eq = mprUriDecode(eq);
        } else {
            pp = mprUriDecode(pp);
            eq = 0;
        }
        if (i < (keyCount * 2)) {
            keyList[i++] = pp;
            keyList[i++] = eq;
        }
    }
    *keys = keyList;
    return keyCount;
}


PUBLIC void espShowRequest(HttpConn *conn)
{
    MprHash     *env;
    MprKey      *kp;
    MprBuf      *buf;
    HttpRx      *rx;
    HttpQueue   *q;
    cchar       *query;
    char        qbuf[BIT_MAX_URI], **keys, *value;
    int         i, numKeys;

    rx = conn->rx;
    httpSetHeaderString(conn, "Cache-Control", "no-cache");
    httpCreateCGIParams(conn);
    espRender(conn, "\r\n");

    /*
        Query
     */
    if ((query = espGetQueryString(conn)) != 0) {
        scopy(qbuf, sizeof(qbuf), query);
        if ((numKeys = getParams(&keys, qbuf, (int) strlen(qbuf))) > 0) {
            for (i = 0; i < (numKeys * 2); i += 2) {
                value = keys[i+1];
                espRender(conn, "QUERY %s=%s\r\n", keys[i], value ? value: "null");
            }
        }
        espRender(conn, "\r\n");
    }

    /*
        Http Headers
     */
    env = espGetHeaderHash(conn);
    for (ITERATE_KEYS(env, kp)) {
        espRender(conn, "HEADER %s=%s\r\n", kp->key, kp->data ? kp->data: "null");
    }
    espRender(conn, "\r\n");

    /*
        Server vars
     */
    for (ITERATE_KEYS(conn->rx->svars, kp)) {
        espRender(conn, "SERVER %s=%s\r\n", kp->key, kp->data ? kp->data: "null");
    }
    espRender(conn, "\r\n");

    /*
        Form vars
     */
    if ((env = espGetParams(conn)) != 0) {
        for (ITERATE_KEYS(env, kp)) {
            espRender(conn, "FORM %s=%s\r\n", kp->key, kp->data ? kp->data: "null");
        }
        espRender(conn, "\r\n");
    }

    /*
        Body
     */
    q = conn->readq;
    if (q->first && rx->bytesRead > 0 && scmp(rx->mimeType, "application/x-www-form-urlencoded") == 0) {
        buf = q->first->content;
        mprAddNullToBuf(buf);
        if ((numKeys = getParams(&keys, mprGetBufStart(buf), (int) mprGetBufLength(buf))) > 0) {
            for (i = 0; i < (numKeys * 2); i += 2) {
                value = keys[i+1];
                espRender(conn, "BODY %s=%s\r\n", keys[i], value ? value: "null");
            }
        }
        espRender(conn, "\r\n");
    }
}


/*
    This is called when unloading a view or controller module
 */
PUBLIC bool espUnloadModule(cchar *module, MprTicks timeout)
{
    MprModule   *mp;
    MprTicks    mark;
    Esp         *esp;

    /* MOB - should this suspend new requests */
    if ((mp = mprLookupModule(module)) != 0) {
        esp = MPR->espService;
        mark = mprGetTicks();
        do {
            lock(esp);
            /* Own request will count as 1 */
            if (esp->inUse <= 1) {
                mprUnloadModule(mp);
                unlock(esp);
                return 1;
            }
            unlock(esp);
            mprSleep(10);
            /* Defaults to 10 secs */
        } while (mprGetRemainingTicks(mark, timeout) > 0);
    }
    return 0;
}


PUBLIC void espUpdateCache(HttpConn *conn, cchar *uri, cchar *data, int lifesecs)
{
    httpUpdateCache(conn, uri, data, lifesecs * MPR_TICKS_PER_SEC);
}


PUBLIC bool espUpdateField(HttpConn *conn, cchar *tableName, cchar *key, cchar *fieldName, cchar *value)
{
    return ediUpdateField(espGetDatabase(conn), tableName, key, fieldName, value) == 0;
}


PUBLIC bool espUpdateFields(HttpConn *conn, cchar *tableName, MprHash *params)
{
    EdiRec  *rec;

    if ((rec = espSetFields(espReadRec(conn, tableName), params)) == 0) {
        return 0;
    }
    return ediUpdateRec(espGetDatabase(conn), rec) == 0;
}


PUBLIC bool espUpdateRec(HttpConn *conn, EdiRec *rec)
{
    return ediUpdateRec(rec->edi, rec) == 0;
}


PUBLIC cchar *espUri(HttpConn *conn, cchar *target)
{
    return httpLink(conn, target, 0);
}


PUBLIC void espManageEspRoute(EspRoute *eroute, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(eroute->appModuleName);
        mprMark(eroute->appModulePath);
        mprMark(eroute->cacheDir);
        mprMark(eroute->compile);
        mprMark(eroute->controllersDir);
        mprMark(eroute->dbDir);
        mprMark(eroute->migrationsDir);
        mprMark(eroute->edi);
        mprMark(eroute->env);
        mprMark(eroute->layoutsDir);
        mprMark(eroute->link);
        mprMark(eroute->searchPath);
        mprMark(eroute->staticDir);
        mprMark(eroute->viewsDir);
    }
}


#endif /* BIT_PACK_ESP */
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
