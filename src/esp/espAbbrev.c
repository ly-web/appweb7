/*
    espAbbrev.c -- ESP Abbreviated API

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "esp.h"

#if BIT_PACK_ESP

/*************************************** Code *********************************/

PUBLIC void addHeader(cchar *key, cchar *fmt, ...)
{
    va_list     args;
    cchar       *value;

    va_start(args, fmt);
    value = sfmtv(fmt, args);
    espAddHeaderString(getConn(), key, value);
    va_end(args);
}


PUBLIC void addParam(cchar *key, cchar *value)
{
    if (!param(key)) {
        setParam(key, value);
    }
}


PUBLIC bool canUser(cchar *abilities, bool warn)
{
    HttpConn    *conn;

    conn = getConn();
    if (httpCanUser(conn, abilities)) {
        return 1;
    }
    if (warn) {
        setStatus(HTTP_CODE_UNAUTHORIZED);
        renderResult(feedback("error", "Access Denied. Insufficient Privilege."));
    }
    return 0;
}


PUBLIC EdiRec *createRec(cchar *tableName, MprJson *params)
{
    return setRec(ediSetFields(ediCreateRec(getDatabase(), tableName), params));
}


PUBLIC bool createRecFromParams(cchar *table)
{
    return updateRec(createRec(table, params()));
}


/*
    Return the session ID
 */
PUBLIC cchar *createSession()
{
    return espCreateSession(getConn());
}


/*
    Destroy a session and erase the session state data.
    This emits an expired Set-Cookie header to the browser to force it to erase the cookie.
 */
PUBLIC void destroySession()
{
    httpDestroySession(getConn());
}


PUBLIC void dontAutoFinalize()
{
    espSetAutoFinalizing(getConn(), 0);
}


PUBLIC bool feedback(cchar *kind, cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFeedbackv(getConn(), kind, fmt, args);
    va_end(args);
    /*
        Return true if there is not an error feedback message
     */
    return getFeedback("error") == 0;
}


PUBLIC void finalize()
{
    espFinalize(getConn());
}


PUBLIC void flash(cchar *kind, cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFlashv(getConn(), kind, fmt, args);
    va_end(args);
}


PUBLIC void flush()
{
    espFlush(getConn());
}


//  FUTURE - getTop is easier
PUBLIC cchar *getAppUri()
{
    return espGetTop(getConn());
}


PUBLIC MprList *getColumns(EdiRec *rec)
{
    if (rec == 0) {
        return 0;
    }
    return ediGetColumns(getDatabase(), rec->tableName);
}


PUBLIC HttpConn *getConn()
{
    HttpConn    *conn;

    conn = mprGetThreadData(((Esp*) MPR->espService)->local);
    if (conn == 0) {
        mprError("Connection is not defined in thread local storage.\n"
        "If using a callback, make sure you invoke espSetConn with the connection before using the ESP abbreviated API");
    }
    assert(conn);
    return conn;
}


PUBLIC cchar *getCookies()
{
    return espGetCookies(getConn());
}


PUBLIC MprOff getContentLength()
{
    return espGetContentLength(getConn());
}


PUBLIC cchar *getContentType()
{
    return getConn()->rx->mimeType;
}


PUBLIC void *getData()
{
    return espGetData(getConn());
}


PUBLIC Edi *getDatabase()
{
    return espGetDatabase(getConn());
}


PUBLIC cchar *getDocuments()
{
    return getConn()->rx->route->documents;
}


#if DEPRECATED || 1
PUBLIC cchar *getDir()
{
    return getDocuments();
}
#endif


PUBLIC EspRoute *getEspRoute()
{
    return espGetEspRoute(getConn());
}


PUBLIC cchar *getFeedback(cchar *kind)
{
    return espGetFeedback(getConn(), kind);
}


PUBLIC cchar *getFlash(cchar *kind)
{
    return espGetFlash(getConn(), kind);
}


PUBLIC cchar *getField(EdiRec *rec, cchar *field)
{
    return ediGetFieldValue(rec, field);
}


PUBLIC EdiGrid *getGrid()
{
    return getConn()->grid;
}


PUBLIC cchar *getHeader(cchar *key)
{
    return espGetHeader(getConn(), key);
}


PUBLIC cchar *getMethod()
{
    return espGetMethod(getConn());
}


PUBLIC cchar *getQuery()
{
    return getConn()->rx->parsedUri->query;
}


PUBLIC EdiRec *getRec()
{
    return getConn()->record;
}


PUBLIC cchar *getReferrer()
{
    return espGetReferrer(getConn());
}


/*
    Get a session and return the session ID. Creates a session if one does not already exist.
 */
PUBLIC cchar *getSessionID()
{
    return espGetSessionID(getConn(), 1);
}


