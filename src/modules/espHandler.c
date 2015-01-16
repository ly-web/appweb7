/*
    espHandler.c -- ESP Appweb handler

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "appweb.h"
#include    "esp.h"

/************************************ Forward *********************************/

static int espDbDirective(MaState *state, cchar *key, cchar *value);
static int espEnvDirective(MaState *state, cchar *key, cchar *value);

/************************************* Code ***********************************/
/*
    <EspApp
        auth=STORE
        database=DATABASE
        home=DIR
        documents=DIR
        combine=true|false
        name=NAME
        prefix=PREFIX
        routes=ROUTES
 */
static int startEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;
    EspRoute    *eroute;
    cchar       *auth, *database, *name, *prefix, *home, *documents, *routeSet, *combine;
    char        *option, *ovalue, *tok;

    home = state->route->home;
    documents = 0;
    routeSet = 0;
    combine = 0;
    prefix = 0;
    database = 0;
    auth = 0;
    name = 0;

    if (scontains(value, "=")) {
        for (option = maGetNextArg(sclone(value), &tok); option; option = maGetNextArg(tok, &tok)) {
            option = ssplit(option, " =\t,", &ovalue);
            ovalue = strim(ovalue, "\"'", MPR_TRIM_BOTH);
            if (smatch(option, "auth")) {
                auth = ovalue;
            } else if (smatch(option, "combine")) {
                combine = ovalue;
#if DEPRECATED || 1
            } else if (smatch(option, "combined")) {
                combine = ovalue;
#endif
            } else if (smatch(option, "database")) {
                database = ovalue;
#if DEPRECATED || 1
            } else if (smatch(option, "dir")) {
                documents = home = ovalue;
#endif
            } else if (smatch(option, "documents")) {
                documents = ovalue;
            } else if (smatch(option, "home")) {
                home = ovalue;
            } else if (smatch(option, "name")) {
                name = ovalue;
            } else if (smatch(option, "prefix")) {
                prefix = ovalue;
            } else if (smatch(option, "routes")) {
                routeSet = ovalue;
            } else {
                mprLog("error esp", 0, "Unknown EspApp option \"%s\"", option);
            }
        }
    }
#if DEPRECATE || 1
    if (!documents) {
        documents = mprJoinPath(home, "documents");
        if (!mprPathExists(documents, X_OK)) {
            documents = mprJoinPath(home, "client");
            if (!mprPathExists(documents, X_OK)) {
                documents = mprJoinPath(home, "public");
                if (!mprPathExists(documents, X_OK)) {
                    documents = home;
                }
            }
        }
    }
#endif
    state->route = route = httpCreateInheritedRoute(state->route);
    route->flags |= HTTP_ROUTE_HOSTED;

    if (auth) {
        if (httpSetAuthStore(route->auth, auth) < 0) {
            mprLog("error esp", 0, "The %s AuthStore is not available on this platform", auth);
            return MPR_ERR_BAD_STATE;
        }
    }
    if (combine) {
        if ((eroute = espRoute(state->route)) == 0) {
            return MPR_ERR_MEMORY;
        }
        eroute->combine = scaselessmatch(combine, "true") || smatch(combine, "1");
    }
    if (database) {
        if (espDbDirective(state, key, database) < 0) {
            return MPR_ERR_BAD_STATE;
        }
    }
    route->flags |= HTTP_ROUTE_HOSTED;
    if (espDefineApp(route, name, prefix, home, documents, routeSet) < 0) {
        return MPR_ERR_CANT_CREATE;
    }
    if (prefix) {
        espSetConfig(route, "esp.appPrefix", prefix);
    }
    return 0;
}


static int finishEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;

    /*
        The order of route finalization will be from the inside. Route finalization causes the route to be added
        to the enclosing host. This ensures that nested routes are defined BEFORE outer/enclosing routes.
     */
    route = state->route;

    if (espConfigureApp(route) < 0) {
        return MPR_ERR_CANT_LOAD;
    }
    if (route != state->prev->route) {
        httpFinalizeRoute(route);
    }
    if (espLoadApp(route) < 0) {
        return MPR_ERR_CANT_LOAD;
    }
    return 0;
}


/*
    <EspApp>
 */
static int openEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    state = maPushState(state);
    return startEspAppDirective(state, key, value);
}


/*
    </EspApp>
 */
static int closeEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    if (finishEspAppDirective(state, key, value) < 0) {
        return MPR_ERR_BAD_STATE;
    }
    maPopState(state);
    return 0;
}


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


#if DEPRECATED || 1
/*
    EspCompile template
 */
static int espCompileDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = espRoute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->compile = sclone(value);
    return 0;
}
#endif


/*
    EspDb provider://database
 */
