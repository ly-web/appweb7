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
static int loadApp(EspRoute *eroute);
static void manageEsp(Esp *esp, int flags);
static void manageReq(EspReq *req, int flags);
static int runAction(HttpConn *conn);
static int unloadEsp(MprModule *mp);
static bool viewExists(HttpConn *conn);

#if !BIT_STATIC
static char *getServiceEntry(cchar *serviceName);
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

    if (rx->flags & (HTTP_OPTIONS | HTTP_TRACE)) {
        /*
            ESP accepts all methods if there is a registered route. However, we only advertise the standard methods.
         */
        httpHandleOptionsTrace(q->conn, "DELETE,GET,HEAD,POST,PUT");
    } else {
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
            //  MOB - should be saved for future similar requests (locking too)
            eroute = allocEspRoute(route);
            return;
        }
        conn->data = req;
        req->esp = esp;
        req->route = route;
        req->eroute = eroute;
        req->autoFinalize = 1;
    }
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
            httpSetSessionVar(conn, ESP_FLASH_VAR, "");
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
    }
}


static int runAction(HttpConn *conn)
{
    HttpRx      *rx;
    HttpRoute   *route;
    EspRoute    *eroute;
    EspReq      *req;
    EspAction   action;
    char        *key, *canonical, *serviceName, *actionName;

    rx = conn->rx;
    req = conn->data;
    route = rx->route;
    eroute = req->eroute;
    assert(eroute);

    if (route->sourceName == 0 || *route->sourceName == '\0') {
        if (eroute->commonService) {
            (eroute->commonService)(conn);
        }
        return 1;
    }
    /*
        Expand any form var $tokens. This permits ${service} and user form data to be used in the service name
     */
    if (schr(route->sourceName, '$')) {
        req->serviceName = stemplate(route->sourceName, rx->params);
    } else {
        req->serviceName = route->sourceName;
    }
    if (eroute->servicesDir) {
        req->servicePath = mprJoinPath(eroute->servicesDir, req->serviceName);
    } else {
        req->servicePath = mprJoinPath(route->dir, req->serviceName);
    }
    key = mprJoinPath(eroute->servicesDir, rx->target);

    if (loadApp(eroute) < 0) {
        httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load esp module for %s", eroute->appName);
        return 0;
    }
#if !BIT_STATIC
    if (!eroute->flat && (eroute->update || !mprLookupKey(esp->actions, key))) {
        char    *source;
        int     recompile = 0;

        /* Trim the drive for VxWorks where simulated host drives only exist on the target */
        source = req->servicePath;
#if VXWORKS
        source = mprTrimPathDrive(source);
#endif
        canonical = mprGetPortablePath(mprGetRelPath(source, route->dir));
        req->cacheName = mprGetMD5WithPrefix(canonical, slen(canonical), "service_");
        req->module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, req->cacheName, BIT_SHOBJ));

        if (!mprPathExists(req->servicePath, R_OK)) {
            mprError("Cannot find service %s", req->servicePath);
            httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot find service to serve request");
            return 0;
        }
        lock(req->esp);
        if (eroute->update) {
            /*
                Test if the source has been updated. This will unload prior modules if stale
             */ 
            if (espModuleIsStale(req->servicePath, req->module, &recompile)) {
                /*  WARNING: GC yield here */
                if (recompile && !espCompile(conn, req->servicePath, req->module, req->cacheName, 0)) {
                    unlock(req->esp);
                    return 0;
                }
            }
        }
        if (mprLookupModule(req->servicePath) == 0) {
            MprModule   *mp;
            req->entry = getServiceEntry(req->serviceName);
            if ((mp = mprCreateModule(req->servicePath, req->module, req->entry, route)) == 0) {
                unlock(req->esp);
                httpMemoryError(conn);
                return 0;
            }
            if (mprLoadModule(mp) < 0) {
                unlock(req->esp);
                httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load compiled esp module for %s", req->servicePath);
                return 0;
            }
        }
        unlock(req->esp);
