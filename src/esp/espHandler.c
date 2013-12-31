/*
    espHandler.c -- Embedded Server Pages (ESP) handler

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "appweb.h"

#if BIT_PACK_ESP
#include    "esp.h"
#include    "edi.h"

/************************************* Local **********************************/
/*
    Singleton ESP control structure
 */
static Esp *esp;

/************************************ Forward *********************************/

static EspRoute *allocEspRoute(HttpRoute *loc);
static int espDbDirective(MaState *state, cchar *key, cchar *value);
static int espEnvDirective(MaState *state, cchar *key, cchar *value);
static EspRoute *getEroute(HttpRoute *route);
static void manageEsp(Esp *esp, int flags);
static void manageReq(EspReq *req, int flags);
static int runAction(HttpConn *conn);
static int unloadEsp(MprModule *mp);
static bool pageExists(HttpConn *conn);

#if !BIT_STATIC
static char *getModuleEntry(EspRoute *eroute, cchar *kind, cchar *source, cchar *cacheName);
static bool layoutIsStale(EspRoute *eroute, cchar *source, cchar *module);
static bool loadApp(HttpRoute *route);
static bool loadModule(HttpRoute *route, cchar *kind, cchar *source, cchar **errMsg);
#endif

/************************************* Code ***********************************/
/*
    Open an instance of the ESP for a new request
 */
static void openEsp(HttpQueue *q)
{
    HttpConn    *conn;
    HttpRx      *rx;
    HttpRoute   *route;
    EspRoute    *eroute;
    EspReq      *req;

    conn = q->conn;
    rx = conn->rx;

    /*
        If unloading a module, this lock will cause a wait here while ESP applications are reloaded.
     */
    lock(esp);
    esp->inUse++;
    unlock(esp);

    if ((req = mprAllocObj(EspReq, manageReq)) == 0) {
        httpMemoryError(conn);
        return;
    }
    /*
        Find the ESP route configuration. Search up the route parent chain
     */
    for (eroute = 0, route = rx->route; route; route = route->parent) {
        if (route->eroute) {
            eroute = route->eroute;
            break;
        }
    }
    if (!route) {
        httpError(conn, 0, "Cannot find a suitable ESP route configuration in appweb.conf");
        return;
    }
    if (!eroute) {
        eroute = allocEspRoute(route);
        return;
    }
    conn->data = req;
    req->esp = esp;
    req->route = route;
    req->autoFinalize = 1;
}


static void closeEsp(HttpQueue *q)
{
    lock(esp);
    esp->inUse--;
    assert(esp->inUse >= 0);
    unlock(esp);
}



PUBLIC void espClearFlash(HttpConn *conn)
{
    EspReq      *req;

    req = conn->data;
    req->flash = 0;
}


static void setupFlash(HttpConn *conn)
{
    EspReq      *req;

    req = conn->data;
    if (httpGetSession(conn, 0)) {
        req->flash = httpGetSessionObj(conn, ESP_FLASH_VAR);
        req->lastFlash = 0;
        if (req->flash) {
            httpRemoveSessionVar(conn, ESP_FLASH_VAR);
            req->lastFlash = mprCloneHash(req->flash);
        }
    }
}


static void pruneFlash(HttpConn *conn)
{
    EspReq  *req;
    MprKey  *kp, *lp;

    req = conn->data;
    if (req->flash && req->lastFlash) {
        for (ITERATE_KEYS(req->flash, kp)) {
            for (ITERATE_KEYS(req->lastFlash, lp)) {
                if (smatch(kp->key, lp->key)) {
                    mprRemoveKey(req->flash, kp->key);
                }
            }
        }
    }
}


static void finalizeFlash(HttpConn *conn)
{
    EspReq  *req;

    req = conn->data;
    if (req->flash && mprGetHashLength(req->flash) > 0) {
        /*  
            If the session does not exist, this will create one. However, must not have
            emitted the headers, otherwise cannot inform the client of the session cookie.
        */
        httpSetSessionObj(conn, ESP_FLASH_VAR, req->flash);
    }
}


/*
    Start the request. At this stage, body data may not have been fully received unless 
    the request is a form (POST method and Content-Type is application/x-www-form-urlencoded).
    Forms are a special case and delay invoking the start callback until all body data is received.
    WARNING: GC yield
 */
static void startEsp(HttpQueue *q)
{
    HttpConn    *conn;
    HttpRoute   *route;
    EspRoute    *eroute;
    EspReq      *req;
    cchar       *view;

    conn = q->conn;
    route = conn->rx->route;
    eroute = route->eroute;
    req = conn->data;

    if (req) {
        mprSetThreadData(req->esp->local, conn);
        httpAuthenticate(conn);
        setupFlash(conn);
        /*
            See if the esp configuration or app needs to be reloaded.
         */
        if (espLoadConfig(route) < 0) {
            httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load esp config for %s", eroute->appName);
            return;
        }
        /* WARNING: GC yield */
        if (!loadApp(route)) {
            httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load esp module for %s", eroute->appName);
            return;
        }
        /* WARNING: GC yield */
        if (!runAction(conn)) {
            pruneFlash(conn);
        } else {
            if (req->autoFinalize) {
                if (!conn->tx->responded) {
                    view = (route->sourceName && route->sourceName) ? conn->rx->target : NULL;
                    /* WARNING: GC yield */
                    espRenderView(conn, view);
                }
                if (req->autoFinalize) {
                    espFinalize(conn);
                }
            }
            pruneFlash(conn);
        }
        finalizeFlash(conn);
        mprSetThreadData(req->esp->local, NULL);
    }
}


/*
    Create a per user session database clone. Used for demos so one users updates to not change anothers view of the database
 */
static void pruneDatabases(Esp *esp)
{
    MprKey      *kp;

    lock(esp);
    for (ITERATE_KEYS(esp->databases, kp)) {
        if (!httpLookupSessionID(kp->key)) {
            mprRemoveKey(esp->databases, kp->key);
            /* Restart scan */
            kp = 0;
        }
    }
    unlock(esp);
}

