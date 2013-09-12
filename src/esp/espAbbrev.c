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


PUBLIC bool canUser(cchar *abilities, bool warn)
{
    HttpConn    *conn;

    conn = getConn();
    if (httpCanUser(conn, abilities)) {
        return 1;
    }
    if (warn) {
        feedback("error", "Access Denied. Insufficient privilege.");
        renderResult(0);
    }
    return 0;
}


PUBLIC EdiRec *createRec(cchar *tableName, MprHash *params)
{
    return espCreateRec(getConn(), tableName, params);
}


PUBLIC bool createRecFromParams(cchar *table)
{
    return updateRec(createRec(table, params()));
}


/*
    Create a new session. Always returns with a fresh session
 */
PUBLIC cchar *createSession()
{
    HttpSession *session;

    if ((session = httpCreateSession(getConn())) != 0) {
        return session->id;
    }
    return 0;
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


PUBLIC void feedback(cchar *kind, cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFeedbackv(getConn(), kind, fmt, args);
    va_end(args);
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


PUBLIC cchar *getAppUri()
{
    return espGetTop(getConn());
}


PUBLIC MprList *getColumns(EdiRec *rec)
{
    return espGetColumns(getConn(), rec);
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
    HttpSession *session;

    if ((session = httpGetSession(getConn(), 1)) != 0) {
        return session->id;
    }
    return 0;
}


PUBLIC cchar *getSessionVar(cchar *key)
{
    return httpGetSessionVar(getConn(), key, 0);
}


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
    return espMakeGrid(contents);
}


PUBLIC MprHash *makeHash(cchar *fmt, ...)
{
    va_list     args;
    cchar       *str;

    va_start(args, fmt);
    str = sfmtv(fmt, args);
    va_end(args);
    return espMakeHash("%s", str);
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


PUBLIC MprHash *params()
{
    return espGetParams(getConn());
}


PUBLIC ssize receive(char *buf, ssize len)
{
    return httpRead(getConn(), buf, len);
}


PUBLIC EdiRec *readRecWhere(cchar *tableName, cchar *fieldName, cchar *operation, cchar *value)
{
    return setRec(ediReadOneWhere(getDatabase(), tableName, fieldName, operation, value));
}


PUBLIC EdiRec *readRec(cchar *tableName, cchar *key)
{
    return setRec(ediReadRec(getDatabase(), tableName, key));
}


PUBLIC EdiRec *readRecByKey(cchar *tableName, cchar *key)
{
    return setRec(ediReadRec(getDatabase(), tableName, key));
}


PUBLIC EdiGrid *readRecsWhere(cchar *tableName, cchar *fieldName, cchar *operation, cchar *value)
{
    return setGrid(ediReadWhere(getDatabase(), tableName, fieldName, operation, value));
}


PUBLIC EdiGrid *readTable(cchar *tableName)
{
    return setGrid(espReadTable(getConn(), tableName));
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
    return espRemoveRec(getConn(), tableName, key);
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


PUBLIC void renderError(int status, cchar *fmt, ...)
{
    va_list     args;
    cchar       *msg;

    va_start(args, fmt);
    msg = sfmt(fmt, args);
    espRenderError(getConn(), status, "%s", msg);
    va_end(args);
}


PUBLIC ssize renderFile(cchar *path)
{
    return espRenderFile(getConn(), path);
}


PUBLIC void renderFlash(cchar *kind, cchar *optionString)
{
    espRenderFlash(getConn(), kind, optionString);
}


PUBLIC ssize renderGrid(EdiGrid *grid)
{
    return espRenderGrid(getConn(), grid, 0);
}


PUBLIC ssize renderRec(EdiRec *rec)
{
    return espRenderRec(getConn(), rec, 0);
}


PUBLIC void renderResult(int status)
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
    MprHash     *components;
    cchar       *indent, *uri, *path, *component;
    int         next, i;

    conn = getConn();
    route = conn->rx->route;
    eroute = route->eroute;
    patterns = httpExpandRouteVars(route, patterns);

    //  MOB - is components used?
    if (patterns == NULL || smatch(patterns, "${COMPONENTS}/**.js")) {
        //  MOB - should we have eroute->components?
        if ((components = mprJsonGetValue(eroute->config, "settings.components", NULL)) != 0) {
            for (i = 0; i < components->length; i++) {
                char num[16];
                component = mprLookupKey(components, itosbuf(num, sizeof(num), i, 10));
                scripts(sfmt("%s/lib/%s/**.js", eroute->clientDir, component));
            }
        }
    }

    if ((files = mprGlobPathFiles(eroute->clientDir, patterns, MPR_PATH_RELATIVE)) == 0) {
        mprError("No scripts defined for current application mode");
        return;
    }
    indent = "";
    //  MOB - how to minify?
    for (ITERATE_ITEMS(files, path, next)) {
        uri = httpLink(conn, path, NULL);
        if (scontains(path, "-IE-") || scontains(path, "html5shiv")) {
            espRender(conn, "%s<!-- [if lt IE 9]>\n", indent);
            espRender(conn, "%s<script src='%s' type='text/javascript'></script>\n", indent, uri);
            espRender(conn, "%s<![endif]-->\n", indent);
        } else {
            espRender(conn, "%s<script src='%s' type='text/javascript'></script>\n", indent, uri);
        }
        indent = "    ";
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
    return espSetField(rec, fieldName, value);
}


PUBLIC EdiRec *setFields(EdiRec *rec, MprHash *params)
{
    return espSetFields(rec, params);
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


PUBLIC void updateCache(cchar *uri, cchar *data, int lifesecs)
{
    espUpdateCache(getConn(), uri, data, lifesecs);
}


PUBLIC bool updateField(cchar *tableName, cchar *key, cchar *fieldName, cchar *value)
{
    return espUpdateField(getConn(), tableName, key, fieldName, value);
}


PUBLIC bool updateFields(cchar *tableName, MprHash *params)
{
    return espUpdateFields(getConn(), tableName, params);
}


PUBLIC bool updateRec(EdiRec *rec)
{
    return espUpdateRec(getConn(), rec);
}


PUBLIC bool updateRecFromParams(cchar *table)
{
    return updateRec(setFields(readRec(table, param("id")), params()));
}

/************************************ Deprecated ****************************/
#if BIT_ESP_LEGACY
/*
    Deprecated in 4.4
 */

PUBLIC void alert(cchar *text, cchar *optionString)
{
    espAlert(getConn(), text, optionString);
}


PUBLIC void anchor(cchar *text, cchar *uri, cchar *optionString) 
{
    espAnchor(getConn(), text, uri, optionString);
}


PUBLIC void button(cchar *name, cchar *value, cchar *optionString)
{
    espButton(getConn(), name, value, optionString);
}


PUBLIC void buttonLink(cchar *text, cchar *uri, cchar *optionString)
{
    espButtonLink(getConn(), text, uri, optionString);
}


PUBLIC void checkbox(cchar *field, cchar *checkedValue, cchar *optionString) 
{
    espCheckbox(getConn(), field, checkedValue, optionString);
}


PUBLIC void division(cchar *body, cchar *optionString) 
{
    espDivision(getConn(), body, optionString);
}


PUBLIC void endform() 
{
    espEndform(getConn());
}


PUBLIC void form(void *record, cchar *optionString)
{
    HttpConn    *conn;

    conn = getConn();
    if (record == 0) {
        record = conn->record;
    }
    espForm(conn, record, optionString); 
}


PUBLIC void icon(cchar *uri, cchar *optionString)
{
    espIcon(getConn(), uri, optionString);
}


PUBLIC void image(cchar *src, cchar *optionString)
{
    espImage(getConn(), src, optionString);
}


PUBLIC void input(cchar *name, cchar *optionString)
{
    espInput(getConn(), name, optionString);
}


PUBLIC void label(cchar *text, cchar *optionString)
{
    espLabel(getConn(), text, optionString);
}


PUBLIC void dropdown(cchar *name, EdiGrid *choices, cchar *optionString) 
{
    espDropdown(getConn(), name, choices, optionString);
}


PUBLIC void mail(cchar *name, cchar *address, cchar *optionString) 
{
    espMail(getConn(), name, address, optionString);
}


PUBLIC void progress(cchar *data, cchar *optionString)
{
    espProgress(getConn(), data, optionString);
}


/*
    radio("priority", "{low: 0, med: 1, high: 2}", NULL)
    radio("priority", "{low: 0, med: 1, high: 2}", "{value:'2'}")
 */
PUBLIC void radio(cchar *name, void *choices, cchar *optionString)
{
    espRadio(getConn(), name, choices, optionString);
}


PUBLIC void refresh(cchar *on, cchar *off, cchar *optionString)
{
    espRefresh(getConn(), on, off, optionString);
}


PUBLIC void script(cchar *uri, cchar *optionString)
{
    espScript(getConn(), uri, optionString);
}


PUBLIC void stylesheet(cchar *uri, cchar *optionString) 
{
    espStylesheet(getConn(), uri, optionString);
}


PUBLIC void table(EdiGrid *grid, cchar *optionString)
{
    if (grid == 0) {
        grid = getGrid();
    }
    espTable(getConn(), grid, optionString);
}


PUBLIC void tabs(EdiGrid *grid, cchar *optionString)
{
    espTabs(getConn(), grid, optionString);
}


PUBLIC void text(cchar *field, cchar *optionString)
{
    espText(getConn(), field, optionString);
}


PUBLIC EdiGrid *getGrid()
{
    return getConn()->grid;
}


PUBLIC cchar *getTop()
{
    return getAppUri();
}


#if DEPRECATE || 1
PUBLIC void inform(cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFlashv(getConn(), "inform", fmt, args);
    va_end(args);
}
#endif


#endif /* BIT_ESP_LEGACY */
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