#endif
    }
    key = mprJoinPath(eroute->servicesDir, rx->target);
    if ((action = mprLookupKey(esp->actions, key)) == 0) {
        req->servicePath = mprJoinPath(eroute->servicesDir, req->serviceName);
        key = sfmt("%s/missing", mprGetPathDir(req->servicePath));
        if ((action = mprLookupKey(esp->actions, key)) == 0) {
            if (!viewExists(conn) && (action = mprLookupKey(esp->actions, "missing")) == 0) {
                httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Missing action for %s in %s", rx->target, 
                        req->servicePath);
                return 0;
            }
        }
    }
    if (rx->flags & HTTP_POST && !espCheckSecurityToken(conn)) {
        return 0;
    }
    if (action) {
        serviceName = stok(sclone(rx->target), "-", &actionName);
        httpSetParam(conn, "service", serviceName);
#if DEPRECATE || 1
        /*
            Deprecated in 4.4
         */
        httpSetParam(conn, "controller", serviceName);
#endif
        httpSetParam(conn, "action", actionName);
        if (eroute->commonService) {
            (eroute->commonService)(conn);
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
    EspRoute    *eroute;
    EspReq      *req;
    EspViewProc view;
    char        *canonical;
    
    rx = conn->rx;
    req = conn->data;
    eroute = req->eroute;
    
    if (name && *name) {
        req->view = mprJoinPath(eroute->viewsDir, name);
        req->source = mprJoinPathExt(req->view, ".esp");

    } else if (req->serviceName) {
        req->view = mprJoinPath(eroute->viewsDir, rx->target);
        req->source = mprJoinPathExt(req->view, ".esp");

    } else {
        httpMapFile(conn, rx->route);
        req->view = conn->tx->filename;
        req->source = req->view;
    }
    if (loadApp(eroute) < 0) {
        httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load esp module for %s", eroute->appName);
        return;
    }
#if !BIT_STATIC
    if (!eroute->flat && (eroute->update || !mprLookupKey(esp->views, mprGetPortablePath(req->source)))) {
        cchar   *source;
        int     recompile = 0;
        /* Trim the drive for VxWorks where simulated host drives only exist on the target */
        source = req->source;
#if VXWORKS
        source = mprTrimPathDrive(source);
#endif
        canonical = mprGetPortablePath(mprGetRelPath(source, req->route->dir));
        req->cacheName = mprGetMD5WithPrefix(canonical, slen(canonical), "view_");
        req->module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, req->cacheName, BIT_SHOBJ));

        if (!mprPathExists(req->source, R_OK)) {
            mprLog(3, "Cannot find web page %s", req->source);
            httpError(conn, HTTP_CODE_NOT_FOUND, "Cannot find web page for %s", rx->uri);
            return;
        }
        lock(req->esp);
        if (eroute->update) {
            espModuleIsStale(req->source, req->module, &recompile);
#if BIT_DEBUG
            /*
                Check if the layout has changed. Only do this if debug as we don't want to slow production versions.
             */
            if (!recompile) {
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
                        if (mprLookupModule(req->source) != 0 && !espUnloadModule(req->source, 0)) {
                            mprError("Cannot unload module %s. Connections still open. Continue using old version.", req->source);        
                            recompile = 0;
                        }
                    }
                }
            }
#endif
            if (recompile) {
                /* WARNING: this will allow GC */
                if (recompile && !espCompile(conn, req->source, req->module, req->cacheName, 1)) {
                    unlock(req->esp);
                    return;
                }
            }
        }
        if (mprLookupModule(req->source) == 0) {
            MprModule   *mp;
            req->entry = sfmt("esp_%s", req->cacheName);
            if ((mp = mprCreateModule(req->source, req->module, req->entry, req->route)) == 0) {
                unlock(req->esp);
                httpMemoryError(conn);
                return;
            }
            mprSetThreadData(esp->local, conn);
            if (mprLoadModule(mp) < 0) {
                unlock(req->esp);
                httpError(conn, HTTP_CODE_INTERNAL_SERVER_ERROR, "Cannot load compiled esp module for %s", req->source);
                return;
            }
        }
        unlock(req->esp);
#endif
    }
    if ((view = mprLookupKey(esp->views, mprGetPortablePath(req->source))) == 0) {
        httpError(conn, HTTP_CODE_NOT_FOUND, "Cannot find defined view for %s", req->view);
        return;
    }
    httpAddHeaderString(conn, "Content-Type", "text/html");
    mprSetThreadData(esp->local, conn);
    (view)(conn);
}


/************************************ Support *********************************/

#if !BIT_STATIC
static char *getServiceEntry(cchar *serviceName)
{
    char    *cp, *entry;

    entry = sfmt("esp_module_%s", mprTrimPathExt(mprGetPathBase(serviceName)));
    for (cp = entry; *cp; cp++) {
        if (!isalnum((uchar) *cp) && *cp != '_') {
            *cp = '_';
        }
    }
    return entry;
}
#endif