static int cloneDatabase(HttpConn *conn)
{
    Esp         *esp;
    EspRoute    *eroute;
    EspReq      *req;
    cchar       *id;

    req = conn->data;
    eroute = conn->rx->route->eroute;
    assert(eroute->edi);
    assert(eroute->edi->flags & EDI_PRIVATE);

    esp = req->esp;
    if (!esp->databases) {
        lock(esp);
        if (!esp->databases) {
            esp->databases = mprCreateHash(0, 0);
            esp->databasesTimer = mprCreateTimerEvent(NULL, "esp-databases", 60 * 1000, pruneDatabases, esp, 0);
        }
        unlock(esp);
    }
    httpGetSession(conn, 1);
    id = httpGetSessionID(conn);
    if ((req->edi = mprLookupKey(esp->databases, id)) == 0) {
        if ((req->edi = ediClone(eroute->edi)) == 0) {
            mprError("Cannot clone database: %s", eroute->edi->path);
            return MPR_ERR_CANT_OPEN;
        }
        mprAddKey(esp->databases, id, req->edi);
    }
    return 0;
}



static int runAction(HttpConn *conn)
{
    HttpRx      *rx;
    HttpRoute   *route;
    EspRoute    *eroute;
    EspReq      *req;
    EspAction   action;
    cchar       *errMsg;
    char        *actionName, *key, *filename, *source;

    rx = conn->rx;
    req = conn->data;
    route = rx->route;
    eroute = route->eroute;
    assert(eroute);

    if (eroute->edi && eroute->edi->flags & EDI_PRIVATE) {
        cloneDatabase(conn);
    } else {
        req->edi = eroute->edi;
    }
    if (route->sourceName == 0 || *route->sourceName == '\0') {
        if (eroute->commonController) {
            (eroute->commonController)(conn);
        }
        return 1;
    }
    /*
        Expand any form var $tokens. This permits ${controller} and user form data to be used in the controller name
     */
    filename = schr(route->sourceName, '$') ? stemplateJson(route->sourceName, rx->params) : route->sourceName;
    source = eroute->controllersDir ? mprJoinPath(eroute->controllersDir, filename) : mprJoinPath(route->home, filename);

#if !BIT_STATIC
    key = mprJoinPath(eroute->controllersDir, rx->target);
    if (!eroute->flat && (eroute->update || !mprLookupKey(esp->actions, key))) {
        if (!loadModule(route, "controller", source, &errMsg)) {
            httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "%s", errMsg);
            return 0;
        }
    }
#endif /* !BIT_STATIC */
    key = mprJoinPath(eroute->controllersDir, rx->target);
    if ((action = mprLookupKey(esp->actions, key)) == 0) {
        if (!pageExists(conn)) {
            /*
                Actions are registered as: source/TARGET where TARGET is typically CONTROLLER-ACTION
             */
            key = sfmt("%s/missing", mprGetPathDir(source));
            if ((action = mprLookupKey(esp->actions, key)) == 0) {
                if ((action = mprLookupKey(esp->actions, "missing")) == 0) {
                    httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Missing action for %s in %s", rx->target, source);
                    return 0;
                }
            }
        }
    }
    if (route->flags & HTTP_ROUTE_XSRF) {
        if (!httpCheckSecurityToken(conn)) {
            if (rx->flags & HTTP_POST) {
                httpSetStatus(conn, HTTP_CODE_UNAUTHORIZED);
                if (eroute->json) {
                    mprLog(2, "Security token is stale. Please reload page.");
                    espRenderString(conn, "{\"retry\": true, \"success\": 0, \"feedback\": {\"error\": \"Security token is stale. Please retry.\"}}");
                    espFinalize(conn);
                } else {
                    httpError(conn, HTTP_CODE_UNAUTHORIZED, "Security token is stale. Please reload page.");
                }
                return 0;
            }
        }
    }
    if (action) {
        httpSetParam(conn, "controller", stok(sclone(rx->target), "-", &actionName));
        httpSetParam(conn, "action", actionName);
        if (eroute->commonController) {
            (eroute->commonController)(conn);
        }
        if (!httpIsFinalized(conn)) {
            (action)(conn);
        }
    }
    return 1;
}


PUBLIC void espRenderView(HttpConn *conn, cchar *name)
{
    HttpRx      *rx;
    HttpRoute   *route;
    EspRoute    *eroute;
    EspReq      *req;
    EspViewProc viewProc;
    cchar       *source, *errMsg;
    
    rx = conn->rx;
    req = conn->data;
    route = rx->route;
    eroute = route->eroute;
    
    if (name) {
        source = mprJoinPathExt(mprJoinPath(eroute->viewsDir, name), ".esp");
    } else {
        httpMapRequest(conn);
        source = conn->tx->filename;
    }
#if !BIT_STATIC
    if (!eroute->flat && (eroute->update || !mprLookupKey(esp->views, mprGetPortablePath(source)))) {
        /* WARNING: GC yield */
        mprHold(source);
        if (!loadModule(route, "view", source, &errMsg)) {
            mprRelease(source);
            httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "%s", errMsg);
            return;
        }
        mprRelease(source);
    }
#endif
    if ((viewProc = mprLookupKey(esp->views, mprGetPortablePath(source))) == 0) {
        httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot find view");
        return;
    }
    httpAddHeaderString(conn, "Content-Type", "text/html");
    if (rx->route->flags & HTTP_ROUTE_XSRF) {
        httpAddSecurityToken(conn);
    }
    /* WARNING: GC yield */
    (viewProc)(conn);
}


/************************************ Support *********************************/

#if !BIT_STATIC
static char *getModuleEntry(EspRoute *eroute, cchar *kind, cchar *source, cchar *cacheName)
{
    char    *cp, *entry;
    
    if (smatch(kind, "view")) {
        entry = sfmt("esp_%s", cacheName);

    } else if (smatch(kind, "app")) {
        if (eroute->flat) {
            entry = sfmt("esp_%s_%s_flat", kind, eroute->appName);
        } else {
            entry = sfmt("esp_%s_%s", kind, eroute->appName);
        }
    } else {
        /* Controller */
        if (eroute->appName) {
            entry = sfmt("esp_%s_%s_%s", kind, eroute->appName, mprTrimPathExt(mprGetPathBase(source)));
        } else {
            entry = sfmt("esp_%s_%s", kind, mprTrimPathExt(mprGetPathBase(source)));
        }
    }
    for (cp = entry; *cp; cp++) {
        if (!isalnum((uchar) *cp) && *cp != '_') {
            *cp = '_';
        }
    }
    return entry;
}


/*
    WARNING: GC yield
 */