PUBLIC cchar *getSessionVar(cchar *key)
{
    return httpGetSessionVar(getConn(), key, 0);
}


#if DEPRECATE || 1
PUBLIC cchar *getTop()
{
    return getAppUri();
}
#endif


PUBLIC MprHash *getUploads()
{
    return espGetUploads(getConn());
}


PUBLIC cchar *getUri()
{
    return espGetUri(getConn());
}


PUBLIC bool hasGrid()
{
    return espHasGrid(getConn());
}


PUBLIC bool hasRec()
{
    return espHasRec(getConn());
}


PUBLIC bool isEof()
{
    return httpIsEof(getConn());
}


PUBLIC bool isFinalized()
{
    return espIsFinalized(getConn());
}


PUBLIC bool isSecure()
{
    return espIsSecure(getConn());
}


PUBLIC EdiGrid *makeGrid(cchar *contents)
{
    return ediMakeGrid(contents);
}


PUBLIC MprHash *makeHash(cchar *fmt, ...)
{
    va_list     args;
    cchar       *str;

    va_start(args, fmt);
    str = sfmtv(fmt, args);
    va_end(args);
    return mprDeserialize(str);
}


PUBLIC MprJson *makeJson(cchar *fmt, ...)
{
    va_list     args;
    cchar       *str;

    va_start(args, fmt);
    str = sfmtv(fmt, args);
    va_end(args);
    return mprParseJson(str);
}


PUBLIC EdiRec *makeRec(cchar *contents)
{
    return ediMakeRec(contents);
}


PUBLIC cchar *makeUri(cchar *target)
{
    return espUri(getConn(), target);
}


PUBLIC bool modeIs(cchar *kind)
{
    EspRoute    *eroute;

    eroute = getConn()->rx->route->eroute;
    return smatch(eroute->mode, kind);
}


PUBLIC cchar *param(cchar *key)
{
    return espGetParam(getConn(), key, 0);
}


PUBLIC MprJson *params()
{
    return espGetParams(getConn());
}


PUBLIC ssize receive(char *buf, ssize len)
{
    return httpRead(getConn(), buf, len);
}


PUBLIC EdiRec *readRecWhere(cchar *tableName, cchar *fieldName, cchar *operation, cchar *value)
{
    return setRec(ediReadRecWhere(getDatabase(), tableName, fieldName, operation, value));
}


PUBLIC EdiRec *readRec(cchar *tableName, cchar *key)
{
    if (key == 0 || *key == 0) {
        key = "1";
    }
    return setRec(ediReadRec(getDatabase(), tableName, key));
}


PUBLIC EdiRec *readRecByKey(cchar *tableName, cchar *key)
{
    return setRec(ediReadRec(getDatabase(), tableName, key));
}


PUBLIC EdiGrid *readWhere(cchar *tableName, cchar *fieldName, cchar *operation, cchar *value)
{
    return setGrid(ediReadWhere(getDatabase(), tableName, fieldName, operation, value));
}


#if DEPRECATE || 1
/* Deprecated in 4.4.1 */
PUBLIC EdiGrid *readRecsWhere(cchar *tableName, cchar *fieldName, cchar *operation, cchar *value)
{
    return readWhere(tableName, fieldName, operation, value);
}
#endif


PUBLIC EdiGrid *readTable(cchar *tableName)
{
    return setGrid(ediReadWhere(getDatabase(), tableName, 0, 0, 0));
}


PUBLIC void redirect(cchar *target)
{
    espRedirect(getConn(), 302, target);
}


PUBLIC void redirectBack()
{
    espRedirectBack(getConn());
}


PUBLIC void removeCookie(cchar *name)
{
    espRemoveCookie(getConn(), name);
}


PUBLIC bool removeRec(cchar *tableName, cchar *key)
{
    if (ediRemoveRec(getDatabase(), tableName, key) < 0) {
        feedback("error", "Cannot delete %s", spascal(tableName));
        return 0;
    }
    feedback("inform", "Deleted %s", spascal(tableName));
    return 1;
}


PUBLIC void removeSessionVar(cchar *key)
{
    httpRemoveSessionVar(getConn(), key);
}


PUBLIC ssize render(cchar *fmt, ...)
{
    va_list     args;
    ssize       count;
    cchar       *msg;

    va_start(args, fmt);
    msg = sfmtv(fmt, args);
    count = espRenderString(getConn(), msg);
    va_end(args);
    return count;
}


PUBLIC ssize renderCached()
{
    return espRenderCached(getConn());;
}

PUBLIC ssize renderConfig()
{
    HttpConn    *conn;
    EspRoute    *eroute;
    MprJson     *settings;

    conn = getConn();
    eroute = conn->rx->route->eroute;
    settings = mprLookupJson(eroute->config, "settings");
    if (settings) {
        return renderString(mprJsonToString(settings, MPR_JSON_QUOTES));
    }
    return 0;
}


