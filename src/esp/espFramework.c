/*
    espFramework.c -- ESP Web Framework API

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "esp.h"

#if BIT_PACK_ESP
/************************************* Code ***********************************/

PUBLIC void espAddComponent(HttpRoute *route, cchar *name)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    if (!mprGetJsonValue(eroute->config, sfmt("settings.components[@ = %s]", name), 0)) {
        mprSetJsonValue(eroute->config, "settings.components[*]", name, 0);
    }
}


/* 
    Add a http header if not already defined
 */
PUBLIC void espAddHeader(HttpConn *conn, cchar *key, cchar *fmt, ...)
{
    va_list     vargs;

    assert(key && *key);
    assert(fmt && *fmt);

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

    assert(key && *key);
    assert(fmt && *fmt);

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


PUBLIC int espCache(HttpRoute *route, cchar *uri, int lifesecs, int flags)
{
    httpAddCache(route, NULL, uri, NULL, NULL, 0, lifesecs * MPR_TICKS_PER_SEC, flags);
    return 0;
}


PUBLIC bool espCheckSecurityToken(HttpConn *conn) 
{
    return httpCheckSecurityToken(conn);
}


PUBLIC cchar *espCreateSession(HttpConn *conn)
{
    HttpSession *session;

    if ((session = httpCreateSession(getConn())) != 0) {
        return session->id;
    }
    return 0;
}


PUBLIC void espDefineAction(HttpRoute *route, cchar *target, void *action)
{
    EspRoute    *eroute;
    Esp         *esp;

    assert(route);
    assert(target && *target);
    assert(action);

    esp = MPR->espService;
    if (target) {
        eroute = route->eroute;
        mprAddKey(esp->actions, mprJoinPath(eroute->controllersDir, target), action);
    }
}


/*
    The base procedure is invoked prior to calling any and all actions on this route
 */
PUBLIC void espDefineBase(HttpRoute *route, EspProc baseProc)
{
    HttpRoute   *rp;
    EspRoute    *eroute, *er;
    int         next;

    eroute = route->eroute;
    for (ITERATE_ITEMS(route->host->routes, rp, next)) {
        if ((er = route->eroute) != 0 && smatch(er->controllersDir, eroute->controllersDir)) {
            er->commonController = baseProc;
        }
    }
}


/*
    Path should be an app-relative path to the view file (relative-path.esp)
 */
PUBLIC void espDefineView(HttpRoute *route, cchar *path, void *view)
{
    Esp         *esp;

    assert(path && *path);
    assert(view);

    if (!route) {
        mprError("Route not defined for view %s", path);
        return;
    }
    esp = MPR->espService;
    path = mprGetPortablePath(mprJoinPath(route->documents, path));
    mprAddKey(esp->views, path, view);
}


PUBLIC void espDestroySession(HttpConn *conn)
{
    httpDestroySession(conn);
}


PUBLIC void espFinalize(HttpConn *conn) 
{
    httpFinalize(conn);
}


PUBLIC void espFlush(HttpConn *conn) 
{
    httpFlush(conn);
}


PUBLIC cchar *espGetConfig(HttpRoute *route, cchar *key, cchar *defaultValue)
{
    EspRoute    *eroute;
    cchar       *value;

    eroute = route->eroute;
    if ((value = mprGetJsonValue(eroute->config, key, 0)) != 0) {
        return value;
    }
    return defaultValue;
}


PUBLIC MprOff espGetContentLength(HttpConn *conn)
{
    return httpGetContentLength(conn);
}


PUBLIC cchar *espGetContentType(HttpConn *conn)
{
    return conn->rx->mimeType;
}


PUBLIC cchar *espGetCookie(HttpConn *conn, cchar *name)
{
    return httpGetCookie(conn, name);
}


PUBLIC cchar *espGetCookies(HttpConn *conn) 
{
    return httpGetCookies(conn);
}


PUBLIC void *espGetData(HttpConn *conn)
{
    EspReq  *req;

    req = conn->data;
    return req->data;
}


PUBLIC Edi *espGetDatabase(HttpConn *conn)
{
    EspRoute    *eroute;

    eroute = conn->rx->route->eroute;
    if (eroute == 0 || eroute->edi == 0) {
        httpError(conn, 0, "Cannot get database instance");
        return 0;
    }
    return eroute->edi;
}


PUBLIC cchar *espGetDocuments(HttpConn *conn)
{   
    return conn->rx->route->documents;
}


#if DEPRECATED || 1
PUBLIC cchar *espGetDir(HttpConn *conn)
{
    return espGetDocuments(conn);
}
#endif


PUBLIC EspRoute *espGetEspRoute(HttpConn *conn)
{
    return conn->rx->route->eroute;
}


PUBLIC cchar *espGetFlash(HttpConn *conn, cchar *kind)
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


PUBLIC cchar *espGetFeedback(HttpConn *conn, cchar *kind)
{
    EspReq      *req;
    MprKey      *kp;
    cchar       *msg;
   
    req = conn->data;
    if (kind == 0 || req->feedback == 0 || mprGetHashLength(req->feedback) == 0) {
        return 0;
    }
    for (kp = 0; (kp = mprGetNextKey(req->feedback, kp)) != 0; ) {
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


PUBLIC int espGetIntParam(HttpConn *conn, cchar *var, int defaultValue)
{
    return httpGetIntParam(conn, var, defaultValue);
}

  
PUBLIC cchar *espGetMethod(HttpConn *conn)
{   
    return conn->rx->method;
} 


PUBLIC cchar *espGetParam(HttpConn *conn, cchar *var, cchar *defaultValue)
{
    return httpGetParam(conn, var, defaultValue);
}


PUBLIC MprJson *espGetParams(HttpConn *conn)
{
    return httpGetParams(conn);
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


PUBLIC Edi *espGetRouteDatabase(HttpRoute *route)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    if (eroute == 0 || eroute->edi == 0) {
        return 0;
    }
    return eroute->edi;
}


PUBLIC cchar *espGetSecurityToken(HttpConn *conn)
{
    return httpGetSecurityToken(conn);
}


PUBLIC cchar *espGetSessionID(HttpConn *conn, int create)
{
    HttpSession *session;

    if ((session = httpGetSession(getConn(), create)) != 0) {
        return session->id;
    }
    return 0;
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
    return httpUri(conn, "~", NULL);
}


PUBLIC MprHash *espGetUploads(HttpConn *conn)
{
    return conn->rx->files;
}


PUBLIC cchar *espGetUri(HttpConn *conn)
{
    return conn->rx->uri;
}


PUBLIC bool espHasComponent(HttpRoute *route, cchar *name)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    return mprGetJsonValue(eroute->config, sfmt("settings.components[@ = '%s']", name), 0) != 0;
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
    Load the config.json
 */
PUBLIC int espLoadConfig(HttpRoute *route)
{
    EspRoute    *eroute;
    MprJson     *msettings;
    MprPath     cinfo;
    cchar       *cpath, *value;

    eroute = route->eroute;
    cpath = mprJoinPath(route->documents, "config.json");
    if (mprGetPathInfo(cpath, &cinfo) == 0) {
        if (eroute->config && cinfo.mtime > eroute->configLoaded) {
            eroute->config = 0;
        }
        eroute->configLoaded = cinfo.mtime;
    }
    if (!eroute->config) {
        if ((eroute->config = mprLoadJson(cpath)) != 0) {
            /*
                Blend the mode properties into settings
             */
            eroute->mode = mprGetJsonValue(eroute->config, "mode", 0);
            if ((msettings = mprGetJson(eroute->config, sfmt("modes.%s", eroute->mode), 0)) != 0) {
                mprBlendJson(mprLookupJson(eroute->config, "settings"), msettings, 0);
            }
            if ((value = espGetConfig(route, "settings.showErrors", 0)) != 0) {
                httpSetRouteShowErrors(route, smatch(value, "true"));
            }
            if ((value = espGetConfig(route, "settings.update", 0)) != 0) {
                eroute->update = smatch(value, "true");
            }
            if ((value = espGetConfig(route, "settings.keepSource", 0)) != 0) {
                eroute->keepSource = smatch(value, "true");
            }
            if ((eroute->serverPrefix = espGetConfig(route, "settings.serverPrefix", 0)) == 0) {
                eroute->serverPrefix = sclone(BIT_ESP_SERVER_PREFIX);
            }
            if ((value = espGetConfig(route, "settings.login.name", 0)) != 0) {
                /* Automatic login as this user. Password not required */
                httpSetAuthUsername(route->auth, value);
            }
            if ((value = espGetConfig(route, "settings.xsrfToken", 0)) != 0) {
                httpSetRouteXsrf(route, smatch(value, "true"));
            }
            if ((value = espGetConfig(route, "settings.sendJson", 0)) != 0) {
                eroute->json = smatch(value, "true");
            }
            if (espTestConfig(route, "settings.map", "compressed")) {
                httpAddRouteMapping(route, "js,css,less", "min.${1}.gz, min.${1}, ${1}.gz");
                httpAddRouteMapping(route, "html,xml", "${1}.gz");
            }
            if (!eroute->database) {
                if ((eroute->database = espGetConfig(route, "server.database", 0)) != 0) {
                    if (espOpenDatabase(route, eroute->database) < 0) {
                        mprError("Cannot open database %s", eroute->database);
                        return MPR_ERR_CANT_OPEN;
                    }
                }
            }
            eroute->json = espTestConfig(route, "settings.json", "1");
        } else {
            eroute->config = mprCreateJson(MPR_JSON_OBJ);
            espAddComponent(route, "legacy-mvc");
        }
        if (espHasComponent(route, "legacy-mvc")) {
            eroute->legacy = 1;
        }
    }
    return 0;
}


PUBLIC bool espMatchParam(HttpConn *conn, cchar *var, cchar *value)
{
    return httpMatchParam(conn, var, value);
}


/*
    Test if a module has been updated (is stale).
    This will unload the module if it loaded but stale.
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
    if (sinfo.valid && sinfo.mtime > minfo.mtime) {
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


PUBLIC void espRedirect(HttpConn *conn, int status, cchar *target)
{
    httpRedirect(conn, status, target);
}


PUBLIC void espRedirectBack(HttpConn *conn)
{
    if (conn->rx->referrer) {
        espRedirect(conn, HTTP_CODE_MOVED_TEMPORARILY, conn->rx->referrer); 
    }
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


PUBLIC ssize espRenderCached(HttpConn *conn)
{
    return httpWriteCached(conn);
}


PUBLIC void espRenderConfig(HttpConn *conn)
{
    EspRoute    *eroute;
    MprJson     *settings;

    eroute = conn->rx->route->eroute;
    settings = mprLookupJson(eroute->config, "settings");
    if (settings) {
        renderString(mprJsonToString(eroute->config, MPR_JSON_QUOTES));
    } else {
        renderError(HTTP_CODE_NOT_FOUND, "Cannot find config.settings to send to client");
    }
    finalize();
}


PUBLIC ssize espRenderError(HttpConn *conn, int status, cchar *fmt, ...)
{
    va_list     args;
    HttpRx      *rx;
    ssize       written;
    cchar       *msg, *title, *text;

    va_start(args, fmt);    

    rx = conn->rx;
    written = 0;

    if (!httpIsFinalized(conn)) {
        if (status == 0) {
            status = HTTP_CODE_INTERNAL_SERVER_ERROR;
        }
        title = sfmt("Request Error for \"%s\"", rx->pathInfo);
        msg = mprEscapeHtml(sfmtv(fmt, args));
        if (rx->route->flags & HTTP_ROUTE_SHOW_ERRORS) {
            text = sfmt(\
                "<!DOCTYPE html>\r\n<html>\r\n<head><title>%s</title></head>\r\n" \
                "<body>\r\n<h1>%s</h1>\r\n" \
                "    <pre>%s</pre>\r\n" \
                "    <p>To prevent errors being displayed in the browser, " \
                "       set <b>ShowErrors off</b> in the appweb.conf file.</p>\r\n", \
                "</body>\r\n</html>\r\n", title, title, msg);
            httpSetHeader(conn, "Content-Type", "text/html");
            written += espRenderString(conn, text);
            espFinalize(conn);
            mprTrace(4, "Request error (%d) for: \"%s\"", status, rx->pathInfo);
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


PUBLIC void espRenderFlash(HttpConn *conn, cchar *kinds)
{
    EspReq      *req;
    MprKey      *kp;
    cchar       *msg;
   
    req = conn->data;
    if (kinds == 0 || req->flash == 0 || mprGetHashLength(req->flash) == 0) {
        return;
    }
    for (kp = 0; (kp = mprGetNextKey(req->flash, kp)) != 0; ) {
        msg = kp->data;
        if (strstr(kinds, kp->key) || strstr(kinds, "all")) {
            espRender(conn, "<span class='flash-%s'>%s</span>", kp->key, msg);
        }
    }
}


/*
    Render a security token
    Security tokens are used to minimize the CSRF threat.
    Note: the HttpSession API prevents session hijacking by pairing with the client IP
 */
PUBLIC void espRenderSecurityToken(HttpConn *conn) 
{
    httpRenderSecurityToken(conn);
}


PUBLIC void espRemoveCookie(HttpConn *conn, cchar *name)
{
    httpSetCookie(conn, name, "", "/", NULL, -1, 0);
}


PUBLIC void espSetConn(HttpConn *conn)
{
    mprSetThreadData(((Esp*) MPR->espService)->local, conn);
}


static void espNotifier(HttpConn *conn, int event, int arg)
{
    EspReq      *req;

    if ((req = conn->data) != 0) {
        espSetConn(conn);
        (req->notifier)(conn, event, arg);
    }
}


PUBLIC void espSetNotifier(HttpConn *conn, HttpNotifier notifier)
{
    EspReq      *req;

    if ((req = conn->data) != 0) {
        req->notifier = notifier;
        httpSetConnNotifier(conn, espNotifier);
    }
}

PUBLIC ssize espRenderGrid(HttpConn *conn, EdiGrid *grid, int flags)
{
    httpAddHeaderString(conn, "Content-Type", "application/json");
    return espRender(conn, "{\n  \"schema\": %s,\n  \"data\": %s}\n", ediGetGridSchemaAsJson(grid), ediGridAsJson(grid, flags));
}


PUBLIC ssize espRenderRec(HttpConn *conn, EdiRec *rec, int flags)
{
    httpAddHeaderString(conn, "Content-Type", "application/json");
    return espRender(conn, "{\"data\": %s, \"schema\": %s}", ediRecAsJson(rec, flags), ediGetRecSchemaAsJson(rec));
}


PUBLIC ssize espRenderSafe(HttpConn *conn, cchar *fmt, ...)
{
    va_list     args;
    cchar       *s;

    va_start(args, fmt);
    s = mprEscapeHtml(sfmtv(fmt, args));
    va_end(args);
    return espRenderBlock(conn, s, slen(s));
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


PUBLIC void espRenderResult(HttpConn *conn, bool success)
{
    EspReq      *req;
    EdiRec      *rec;

    req = conn->data;
    rec = getRec();
    if (rec && rec->errors) {
        espRender(conn, "{\"error\": %d, \"feedback\": %s, \"fieldErrors\": %s}", !success, 
            req->feedback ? mprSerialize(req->feedback, MPR_JSON_QUOTES) : "{}",
            mprSerialize(rec->errors, MPR_JSON_QUOTES));
    } else {
        espRender(conn, "{\"error\": %d, \"feedback\": %s}", !success, 
            req->feedback ? mprSerialize(req->feedback, MPR_JSON_QUOTES) : "{}");
    }
    espFinalize(conn);
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
    assert(key && *key);
    if (conn->tx == 0) {
        return MPR_ERR_CANT_ACCESS;
    }
    return mprRemoveKey(conn->tx->headers, key);
}


PUBLIC void espRemoveSessionVar(HttpConn *conn, cchar *var) 
{
    httpRemoveSessionVar(conn, var);
}


PUBLIC int espSaveConfig(HttpRoute *route)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    return mprSaveJson(eroute->config, mprJoinPath(route->documents, "config.json"), MPR_JSON_PRETTY);
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


PUBLIC int espSetConfig(HttpRoute *route, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    return mprSetJsonValue(eroute->config, key, value, 0);
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


PUBLIC void espSetData(HttpConn *conn, void *data)
{
    EspReq  *req;

    req = conn->data;
    req->data = data;
}


PUBLIC void espSetFeedback(HttpConn *conn, cchar *kind, cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFeedbackv(conn, kind, fmt, args);
    va_end(args);
}


PUBLIC void espSetFeedbackv(HttpConn *conn, cchar *kind, cchar *fmt, va_list args)
{
    EspReq      *req;
    cchar       *prior, *msg;

    req = conn->data;
    msg = sfmtv(fmt, args);

    if (req->feedback == 0) {
        req->feedback = mprCreateHash(0, MPR_HASH_STABLE);
    }
    if ((prior = mprLookupKey(req->feedback, kind)) != 0) {
        mprAddKey(req->feedback, kind, sjoin(prior, "\n", msg, NULL));
    } else {
        mprAddKey(req->feedback, kind, sclone(msg));
    }
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
    cchar       *prior, *msg;

    req = conn->data;
    msg = sfmtv(fmt, args);

    if (req->flash == 0) {
        req->flash = mprCreateHash(0, MPR_HASH_STABLE);
    }
    if ((prior = mprLookupKey(req->flash, kind)) != 0) {
        mprAddKey(req->flash, kind, sjoin(prior, "\n", msg, NULL));
    } else {
        mprAddKey(req->flash, kind, sclone(msg));
    }
    /*
        Create a session as early as possible so a Set-Cookie header can be omitted.
     */
    httpGetSession(conn, 1);
}


PUBLIC EdiGrid *espSetGrid(HttpConn *conn, EdiGrid *grid)
{
    return conn->grid = grid;
}


/*  
    Set a http header. Overwrite if present.
 */
PUBLIC void espSetHeader(HttpConn *conn, cchar *key, cchar *fmt, ...)
{
    va_list     vargs;

    assert(key && *key);
    assert(fmt && *fmt);

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



PUBLIC EdiRec *espSetRec(HttpConn *conn, EdiRec *rec)
{
    return conn->record = rec;
}


PUBLIC void espSecurityToken(HttpConn *conn) 
{
    espRenderSecurityToken(conn);
}


PUBLIC int espSetSessionVar(HttpConn *conn, cchar *var, cchar *value) 
{
    return httpSetSessionVar(conn, var, value);
}


PUBLIC void espSetStatus(HttpConn *conn, int status)
{
    httpSetStatus(conn, status);
}


PUBLIC void espShowRequest(HttpConn *conn)
{
    MprHash     *env;
    MprJson     *params, *param;
    MprKey      *kp;
    MprJson     *jkey;
    HttpRx      *rx;
    int         i;

    rx = conn->rx;
    httpAddHeaderString(conn, "Cache-Control", "no-cache");
    httpCreateCGIParams(conn);
    espRender(conn, "\r\n");

    /*
        Query
     */
    for (ITERATE_JSON(rx->params, jkey, i)) {
        espRender(conn, "PARAMS %s=%s\r\n", jkey->name, jkey->value ? jkey->value : "null");
    }
    espRender(conn, "\r\n");

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
    if ((params = espGetParams(conn)) != 0) {
        for (ITERATE_JSON(params, param, i)) {
            espRender(conn, "FORM %s=%s\r\n", param->name, param->value);
        }
        espRender(conn, "\r\n");
    }

#if KEEP
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
#endif
}


PUBLIC bool espTestConfig(HttpRoute *route, cchar *key, cchar *desired)
{
    EspRoute    *eroute;
    cchar       *value;

    eroute = route->eroute;
    if ((value = mprGetJsonValue(eroute->config, key, 0)) != 0) {
        return smatch(value, desired);
    }
    return 0;
}


/*
    This is called when unloading a view or controller module
 */
PUBLIC bool espUnloadModule(cchar *module, MprTicks timeout)
{
    MprModule   *mp;
    MprTicks    mark;
    Esp         *esp;

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


PUBLIC cchar *espUri(HttpConn *conn, cchar *target)
{
    return httpUri(conn, target, 0);
}


PUBLIC void espManageEspRoute(EspRoute *eroute, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(eroute->appDir);
        mprMark(eroute->appName);
        mprMark(eroute->appModulePath);
        mprMark(eroute->cacheDir);
        mprMark(eroute->clientDir);
        mprMark(eroute->compile);
        mprMark(eroute->config);
        mprMark(eroute->controllersDir);
        mprMark(eroute->database);
        mprMark(eroute->dbDir);
        mprMark(eroute->edi);
        mprMark(eroute->env);
        mprMark(eroute->layoutsDir);
        mprMark(eroute->link);
        mprMark(eroute->searchPath);
        mprMark(eroute->serverPrefix);
        mprMark(eroute->srcDir);
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