static bool loadModule(HttpRoute *route, cchar *kind, cchar *source, cchar **errMsg)
{
    Esp         *esp;
    EspRoute    *eroute;
    MprModule   *mp;
    cchar       *appName, *cacheName, *canonical, *entry, *module;
    int         isView, recompile;

    eroute = route->eroute;
    esp = MPR->espService;

#if VXWORKS
    /* 
        Trim the drive for VxWorks where simulated host drives only exist on the target
     */
    source = mprTrimPathDrive(source);
#endif
    canonical = mprGetPortablePath(mprGetRelPath(source, route->documents));
    appName = eroute->appName ? eroute->appName : route->host->name;
    cacheName = mprGetMD5WithPrefix(sfmt("%s:%s", appName, canonical), -1, sjoin(kind, "_", NULL));
    module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, cacheName, BIT_SHOBJ));
    isView = smatch(kind, "view");

    lock(esp);
    if (eroute->update) {
        if (!mprPathExists(source, R_OK)) {
            mprError("Cannot find %s \"%s\" to load", kind, source);
            return 0;
        }
        if (espModuleIsStale(source, module, &recompile) || (isView && layoutIsStale(eroute, source, module))) {
            if (recompile) {
                mprHoldBlocks(source, module, cacheName, NULL);
                if (!espCompile(route, NULL, source, module, cacheName, isView, (char**) errMsg)) {
                    mprReleaseBlocks(source, module, cacheName, NULL);
                    unlock(esp);
                    return 0;
                }
                mprReleaseBlocks(source, module, cacheName, NULL);
            }
        }
    } else {
        mprTrace(4, "EspUpdate is disabled for this route: %s", route->name);
    }
    if (mprLookupModule(source) == 0) {
        entry = getModuleEntry(eroute, kind, source, cacheName);
        if ((mp = mprCreateModule(source, module, entry, route)) == 0) {
            mprError("Memory allocation error loading module");
            unlock(esp);
            return 0;
        }
        mprLog(3, "ESP: loadModule: \"%s\", %s", kind, source);
        if (mprLoadModule(mp) < 0) {
            mprError("Cannot load compiled esp module");
            unlock(esp);
            return 0;
        }
    }
    unlock(esp);
    return 1;
}


/* 
    WARNING: GC yield 
 */
static bool loadApp(HttpRoute *route)
{
    EspRoute    *eroute;
    cchar       *source, *errMsg;

    eroute = route->eroute;
    if (!eroute->appName) {
        return 1;
    }
    if (eroute->flat) {
        source = mprJoinPath(eroute->cacheDir, sfmt("%s.c", eroute->appName));
    } else {
        source = mprJoinPath(eroute->srcDir, "app.c");
    }
    if (!eroute->flat && !loadModule(route, "app", source, &errMsg)) {
        mprError("%s", errMsg);
        return 0;
    }
    return 1;
}


/*
    Test if a module has been updated (is stale).
    This will unload the module if it loaded but stale.
    Set recompile to true if the source is absent or more recent
 */
