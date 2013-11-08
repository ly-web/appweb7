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
static int loadApp(HttpRoute *route, MprDispatcher *dispatcher);
static void manageEsp(Esp *esp, int flags);
static void manageReq(EspReq *req, int flags);
static int runAction(HttpConn *conn);
static int unloadEsp(MprModule *mp);
static bool pageExists(HttpConn *conn);

#if !BIT_STATIC
static char *getControllerEntry(cchar *appName, cchar *controllerFile);
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
        } else {
            req->flash = 0;
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
                if (smatch(kp->key, lp->key) && kp->data == lp->data) {
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
 */
static void startEsp(HttpQueue *q)
{
    HttpConn    *conn;
    EspReq      *req;

    conn = q->conn;
    req = conn->data;

    if (req) {
        mprSetThreadData(req->esp->local, conn);
        setupFlash(conn);
        if (!runAction(conn)) {
            pruneFlash(conn);
        } else {
            pruneFlash(conn);
            if (req->autoFinalize) {
                if (!conn->tx->responded) {
                    espRenderView(conn, 0);
                }
                if (req->autoFinalize) {
                    espFinalize(conn);
                }
            }
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
    char        *actionName, *key, *controllerName;

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
    if (schr(route->sourceName, '$')) {
        req->controllerFile = stemplateJson(route->sourceName, rx->params);
    } else {
        req->controllerFile = route->sourceName;
    }
    if (eroute->controllersDir) {
        req->controllerPath = mprJoinPath(eroute->controllersDir, req->controllerFile);
    } else {
        /*
            Look for controllers under the home rather than documents. Must not publish source.
         */
        req->controllerPath = mprJoinPath(route->home, req->controllerFile);
    }
    key = mprJoinPath(eroute->controllersDir, rx->target);

#if BIT_DEBUG
    /*
        See if the config.json or app needs to be reloaded.
     */
    if (espLoadConfig(route) < 0) {
        return MPR_ERR_CANT_LOAD;
    }
    if (loadApp(route, conn->dispatcher) < 0) {
        httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load esp module for %s", eroute->appName);
        return 0;
    }
#endif
#if !BIT_STATIC
    if (!eroute->flat && (eroute->update || !mprLookupKey(esp->actions, key))) {
        char        *canonical, *source, *errMsg;
        int         recompile = 0;

        /* Trim the drive for VxWorks where simulated host drives only exist on the target */
        source = req->controllerPath;
#if VXWORKS
        source = mprTrimPathDrive(source);
#endif
        canonical = mprGetPortablePath(mprGetRelPath(source, route->documents));
        req->cacheName = mprGetMD5WithPrefix(sfmt("%s:%s", eroute->appName, canonical), -1, "controller_");
        req->module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, req->cacheName, BIT_SHOBJ));

        if (!mprPathExists(req->controllerPath, R_OK)) {
            httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot find controller \"%s\" to serve request", 
                req->controllerPath);
            return 0;
        }
        lock(req->esp);
        if (eroute->update) {
            /*
                Test if the source has been updated. This will unload prior modules if stale
             */ 
            if (espModuleIsStale(req->controllerPath, req->module, &recompile)) {
                mprLog(4, "ESP controller %s is newer than module %s, recompiling ...", source, req->controllerPath, req->module);
                /*  WARNING: GC yield here */
                if (recompile && !espCompile(route, conn->dispatcher, req->controllerPath, req->module, req->cacheName, 0, &errMsg)) {
                    httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "%s", errMsg);
                    unlock(req->esp);
                    return 0;
                }
            }
        }
        if (mprLookupModule(req->controllerPath) == 0) {
            MprModule   *mp;
            req->entry = getControllerEntry(eroute->appName, req->controllerFile);
            if ((mp = mprCreateModule(req->controllerPath, req->module, req->entry, route)) == 0) {
                unlock(req->esp);
                httpMemoryError(conn);
                return 0;
            }
            if (mprLoadModule(mp) < 0) {
                unlock(req->esp);
                httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load compiled esp module for %s", req->controllerPath);
                return 0;
            }
        }
        unlock(req->esp);
    }
#endif
    key = mprJoinPath(eroute->controllersDir, rx->target);
    if ((action = mprLookupKey(esp->actions, key)) == 0) {
        if (!pageExists(conn)) {
            /*
                Actions are registered as: controllerPath/TARGET where TARGET is typically CONTROLLER-ACTION
             */
            req->controllerPath = mprJoinPath(eroute->controllersDir, req->controllerFile);
            key = sfmt("%s/missing", mprGetPathDir(req->controllerPath));
            if ((action = mprLookupKey(esp->actions, key)) == 0) {
                if ((action = mprLookupKey(esp->actions, "missing")) == 0) {
                    httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Missing action for %s in %s", rx->target, req->controllerPath);
                    return 0;
                }
            }
        }
    }
    if (rx->flags & HTTP_POST && rx->authenticated && (route->flags & HTTP_ROUTE_XSRF)) {
        if (!httpCheckSecurityToken(conn)) {
            httpCreateSecurityToken(conn);
            httpRenderSecurityToken(conn);
            httpSetStatus(conn, HTTP_CODE_UNAUTHORIZED);
            if (eroute->json) {
                espRenderString(conn, 
                    "{\"success\": 0, \"feedback\": {\"error\": \"Security token is stale. Please retry.\"}}");
                espFinalize(conn);
            } else {
                httpError(conn, HTTP_CODE_UNAUTHORIZED, "Security token is stale. Please retry.");
            }
            return 0;
        }
    }

    if (action) {
        controllerName = stok(sclone(rx->target), "-", &actionName);
        httpSetParam(conn, "controller", controllerName);
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
    EspViewProc view;
    cchar       *appName;
    
    rx = conn->rx;
    req = conn->data;
    route = rx->route;
    eroute = route->eroute;
    
    if (name && *name) {
        req->view = mprJoinPath(eroute->viewsDir, name);
        req->source = mprJoinPathExt(req->view, ".esp");

    } else if (req->controllerFile) {
        req->view = mprJoinPath(eroute->viewsDir, rx->target);
        req->source = mprJoinPathExt(req->view, ".esp");

    } else {
        httpMapFile(conn, rx->route);
        req->view = conn->tx->filename;
        req->source = req->view;
    }
    if (loadApp(route, conn->dispatcher) < 0) {
        httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load esp module for %s", eroute->appName);
        return;
    }
#if !BIT_STATIC
    if (!eroute->flat && (eroute->update || !mprLookupKey(esp->views, mprGetPortablePath(req->source)))) {
        cchar       *canonical, *source;
        char        *errMsg;
        int         recompile = 0;
        /* Trim the drive for VxWorks where simulated host drives only exist on the target */
        source = req->source;
#if VXWORKS
        source = mprTrimPathDrive(source);
#endif
        canonical = mprGetPortablePath(mprGetRelPath(source, req->route->documents));
        appName = eroute->appName ? eroute->appName : route->host->name;
        req->cacheName = mprGetMD5WithPrefix(sfmt("%s:%s", appName, canonical), -1, "view_");
        req->module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, req->cacheName, BIT_SHOBJ));

        if (!mprPathExists(req->source, R_OK)) {
            mprLog(3, "Cannot find ESP source %s", req->source);
            httpError(conn, HTTP_CODE_NOT_FOUND, "Cannot find resource for %s", rx->uri);
            return;
        }
        lock(req->esp);
        if (eroute->update) {
            espModuleIsStale(req->source, req->module, &recompile);
            if (recompile) {
                mprLog(4, "ESP page %s is newer than module %s, recompiling ...", req->source, req->module);
#if BIT_DEBUG
            } else {
                /*
                    Check if the layout has changed. Only do this if debug as we don't want to slow production versions.
                 */
                char    *data, *lpath, *quote, *layout;
                ssize   len;
                if ((data = mprReadPathContents(req->source, &len)) != 0) {
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
                        espModuleIsStale(layout, req->module, &recompile);
                    }
                    if (recompile) {
                        mprLog(4, "ESP layout %s is newer than module %s, recompiling ...", layout, req->module);
                        if (mprLookupModule(req->source) != 0 && !espUnloadModule(req->source, BIT_ESP_RELOAD_TIMEOUT)) {
                            mprError("Cannot unload module %s. Connections still open. Continue using old version.", req->source);        
                            recompile = 0;
                        }
                    }
                }
#endif
            }
            if (recompile) {
                /* WARNING: this will allow GC */
                if (recompile && !espCompile(rx->route, conn->dispatcher, req->source, req->module, req->cacheName, 1, &errMsg)) {
                    httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, errMsg);
                    unlock(req->esp);
                    return;
                }
            }
        } else {
            mprTrace(4, "EspUpdate is disabled for this route: %s, uri %s", route->name, rx->uri);
        }
        if (mprLookupModule(req->source) == 0) {
            MprModule   *mp;
            req->entry = sfmt("esp_%s", req->cacheName);
            if ((mp = mprCreateModule(req->source, req->module, req->entry, req->route)) == 0) {
                unlock(req->esp);
                httpMemoryError(conn);
                return;
            }
            if (mprLoadModule(mp) < 0) {
                unlock(req->esp);
                httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load compiled esp module for %s", req->source);
                return;
            }
        }
        unlock(req->esp);
    }