static int espDbDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = espRoute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (espOpenDatabase(state->route, value) < 0) {
        if (!(state->flags & MA_PARSE_NON_SERVER)) {
            mprLog("error esp", 0, "Cannot open database '%s'. Use: provider://database", value);
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

    if ((eroute = espRoute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%S ?S", &name, &path)) {
        return MPR_ERR_BAD_SYNTAX;
    }
#if DEPRECATED || 1
    if (smatch(name, "mvc")) {
        espSetDefaultDirs(state->route);
    } else
#endif
    {
        path = stemplate(path, state->route->vars);
        path = stemplate(mprJoinPath(state->route->home, path), state->route->vars);
        httpSetDir(state->route, name, path);
    }
    return 0;
}


#if DEPRECATED || 1
/*
    Define Visual Studio environment if not already present
 */
static void defineVisualStudioEnv(MaState *state)
{
    Http    *http;
    int     is64BitSystem;

    http = MPR->httpService;
    if (scontains(getenv("LIB"), "Visual Studio") &&
        scontains(getenv("INCLUDE"), "Visual Studio") &&
        scontains(getenv("PATH"), "Visual Studio")) {
        return;
    }
    if (scontains(http->platform, "-x64-")) {
        is64BitSystem = smatch(getenv("PROCESSOR_ARCHITECTURE"), "AMD64") || getenv("PROCESSOR_ARCHITEW6432");
        espEnvDirective(state, "EspEnv",
            "LIB \"${WINSDK}\\LIB\\${WINVER}\\um\\x64;${WINSDK}\\LIB\\x64;${VS}\\VC\\lib\\amd64\"");
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

    } else if (scontains(http->platform, "-arm-")) {
        /* Cross building on x86 for arm. No winsdk 7 support for arm */
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\${WINVER}\\um\\arm;${VS}\\VC\\lib\\arm\"");
        espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_arm;${VS}\\Common7\\Tools;"
            "${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\arm\"");

    } else {
        /* Building for X86 */
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\${WINVER}\\um\\x86;${WINSDK}\\LIB\\x86;"
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

    if ((eroute = espRoute(state->route)) == 0) {
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
#endif


/*
    EspKeepSource on|off
 */
static int espKeepSourceDirective(MaState *state, cchar *key, cchar *value)
{
    bool        on;

    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    state->route->keepSource = on;
    return 0;
}


#if DEPRECATED || 1
/*
    EspLink template
 */
static int espLinkDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = espRoute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->link = sclone(value);
    return 0;
}
#endif


/*
    EspPermResource [resource ...]
 */
static int espPermResourceDirective(MaState *state, cchar *key, cchar *value)
{
    char        *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddPermResource(state->route, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddPermResource(state->route, name);
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
    char        *name, *next;

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
    EspRoute
        methods=METHODS
        pattern=PATTERN
        source=SOURCE
        target=TARGET
 */
static int espRouteDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    HttpRoute   *route;
    cchar       *methods, *name, *pattern, *source, *target;
    char        *option, *ovalue, *tok;

    pattern = 0;
    name = 0;
    source = 0;
    target = 0;
    methods = "GET";

    if (scontains(value, "=")) {
        for (option = maGetNextArg(sclone(value), &tok); option; option = maGetNextArg(tok, &tok)) {
            option = ssplit(option, "=,", &ovalue);
            ovalue = strim(ovalue, "\"'", MPR_TRIM_BOTH);
            if (smatch(option, "methods")) {
                methods = ovalue;
            } else if (smatch(option, "name")) {
                name = ovalue;
            } else if (smatch(option, "pattern") || smatch(option, "prefix")) {
                /* DEPRECATED prefix */
                pattern = ovalue;
            } else if (smatch(option, "source")) {
                source = ovalue;
            } else if (smatch(option, "target")) {
                target = ovalue;
            } else {
                mprLog("error esp", 0, "Unknown EspRoute option \"%s\"", option);
            }
        }
    }
    if (!pattern || !target) {
        return MPR_ERR_BAD_SYNTAX;
    }
    if (target == 0 || *target == 0) {
        target = "$&";
    }
    target = stemplate(target, state->route->vars);
    if ((route = httpDefineRoute(state->route, methods, pattern, target, source)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    httpSetRouteHandler(route, "espHandler");
    if ((eroute = espRoute(route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (name) {
        eroute->appName = sclone(name);
    }
    return 0;
}


/*
    EspRouteSet kind
 */
static int espRouteSetDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    char        *kind;

    if ((eroute = espRoute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%S", &kind)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    httpAddRouteSet(state->route, kind);
    return 0;
}


/*
    EspUpdate on|off
 */
static int espUpdateDirective(MaState *state, cchar *key, cchar *value)
{
    bool        on;

    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    state->route->update = on;
    return 0;
}

/************************************ Init ************************************/
/*
    Loadable module configuration
 */
PUBLIC int httpEspInit(Http *http, MprModule *module)
{
    if (espOpen(module) < 0) {
        return MPR_ERR_CANT_CREATE;
    }
    /*
        Add appweb configuration file directives
     */
    maAddDirective("EspApp", espAppDirective);
    maAddDirective("<EspApp", openEspAppDirective);
    maAddDirective("</EspApp", closeEspAppDirective);
    maAddDirective("EspDb", espDbDirective);
    maAddDirective("EspDir", espDirDirective);
    maAddDirective("EspKeepSource", espKeepSourceDirective);
    maAddDirective("EspPermResource", espPermResourceDirective);
    maAddDirective("EspResource", espResourceDirective);
    maAddDirective("EspResourceGroup", espResourceGroupDirective);
    maAddDirective("EspRoute", espRouteDirective);
    maAddDirective("EspRouteSet", espRouteSetDirective);
    maAddDirective("EspUpdate", espUpdateDirective);

#if DEPRECATE || 1
{
    cchar   *path;

    maAddDirective("EspCompile", espCompileDirective);
    maAddDirective("EspLink", espLinkDirective);
    maAddDirective("EspEnv", espEnvDirective);

    /*
        Load the esp.conf directives to compile esp
     */
    path = mprJoinPath(mprGetAppDir(), "esp.conf");
    if (mprPathExists(path, R_OK) && (http->platformDir || httpSetPlatformDir(0) == 0)) {
        if (maParseFile(NULL, mprJoinPath(mprGetAppDir(), "esp.conf")) < 0) {
            mprLog("error esp", 0, "Cannot parse %s", path);
            return MPR_ERR_CANT_OPEN;
        }
    }
}
#endif
    return 0;
}

/*
    @copy   default

    Copyright (c) Embedthis Software. All Rights Reserved.

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