PUBLIC bool espModuleIsStale(cchar *source, cchar *module, int *recompile)
{
    MprModule   *mp;
    MprPath     sinfo, minfo;

    *recompile = 0;
    mprGetPathInfo(module, &minfo);
    if (!minfo.valid) {
        if ((mp = mprLookupModule(source)) != 0) {
            if (!espUnloadModule(source, BIT_ESP_RELOAD_TIMEOUT)) {
                mprError("Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
        }
        *recompile = 1;
        mprLog(4, "ESP %s is newer than module %s, recompiling ...", source, module);
        return 1;
    }
    mprGetPathInfo(source, &sinfo);
    if (sinfo.valid && sinfo.mtime > minfo.mtime) {
        if ((mp = mprLookupModule(source)) != 0) {
            if (!espUnloadModule(source, BIT_ESP_RELOAD_TIMEOUT)) {
                mprError("Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
        }
        *recompile = 1;
        mprLog(4, "ESP %s is newer than module %s, recompiling ...", source, module);
        return 1;
    }
    if ((mp = mprLookupModule(source)) != 0) {
        if (minfo.mtime > mp->modified) {
            /* Module file has been updated */
            if (!espUnloadModule(source, BIT_ESP_RELOAD_TIMEOUT)) {
                mprError("Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
            mprLog(4, "ESP module %s has been externally updated, reloading ...", module);
            return 1;
        }
    }
    /* Loaded module is current */
    return 0;
}


/*
    Check if the layout has changed
 */
static bool layoutIsStale(EspRoute *eroute, cchar *source, cchar *module)
{
    char    *data, *lpath, *quote;
    cchar   *layout;
    ssize   len;
    bool    stale;
    int     recompile;

    stale = 0;
    if ((data = mprReadPathContents(source, &len)) != 0) {
        if ((lpath = scontains(data, "@ layout \"")) != 0) {
            lpath = strim(&lpath[10], " ", MPR_TRIM_BOTH);
            if ((quote = schr(lpath, '"')) != 0) {
                *quote = '\0';
            }
            layout = (eroute->layoutsDir && *lpath) ? mprJoinPath(eroute->layoutsDir, lpath) : 0;
        } else {
            layout = (eroute->layoutsDir) ? mprJoinPath(eroute->layoutsDir, "default.esp") : 0;
        }
        if (layout) {
            stale = espModuleIsStale(layout, module, &recompile);
            if (stale) {
                mprLog(4, "ESP layout %s is newer than module %s", layout, module);
            }
        }
    }
    return stale;
}
#endif /* BIT_STATIC */


/*
    Test if the the required ESP page exists
 */
static bool pageExists(HttpConn *conn)
{
    HttpRx      *rx;
    EspRoute    *eroute;
    cchar       *source, *dir;
    
    rx = conn->rx;
    eroute = rx->route->eroute;
    dir = eroute->viewsDir ? eroute->viewsDir : rx->route->documents;
    source = mprJoinPathExt(mprJoinPath(dir, rx->target), ".esp");
    return mprPathExists(source, R_OK);
}


/************************************ Esp Route *******************************/
/*
    Public so that esp.c can also call
 */
PUBLIC void espManageEspRoute(EspRoute *eroute, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(eroute->appDir);
        mprMark(eroute->appName);
#if UNSED
        mprMark(eroute->appModulePath);
#endif
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
        mprMark(eroute->mutex);
        mprMark(eroute->searchPath);
        mprMark(eroute->routeSet);
        mprMark(eroute->srcDir);
        mprMark(eroute->viewsDir);
    }
}


//  FUTURE - make public and share with esp.c

static EspRoute *allocEspRoute(HttpRoute *route)
{
    cchar       *path;
    MprPath     info;
    EspRoute    *eroute;
    
    if ((eroute = mprAllocObj(EspRoute, espManageEspRoute)) == 0) {
        return 0;
    }
#if DEBUG_IDE && KEEP
    path = mprGetAppDir();
#else
    path = httpGetRouteVar(route, "CACHE_DIR");
    if (!path || mprGetPathInfo(path, &info) != 0 || !info.isDir) {
        path = mprJoinPath(route->home, "cache");
    }
    if (mprGetPathInfo(path, &info) != 0 || !info.isDir) {
        path = route->home;
    }
#endif
    /*
        Use a relative path incase a Chroot directive happens after loading the esp handler
     */
    eroute->cacheDir = (char*) mprGetRelPath(path, NULL);
    eroute->update = BIT_DEBUG;
    eroute->keepSource = BIT_DEBUG;
    eroute->lifespan = 0;
    eroute->mutex = mprCreateLock();
    route->eroute = eroute;
    return eroute;
}


static EspRoute *cloneEspRoute(HttpRoute *route, EspRoute *parent)
{
    EspRoute      *eroute;
    
    assert(parent);
    assert(route);

    if ((eroute = mprAllocObj(EspRoute, espManageEspRoute)) == 0) {
        return 0;
    }
    eroute->top = parent->top;
    eroute->searchPath = parent->searchPath;
    eroute->edi = parent->edi;
    eroute->commonController = parent->commonController;
    eroute->update = parent->update;
    eroute->keepSource = parent->keepSource;
    eroute->lifespan = parent->lifespan;
    if (parent->compile) {
        eroute->compile = sclone(parent->compile);
    }
    if (parent->link) {
        eroute->link = sclone(parent->link);
    }
    if (parent->env) {
        eroute->env = mprCloneHash(parent->env);
    }
    eroute->appDir = parent->appDir;
    eroute->appName = parent->appName;
    eroute->cacheDir = parent->cacheDir;
    eroute->clientDir = parent->clientDir;
    eroute->config = parent->config;
    eroute->configLoaded = parent->configLoaded;
    eroute->dbDir = parent->dbDir;
    eroute->layoutsDir = parent->layoutsDir;
    eroute->srcDir = parent->srcDir;
    eroute->controllersDir = parent->controllersDir;
    eroute->viewsDir = parent->viewsDir;
    route->eroute = eroute;
    return eroute;
}


PUBLIC void espSetDefaultDirs(HttpRoute *route)
{
    EspRoute    *eroute;
    char        *dir;

    eroute = route->eroute;
    dir = route->documents;

    eroute->dbDir       = mprJoinPath(dir, "db");
    eroute->cacheDir    = mprJoinPath(dir, "cache");
    eroute->clientDir   = mprJoinPath(dir, "client");
    eroute->controllersDir = mprJoinPath(dir, "controllers");
    eroute->srcDir      = mprJoinPath(dir, "src");
    eroute->appDir      = mprJoinPath(dir, "client/app");
    eroute->layoutsDir  = mprJoinPath(eroute->clientDir, "layouts");
    eroute->viewsDir    = eroute->appDir;

    httpSetRouteVar(route, "CACHE_DIR", eroute->cacheDir);
    httpSetRouteVar(route, "CLIENT_DIR", eroute->clientDir);
    httpSetRouteVar(route, "CONTROLLERS_DIR", eroute->controllersDir);
    httpSetRouteVar(route, "DB_DIR", eroute->dbDir);
    httpSetRouteVar(route, "LAYOUTS_DIR", eroute->layoutsDir);
    httpSetRouteVar(route, "SRC_DIR", eroute->srcDir);
    httpSetRouteVar(route, "VIEWS_DIR", eroute->viewsDir);
}


#if BIT_ESP_LEGACY
PUBLIC void espSetLegacyDirs(HttpRoute *route)
{
    EspRoute    *eroute;
    char        *dir;

    eroute = route->eroute;
    dir = route->documents;
    eroute->clientDir  = mprJoinPath(dir, "static");
    eroute->layoutsDir = mprJoinPath(dir, "layouts");
    eroute->viewsDir   = mprJoinPath(dir, "views");
    httpSetRouteVar(route, "CLIENT_DIR", eroute->clientDir);
    httpSetRouteVar(route, "LAYOUTS_DIR", eroute->layoutsDir);
    httpSetRouteVar(route, "VIEWS_DIR", eroute->viewsDir);
}
#endif


/*
    Manage all links for EspReq for the garbage collector
 */
static void manageReq(EspReq *req, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(req->commandLine);
        mprMark(req->flash);
        mprMark(req->feedback);
        mprMark(req->route);
        mprMark(req->data);
        mprMark(req->edi);
    }
}


/*
    Manage all links for Esp for the garbage collector
 */
static void manageEsp(Esp *esp, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(esp->actions);
        mprMark(esp->databases);
        mprMark(esp->databasesTimer);
        mprMark(esp->ediService);
#if BIT_ESP_LEGACY
        mprMark(esp->internalOptions);
#endif
        mprMark(esp->local);
        mprMark(esp->mutex);
        mprMark(esp->views);
    }
}


/*
    Get a dedicated EspRoute for an HttpRoute. Allocate if required. It is expected that the caller will modify the EspRoute.
 */
static EspRoute *getEroute(HttpRoute *route)
{
    HttpRoute   *rp;

    if (route->eroute) {
        if (!route->parent || route->parent->eroute != route->eroute) {
            return route->eroute;
        }
    }

    /*
        Lookup up the route chain for any configured EspRoutes
     */
    for (rp = route; rp; rp = rp->parent) {
        if (rp->eroute) {
            return cloneEspRoute(route, rp->eroute);
        }
    }
    return allocEspRoute(route);
}


#if BIT_ESP_LEGACY
/*
    Deprecated in 4.4
 */
static HttpRoute *addLegacyRestful(HttpRoute *parent, cchar *prefix, cchar *action, cchar *methods, cchar *pattern, 
    cchar *target, cchar *resource)
{
    cchar       *name, *nameResource, *source, *token;

    token = "{controller}";
    nameResource = smatch(resource, token) ? "*" : resource;

    if (parent->prefix) {
        name = sfmt("%s/%s/%s", parent->prefix, nameResource, action);
        pattern = sfmt("^%s/%s%s", parent->prefix, resource, pattern);
    } else {
        name = sfmt("/%s/%s", nameResource, action);
        if (*resource == '{') {
            pattern = sfmt("^/%s%s", resource, pattern);
        } else {
            pattern = sfmt("^/{controller=%s}%s", resource, pattern);
        }
    }
    if (*resource == '{') {
        target = sfmt("$%s-%s", resource, target);
        source = sfmt("$%s.c", resource);
    } else {
        target = sfmt("%s-%s", resource, target);
        source = sfmt("%s.c", resource);
    }
    return httpDefineRoute(parent, name, methods, pattern, target, source);
}


/*
    Deprecated in 4.4.0
 */
PUBLIC void httpAddLegacyResourceGroup(HttpRoute *parent, cchar *prefix, cchar *resource)
{
    addLegacyRestful(parent, prefix, "create",    "POST",    "(/)*$",                   "create",        resource);
    addLegacyRestful(parent, prefix, "destroy",   "DELETE",  "/{id=[0-9]+}$",           "destroy",       resource);
    addLegacyRestful(parent, prefix, "edit",      "GET",     "/{id=[0-9]+}/edit$",      "edit",          resource);
    addLegacyRestful(parent, prefix, "init",      "GET",     "/init$",                  "init",          resource);
    addLegacyRestful(parent, prefix, "list",      "GET",     "(/)*$",                   "list",          resource);
    addLegacyRestful(parent, prefix, "show",      "GET",     "/{id=[0-9]+}$",           "show",          resource);
    addLegacyRestful(parent, prefix, "update",    "PUT",     "/{id=[0-9]+}$",           "update",        resource);
    addLegacyRestful(parent, prefix, "action",    "POST",    "/{action}/{id=[0-9]+}$",  "${action}",     resource);
    addLegacyRestful(parent, prefix, "default",   "GET,POST","/{action}$",              "cmd-${action}", resource);
}


PUBLIC void httpAddLegacyResource(HttpRoute *parent, cchar *prefix, cchar *resource)
{
    addLegacyRestful(parent, prefix, "init",      "GET",     "/init$",       "init",          resource);
    addLegacyRestful(parent, prefix, "create",    "POST",    "(/)*$",        "create",        resource);
    addLegacyRestful(parent, prefix, "edit",      "GET",     "/edit$",       "edit",          resource);
    addLegacyRestful(parent, prefix, "show",      "GET",     "(/)*$",        "show",          resource);
    addLegacyRestful(parent, prefix, "update",    "PUT",     "(/)*$",        "update",        resource);
    addLegacyRestful(parent, prefix, "destroy",   "DELETE",  "(/)*$",        "destroy",       resource);
    addLegacyRestful(parent, prefix, "default",   "GET,POST","/{action}$",   "cmd-${action}", resource);
}
#endif


PUBLIC void espAddHomeRoute(HttpRoute *parent)
{
    cchar   *source, *name, *path, *pattern, *prefix;

    prefix = parent->prefix ? parent->prefix : "";
    source = parent->sourceName;
    name = sjoin(prefix, "/home", NULL);
    path = stemplate("${CLIENT_DIR}/index.esp", parent->vars);
    pattern = sfmt("^%s(/)$", prefix);
    httpDefineRoute(parent, name, "GET,POST", pattern, path, source);
}


PUBLIC void espAddRouteSet(HttpRoute *route, cchar *set)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    if (set == 0 || *set == 0) {
        return;
    }
    if (scaselessmatch(set, "esp-angular-mvc")) {
        httpAddWebSocketsRoute(route, route->serverPrefix, "/*/stream");
        httpAddResourceGroup(route, route->serverPrefix, "{controller}");
        httpAddClientRoute(route, "", "/public");
        httpHideRoute(route, 1);
        eroute->viewsDir = eroute->appDir;
        eroute->layoutsDir = mprJoinPath(eroute->clientDir, "layouts");

    } else if (scaselessmatch(set, "esp-html-mvc")) {
        httpAddRestfulRoute(route, route->serverPrefix, "delete", "POST", "/{id=[0-9]+}/delete$", "delete", "{controller}");
        httpAddResourceGroup(route, route->serverPrefix, "{controller}");
        httpAddClientRoute(route, "", "/public");
        httpHideRoute(route, 1);
        eroute->viewsDir = eroute->appDir;
        eroute->layoutsDir = mprJoinPath(eroute->clientDir, "layouts");

#if BIT_ESP_LEGACY
    /*
        Deprecated in 4.4
     */
    } else if (scaselessmatch(set, "mvc")) {
        espAddHomeRoute(route);
        httpAddClientRoute(route, "/static", "/static");

    } else if (scaselessmatch(set, "mvc-fixed")) {
        espAddHomeRoute(route);
        httpAddClientRoute(route, "/static", "/static");
        httpDefineRoute(route, "default", NULL, "^/{controller}(~/{action}~)", "${controller}-${action}", "${controller}.c");

    } else if (scaselessmatch(set, "restful") || scaselessmatch(set, "esp-legacy-mvc")) {
        if (eroute->legacy) {
            espAddHomeRoute(route);
            httpAddClientRoute(route, "/static", "/static");
            httpAddLegacyResourceGroup(route, "", "{controller}");
        } else {
            httpAddResourceGroup(route, route->serverPrefix, "{controller}");
            httpAddClientRoute(route, "", "/client");
        }

    } else if (!scaselessmatch(set, "none")) {
        mprError("Unknown route set %s", set);
#endif
    }
}

/*********************************** Directives *******************************/
/*
    <EspApp 
  or 
    EspApp 
        auth=STORE 
        database=DATABASE 
        dir=DIR 
        flat=true|false
        name=NAME 
        prefix=PREFIX 
        routes=ROUTES 

    Old syntax DEPRECATED in 4.4: EspApp Prefix [Dir [RouteSet [Database]]]
 */
static int startEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;
    EspRoute    *eroute;
    cchar       *auth, *database, *name, *prefix, *dir, *routeSet, *flat;
    char        *option, *ovalue, *tok;

    dir = ".";
    routeSet = 0;
    flat = "false";
    prefix = 0;
    database = 0;
    auth = 0;
    name = 0;

    if (scontains(value, "=")) {
        for (option = maGetNextArg(sclone(value), &tok); option; option = maGetNextArg(tok, &tok)) {
            option = stok(option, " =\t,", &ovalue);
            ovalue = strim(ovalue, "\"'", MPR_TRIM_BOTH);
            if (smatch(option, "auth")) {
                auth = ovalue;
            } else if (smatch(option, "database")) {
                database = ovalue;
            } else if (smatch(option, "dir")) {
                dir = ovalue;
            } else if (smatch(option, "flat")) {
                flat = ovalue;
            } else if (smatch(option, "name")) {
                name = ovalue;
            } else if (smatch(option, "prefix")) {
                prefix = ovalue;
            } else if (smatch(option, "routes")) {
                routeSet = ovalue;
#if DEPRECATED || 1
            } else if (smatch(option, "type")) {
                /* Ignored */
#endif
            } else {
                mprError("Unknown EspApp option \"%s\"", option);
            }
        }

#if DEPRECATED || 1
    } else {
        /* 
            Deprecated in 4.4.0
         */
        if (!maTokenize(state, value, "%S ?S ?S ?S", &prefix, &dir, &routeSet, &database)) {
            return MPR_ERR_BAD_SYNTAX;
        }
        name = "app";
#endif
    }
    if (smatch(prefix, "/") || smatch(prefix, "")) {
        prefix = 0;
    }
    if (/* FUTURE smatch(prefix, state->route->prefix) && */ mprSamePath(state->route->documents, dir)) {
        /* 
            Can use existing route as it has the same prefix and documents directory. 
         */
        route = state->route;
    } else {
        route = httpCreateInheritedRoute(state->route);
    }
    state->route = route;
    httpSetRouteDocuments(route, dir);

    if ((eroute = getEroute(route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->top = eroute;
    eroute->flat = scaselessmatch(flat, "true") || smatch(flat, "1");
    if (name) {
        eroute->appName = sclone(name);
    }
    httpSetRouteVar(route, "APP_NAME", name);
    eroute->routeSet = sclone(routeSet);
    espSetDefaultDirs(route);
    if (prefix) {
        if (*prefix != '/') {
            mprError("Prefix name should start with a \"/\"");
            prefix = sjoin("/", prefix, NULL);
        }
        prefix = stemplate(prefix, route->vars);
        httpSetRouteName(route, prefix);
        httpSetRoutePrefix(route, prefix);
        httpSetRoutePattern(route, sfmt("^%s%", prefix), 0);
    } else {
        httpSetRouteName(route, sfmt("/%s", name));
    }
    httpSetRouteVar(route, "PREFIX", prefix);
    /*
        Load the config file here before creating routes
     */
    if (espLoadConfig(route) < 0) {
        return MPR_ERR_CANT_LOAD;
    }
    espSetConfig(route, "esp.appPrefix", prefix);
    espSetConfig(route, "esp.prefix", sjoin(prefix ? prefix : "", route->serverPrefix, NULL));
#if BIT_ESP_LEGACY
    if (eroute->legacy && (eroute->routeSet == 0 || *eroute->routeSet == '\0')) {
        eroute->routeSet = sclone("restful");
    }
#endif
    if (auth) {
        if (httpSetAuthStore(route->auth, auth) < 0) {
            mprError("The %s AuthStore is not available on this platform", auth);
            return MPR_ERR_BAD_STATE;
        }
    }

    httpSetRouteTarget(route, "run", "$&");
    httpAddRouteHandler(route, "espHandler", "");
    httpAddRouteHandler(route, "espHandler", "esp");

#if BIT_ESP_LEGACY
    if (!eroute->legacy)
#endif
        httpAddRouteIndex(route, "index.esp");

    if (database) {
        eroute->database = sclone(database);
        if (espDbDirective(state, key, eroute->database) < 0) {
            return MPR_ERR_BAD_STATE;
        }
    }
    return 0;
}


static int finishEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;
    EspRoute    *eroute;
    MprJson     *preload, *item;
    cchar       *errMsg, *source;
    char        *kind;
    int         i;

    /*
        The order of route finalization will be from the inside. Route finalization causes the route to be added
        to the enclosing host. This ensures that nested routes are defined BEFORE outer/enclosing routes.
     */
    route = state->route;
    eroute = route->eroute;
    espAddRouteSet(route, eroute->routeSet);
    if (route != state->prev->route) {
        httpFinalizeRoute(route);
    }
#if !BIT_STATIC
    if (!state->appweb->skipModules) {
        /*
            Note: the config parser pauses GC, so this will never yield
         */
        if (!loadApp(route)) {
            return MPR_ERR_CANT_LOAD;
        }
        if ((preload = mprGetJsonObj(eroute->config, "esp.preload", 0)) != 0) {
            for (ITERATE_JSON(preload, item, i)) {
                source = stok(sclone(item->value), ":", &kind);
                if (!kind) kind = "controller";
                source = mprJoinPath(eroute->controllersDir, source);
                if (!loadModule(state->route, kind, source, &errMsg)) {
                    mprError("Cannot preload esp module %s. %s", source, errMsg);
                    return MPR_ERR_CANT_LOAD;
                }
            }
        }
    }
#endif
    return 0;
}


/*
    <Espapp>
 */
static int openEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    state = maPushState(state);
    return startEspAppDirective(state, key, value);
}


/*
    </Espapp>
 */
static int closeEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    if (finishEspAppDirective(state, key, value) < 0) {
        return MPR_ERR_BAD_STATE;
    }
    maPopState(state);
    return 0;
}


/*
    see openEspAppDirective
 */
static int espAppDirective(MaState *state, cchar *key, cchar *value)
{
    state = maPushState(state);
    if (startEspAppDirective(state, key, value) < 0) {
        return MPR_ERR_BAD_STATE;
    }
    if (finishEspAppDirective(state, key, value) < 0) {
        return MPR_ERR_BAD_STATE;
    }
    maPopState(state);
    return 0;
}


/*
    EspCompile template
 */
static int espCompileDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->compile = sclone(value);
    return 0;
}