#endif
    if ((view = mprLookupKey(esp->views, mprGetPortablePath(req->source))) == 0) {
        httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot find defined view for %s", req->view);
        return;
    }
    httpAddHeaderString(conn, "Content-Type", "text/html");
    (view)(conn);
}


/************************************ Support *********************************/

#if !BIT_STATIC
static char *getControllerEntry(cchar *appName, cchar *controllerFile)
{
    char    *cp, *entry;
    
    if (appName && *appName) {
        entry = sfmt("esp_controller_%s_%s", appName, mprTrimPathExt(mprGetPathBase(controllerFile)));
    } else {
        entry = sfmt("esp_controller_%s", mprTrimPathExt(mprGetPathBase(controllerFile)));
    }
    for (cp = entry; *cp; cp++) {
        if (!isalnum((uchar) *cp) && *cp != '_') {
            *cp = '_';
        }
    }
    return entry;
}
#endif


static int loadApp(HttpRoute *route, MprDispatcher *dispatcher)
{
    EspRoute    *eroute;
    cchar       *canonical, *source, *cacheName, *appName;

    eroute = route->eroute;
    if (!eroute->appName) {
        return 0;
    }
    appName = eroute->appName ? eroute->appName : route->host->name;

    if (eroute->flat) {
        source = mprJoinPath(eroute->cacheDir, sfmt("%s.c", eroute->appName));
        eroute->appModulePath = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, eroute->appName, BIT_SHOBJ));
        cacheName = 0;
    } else {
        source = mprJoinPath(eroute->srcDir, "app.c");
        if (!mprPathExists(source, R_OK)) {
            mprError("Cannot find %s", source);
            return 0;
        }
        canonical = mprGetPortablePath(mprGetRelPath(source, route->documents));
        cacheName = mprGetMD5WithPrefix(sfmt("%s:%s", appName, canonical), -1, "app_");
        eroute->appModulePath = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, cacheName, BIT_SHOBJ));
    }