#if FUTURE && KEEP
static bool getConfig(EspRoute *eroute, cchar *key, cchar *defaultValue)
{
    cchar   *value;

    if ((value = mprQueryJsonString(eroute->config, key)) != 0) {
        return value;
    }
    return defaultValue;
}


static bool testConfig(EspRoute *eroute, cchar *key, cchar *desired)
{
    cchar   *value;

    if ((value = mprQueryJsonString(eroute->config, key)) != 0) {
        return smatch(value, desired);
    }
    return 0;
}
#endif


static int loadApp(EspRoute *eroute)
{
    MprModule   *mp;
    MprHash     *settings, *msettings;
    MprKey      *kp;
    cchar       *canonical, *config, *source, *cacheName, *entry, *value;

    if (!eroute->appName) {
        return 0;
    }
    source = mprJoinPath(eroute->srcDir, "app.c");
    canonical = mprGetPortablePath(mprGetRelPath(source, eroute->route->dir));
    cacheName = mprGetMD5WithPrefix(canonical, slen(canonical), "app_");
    eroute->appModulePath = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, cacheName, BIT_SHOBJ));

    if (mprPathExists(eroute->appModulePath, R_OK)) {
        if ((mp = mprLookupModule(eroute->appName)) != 0) {
    #if !BIT_STATIC
            if (eroute->update) {
                MprPath minfo;
                mprGetPathInfo(mp->path, &minfo);
                if (minfo.valid && mp->modified < minfo.mtime) {
                    //  MOB - but should only do if nobody running
                    if (!espUnloadModule(eroute->appName, 0)) {
                        mprError("Cannot unload module %s. Connections still open. Continue using old version.",  
                            eroute->appName);
                        /* Cannot unload - so keep using old module */
                        return 0;
                    }
                    mp = 0;
                }
            }
    #endif
        }
        if (!mp) {
            entry = sfmt("esp_app_%s", eroute->appName);
            if ((mp = mprCreateModule(eroute->appName, eroute->appModulePath, entry, eroute->route)) == 0) {
                mprError("Cannot find module %s", eroute->appModulePath);
                return MPR_ERR_CANT_FIND;
            }
            if (mprLoadModule(mp) < 0) {
                mprError("Cannot load esp module for %s", eroute->appName);
                return MPR_ERR_CANT_LOAD;
            }
            if (eroute->route->flags & HTTP_ROUTE_ANGULAR) {
                if ((config = mprReadPathContents(mprJoinPath(eroute->clientDir, "config.json"), NULL)) != 0) {
                    eroute->config = mprDeserialize(config);
                    /*
                        Blend the mode properties into settings
                     */
                    if ((settings = mprQueryJsonValue(eroute->config, "settings", MPR_JSON_OBJ)) != 0) {
                        eroute->mode = mprQueryJsonString(eroute->config, "mode");
                        if ((msettings = mprQueryJsonValue(eroute->config, sfmt("modes.%s", eroute->mode), MPR_JSON_OBJ)) != 0) {
                            for (ITERATE_KEYS(msettings, kp)) {
                                mprAddKeyWithType(settings, kp->key, kp->data, kp->type);
                            }
                        }
                    }
                    if ((value = mprQueryJsonString(eroute->config, "settings.showErrors")) != 0) {
                        eroute->showErrors = smatch(value, "true");
                    }
                    if ((value = mprQueryJsonString(eroute->config, "settings.update")) != 0) {
                        eroute->update = smatch(value, "true");
                    }
                    if ((value = mprQueryJsonString(eroute->config, "settings.keepSource")) != 0) {
                        eroute->keepSource = smatch(value, "true");
                    }
                    if ((value = mprQueryJsonString(eroute->config, "settings.autoLogin")) != 0) {
                        eroute->autoLogin = smatch(value, "true");
                    }
                    if ((value = mprQueryJsonString(eroute->config, "settings.map")) != 0) {
                        if (smatch(value, "compressed")) {
                            httpAddRouteMapping(eroute->route, "js,css,less", "min.${1}.gz, min.${1}, ${1}.gz");
                            httpAddRouteMapping(eroute->route, "html,xml", "${1}.gz");
                        }
                        // httpAddRouteMapping(state->route, extensions, mappings);
                    }
                }
            }
        }
    }
    return 0;
}


/*
    Test if the the required view exists
 */