PUBLIC int espOpenDatabase(HttpRoute *route, cchar *spec)
{
    EspRoute    *eroute;
    char        *provider, *path;
    int         flags;

    eroute = route->eroute;
    flags = EDI_CREATE | EDI_AUTO_SAVE;
    provider = stok(sclone(spec), "://", &path);
    if (provider == 0 || path == 0) {
        return MPR_ERR_BAD_ARGS;
    }
    path = mprJoinPath(eroute->dbDir, path);
    if ((eroute->edi = ediOpen(mprGetRelPath(path, NULL), provider, flags)) == 0) {
        return MPR_ERR_CANT_OPEN;
    }
    return 0;
}


/*
    EspDb provider://database
 */
static int espDbDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (espOpenDatabase(state->route, value) < 0) {
        if (!(state->flags & MA_PARSE_NON_SERVER)) {
            mprError("Cannot open database '%s'. Use: provider://database", value);
            return MPR_ERR_CANT_OPEN;
        }
    }
    return 0;
}


/*
    EspDir key path
 */
static int espDirDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    char        *name, *path;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%S ?S", &name, &path)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    if (smatch(name, "mvc")) {
        espSetDefaultDirs(state->route);
    } else {
        path = stemplate(path, state->route->vars);
        path = stemplate(mprJoinPath(state->route->home, path), state->route->vars);
        if (smatch(name, "cache")) {
            eroute->cacheDir = path;
        } else if (smatch(name, "client")) {
            eroute->clientDir = path;
        } else if (smatch(name, "controllers")) {
            eroute->controllersDir = path;
        } else if (smatch(name, "db")) {
            eroute->dbDir = path;
        } else if (smatch(name, "layouts")) {
            eroute->layoutsDir = path;
        } else if (smatch(name, "src")) {
            eroute->srcDir = path;
        } else if (smatch(name, "views")) {
            eroute->viewsDir = path;
#if DEPRECATED || 1
        } else if (smatch(name, "static")) {
            eroute->clientDir = path;
#endif
        }
        httpSetRouteVar(state->route, name, path);
    }
    return 0;
}