#if !BIT_STATIC
    {
        MprModule   *mp;
        char        *errMsg, *entry;
        int         recompile;
        if (!eroute->flat && eroute->update && espModuleIsStale(source, eroute->appModulePath, &recompile)) {
            mprLog(4, "ESP application %s is newer than module %s, recompiling ...", source, eroute->appModulePath);
            /*  WARNING: GC yield here */
            if (recompile && !espCompile(route, dispatcher, source, eroute->appModulePath, cacheName, 0, &errMsg)) {
                mprError("Cannot compile %s", source);
                return MPR_ERR_CANT_INITIALIZE;
            }
        }
        if ((mp = mprLookupModule(eroute->appName)) == 0) {
            if (eroute->flat) {
                entry = sfmt("esp_app_%s_flat", eroute->appName);
            } else {
                entry = sfmt("esp_app_%s", eroute->appName);
            }
            if ((mp = mprCreateModule(eroute->appName, eroute->appModulePath, entry, route)) == 0) {
                mprError("Cannot find module %s", eroute->appModulePath);
                return MPR_ERR_CANT_FIND;
            }
            if (mprLoadModule(mp) < 0) {
                mprError("Cannot load esp module for %s", eroute->appName);
                return MPR_ERR_CANT_LOAD;
            }
        }
    }
