/*
    espAbbrev.c -- ESP Abbreviated API

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "esp.h"

#if BIT_PACK_ESP
/******************************* Abbreviated Controls *************************/ 
#if DEPRECATED || 1

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


PUBLIC void chart(EdiGrid *grid, cchar *optionString)
{
    espChart(getConn(), grid, optionString);
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


PUBLIC void flash(cchar *kind, cchar *optionString)
{
    espFlash(getConn(), kind, optionString);
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

#endif /* DEPRECATED */

PUBLIC void scripts(cchar *optionString)
{
    espScripts(getConn(), optionString);
}

PUBLIC void securityToken()
{
    espSecurityToken(getConn());
}


/******************************* Abbreviated API ******************************/

PUBLIC void addHeader(cchar *key, cchar *fmt, ...)
{
    va_list     args;
    cchar       *value;

    va_start(args, fmt);
    value = sfmtv(fmt, args);
    espAddHeaderString(getConn(), key, value);
    va_end(args);
}


PUBLIC EdiRec *createRec(cchar *tableName, MprHash *params)
{
    return espCreateRec(getConn(), tableName, params);
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


PUBLIC void finalize()
{
    espFinalize(getConn());
}


PUBLIC void flush()
{
    espFlush(getConn());
}


PUBLIC MprList *getColumns(EdiRec *rec)
{
    return espGetColumns(getConn(), rec);
}


PUBLIC HttpConn *getConn()
{
    return mprGetThreadData(((Esp*) MPR->espService)->local);
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


PUBLIC Edi *getDatabase()
{
    return espGetDatabase(getConn());
}


PUBLIC EspRoute *getEspRoute()
{
    return espGetEspRoute(getConn());
}


PUBLIC cchar *getDir()
{
    return getConn()->rx->route->dir;
}


PUBLIC cchar *getField(EdiRec *rec, cchar *field)
{
    return ediGetFieldValue(rec, field);
}


#if DEPRECATED || 1
PUBLIC EdiGrid *getGrid()
{
    return getConn()->grid;
}
#endif


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


#if DEPRECATED || 1
PUBLIC EdiRec *getRec()
{
    return getConn()->record;
}
#endif


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


PUBLIC cchar *session(cchar *key)
{
    return getSessionVar(key);
}


PUBLIC cchar *getTop()
{
    return espGetTop(getConn());
}


PUBLIC MprHash *getUploads()
{
    return espGetUploads(getConn());
}


PUBLIC cchar *getUri()
{
    return espGetUri(getConn());
}


#if DEPRECATED || 1
PUBLIC bool hasGrid()
{
    return espHasGrid(getConn());
}


PUBLIC bool hasRec()
{
    return espHasRec(getConn());
}
#endif


PUBLIC void inform(cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFlashv(getConn(), "inform", fmt, args);
    va_end(args);
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


PUBLIC cchar *param(cchar *key)
{
    return espGetParam(getConn(), key, 0);
}


PUBLIC MprHash *params()
{
    return espGetParams(getConn());
}


#if UNUSED
//  MOB - rethink
PUBLIC bool pmatch(cchar *key)
{
    return smatch(espGetParam(getConn(), key, 0), getField(getRec(), key));
}
#endif


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


#if UNUSED
PUBLIC EdiGrid *readTable(cchar *tableName)
{
    EdiGrid *grid;
    
    grid = ediReadWhere(getDatabase(), tableName, 0, 0, 0);
    setGrid(grid);
    return grid;
}
#endif


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
    espSetCookie(getConn(), name, "", "/", NULL, -1, 0);
}


PUBLIC bool removeRec(cchar *tableName, cchar *key)
{
    return espRemoveRec(getConn(), tableName, key);
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


#if UNUSED
PUBLIC void renderFailure(cchar *fmt, ...)
{
    va_list     args;
    cchar       *msg;

    va_start(args, fmt);
    msg = sfmtv(fmt, args);
    va_end(args);
    espRenderFailure(getConn(), "%s", msg);
}
#endif


PUBLIC ssize renderFile(cchar *path)
{
    return espRenderFile(getConn(), path);
}


PUBLIC ssize renderGrid(EdiGrid *grid)
{
    return espRenderGrid(getConn(), grid, 0);
}


PUBLIC ssize renderRec(EdiRec *rec)
{
    return espRenderRec(getConn(), rec, 0);
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


#if UNUSED
PUBLIC void renderSuccess(cchar *fmt, ...)
{
    va_list     args;
    cchar       *msg;

    va_start(args, fmt);
    msg = sfmtv(fmt, args);
    va_end(args);
    espRenderSuccess(getConn(), "%s", msg);
}
#endif


PUBLIC void renderResult(int status)
{
    espRenderResult(getConn(), status);
}


PUBLIC void renderView(cchar *view)
{
    espRenderView(getConn(), view);
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


PUBLIC EdiRec *setField(EdiRec *rec, cchar *fieldName, cchar *value)
{
    return espSetField(rec, fieldName, value);
}


PUBLIC EdiRec *setFields(EdiRec *rec, MprHash *params)
{
    return espSetFields(rec, params);
}


PUBLIC void setFlash(cchar *kind, cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFlashv(getConn(), kind, fmt, args);
    va_end(args);
}


#if DEPRECATED || 1
PUBLIC EdiGrid *setGrid(EdiGrid *grid)
{
    getConn()->grid = grid;
    return grid;
}
#endif


PUBLIC void setHeader(cchar *key, cchar *fmt, ...)
{
    va_list     args;
    cchar       *value;

    va_start(args, fmt);
    value = sfmtv(fmt, args);
    espSetHeaderString(getConn(), key, value);
    va_end(args);
}


PUBLIC void setParam(cchar *key, cchar *value)
{
    espSetParam(getConn(), key, value);
}


PUBLIC void setIntParam(cchar *key, int value)
{
    espSetIntParam(getConn(), key, value);
}


#if DEPRECATED || 1
PUBLIC EdiRec *setRec(EdiRec *rec)
{
    return espSetRec(getConn(), rec);
}
#endif


PUBLIC void setSessionVar(cchar *key, cchar *value)
{
    httpSetSessionVar(getConn(), key, value);
}


PUBLIC void setStatus(int status)
{
    espSetStatus(getConn(), status);
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