/*
    Define Visual Studio environment if not already present
 */
static void defineVisualStudioEnv(MaState *state)
{
    MaAppweb    *appweb;
    int         is64BitSystem;

    appweb = MPR->appwebService;

    if (scontains(getenv("LIB"), "Visual Studio") &&
        scontains(getenv("INCLUDE"), "Visual Studio") &&
        scontains(getenv("PATH"), "Visual Studio")) {
        return;
    }
    if (scontains(appweb->platform, "-x64-")) {
        is64BitSystem = smatch(getenv("PROCESSOR_ARCHITECTURE"), "AMD64") || getenv("PROCESSOR_ARCHITEW6432");
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\win8\\um\\x64;${WINSDK}\\LIB\\x64;${VS}\\VC\\lib\\amd64\"");
        if (is64BitSystem) {
            espEnvDirective(state, "EspEnv", 
                "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\amd64;${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;"
                "${VS}\\VC\\VCPackages;${WINSDK}\\bin\\x64\"");

        } else {
            /* Cross building on x86 for 64-bit */
            espEnvDirective(state, "EspEnv", 
                "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_amd64;"
                "${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\x86\"");
        }

    } else if (scontains(appweb->platform, "-arm-")) {
        /* Cross building on x86 for arm. No winsdk 7 support for arm */
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\win8\\um\\arm;${VS}\\VC\\lib\\arm\"");
        espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_arm;${VS}\\Common7\\Tools;"
            "${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\arm\"");

    } else {
        /* Building for X86 */
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\win8\\um\\x86;${WINSDK}\\LIB\\x86;"
            "${WINSDK}\\LIB;${VS}\\VC\\lib\"");
        espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin;${VS}\\Common7\\Tools;"
            "${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\"");
    }
    espEnvDirective(state, "EspEnv", "INCLUDE \"${VS}\\VC\\INCLUDE;${WINSDK}\\include;${WINSDK}\\include\\um;"
        "${WINSDK}\\include\\shared\"");
}