#endif
    return 0;
}


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
    eroute->cacheDir = (char*) path;
    eroute->update = BIT_DEBUG;
    eroute->keepSource = BIT_DEBUG;
    eroute->lifespan = 0;
    eroute->serverPrefix = MPR->emptyString;
    route->eroute = eroute;
    route->flags |= HTTP_ROUTE_XSRF;
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
    eroute->appModulePath = parent->appModulePath;
    eroute->cacheDir = parent->cacheDir;
    eroute->clientDir = parent->clientDir;
    eroute->config = parent->config;
    eroute->configLoaded = parent->configLoaded;
    eroute->dbDir = parent->dbDir;
    eroute->layoutsDir = parent->layoutsDir;
    eroute->srcDir = parent->srcDir;
    eroute->controllersDir = parent->controllersDir;
    eroute->viewsDir = parent->viewsDir;
    eroute->serverPrefix = parent->serverPrefix;
    route->eroute = eroute;
    return eroute;
}


PUBLIC void espSetDirs(HttpRoute *route)
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
    eroute->layoutsDir  = mprJoinPath(dir, "layouts");
    eroute->viewsDir    = mprJoinPath(dir, "views");

    httpSetRouteVar(route, "CACHE_DIR", eroute->cacheDir);
    httpSetRouteVar(route, "CLIENT_DIR", eroute->clientDir);
    httpSetRouteVar(route, "CONTROLLERS_DIR", eroute->controllersDir);
    httpSetRouteVar(route, "DB_DIR", eroute->dbDir);
    httpSetRouteVar(route, "LAYOUTS_DIR", eroute->layoutsDir);
    httpSetRouteVar(route, "SRC_DIR", eroute->srcDir);
    httpSetRouteVar(route, "VIEWS_DIR", eroute->viewsDir);
}


/*
    Manage all links for EspReq for the garbage collector
 */