PUBLIC void renderError(int status, cchar *fmt, ...)
{
    va_list     args;
    cchar       *msg;

    va_start(args, fmt);
    msg = sfmt(fmt, args);
    espRenderError(getConn(), status, "%s", msg);
    va_end(args);
}


#if UNUSED
//  FUTURE - need espRenderFeedback
//  FUTURE - doc
PUBLIC void renderFeedback(int status, cchar *kind, ...)
{
    va_list     args;
    cchar       *fmt, *msg;

    if (kind) {
        va_start(args, kind);
        fmt = va_arg(args, cchar *);
        msg = sfmt(fmt, args);
        espSetFeedbackv(getConn(), kind, fmt, args);
        va_end(args);
    }
    renderResult(status);
}
#endif


PUBLIC ssize renderFile(cchar *path)
{
    return espRenderFile(getConn(), path);
}


PUBLIC void renderFlash(cchar *kind)
{
    espRenderFlash(getConn(), kind);
}


PUBLIC ssize renderGrid(EdiGrid *grid)
{
    return espRenderGrid(getConn(), grid, 0);
}


PUBLIC ssize renderRec(EdiRec *rec)
{
    return espRenderRec(getConn(), rec, 0);
}


//  FUTURE - change this to renderStatus?

PUBLIC void renderResult(bool status)
{
    espRenderResult(getConn(), status);
}


PUBLIC ssize renderSafe(cchar *fmt, ...)
{
    va_list     args;
    ssize       count;
    cchar       *msg;

    va_start(args, fmt);
    msg = sfmtv(fmt, args);
    count = espRenderSafeString(getConn(), msg);
    va_end(args);
    return count;
}


PUBLIC ssize renderString(cchar *s)
{
    return espRenderString(getConn(), s);
}


PUBLIC void renderView(cchar *view)
{
    espRenderView(getConn(), view);
}


PUBLIC void renderSecurityToken()
{
    espSecurityToken(getConn());
}


/*
    <% scripts(patterns); %>

    Where patterns may contain *, ** and !pattern for exclusion
 */
PUBLIC void scripts(cchar *patterns)
{
    HttpConn    *conn;
    HttpRoute   *route;
    EspRoute    *eroute;
    MprList     *files;
    MprJson     *components, *component, *componentScripts, *file;
    cchar       *uri, *path;
    int         next, ci, fi;

    conn = getConn();
    route = conn->rx->route;
    eroute = route->eroute;
    patterns = httpExpandRouteVars(route, patterns);

    if (!patterns || !*patterns) {
        if (modeIs("release")) {
            //  MOB - angular specific
            scripts(sfmt("all-%s.min.js", espGetConfig(route, "version", "1.0.0")));
        } else {
            if ((components = mprGetJson(eroute->config, "settings.components", 0)) != 0) {
                for (ITERATE_JSON(components, component, ci)) {
                    if ((componentScripts = mprGetJson(component, "scripts", 0)) != 0) {
                        for (ITERATE_JSON(componentScripts, file, fi)) {
                            if (smatch(file->value, "*")) {
                                scripts(sfmt("lib/%s/**.js", component->name));
                            } else {
                                scripts(sfmt("lib/%s/%s", component->name, file->value));
                            }
                        }
                    }
                }
            }
            if (mprPathExists(mprJoinPath(eroute->clientDir, "app/main.js"), R_OK)) {
                scripts("app/main.js");
            }
            scripts("app/*/**.js");
        }
        return;
    }
    if (patterns && *patterns) {
        if ((files = mprGlobPathFiles(eroute->clientDir, patterns, MPR_PATH_RELATIVE)) == 0 || mprGetListLength(files) == 0) {
            if (!scontains(patterns, "*")) {
                files = mprCreateList(0, 0);
                mprAddItem(files, patterns);
            }
        }
        for (ITERATE_ITEMS(files, path, next)) {
            path = strim(path, ".gz", MPR_TRIM_END);
            uri = httpUri(conn, path, NULL);
            if (scontains(path, "-IE-") || scontains(path, "html5shiv")) {
                espRender(conn, "    <!-- [if lt IE 9]>\n");
                espRender(conn, "        <script src='%s' type='text/javascript'></script>\n", uri);
                espRender(conn, "    <![endif]-->\n");
            } else {
                espRender(conn, "    <script src='%s' type='text/javascript'></script>\n", uri);
            }
        }
    }
}


PUBLIC void securityToken()
{
    espSecurityToken(getConn());
}


PUBLIC void setConn(HttpConn *conn)
{
    espSetConn(conn);
}


PUBLIC void setContentType(cchar *mimeType)
{
    espSetContentType(getConn(), mimeType);
}