/*
    EspEnv var string
    This defines an environment variable setting. It is defined only when commands for this route are executed.
 */
static int espEnvDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    char        *ekey, *evalue;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%S ?S", &ekey, &evalue)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    if (eroute->env == 0) {
        eroute->env = mprCreateHash(-1, MPR_HASH_STABLE);
    }
    evalue = espExpandCommand(state->route, evalue, "", "");
    if (scaselessmatch(ekey, "VisualStudio")) {
        defineVisualStudioEnv(state);
    } else {
        mprAddKey(eroute->env, ekey, evalue);
    }
    if (scaselessmatch(ekey, "PATH")) {
        if (eroute->searchPath) {
            eroute->searchPath = sclone(evalue);
        } else {
            eroute->searchPath = sjoin(eroute->searchPath, MPR_SEARCH_SEP, evalue, NULL);
        }
    }
    return 0;
}


/*
    EspKeepSource on|off
 */
static int espKeepSourceDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    bool        on;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    eroute->keepSource = on;
    return 0;
}


/*
    EspLink template
 */
static int espLinkDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->link = sclone(value);
    return 0;
}


/*
    Initialize and load a statically linked ESP module
 */
PUBLIC int espStaticInitialize(EspModuleEntry entry, cchar *appName, cchar *routeName)
{
    HttpRoute   *route;

    if ((route = httpLookupRoute(NULL, routeName)) == 0) {
        mprError("Cannot find route %s", routeName);
        return MPR_ERR_CANT_ACCESS;
    }
    return (entry)(route, NULL);
}


/*
    EspPermResource [resource ...]
 */
static int espPermResourceDirective(MaState *state, cchar *key, cchar *value)
{
    char        *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddPermResource(state->route, state->route->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddPermResource(state->route, state->route->serverPrefix, name);
            name = stok(NULL, ", \t\r\n", &next);
        }
    }
    return 0;
}

/*
    EspResource [resource ...]
 */
static int espResourceDirective(MaState *state, cchar *key, cchar *value)
{
    char        *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddResource(state->route, state->route->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddResource(state->route, state->route->serverPrefix, name);
            name = stok(NULL, ", \t\r\n", &next);
        }
    }
    return 0;
}


/*
    EspResourceGroup [resource ...]
 */
static int espResourceGroupDirective(MaState *state, cchar *key, cchar *value)
{
    char        *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddResourceGroup(state->route, state->route->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddResourceGroup(state->route, state->route->serverPrefix, name);
            name = stok(NULL, ", \t\r\n", &next);
        }
    }
    return 0;
}


/*
    EspRoutePrefix /server
    Sets the route prefix to use for routes to talk to the server
 */
static int espRoutePrefixDirective(MaState *state, cchar *key, cchar *value)
{
    httpSetRouteServerPrefix(state->route, value);
    httpSetRouteVar(state->route, "SERVER_PREFIX", sjoin(state->route->prefix ? state->route->prefix: "", state->route->serverPrefix, NULL));
    return 0;
}