static void manageReq(EspReq *req, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(req->cacheName);
        mprMark(req->commandLine);
        mprMark(req->controllerFile);
        mprMark(req->controllerPath);
        mprMark(req->entry);
        mprMark(req->flash);
        mprMark(req->feedback);
        mprMark(req->module);
        mprMark(req->record);
        mprMark(req->route);
        mprMark(req->source);
        mprMark(req->view);
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
#if BIT_ESP_LEGACY || DEPRECATE
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


#if DEPRECATED || 1
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


#if UNUSED
static void configAction(HttpConn *conn)
{
    EspRoute    *eroute;
    MprJson     *settings;

    eroute = conn->rx->route->eroute;
    settings = mprLookupJson(eroute->config, "settings");
    httpSetContentType(conn, "application/json");
    if (settings) {
        renderString(mprJsonToString(settings, MPR_JSON_QUOTES));
    } else {
        renderError(HTTP_CODE_NOT_FOUND, "Cannot find config.settings to send to client");
    }
    finalize();
}


PUBLIC void espAddEspRoute(HttpRoute *parent)
{
    HttpRoute   *route;
    EspRoute    *eroute;
    char        *prefix;

    prefix = parent->prefix ? parent->prefix : "";
    if ((route = httpDefineRoute(parent, sfmt("%s/esp", prefix), "GET", sfmt("^%s/esp/{action}$", prefix), "esp-$1", ".")) != 0) {
        eroute = cloneEspRoute(route, parent->eroute);
        eroute->update = 0;
        espDefineAction(route, "esp-config", configAction);
    }
}
#endif


PUBLIC void espAddRouteSet(HttpRoute *route, cchar *set)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    if (!eroute->legacy) {
        httpAddRouteSet(route, eroute->serverPrefix, set);
#if DEPRECATE || 1
    } else {
        /*
            Deprecated in 4.4
         */
        if (scaselessmatch(set, "mvc")) {
            httpAddHomeRoute(route);
            httpAddClientRoute(route, "/static", "/static");

        } else if (scaselessmatch(set, "mvc-fixed")) {
            httpAddHomeRoute(route);
            httpAddClientRoute(route, "/static", "/static");
            httpDefineRoute(route, "default", NULL, "^/{controller}(~/{action}~)", "${controller}-${action}", "${controller}.c");

        } else if (scaselessmatch(set, "restful")) {
            httpAddHomeRoute(route);
            httpAddClientRoute(route, "/static", "/static");
            httpAddLegacyResourceGroup(route, "", "{controller}");

        } else if (!scaselessmatch(set, "none")) {
            mprError("Unknown route set %s", set);
        }
    }
#endif
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
    routeSet = "restful";
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
    if (smatch(prefix, "/")) {
        prefix = 0;
    }
    if (smatch(prefix, state->route->prefix) && mprSamePath(state->route->documents, dir)) {
        /* 
            Can use existing route as it has the same prefix and documents directory. 
         */
        route = state->route;
    } else {
        route = httpCreateInheritedRoute(state->route);
    }
    httpSetRouteDocuments(route, dir);
    
    if ((eroute = getEroute(route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->top = eroute;
    eroute->flat = scaselessmatch(flat, "true") || smatch(flat, "1");
    eroute->appName = sclone(name);
    httpSetRouteVar(route, "APP_NAME", name);
    if (routeSet) {
        eroute->routeSet = sclone(routeSet);
    }
    state->route = route;

    espSetDirs(route);
    /*
        Load the config.json here before creating routes. This allows config.json to override settings.
     */
    if (espLoadConfig(route) < 0) {
        return MPR_ERR_CANT_LOAD;
    }
    if (prefix == 0 || *prefix == 0) {
        prefix = espGetConfig(route, "settings.appPrefix", 0);
    }
    espSetConfig(route, "settings.appPrefix", prefix);
    espSetConfig(route, "settings.prefix", sjoin(prefix, eroute->serverPrefix, NULL));
#if DEPRECATE || 1
    if (eroute->legacy) {
        eroute->clientDir = mprJoinPath(route->documents, "static");
        httpSetRouteVar(route, "CLIENT_DIR", eroute->clientDir);
    }
#endif
    if (auth) {
        if (httpSetAuthStore(route->auth, auth) < 0) {
            mprError("The %s AuthStore is not available on this platform", auth);
            return MPR_ERR_BAD_STATE;
        }
    }
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
    httpSetRouteTarget(route, "run", "$&");
    httpAddRouteHandler(route, "espHandler", "");
    httpAddRouteHandler(route, "espHandler", "esp");
    if (!eroute->legacy) {
        httpAddRouteIndex(route, "index.esp");
    }
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

    /*
        The order of route finalization will be from the inside. Route finalization causes the route to be added
        to the enclosing host. This ensures that nested routes are defined BEFORE outer/enclosing routes.
     */
    route = state->route;
    eroute = route->eroute;
    if (eroute->routeSet) {
#if UNUSED
        espAddEspRoute(route);
#endif
        espAddRouteSet(route, eroute->routeSet);
    }
    if (route != state->prev->route) {
        httpFinalizeRoute(route);
    }
    if (!state->appweb->skipModules) {
        if (loadApp(route, NULL) < 0) {
            return MPR_ERR_CANT_LOAD;
        }
    }
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
        espSetDirs(state->route);
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
    EspRoute    *eroute;
    char        *name, *next;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (value == 0 || *value == '\0') {
        httpAddPermResource(state->route, eroute->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddPermResource(state->route, eroute->serverPrefix, name);
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
    EspRoute    *eroute;
    char        *name, *next;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (value == 0 || *value == '\0') {
        httpAddResource(state->route, eroute->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddResource(state->route, eroute->serverPrefix, name);
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
    EspRoute    *eroute;
    char        *name, *next;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (value == 0 || *value == '\0') {
        httpAddResourceGroup(state->route, eroute->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddResourceGroup(state->route, eroute->serverPrefix, name);
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
    EspRoute    *eroute;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->serverPrefix = value;
    httpSetRouteVar(state->route, "ESP_SERVER_PREFIX", eroute->serverPrefix);
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
    eroute->appName = sclone(name);
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
#if BIT_ESP_LEGACY || DEPRECATE || 1
    /* Thread-safe */
    if ((esp->internalOptions = mprCreateHash(-1, MPR_HASH_STATIC_VALUES)) == 0) {
        return 0;
    }
    espInitHtmlOptions(esp);
    //  MOB
#if BIT_PACK_ESP && BIT_ESP_LEGACY
    espInitHtmlOptions2(esp);
#endif
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