static bool viewExists(HttpConn *conn)
{
    HttpRx      *rx;
    EspRoute    *eroute;
    EspReq      *req;
    cchar       *source;
    
    rx = conn->rx;
    req = conn->data;
    eroute = req->eroute;
    
    source = mprJoinPathExt(mprJoinPath(eroute->viewsDir, rx->target), ".esp");
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
#if DEBUG_IDE
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
    eroute->showErrors = BIT_DEBUG;
    eroute->keepSource = BIT_DEBUG;
    eroute->lifespan = 0;
    eroute->route = route;
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
    eroute->commonService = parent->commonService;
    eroute->update = parent->update;
    eroute->keepSource = parent->keepSource;
    eroute->showErrors = parent->showErrors;
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
    eroute->dbDir = parent->dbDir;
    eroute->route = route;
    eroute->srcDir = parent->srcDir;
    eroute->servicesDir = parent->servicesDir;
#if DEPRECATED || 1
    eroute->layoutsDir = parent->layoutsDir;
    eroute->viewsDir = parent->viewsDir;
#endif
    route->eroute = eroute;
#if UNUSED
    eroute->modelsDir = parent->modelsDir;
    eroute->controllersDir = parent->controllersDir;
    eroute->templatesDir = parent->templatesDir;
    eroute->migrationsDir = parent->migrationsDir;
#endif
    return eroute;
}


PUBLIC void espSetMvcDirs(EspRoute *eroute)
{
    HttpRoute   *route;
    char        *dir;

    route = eroute->route;
    dir = eroute->route->dir;

    eroute->dbDir = mprJoinPath(dir, "db");
    eroute->cacheDir = mprJoinPath(dir, "cache");

    if (route->flags & HTTP_ROUTE_ANGULAR) {
        eroute->clientDir = mprJoinPath(dir, "client");
        eroute->servicesDir = mprJoinPath(dir, "services");
        eroute->srcDir = mprJoinPath(eroute->servicesDir, "src");
        eroute->appDir = mprJoinPath(eroute->clientDir, "app");
#if UNUSED
        eroute->templatesDir = mprJoinPath(eroute->clientDir, "templates");
        eroute->modelsDir = mprJoinPath(eroute->clientDir, "models");
        eroute->migrationsDir = mprJoinPath(eroute->dbDir, "migrations");
        eroute->controllersDir = mprJoinPath(eroute->clientDir, "controllers");
        eroute->viewsDir = mprJoinPath(eroute->servicesDir, "views");
        eroute->layoutsDir = mprJoinPath(eroute->viewsDir, "layouts");
#endif

#if DEPRECATED || 1
    /*
        Deprecated in 4.4
     */
    } else {
        eroute->clientDir = mprJoinPath(dir, "static");
        eroute->layoutsDir = mprJoinPath(dir, "layouts");
#if UNUSED
        eroute->migrationsDir = mprJoinPath(eroute->dbDir, "migrations");
#endif
        eroute->servicesDir = mprJoinPath(dir, "controllers");
        eroute->srcDir = mprJoinPath(dir, "src");
        eroute->viewsDir = mprJoinPath(dir, "views");
#endif
    }
    httpSetRouteVar(route, "CACHE_DIR", eroute->cacheDir);
    httpSetRouteVar(route, "CLIENT_DIR", eroute->clientDir);
    httpSetRouteVar(route, "DB_DIR", eroute->dbDir);
    httpSetRouteVar(route, "LAYOUTS_DIR", eroute->layoutsDir);
    httpSetRouteVar(route, "SERVICES_DIR", eroute->servicesDir);
#if DEPRECATED || 1
    httpSetRouteVar(route, "CONTROLLERS_DIR", eroute->servicesDir);
#endif
    httpSetRouteVar(route, "SRC_DIR", eroute->srcDir);
    httpSetRouteVar(route, "VIEWS_DIR", eroute->viewsDir);
#if UNUSED
    httpSetRouteVar(route, "MIGRATIONS_DIR", eroute->migrationsDir);
    httpSetRouteVar(route, "MODELS_DIR", eroute->modelsDir);
#endif
}


/*
    Manage all links for EspReq for the garbage collector
 */
static void manageReq(EspReq *req, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(req->cacheName);
        mprMark(req->commandLine);
        mprMark(req->serviceName);
        mprMark(req->servicePath);
        mprMark(req->entry);
        mprMark(req->eroute);
        mprMark(req->flash);
        mprMark(req->module);
        mprMark(req->record);
        mprMark(req->route);
        mprMark(req->source);
        mprMark(req->view);
    }
}


/*
    Manage all links for Esp for the garbage collector
 */