/*
    EspRoute 
        methods=METHODS
        name=NAME 
        prefix=PREFIX 
        source=SOURCE
        target=TARGET

    Old syntax DEPRECATED in 4.4: EspRoute name methods prefix target source
 */
static int espRouteDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    HttpRoute   *route;
    cchar       *methods, *name, *prefix, *source, *target;
    char        *option, *ovalue, *tok;

    prefix = 0;
    name = 0;
    source = 0;
    target = 0;
    methods = "GET";

    if (scontains(value, "=")) {
        for (option = maGetNextArg(sclone(value), &tok); option; option = maGetNextArg(tok, &tok)) {
            option = stok(option, "=,", &ovalue);
            ovalue = strim(ovalue, "\"'", MPR_TRIM_BOTH);
            if (smatch(option, "methods")) {
                methods = ovalue;
            } else if (smatch(option, "name")) {
                name = ovalue;
            } else if (smatch(option, "prefix")) {
                prefix = ovalue;
            } else if (smatch(option, "source")) {
                source = ovalue;
            } else if (smatch(option, "target")) {
                target = ovalue;
            } else {
                mprError("Unknown EspRoute option \"%s\"", option);
            }
        }
#if DEPRECATED || 1
    } else {
        /* 
            Deprecated in 4.4.0
         */
        if (!maTokenize(state, value, "%S %S %S %S ?S", &name, &methods, &prefix, &target, &source)) {
            return MPR_ERR_BAD_SYNTAX;
        }
#endif
    }
    if (!prefix || !target) {
        return MPR_ERR_BAD_SYNTAX;
    }
    if (target == 0 || *target == 0) {
        target = "$&";
    }
    target = stemplate(target, state->route->vars);
    if ((route = httpDefineRoute(state->route, name, methods, prefix, target, source)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    httpSetRouteHandler(route, "espHandler");
    if ((eroute = getEroute(route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (name) {
        eroute->appName = sclone(name);
    }
    return 0;
}


PUBLIC int espBindProc(HttpRoute *parent, cchar *pattern, void *proc)
{
    EspRoute    *eroute;
    HttpRoute   *route;

    if ((route = httpDefineRoute(parent, pattern, "ALL", pattern, "$&", "unused")) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    httpSetRouteHandler(route, "espHandler");

    if ((eroute = getEroute(route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->update = 0;
    espDefineAction(route, pattern, proc);
    return 0;
}


/*
    EspRouteSet kind
 */
static int espRouteSetDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    char        *kind;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%S", &kind)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    espAddRouteSet(state->route, kind);
    return 0;
}


#if DEPRECATE || 1
/*
    EspShowErrors on|off
    Now use ShowErrors
 */
static int espShowErrorsDirective(MaState *state, cchar *key, cchar *value)
{
    bool    on;

    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    httpSetRouteShowErrors(state->route, on);
    return 0;
}
#endif


/*
    EspUpdate on|off
 */
static int espUpdateDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    bool        on;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    eroute->update = on;
    return 0;
}


/************************************ Init ************************************/
/*
    Loadable module configuration
 */
PUBLIC int maEspHandlerInit(Http *http, MprModule *module)
{
    HttpStage   *handler;
    MaAppweb    *appweb;

    appweb = httpGetContext(http);

    if ((handler = httpCreateHandler(http, "espHandler", module)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    http->espHandler = handler;
    handler->open = openEsp; 
    handler->close = closeEsp; 
    handler->start = startEsp; 
    if ((esp = mprAllocObj(Esp, manageEsp)) == 0) {
        return MPR_ERR_MEMORY;
    }
    handler->stageData = esp;
    MPR->espService = esp;
    esp->mutex = mprCreateLock();
    esp->local = mprCreateThreadLocal();
    if (module) {
        mprSetModuleFinalizer(module, unloadEsp);
    }
#if BIT_ESP_LEGACY
    espInitHtmlOptions(esp);
#endif
    /* Thread-safe */
    if ((esp->views = mprCreateHash(-1, MPR_HASH_STATIC_VALUES)) == 0) {
        return 0;
    }
    if ((esp->actions = mprCreateHash(-1, MPR_HASH_STATIC_VALUES)) == 0) {
        return 0;
    }
    /*
        Add configuration file directives
     */
    maAddDirective(appweb, "EspApp", espAppDirective);
    maAddDirective(appweb, "<EspApp", openEspAppDirective);
    maAddDirective(appweb, "</EspApp", closeEspAppDirective);
    maAddDirective(appweb, "EspCompile", espCompileDirective);
    maAddDirective(appweb, "EspDb", espDbDirective);
    maAddDirective(appweb, "EspDir", espDirDirective);
    maAddDirective(appweb, "EspEnv", espEnvDirective);
    maAddDirective(appweb, "EspKeepSource", espKeepSourceDirective);
    maAddDirective(appweb, "EspLink", espLinkDirective);
    maAddDirective(appweb, "EspPermResource", espPermResourceDirective);
    maAddDirective(appweb, "EspResource", espResourceDirective);
    maAddDirective(appweb, "EspResourceGroup", espResourceGroupDirective);
    maAddDirective(appweb, "EspRoute", espRouteDirective);
    maAddDirective(appweb, "EspRoutePrefix", espRoutePrefixDirective);
    maAddDirective(appweb, "EspRouteSet", espRouteSetDirective);
    maAddDirective(appweb, "EspUpdate", espUpdateDirective);
#if DEPRECATE || 1
    maAddDirective(appweb, "EspShowErrors", espShowErrorsDirective);
#endif
    if ((esp->ediService = ediCreateService()) == 0) {
        return 0;
    }
#if BIT_PACK_MDB
    /* Memory database */
    mdbInit();
#endif
#if BIT_PACK_SDB
    /* Sqlite */
    sdbInit();
#endif
    return 0;
}


static int unloadEsp(MprModule *mp)
{
    HttpStage   *stage;

    if (esp->inUse) {
       return MPR_ERR_BUSY;
    }
    if ((stage = httpLookupStage(MPR->httpService, mp->name)) != 0) {
        stage->flags |= HTTP_STAGE_UNLOADED;
    }
    return 0;
}


#else /* BIT_PACK_ESP */

PUBLIC int maEspHandlerInit(Http *http, MprModule *mp)
{
    mprNop(0);
    return 0;
}

#endif /* BIT_PACK_ESP */
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