PUBLIC void setCookie(cchar *name, cchar *value, cchar *path, cchar *cookieDomain, MprTicks lifespan, bool isSecure)
{
    espSetCookie(getConn(), name, value, path, cookieDomain, lifespan, isSecure);
}


PUBLIC void setData(void *data)
{
    espSetData(getConn(), data);
}


PUBLIC EdiRec *setField(EdiRec *rec, cchar *fieldName, cchar *value)
{
    return ediSetField(rec, fieldName, value);
}


PUBLIC EdiRec *setFields(EdiRec *rec, MprJson *params)
{
    return ediSetFields(rec, params);
}


PUBLIC EdiGrid *setGrid(EdiGrid *grid)
{
    getConn()->grid = grid;
    return grid;
}


PUBLIC void setHeader(cchar *key, cchar *fmt, ...)
{
    va_list     args;
    cchar       *value;

    va_start(args, fmt);
    value = sfmtv(fmt, args);
    espSetHeaderString(getConn(), key, value);
    va_end(args);
}


PUBLIC void setIntParam(cchar *key, int value)
{
    espSetIntParam(getConn(), key, value);
}


PUBLIC void setNotifier(HttpNotifier notifier)
{
    espSetNotifier(getConn(), notifier);
}


PUBLIC void setParam(cchar *key, cchar *value)
{
    espSetParam(getConn(), key, value);
}


PUBLIC EdiRec *setRec(EdiRec *rec)
{
    return espSetRec(getConn(), rec);
}


PUBLIC void setSessionVar(cchar *key, cchar *value)
{
    httpSetSessionVar(getConn(), key, value);
}


PUBLIC void setStatus(int status)
{
    espSetStatus(getConn(), status);
}


PUBLIC cchar *session(cchar *key)
{
    return getSessionVar(key);
}


PUBLIC void setTimeout(void *proc, MprTicks timeout, void *data)
{
    mprCreateEvent(getConn()->dispatcher, "setTimeout", (int) timeout, proc, data, 0);
}


PUBLIC void showRequest()
{
    espShowRequest(getConn());
}


/*
    <% stylesheets(patterns); %>

    Where patterns may contain *, ** and !pattern for exclusion
 */
PUBLIC void stylesheets(cchar *patterns)
{
    HttpConn    *conn;
    HttpRoute   *route;
    EspRoute    *eroute;
    MprList     *files;
    cchar       *uri, *path, *kind;
    int         next;

    conn = getConn();
    route = conn->rx->route;
    eroute = route->eroute;
    patterns = httpExpandRouteVars(route, patterns);

    if (!patterns || !*patterns) {
        if (modeIs("release")) {
            stylesheets(sfmt("css/all-%s.min.css", espGetConfig(route, "version", "1.0.0")));
        } else {
            stylesheets("css/all.less");
        }
        return;
    }
    if ((files = mprGlobPathFiles(eroute->clientDir, patterns, MPR_PATH_RELATIVE)) == 0 || mprGetListLength(files) == 0) {
        files = mprCreateList(0, 0);
        mprAddItem(files, patterns);
    }
    for (ITERATE_ITEMS(files, path, next)) {
        path = strim(path, ".gz", MPR_TRIM_END);
        uri = httpUri(conn, path, NULL);
        kind = mprGetPathExt(path);
        if (smatch(kind, "css")) {
            espRender(conn, "    <link rel='stylesheet' type='text/css' href='%s' />\n", uri);
        } else {
            espRender(conn, "    <link rel='stylesheet/%s' type='text/css' href='%s' />\n", kind, uri);
        }
    }
}


PUBLIC void updateCache(cchar *uri, cchar *data, int lifesecs)
{
    espUpdateCache(getConn(), uri, data, lifesecs);
}


PUBLIC bool updateField(cchar *tableName, cchar *key, cchar *fieldName, cchar *value)
{
    return ediUpdateField(getDatabase(), tableName, key, fieldName, value) == 0;
}


PUBLIC bool updateFields(cchar *tableName, MprJson *params)
{
    EdiRec  *rec;
    cchar   *key;

    key = mprLookupJsonValue(params, "id");
    if ((rec = ediSetFields(ediReadRec(getDatabase(), tableName, key), params)) == 0) {
        return 0;
    }
    return updateRec(rec);
}


PUBLIC bool updateRec(EdiRec *rec)
{
    if (ediUpdateRec(getDatabase(), rec) < 0) {
        feedback("error", "Cannot save %s", spascal(rec->tableName));
        return 0;
    }
    feedback("inform", "Saved %s", spascal(rec->tableName));
    return 1;
}


PUBLIC bool updateRecFromParams(cchar *table)
{
    return updateRec(setFields(readRec(table, param("id")), params()));
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