static void manageEsp(Esp *esp, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(esp->actions);
        mprMark(esp->ediService);
        mprMark(esp->internalOptions);
        mprMark(esp->local);
        mprMark(esp->mutex);
        mprMark(esp->views);
    }
}


/*
    Get an EspRoute structure for a given route. Allocate or clone if required. It is expected that the caller will
    modify the EspRoute.
 */
static EspRoute *getEroute(HttpRoute *route)
{
    HttpRoute   *rp;

    if (route->eroute && ((EspRoute*) route->eroute)->route == route) {
        return route->eroute;
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

/*********************************** Directives *******************************/
/*
    EspApp name=NAME prefix=PREFIX dir=DIR routes=ROUTES database=DATABASE flat=true|false
    DEPRECATED in 4.4: EspApp Prefix [Dir [RouteSet [Database]]]
 */
static int espAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;
    EspRoute    *eroute;
    char        *name, *option, *ovalue, *prefix, *dir, *routeSet, *database, *tok, *flat;

    dir = ".";
    routeSet = "restful";
    flat = "false";
    prefix = "/";
    database = 0;

    if (scontains(value, "=")) {
        for (option = maGetNextToken(sclone(value), &tok); option; option = maGetNextToken(tok, &tok)) {
            option = stok(option, " =\t,", &ovalue);
            ovalue = strim(ovalue, "\"'", MPR_TRIM_BOTH);
            if (smatch(option, "name")) {
                name = ovalue;
            } else if (smatch(option, "prefix")) {
                prefix = ovalue;
            } else if (smatch(option, "dir")) {
                dir = ovalue;
            } else if (smatch(option, "routes")) {
                routeSet = ovalue;
            } else if (smatch(option, "database")) {
                database = ovalue;
            } else if (smatch(option, "flat")) {
                flat = ovalue;
            } else {
                mprError("Unknown EspApp option %s", option);
            }
        }

    } else {
        //  DEPRECATED SYNTAX
        if (!maTokenize(state, value, "%S ?S ?S ?S", &prefix, &dir, &routeSet, &database)) {
            return MPR_ERR_BAD_SYNTAX;
        }
        name = "app";
    }
    if (smatch(prefix, "/")) {
        prefix = 0;
    }
    /*
        Always create an application route so all resources can inherit (share) handler definitions
     */
    route = httpCreateInheritedRoute(state->route);
    httpSetRouteName(route, name);
    if ((eroute = getEroute(route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->top = eroute;
    eroute->flat = scaselessmatch(flat, "true") || smatch(flat, "1");
    eroute->appName = sclone(name);

    state = maPushState(state);
    state->route = route;

    if (prefix) {
        if (*prefix != '/') {
            mprError("Prefix name should start with a \"/\"");
            prefix = sjoin("/", prefix, NULL);
        }
        prefix = stemplate(prefix, route->vars);
    }
    if (prefix) {
        httpSetRouteName(route, prefix);
        httpSetRoutePrefix(route, prefix);
    }
    httpSetRouteDir(route, dir);
    httpSetRouteTarget(route, "run", "unused");
    httpAddRouteHandler(route, "espHandler", "");
    httpAddRouteHandler(route, "espHandler", "esp");

    if (routeSet) {
        if (smatch(routeSet, "angular")) {
            route->flags |= HTTP_ROUTE_ANGULAR;
        }
        //  MOB - RATIONALIZE
        if (smatch(routeSet, "mvc") || smatch(routeSet, "mvc-fixed") || smatch(routeSet, "restful") || smatch(routeSet, "angular")) {
            espSetMvcDirs(eroute);
        }
        httpAddRouteSet(state->route, routeSet);
    }
    if (database && espDbDirective(state, key, database) < 0) {
        maPopState(state);
        return MPR_ERR_BAD_STATE;
    }
    httpFinalizeRoute(route);
    maPopState(state);

    if (!state->appweb->skipModules && loadApp(eroute) < 0) {
        return MPR_ERR_CANT_LOAD;
    }
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


/*
    EspDb provider://database
 */
static int espDbDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    char        *provider, *path;
    int         flags;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    //  MOB - is auto save really wanted?
    flags = EDI_CREATE | EDI_AUTO_SAVE;
    provider = stok(sclone(value), "://", &path);
    if (provider == 0 || path == 0) {
        mprError("Bad database spec '%s'. Use: provider://database", value);
        return MPR_ERR_CANT_OPEN;
    }
    path = mprJoinPath(eroute->dbDir, path);
    if ((eroute->edi = ediOpen(mprGetRelPath(path, NULL), provider, flags)) == 0) {
        if (!(state->flags & MA_PARSE_NON_SERVER)) {
            mprError("Cannot open database %s", path);
            return MPR_ERR_CANT_OPEN;
        }
    }
    //  MOB - who closes?
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
        espSetMvcDirs(eroute);
    } else {
        path = stemplate(mprJoinPath(state->route->home, path), state->route->vars);
        if (smatch(name, "cache")) {
            eroute->cacheDir = path;
        } else if (smatch(name, "client")) {
            eroute->clientDir = path;
        } else if (smatch(name, "db")) {
            eroute->dbDir = path;
#if UNUSED
        } else if (smatch(name, "migrations")) {
            eroute->migrationsDir = path;
        } else if (smatch(name, "models")) {
            eroute->modelsDir = path;
        } else if (smatch(name, "templates")) {
            eroute->templatesDir = path;
#endif
        } else if (smatch(name, "src")) {
            eroute->srcDir = path;
        } else if (smatch(name, "services")) {
            eroute->servicesDir = path;
#if DEPRECATED || 1
        } else if (smatch(name, "views")) {
            eroute->viewsDir = path;
        } else if (smatch(name, "layouts")) {
            eroute->layoutsDir = path;
        } else if (smatch(name, "controllers")) {
            eroute->servicesDir = path;
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
            espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\amd64;${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\x64\"");

        } else {
            /* Cross building on x86 for 64-bit */
            espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_amd64;${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\x86\"");
        }

    } else if (scontains(appweb->platform, "-arm-")) {
        /* Cross building on x86 for arm. No winsdk 7 support for arm */
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\win8\\um\\arm;${VS}\\VC\\lib\\arm\"");
        espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_arm;${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\arm\"");

    } else {
        /* Building for X86 */
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\win8\\um\\x86;${WINSDK}\\LIB\\x86;${WINSDK}\\LIB;${VS}\\VC\\lib\"");
        espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin;${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\"");
    }
    espEnvDirective(state, "EspEnv", "INCLUDE \"${VS}\\VC\\INCLUDE;${WINSDK}\\include;${WINSDK}\\include\\um;${WINSDK}\\include\\shared\"");
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
        eroute->env = mprCreateHash(-1, 0);
    }
    evalue = espExpandCommand(eroute, evalue, "", "");
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
    MOB - appname is not used
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
    EspResource [resource ...]
 */
static int espResourceDirective(MaState *state, cchar *key, cchar *value)
{
    char    *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddResource(state->route, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddResource(state->route, name);
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
    char    *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddResourceGroup(state->route, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddResourceGroup(state->route, name);
            name = stok(NULL, ", \t\r\n", &next);
        }
    }
    return 0;
}


/*
    EspRoute name methods pattern target source
 */
static int espRouteDirective(MaState *state, cchar *key, cchar *value)
{
    char    *name, *methods, *pattern, *target, *source;

    if (!maTokenize(state, value, "%S %S %S %S ?S", &name, &methods, &pattern, &target, &source)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    target = stemplate(target, state->route->vars);
    httpDefineRoute(state->route, name, methods, pattern, target, source);
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
    httpAddRouteSet(state->route, kind);
    return 0;
}


/*
    EspShowErrors on|off
 */
static int espShowErrorsDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    bool        on;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    eroute->showErrors = on;
    return 0;
}


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
    if ((esp->internalOptions = mprCreateHash(-1, MPR_HASH_STATIC_VALUES)) == 0) {
        return 0;
    }
    espInitHtmlOptions(esp);

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
    maAddDirective(appweb, "EspCompile", espCompileDirective);
    maAddDirective(appweb, "EspDb", espDbDirective);
    maAddDirective(appweb, "EspDir", espDirDirective);
    maAddDirective(appweb, "EspEnv", espEnvDirective);
    maAddDirective(appweb, "EspKeepSource", espKeepSourceDirective);
    maAddDirective(appweb, "EspLink", espLinkDirective);
    maAddDirective(appweb, "EspResource", espResourceDirective);
    maAddDirective(appweb, "EspResourceGroup", espResourceGroupDirective);
    maAddDirective(appweb, "EspRoute", espRouteDirective);
    maAddDirective(appweb, "EspRouteSet", espRouteSetDirective);
    maAddDirective(appweb, "EspShowErrors", espShowErrorsDirective);
    maAddDirective(appweb, "EspUpdate", espUpdateDirective);

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
