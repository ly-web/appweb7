/**
    esp.c -- Embedded Server Pages (ESP) utility program

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************* Includes ***********************************/

#include    "esp.h"

#if BIT_PACK_ESP
/********************************** Locals ************************************/
/*
    Global application object. Provides the top level roots of all data objects for the GC.
 */
typedef struct App {
    Mpr         *mpr;
    MaAppweb    *appweb;
    MaServer    *server;

    cchar       *appName;               /* Application name */
    cchar       *serverRoot;            /* Root directory for server config */
    cchar       *configFile;            /* Arg to --config */
    cchar       *currentDir;            /* Initial starting current directory */
    cchar       *database;              /* Database provider "mdb" | "sdb" */
    cchar       *flatPath;              /* Output filename for flat compilations */

    cchar       *binDir;                /* Appweb bin directory */
    cchar       *espDir;                /* ESP prototype directory */
    cchar       *componentsDir;         /* ESP generated components directory */
    cchar       *templatesDir;          /* ESP templates directory */
    cchar       *listen;                /* Listen endpoint for "esp run" */
    cchar       *platform;              /* Target platform os-arch-profile (lower) */
    cchar       *topComponent;          /* Top level component */
    MprFile     *flatFile;              /* Output file for flat compilations */
    MprList     *flatItems;             /* Items to invoke from Init */

    MprList     *routes;                /* Routes to process */
    EspRoute    *eroute;                /* Selected ESP route to build */
    HttpRoute   *route;                 /* Selected route to build */
    MprList     *files;                 /* List of files to process */
    MprList     *build;                 /* Items to build */
    MprList     *slink;                 /* List of items for static link */
    MprHash     *targets;               /* Command line targets */
    EdiGrid     *migrations;            /* Migrations table */

    cchar       *command;               /* Compilation or link command */
    cchar       *cacheName;             /* MD5 name of cached component */
    cchar       *csource;               /* Name of "C" source for page or controller */
    cchar       *genlink;               /* Static link resolution file */
    cchar       *routeName;             /* Name of route to use for ESP configuration */
    cchar       *routePrefix;           /* Route prefix to use for ESP configuration */
    cchar       *routeSet;              /* Desired route set package */
    cchar       *module;                /* Compiled module name */
    cchar       *base;                  /* Base filename */
    cchar       *entry;                 /* Module entry point */
    cchar       *serverPrefix;          /* Prefix to talk to the server */

    int         error;                  /* Any processing error */
    int         flat;                   /* Combine all inputs into one, flat output */ 
    int         keep;                   /* Keep source */ 
    int         overwrite;              /* Overwrite existing files if required */
    int         quiet;                  /* Don't trace progress */
    int         rebuild;                /* Force a rebuild */
    int         reverse;                /* Reverse migrations */
    int         show;                   /* Show compilation commands */
    int         staticLink;             /* Use static linking */
    int         verbose;                /* Verbose mode */
    int         why;                    /* Why rebuild */
} App;

static App       *app;                  /* Top level application object */
static Esp       *esp;                  /* ESP control object */
static Http      *http;                 /* HTTP service object */
static MaAppweb  *appweb;               /* Appweb service object */
static int       nextMigration;         /* Sequence number for next migration */

/*
    CompileFile flags
 */
#define ESP_CONTROlLER  0x1             /* Compile a controller */
#define ESP_VIEW        0x2             /* Compile a view */
#define ESP_PAGE        0x4             /* Compile a stand-alone ESP page */
#define ESP_MIGRATION   0x8             /* Compile a database migration */
#define ESP_SRC         0x10            /* Files in src */

#define ESP_FOUND_TARGET 1

#define ESP_MIGRATIONS  "_EspMigrations"

/***************************** Forward Declarations ***************************/

static void clean(int argc, char **argv);
static void compile(int argc, char **argv);
static void compileItems(HttpRoute *route);
static void compileFlat(HttpRoute *route);
static void copyEspDir(cchar *fromDir, cchar *toDir);
static void createMigration(cchar *name, cchar *table, cchar *comment, int fieldCount, char **fields);
static HttpRoute *createRoute(cchar *dir);
static void fail(cchar *fmt, ...);
static void fatal(cchar *fmt, ...);
static bool findHostingConfig();
static MprList *getRoutes();
static MprHash *getTargets(int argc, char **argv);
static void generate(int argc, char **argv);
static void generateApp(int argc, char **argv);
static void generateAppDb();
static void generateAppFiles();
static void generateHostingConfig();
static void generateAppSrc();
static void generateMigration(int argc, char **argv);
static char *getTemplate(cchar *path, MprHash *tokens);
static void initialize();
static void makeEspDir(cchar *dir);
static void makeEspFile(cchar *path, cchar *data, cchar *msg);
static void manageApp(App *app, int flags);
static void migrate(int argc, char **argv);
static void process(int argc, char **argv);
static bool readHostingConfig();
static bool requiredRoute(HttpRoute *route);
static void run(int argc, char **argv);
static bool selectResource(cchar *path, cchar *kind);
static void trace(cchar *tag, cchar *fmt, ...);
static void usageError();
static void vtrace(cchar *tag, cchar *fmt, ...);
static void why(cchar *path, cchar *fmt, ...);

/*********************************** Code *************************************/

PUBLIC int main(int argc, char **argv)
{
    Mpr     *mpr;
    cchar   *argp, *logSpec;
    int     argind, rc;

    if ((mpr = mprCreate(argc, argv, 0)) == NULL) {
        exit(1);
    }
    if ((app = mprAllocObj(App, manageApp)) == NULL) {
        exit(2);
    }
    mprAddRoot(app);
    mprAddStandardSignals();

    logSpec = "stderr:0";
    argc = mpr->argc;
    argv = (char**) mpr->argv;
    app->mpr = mpr;
    app->configFile = 0;
    app->listen = sclone(ESP_LISTEN);
#if BIT_PACK_SDB
    app->database = sclone("sdb");
#elif BIT_PACK_MDB
    app->database = sclone("mdb");
#else
    mprError("No database provider defined");
#endif

    for (argind = 1; argind < argc && !app->error; argind++) {
        argp = argv[argind];
        if (*argp++ != '-') {
            break;
        }
        if (*argp == '-') {
            argp++;
        }
        if (smatch(argp, "chdir")) {
            if (argind >= argc) {
                usageError();
            } else {
                argp = argv[++argind];
                if (chdir((char*) argp) < 0) {
                    fail("Cannot change directory to %s", argp);
                }
            }

        } else if (smatch(argp, "config") || smatch(argp, "conf")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->configFile = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "database")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->database = sclone(argv[++argind]);
                if (!smatch(app->database, "mdb") && !smatch(app->database, "sdb")) {
                    fail("Unknown database \"%s\"", app->database);
                    usageError();
                }
            }

        } else if (smatch(argp, "flat") || smatch(argp, "f")) {
            app->flat = 1;

        } else if (smatch(argp, "genlink") || smatch(argp, "g")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->genlink = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "keep") || smatch(argp, "k")) {
            app->keep = 1;

        } else if (smatch(argp, "listen") || smatch(argp, "l")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->listen = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "log") || smatch(argp, "l")) {
            if (argind >= argc) {
                usageError();
            } else {
                logSpec = argv[++argind];
            }

        } else if (smatch(argp, "name")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->appName = argv[++argind];
            }

        } else if (smatch(argp, "overwrite")) {
            app->overwrite = 1;

        } else if (smatch(argp, "platform")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->platform = slower(argv[++argind]);
            }

        } else if (smatch(argp, "quiet") || smatch(argp, "q")) {
            app->quiet = 1;

        } else if (smatch(argp, "rebuild") || smatch(argp, "r")) {
            app->rebuild = 1;

        } else if (smatch(argp, "routeName")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->routeName = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "routePrefix")) {
            if (argind >= argc) {
                usageError();
            } else {
                app->routePrefix = sclone(argv[++argind]);
            }

        } else if (smatch(argp, "show") || smatch(argp, "s")) {
            app->show = 1;

        } else if (smatch(argp, "static")) {
            app->staticLink = 1;

        } else if (smatch(argp, "verbose") || smatch(argp, "v")) {
            logSpec = "stderr:2";
            app->verbose = 1;

        } else if (smatch(argp, "version") || smatch(argp, "V")) {
            mprPrintf("%s %s-%s\n", mprGetAppTitle(), BIT_VERSION, BIT_BUILD_NUMBER);
            exit(0);

        } else if (smatch(argp, "why") || smatch(argp, "w")) {
            app->why = 1;

        } else {
            fail("Unknown switch \"%s\"", argp);
            usageError();
        }
    }
    if (app->error) {
        return app->error;
    }
    if ((argc - argind) == 0) {
        usageError();
        return app->error;
    }
    mprStartLogging(logSpec, 0);
    mprSetCmdlineLogging(1);

    if (mprStart() < 0) {
        mprError("Cannot start MPR for %s", mprGetAppName());
        mprDestroy(MPR_EXIT_DEFAULT);
        return MPR_ERR_CANT_INITIALIZE;
    }
    if (!app->error) {
        initialize();
        process(argc - argind, &argv[argind]);
    }
    rc = app->error;
    mprDestroy(MPR_EXIT_DEFAULT);
    return rc;
}


static void manageApp(App *app, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(app->appName);
        mprMark(app->appweb);
        mprMark(app->cacheName);
        mprMark(app->command);
        mprMark(app->configFile);
        mprMark(app->csource);
        mprMark(app->currentDir);
        mprMark(app->database);
        mprMark(app->files);
        mprMark(app->flatFile);
        mprMark(app->flatItems);
        mprMark(app->flatPath);
        mprMark(app->genlink);
        mprMark(app->binDir);
        mprMark(app->espDir);
        mprMark(app->componentsDir);
        mprMark(app->templatesDir);
        mprMark(app->listen);
        mprMark(app->module);
        mprMark(app->mpr);
        mprMark(app->base);
        mprMark(app->migrations);
        mprMark(app->entry);
        mprMark(app->topComponent);
        mprMark(app->platform);
        mprMark(app->build);
        mprMark(app->slink);
        mprMark(app->routes);
        mprMark(app->routeName);
        mprMark(app->routePrefix);
        mprMark(app->routeSet);
        mprMark(app->server);
        mprMark(app->serverRoot);
        mprMark(app->targets);
    }
}


/*
    Create a new route. Only used by generateApp. All other routes are created when appweb.conf is loaded.
 */
static HttpRoute *createRoute(cchar *dir)
{
    HttpRoute   *route;
    EspRoute    *eroute;

    if ((route = httpCreateRoute(NULL)) == 0) {
        return 0;
    }
    if ((eroute = mprAllocObj(EspRoute, espManageEspRoute)) == 0) {
        return 0;
    }
    eroute->config = mprCreateJson(0);
    route->eroute = eroute;
    httpSetRouteDocuments(route, dir);
    espSetDirs(route);
    return route;
}


static void initialize()
{
    app->currentDir = mprGetCurrentPath();
    app->binDir = mprGetAppDir();
    app->espDir = mprJoinPath(mprGetAppDir(), "../esp");
    app->componentsDir = mprJoinPath(app->espDir, "components");
    app->templatesDir = mprJoinPath(app->espDir, "templates");
    httpCreate(HTTP_SERVER_SIDE | HTTP_UTILITY);
}


static MprHash *getTargets(int argc, char **argv)
{
    MprHash     *targets;
    int         i;

    targets = mprCreateHash(0, MPR_HASH_STABLE);
    for (i = 0; i < argc; i++) {
        mprAddKey(targets, mprGetAbsPath(argv[i]), NULL);
    }
    return targets;
}


static bool similarRoute(HttpRoute *r1, HttpRoute *r2)
{
    EspRoute    *e1, *e2;

    e1 = r1->eroute;
    e2 = r2->eroute;

    if (!smatch(r1->documents, r2->documents)) {
        return 0;
    }
    if (!smatch(r1->home, r2->home)) {
        return 0;
    }
    if (!smatch(r1->sourceName, r2->sourceName)) {
        return 0;
    }
    if (!smatch(r1->sourceName, r2->sourceName)) {
        return 0;
    }
    if (!smatch(e1->appDir, e2->appDir)) {
        return 0;
    }
    if (!smatch(e1->clientDir, e2->clientDir)) {
        return 0;
    }
    if (!smatch(e1->controllersDir, e2->controllersDir)) {
        return 0;
    }
    if (!smatch(e1->layoutsDir, e2->layoutsDir)) {
        return 0;
    }
    if (!smatch(e1->srcDir, e2->srcDir)) {
        return 0;
    }
    if (!smatch(e1->viewsDir, e2->viewsDir)) {
        return 0;
    }
    return 1;
}


static MprList *getRoutes()
{
    HttpHost    *host;
    HttpRoute   *route, *parent, *rp;
    EspRoute    *eroute;
    MprList     *routes;
    MprKey      *kp;
    cchar       *routeName, *routePrefix;
    int         prev, nextRoute;

    if (app->error) {
        return 0;
    }
    if ((host = mprGetFirstItem(http->hosts)) == 0) {
        fail("Cannot find default host");
        return 0;
    }
    routeName = app->routeName;
    routePrefix = app->routePrefix ? app->routePrefix : 0;
    routes = mprCreateList(0, MPR_LIST_STABLE);

    /*
        Filter ESP routes. Go in reverse order to locate outermost routes first.
     */
    for (prev = -1; (route = mprGetPrevItem(host->routes, &prev)) != 0; ) {
        if ((eroute = route->eroute) == 0 || !eroute->compile) {
            /* No ESP configuration for compiling */
            continue;
        }
        if (routeName) {
            mprTrace(3, "Check route name %s, prefix %s with %s", route->name, route->startWith, routeName);
            if (!smatch(routeName, route->name)) {
                continue;
            }
        } else if (routePrefix) {
            mprTrace(3, "Check route name %s, prefix %s with %s", route->name, route->startWith, routePrefix);
            if (!smatch(routePrefix, route->prefix) && !smatch(routePrefix, route->startWith)) {
                continue;
            }
        } else {
            mprTrace(3, "Check route name %s, prefix %s", route->name, route->startWith);
        }
        parent = route->parent;
        if (parent && parent->eroute &&
            ((EspRoute*) parent->eroute)->compile && smatch(route->documents, parent->documents) && parent->startWith) {
            /*
                Use the parent instead if it has the same directory and is not the default route
                This is for MVC apps with a prefix of "/" and a directory the same as the default route.
             */
            continue;
        }
        if (!requiredRoute(route)) {
            mprTrace(2, "Skip route %s not required for selected targets", route->name);
            continue;
        }
        /*
            Check for routes with duplicate documents and home directories
         */
        rp = 0;
        for (ITERATE_ITEMS(routes, rp, nextRoute)) {
            if (similarRoute(route, rp)) {
                mprTrace(2, "Skip route %s because of prior similar route: %s", route->name, rp->name);
                route = 0;
                break;
            }
        }
        if (route && mprLookupItem(routes, route) < 0) {
            mprTrace(2, "Compiling route dir: %s name: %s prefix: %s", route->documents, route->name, route->startWith);
            mprAddItem(routes, route);
        }
    }
    if (mprGetListLength(routes) == 0) {
        if (routeName) {
            fail("Cannot find usable ESP configuration in %s for route %s", app->configFile, routeName);
        } else if (routePrefix) {
            fail("Cannot find usable ESP configuration in %s for route prefix %s", app->configFile, routePrefix);
        } else {
            kp = mprGetFirstKey(app->targets);
            if (kp) {
                fail("Cannot find usable ESP configuration in %s for %s", app->configFile, kp->key);
            } else {
                fail("Cannot find usable ESP configuration", app->configFile);
            }
        }
        return 0;
    }
    /*
        Check we have a route for all targets
     */
    for (ITERATE_KEYS(app->targets, kp)) {
        if (!kp->type) {
            fail("Cannot find a usable route for %s", kp->key);
        }
    }
    /*
        Set default route and eroute
     */
    if ((app->route = mprGetFirstItem(routes)) == 0) {
        fail("Cannot find a suitable route");
    }
    eroute = app->eroute = app->route->eroute;
    assert(eroute);
    if (eroute->config) {
        app->topComponent = mprGetJsonValue(eroute->config, "generate.top", 0);
        app->appName = eroute->appName;
        app->topComponent = mprGetJsonValue(eroute->config, "generate.top", 0);
    }
    return routes;
}


/*
    Search strategy is:

    [--config path] : ./appweb.conf : [parent]/appweb.conf
 */
static bool findHostingConfig()
{
    cchar   *name, *path, *userPath, *nextPath;

    name = mprJoinPathExt(BIT_PRODUCT, ".conf");
    userPath = app->configFile;
    if (app->configFile == 0) {
        app->configFile = name;
    }
    mprLog(1, "Probe for \"%s\"", app->configFile);
    if (!mprPathExists(app->configFile, R_OK)) {
        if (userPath) {
            fail("Cannot open config file %s", app->configFile);
            return 0;
        }
        for (path = mprGetCurrentPath(); path; path = nextPath) {
            mprLog(1, "Probe for \"%s\"", path);
            if (mprPathExists(mprJoinPath(path, name), R_OK)) {
                app->configFile = mprJoinPath(path, name);
                break;
            }
            app->configFile = 0;
            nextPath = mprGetPathParent(path);
            if (mprSamePath(nextPath, path)) {
                break;
            }
        }
        if (!app->configFile) {
            fail("Cannot find appweb.config");
            return 0;
        }
    }
    app->serverRoot = mprGetAbsPath(mprGetPathDir(app->configFile));
    if (!userPath) {
        if (chdir(mprGetPathDir(app->configFile)) < 0) {
            fail("Cannot change directory to %s", mprGetPathDir(app->configFile));
            return 0;
        }
    }
    return 1;
}


/*
    Read the appweb.conf configuration file
 */
static bool readHostingConfig()
{
    HttpStage   *stage;

    if ((app->appweb = maCreateAppweb()) == 0) {
        fail("Cannot create HTTP service for %s", mprGetAppName());
        return 0;
    }
    appweb = MPR->appwebService = app->appweb;
    appweb->skipModules = 1;
    http = app->appweb->http;
    if (maSetPlatform(app->platform) < 0) {
        fail("Cannot find platform %s", app->platform);
        return 0;
    }
    appweb->staticLink = app->staticLink;

    if (!findHostingConfig() || app->error) {
        return 0;
    }
    if ((app->server = maCreateServer(appweb, "default")) == 0) {
        fail("Cannot create HTTP server for %s", mprGetAppName());
        return 0;
    }
    if (maParseConfig(app->server, app->configFile, MA_PARSE_NON_SERVER) < 0) {
        fail("Cannot configure the server, exiting.");
        return 0;
    }
    if ((stage = httpLookupStage(http, "espHandler")) == 0) {
        fail("Cannot find ESP handler in %s", app->configFile);
        return 0;
    }
    esp = stage->stageData;
    return !app->error;
}


static void process(int argc, char **argv)
{
    cchar       *cmd;
    bool        generateApp;

    assert(argc >= 1);

    cmd = argv[0];
    generateApp = smatch(cmd, "generate") && argc > 1 && smatch(argv[1], "app");
    if (!generateApp) {
        readHostingConfig();
    }
    if (smatch(cmd, "generate")) {
        generate(argc - 1, &argv[1]);

    } else if (smatch(cmd, "migrate")) {
        app->routes = getRoutes();
        migrate(argc - 1, &argv[1]);

    } else if (smatch(cmd, "clean")) {
        app->targets = getTargets(argc - 1, &argv[1]);
        app->routes = getRoutes();
        clean(argc -1, &argv[1]);

    } else if (smatch(cmd, "compile")) {
        app->targets = getTargets(argc - 1, &argv[1]);
        app->routes = getRoutes();
        compile(argc -1, &argv[1]);

    } else if (smatch(cmd, "run")) {
        app->routes = getRoutes();
        run(argc - 1, &argv[1]);

    } else if (cmd && *cmd) {
        fail("Unknown command %s", cmd);

    } else {
        usageError();
    }
}


static void clean(int argc, char **argv)
{
    MprList         *files;
    MprDirEntry     *dp;
    EspRoute        *eroute;
    HttpRoute       *route;
    char            *path;
    int             next, nextFile;

    if (app->error) {
        return;
    }
    for (ITERATE_ITEMS(app->routes, route, next)) {
        eroute = route->eroute;
        if (eroute->cacheDir) {
            trace("clean", "Route \"%s\" at %s", route->name, route->documents);
            files = mprGetPathFiles(eroute->cacheDir, MPR_PATH_RELATIVE);
            for (nextFile = 0; (dp = mprGetNextItem(files, &nextFile)) != 0; ) {
                path = mprJoinPath(eroute->cacheDir, dp->name);
                if (mprPathExists(path, R_OK)) {
                    trace("clean", "%s", path);
                    mprDeletePath(path);
                }
            }
        }
    }
    trace("Task", "Complete");
}


static void run(int argc, char **argv)
{
    MprCmd      *cmd;

    if (app->error) {
        return;
    }
    cmd = mprCreateCmd(0);
    trace("Run", "appweb -v");
    if (mprRunCmd(cmd, "appweb -v", NULL, NULL, NULL, -1, MPR_CMD_DETACH) != 0) {
        fail("Cannot run command: appweb -v");
        return;
    }
    mprWaitForCmd(cmd, -1);
}


static int runEspCommand(HttpRoute *route, cchar *command, cchar *csource, cchar *module)
{
    MprCmd      *cmd;
    MprList     *elist;
    MprKey      *var;
    EspRoute    *eroute;
    cchar       **env;
    char        *err, *out;

    eroute = route->eroute;
    cmd = mprCreateCmd(0);
    if ((app->command = espExpandCommand(route, command, csource, module)) == 0) {
        fail("Missing EspCompile directive for %s", csource);
        return MPR_ERR_CANT_READ;
    }
    mprTrace(4, "ESP command: %s\n", app->command);
    if (eroute->env) {
        elist = mprCreateList(0, MPR_LIST_STABLE);
        for (ITERATE_KEYS(eroute->env, var)) {
            mprAddItem(elist, sfmt("%s=%s", var->key, var->data));
        }
        mprAddNullItem(elist);
        env = (cchar**) &elist->items[0];
    } else {
        env = 0;
    }
    if (eroute->searchPath) {
        mprSetCmdSearchPath(cmd, eroute->searchPath);
    }
    if (app->show) {
        trace("Run", app->command);
    }
    //  WARNING: GC will run here
    if (mprRunCmd(cmd, app->command, env, &out, &err, -1, 0) != 0) {
        if (err == 0 || *err == '\0') {
            /* Windows puts errors to stdout Ugh! */
            err = out;
        }
        fail("Cannot run command: \n%s\nError: %s", app->command, err);
        return MPR_ERR_CANT_COMPLETE;
    }
    if (out && *out) {
#if BIT_WIN_LIKE
        if (!scontains(out, "Creating library ")) {
            if (!smatch(mprGetPathBase(csource), strim(out, " \t\r\n", MPR_TRIM_BOTH))) {
                mprRawLog(0, "%s\n", out);
            }
        }
#else
        mprRawLog(0, "%s\n", out);
#endif
    }
    if (err && *err) {
        mprRawLog(0, "%s\n", err);
    }
    return 0;
}


static void compileFile(HttpRoute *route, cchar *source, int kind)
{
    EspRoute    *eroute;
    cchar       *canonical, *defaultLayout, *page, *layout, *data, *prefix, *lpath;
    char        *err, *quote, *script;
    ssize       len;
    int         recompile;

    if (app->error) {
        return;
    }
    eroute = route->eroute;
    defaultLayout = 0;
    if (kind == ESP_SRC) {
        prefix = "app_";
    } else if (kind == ESP_CONTROlLER) {
        prefix = "controller_";
    } else if (kind == ESP_MIGRATION) {
        prefix = "migration_";
    } else {
        prefix = "view_";
    }
    canonical = mprGetPortablePath(mprGetRelPath(source, route->documents));
    app->cacheName = mprGetMD5WithPrefix(sfmt("%s:%s", eroute->appName, canonical), -1, prefix);
    app->module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, app->cacheName, BIT_SHOBJ));
    defaultLayout = (eroute->layoutsDir) ? mprJoinPath(eroute->layoutsDir, "default.esp") : 0;
    mprMakeDir(eroute->cacheDir, 0755, -1, -1, 1);

    if (app->flat) {
        why(source, "flat forces complete rebuild");
    } else if (app->rebuild) {
        why(source, "due to forced rebuild");
    } else if (!espModuleIsStale(source, app->module, &recompile)) {
        if (kind & (ESP_PAGE | ESP_VIEW)) {
            if ((data = mprReadPathContents(source, &len)) == 0) {
                fail("Cannot read %s", source);
                return;
            }
            if ((lpath = scontains(data, "@ layout \"")) != 0) {
                lpath = strim(&lpath[10], " ", MPR_TRIM_BOTH);
                if ((quote = schr(lpath, '"')) != 0) {
                    *quote = '\0';
                }
                layout = (eroute->layoutsDir && *lpath) ? mprJoinPath(eroute->layoutsDir, lpath) : 0;
            } else {
                layout = defaultLayout;
            }
            if (!layout || !espModuleIsStale(layout, app->module, &recompile)) {
                why(source, "is up to date");
                return;
            }
        } else {
            why(source, "is up to date");
            return;
        }
    } else if (mprPathExists(app->module, R_OK)) {
        why(source, "has been modified");
    } else {
        why(source, "%s is missing", app->module);
    }
    if (app->flatFile) {
        mprWriteFileFmt(app->flatFile, "/*\n    Source from %s\n */\n", source);
    }
    if (kind & (ESP_CONTROlLER | ESP_MIGRATION | ESP_SRC)) {
        app->csource = source;
        if (app->flatFile) {
            if ((data = mprReadPathContents(source, &len)) == 0) {
                fail("Cannot read %s", source);
                return;
            }
            if (mprWriteFile(app->flatFile, data, slen(data)) < 0) {
                fail("Cannot write compiled script file %s", app->flatFile->path);
                return;
            }
            mprWriteFileFmt(app->flatFile, "\n\n");
            if (eroute->appName && *eroute->appName) {
                mprAddItem(app->flatItems, sfmt("esp_controller_%s_%s", eroute->appName, mprTrimPathExt(mprGetPathBase(source))));
            } else {
                mprAddItem(app->flatItems, sfmt("esp_controller_%s", mprTrimPathExt(mprGetPathBase(source))));
            }
        }
    }
    if (kind & (ESP_PAGE | ESP_VIEW)) {
        if ((page = mprReadPathContents(source, &len)) == 0) {
            fail("Cannot read %s", source);
            return;
        }
        /* No yield here */
        if ((script = espBuildScript(route, page, source, app->cacheName, defaultLayout, NULL, &err)) == 0) {
            fail("Cannot build %s, error %s", source, err);
            return;
        }
        len = slen(script);
        if (app->flatFile) {
            if (mprWriteFile(app->flatFile, script, len) < 0) {
                fail("Cannot write compiled script file %s", app->flatFile->path);
                return;
            }
            mprWriteFileFmt(app->flatFile, "\n\n");
            mprAddItem(app->flatItems, sfmt("esp_%s", app->cacheName));

        } else {
            app->csource = mprJoinPathExt(mprTrimPathExt(app->module), ".c");
            trace("Parse", "%s", source);
            mprMakeDir(eroute->cacheDir, 0755, -1, -1, 1);
            if (mprWritePathContents(app->csource, script, len, 0664) < 0) {
                fail("Cannot write compiled script file %s", app->csource);
                return;
            }
        }
    }
    if (!app->flatFile) {
        /*
            WARNING: GC yield here
         */
        trace("Compile", "%s", app->csource);
        if (!eroute->compile) {
            fail("Missing EspCompile directive for %s", app->csource);
            return;
        }
        if (runEspCommand(route, eroute->compile, app->csource, app->module) < 0) {
            return;
        }
        if (eroute->link) {
            vtrace("Link", "%s", mprGetRelPath(mprTrimPathExt(app->module), NULL));
            if (runEspCommand(route, eroute->link, app->csource, app->module) < 0) {
                return;
            }
#if !(BIT_DEBUG && MACOSX)
            /*
                MAC needs the object for debug information
             */
            mprDeletePath(mprJoinPathExt(mprTrimPathExt(app->module), BIT_OBJ));
#endif
        }
        if (!eroute->keepSource && !app->keep && (kind & (ESP_VIEW | ESP_PAGE))) {
            mprDeletePath(app->csource);
        }
    }
}


/*
    esp compile [flat | controller_names | page_names]
        [] - compile controllers and pages separately into cache
        [controller_names/page_names] - compile single file
        [app] - compile all files into a single source file with one init that calls all sub-init files

    esp compile path/name.ejs ...
        [controller_names/page_names] - compile single file

    esp compile static
        use makerom code and compile static into a file in cache

 */
static void compile(int argc, char **argv)
{
    EspRoute    *eroute;
    HttpRoute   *route;
    MprFile     *file;
    MprKey      *kp;
    cchar       *name;
    int         next;

    if (app->error) {
        return;
    }
    if (app->flat && app->genlink) {
        app->slink = mprCreateList(0, MPR_LIST_STABLE);
    }
    for (ITERATE_ITEMS(app->routes, route, next)) {
        eroute = route->eroute;
        mprMakeDir(eroute->cacheDir, 0755, -1, -1, 1);
        mprTrace(2, "Build with route \"%s\" at %s", route->name, route->documents);
        if (app->flat) {
            compileFlat(route);
        } else {
            compileItems(route);
        }
    }
    /*
        Check we have compiled all targets
     */
    for (ITERATE_KEYS(app->targets, kp)) {
        if (!kp->type) {
            fail("Cannot find target %s to compile", kp->key);
        }
    }
    if (app->slink) {
        trace("Generate", app->genlink);
        if ((file = mprOpenFile(app->genlink, O_WRONLY | O_TRUNC | O_CREAT | O_BINARY, 0664)) == 0) {
            fail("Cannot open %s", app->flatPath);
            return;
        }
        mprWriteFileFmt(file, "/*\n    %s -- Generated Appweb Static Initialization\n */\n", app->genlink);
        mprWriteFileFmt(file, "#include \"esp.h\"\n\n");
        for (ITERATE_ITEMS(app->slink, route, next)) {
            eroute = route->eroute;
            name = app->appName ? app->appName : mprGetPathBase(route->documents);
            mprWriteFileFmt(file, "extern int esp_app_%s(HttpRoute *route, MprModule *module);", name);
            mprWriteFileFmt(file, "    /* SOURCE %s */\n",
                mprGetRelPath(mprJoinPath(eroute->cacheDir, sjoin(name, ".c", NULL)), NULL));
        }
        mprWriteFileFmt(file, "\nPUBLIC void appwebStaticInitialize()\n{\n");
        for (ITERATE_ITEMS(app->slink, route, next)) {
            name = app->appName ? app->appName : mprGetPathBase(route->documents);
            mprWriteFileFmt(file, "    espStaticInitialize(esp_app_%s, \"%s\", \"%s\");\n", name, name, route->name);
        }
        mprWriteFileFmt(file, "}\n");
        mprCloseFile(file);
        app->slink = 0;
    }
    if (!app->error) {
        trace("Task", "Complete");
    }
}


/*
    Select a route that is responsible for a target
 */
static bool requiredRoute(HttpRoute *route)
{
    EspRoute    *eroute;
    MprKey      *kp;
    cchar       *source;

    if (app->targets == 0 || mprGetHashLength(app->targets) == 0) {
        return 1;
    }
    for (ITERATE_KEYS(app->targets, kp)) {
        if (mprIsParentPathOf(route->documents, kp->key)) {
            kp->type = ESP_FOUND_TARGET;
            return 1;
        }
        if (route->sourceName) {
            eroute = route->eroute;
            source = mprJoinPath(eroute->controllersDir, route->sourceName);
            if (mprIsParentPathOf(kp->key, source)) {
                kp->type = ESP_FOUND_TARGET;
                return 1;
            }
        }
    }
    return 0;
}


/*
    Select a resource that matches specified targets
 */
static bool selectResource(cchar *path, cchar *kind)
{
    MprKey  *kp;
    cchar   *ext;

    ext = mprGetPathExt(path);
    if (kind && !smatch(ext, kind)) {
        return 0;
    }
    if (app->targets == 0 || mprGetHashLength(app->targets) == 0) {
        return 1;
    }
    for (ITERATE_KEYS(app->targets, kp)) {
        if (mprIsParentPathOf(kp->key, path)) {
            kp->type = ESP_FOUND_TARGET;
            return 1;
        }
    }
    return 0;
}


/*
    Compile all the items relevant to a route
 */
static void compileItems(HttpRoute *route)
{
    EspRoute    *eroute;
    MprDirEntry *dp;
    cchar       *path;
    int         next;

    eroute = route->eroute;
    if (eroute->controllersDir) {
        assert(eroute);
        app->files = mprGetPathFiles(eroute->controllersDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (selectResource(path, "c")) {
                compileFile(route, path, ESP_CONTROlLER);
            }
        }
    }
    if (eroute->viewsDir) {
        app->files = mprGetPathFiles(eroute->viewsDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (sstarts(path, eroute->layoutsDir)) {
                continue;
            }
            if (selectResource(path, "esp")) {
                compileFile(route, path, ESP_VIEW);
            }
        }
    }
    if (eroute->srcDir) {
        path = mprJoinPath(eroute->srcDir, "app.c");
        if (mprPathExists(path, R_OK) && selectResource(path, "c")) {
            compileFile(route, path, ESP_SRC);
        }
    }
    if (eroute->clientDir) {
        app->files = mprGetPathFiles(eroute->clientDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (selectResource(path, "esp")) {
                compileFile(route, path, ESP_PAGE);
            }
        }

    } else {
        /* Non-MVC */
        app->files = mprGetPathFiles(route->documents, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (selectResource(path, "esp")) {
                compileFile(route, path, ESP_PAGE);
            }
        }
        /*
            Stand-alone controllers
         */
        if (route->sourceName) {
            path = mprJoinPath(route->home, route->sourceName);
            if (mprPathExists(path, R_OK)) {
                compileFile(route, path, ESP_CONTROlLER);
            }
        }
    }
}


/*
    Compile all the items for a route into a flat (single) output file
 */
static void compileFlat(HttpRoute *route)
{
    MprDirEntry     *dp;
    MprKeyValue     *kp;
    EspRoute        *eroute;
    cchar           *name;
    char            *path, *line;
    int             next, kind;

    eroute = route->eroute;
    name = app->appName ? app->appName : mprGetPathBase(route->documents);

    /*
        Flat ... Catenate all source
     */
    app->flatItems = mprCreateList(-1, MPR_LIST_STABLE);
    app->flatPath = mprJoinPath(eroute->cacheDir, sjoin(name, ".c", NULL));

    app->build = mprCreateList(0, MPR_LIST_STABLE);
    if (eroute->controllersDir) {
        app->files = mprGetPathFiles(eroute->controllersDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "c")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "controller", 0));
            }
        }
    }
    if (eroute->viewsDir) {
        app->files = mprGetPathFiles(eroute->viewsDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            mprAddItem(app->build, mprCreateKeyPair(path, "view", 0));
        }
    }
    if (eroute->clientDir) {
        app->files = mprGetPathFiles(eroute->clientDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "esp")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "page", 0));
            }
        }
    }
    if (!eroute->controllersDir && !eroute->clientDir) {
        app->files = mprGetPathFiles(route->documents, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "esp")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "page", 0));
            }
        }
    }
    if (mprGetListLength(app->build) > 0) {
        if ((app->flatFile = mprOpenFile(app->flatPath, O_WRONLY | O_TRUNC | O_CREAT | O_BINARY, 0664)) == 0) {
            fail("Cannot open %s", app->flatPath);
            return;
        }
        mprWriteFileFmt(app->flatFile, "/*\n    Flat compilation of %s\n */\n\n", name);
        mprWriteFileFmt(app->flatFile, "#include \"esp.h\"\n\n");

        for (ITERATE_ITEMS(app->build, kp, next)) {
            if (smatch(kp->value, "controller")) {
                kind = ESP_CONTROlLER;
            } else if (smatch(kp->value, "page")) {
                kind = ESP_VIEW;
            } else {
                kind = ESP_PAGE;
            }
            compileFile(route, kp->key, kind);
        }
        if (app->slink) {
            mprAddItem(app->slink, route);
        }
        mprWriteFileFmt(app->flatFile, "\nESP_EXPORT int esp_app_%s(HttpRoute *route, MprModule *module) {\n", name);
        for (next = 0; (line = mprGetNextItem(app->flatItems, &next)) != 0; ) {
            mprWriteFileFmt(app->flatFile, "    %s(route, module);\n", line);
        }
        mprWriteFileFmt(app->flatFile, "    return 0;\n}\n");
        mprCloseFile(app->flatFile);

        app->module = mprNormalizePath(sfmt("%s/%s%s", eroute->cacheDir, name, BIT_SHOBJ));
        trace("Compile", "%s", name);
        if (runEspCommand(route, eroute->compile, app->flatPath, app->module) < 0) {
            return;
        }
        if (eroute->link) {
            trace("Link", "%s", mprGetRelPath(mprTrimPathExt(app->module), NULL));
            if (runEspCommand(route, eroute->link, app->flatPath, app->module) < 0) {
                return;
            }
        }
    }
    app->flatItems = 0;
    app->flatFile = 0;
    app->flatPath = 0;
    app->build = 0;
}


/*
    Initialize the application components from the command line
  */
static void addComponents(int argc, char **argv)
{
    int     i;

    espAddComponent(app->route, "server");
    for (i = 0; i < argc; i++) {
        espAddComponent(app->route, argv[i]);
    }
}


static void addDeps(cchar *component)
{
    MprJson     *config, *depends, *dep;
    cchar       *path, *cpath;
    int         i;

    path = mprJoinPath(app->componentsDir, component);
    if (!mprPathExists(path, X_OK)) {
        fail("Cannot find component \"%s\"", component);
        return;
    }
    cpath = mprJoinPath(path, "config.json");
    if (mprPathExists(cpath, R_OK)) {
        if ((config = mprLoadJson(cpath)) == 0) {
            fail("Cannot load %s", cpath);
            return;
        }
        if ((depends = mprGetJson(config, "depends", 0)) != 0) {
            for (ITERATE_JSON(depends, dep, i)) {
                if (!espHasComponent(app->route, dep->value)) {
                    addDeps(dep->value);
                }
            }
        }
    }
    if (!espHasComponent(app->route, component)) {
        mprTrace(4, "Add component %s", component);
        espAddComponent(app->route, component);
    }
}


static void addComponentDeps()
{
    MprJson     *components, *component;
    int         i;

    components = mprGetJson(app->eroute->config, "settings.components", 0);
    mprSetJson(app->eroute->config, "settings.components", mprCreateJson(MPR_JSON_ARRAY), 0);
    for (ITERATE_JSON(components, component, i)) {
        addDeps(component->value);
    }
}


/*
    generate app NAME [components ...]
 */
static void generateApp(int argc, char **argv)
{
    cchar   *dir, *name;

    name = argv[0];
    app->route = createRoute(name);
    app->eroute = app->route->eroute;
    addComponents(argc - 1, &argv[1]);
    addComponentDeps();
    if (app->error) {
        return;
    }
    if (smatch(name, ".")) {
        dir = mprGetCurrentPath();
        name = mprGetPathBase(dir);
        if (chdir(mprGetPathParent(dir)) < 0) {
            fail("Cannot change directory to %s", mprGetPathParent(dir));
            return;
        }
    }
    app->appName = sclone(name);
    app->configFile = mprJoinPath(mprGetAppDir(), "esp.conf");
    if (!mprPathExists(app->configFile, R_OK)) {
        fail("Cannot open config file %s", app->configFile);
        return;
    }
    generateAppFiles();
    generateHostingConfig();
    generateAppSrc();
    generateAppDb();
}


/*
    esp migration description table [field:type [, field:type] ...]

    The description is used to name the migration
 */
static void generateMigration(int argc, char **argv)
{
    cchar       *stem, *table, *name;

    if (argc < 2) {
        fail("Bad migration command line");
    }
    if (app->error) {
        return;
    }
    table = sclone(argv[1]);
    stem = sfmt("Migration %s", argv[0]);
    /* Migration name used in the filename and in the exported load symbol */
    name = sreplace(slower(stem), " ", "_");
    createMigration(name, table, stem, argc - 2, &argv[2]);
}


static void createMigration(cchar *name, cchar *table, cchar *comment, int fieldCount, char **fields)
{
    MprHash     *tokens;
    MprList     *files;
    MprDirEntry *dp;
    cchar       *dir, *seq, *forward, *backward, *data, *path, *def, *field, *tail, *typeDefine;
    char        *typeString;
    int         i, type, next;

    seq = sfmt("%s%d", mprGetDate("%Y%m%d%H%M%S"), nextMigration);
    forward = sfmt("    ediAddTable(db, \"%s\");\n", table);
    backward = sfmt("    ediRemoveTable(db, \"%s\");\n", table);

    def = sfmt("    ediAddColumn(db, \"%s\", \"id\", EDI_TYPE_INT, EDI_AUTO_INC | EDI_INDEX | EDI_KEY);\n", table);
    forward = sjoin(forward, def, NULL);

    for (i = 0; i < fieldCount; i++) {
        field = stok(sclone(fields[i]), ":", &typeString);
        if ((type = ediParseTypeString(typeString)) < 0) {
            fail("Unknown type '%s' for field '%s'", typeString, field);
            return;
        }
        if (smatch(field, "id")) {
            continue;
        }
        typeDefine = sfmt("EDI_TYPE_%s", supper(ediGetTypeString(type)));
        def = sfmt("    ediAddColumn(db, \"%s\", \"%s\", %s, 0);\n", table, field, typeDefine);
        forward = sjoin(forward, def, NULL);
    }
    dir = mprJoinPath(app->eroute->dbDir, "migrations");
    makeEspDir(dir);

    path = sfmt("%s/%s_%s.c", dir, seq, name, ".c");
    tokens = mprDeserialize(sfmt("{ NAME: '%s', COMMENT: '%s', FORWARD: '%s', BACKWARD: '%s' }", name, comment, forward, backward));
    data = getTemplate("server/migration.c", tokens);

    files = mprGetPathFiles("db/migrations", MPR_PATH_RELATIVE);
    tail = sfmt("%s.c", name);
    for (ITERATE_ITEMS(files, dp, next)) {
        if (sends(dp->name, tail)) {
            if (!app->overwrite) {
                trace("Exists", "A migration with the same description already exists: %s", dp->name);
                return;
            }
            mprDeletePath(mprJoinPath("db/migrations/", dp->name));
        }
    }
    makeEspFile(path, data, "Migration");
}


/*
    esp generate controller name [action [, action] ...]

    Generate a server-side controller.
 */
static void generateController(int argc, char **argv)
{
    MprHash     *tokens;
    cchar       *actions, *defines, *name, *path, *data, *title, *action;
    int         i;

    if (argc < 1) {
        usageError();
        return;
    }
    if (app->error) {
        return;
    }
    name = sclone(argv[0]);
    title = spascal(name);
    path = mprJoinPathExt(mprJoinPath(app->eroute->controllersDir, name), ".c");
    defines = sclone("");
    actions = sclone("");
    for (i = 1; i < argc; i++) {
        action = argv[i];
        defines = sjoin(defines, sfmt("    espDefineAction(route, \"%s-cmd-%s\", %s);\n", name, action, action), NULL);
        actions = sjoin(actions, sfmt("static void %s() {\n}\n\n", action), NULL);
    }
    tokens = mprDeserialize(sfmt("{ APP: '%s', NAME: '%s', TITLE: '%s', ACTIONS: '%s', DEFINE_ACTIONS: '%s' }", 
        app->appName, name, title, actions, defines));
    data = getTemplate("server/controller.c", tokens);
    makeEspFile(path, data, "Controller");
}


static void generateScaffoldController(int argc, char **argv)
{
    MprHash     *tokens;
    cchar       *defines, *name, *path, *data, *title;

    if (app->error) {
        return;
    }
    name = sclone(argv[0]);
    title = spascal(name);

    defines = sclone("");
    tokens = mprDeserialize(sfmt("{ APP: '%s', NAME: '%s', TITLE: '%s', DEFINE_ACTIONS: '%s' }", app->appName, name, title, defines));
    data = getTemplate(mprJoinPath(app->topComponent, "controller.c"), tokens);
    path = mprJoinPathExt(mprJoinPath(app->eroute->controllersDir, name), ".c");
    makeEspFile(path, data, "Scaffold");
}


static void generateClientController(int argc, char **argv)
{
    MprHash     *tokens;
    cchar       *defines, *name, *path, *data, *title;

    if (app->error) {
        return;
    }
    name = sclone(argv[0]);
    title = spascal(name);

    path = mprJoinPathExt(mprJoinPath(app->eroute->appDir, sfmt("%s/%sControl", name, title)), "js");
    defines = sclone("");
    tokens = mprDeserialize(sfmt("{ APPDIR: '%s', NAME: '%s', TITLE: '%s', DEFINE_ACTIONS: '%s', SERVICE: '%s' }",
        app->eroute->appDir, name, title, defines, app->eroute->serverPrefix));
    data = getTemplate(mprJoinPath(app->topComponent, "controller.js"), tokens);
    makeEspFile(path, data, "Controller Scaffold");
}


static void generateClientModel(int argc, char **argv)
{
    MprHash     *tokens;
    cchar       *title, *name, *path, *data;

    if (app->error) {
        return;
    }
    name = sclone(argv[0]);
    title = spascal(name);

    path = sfmt("%s/%s/%s.js", app->eroute->appDir, name, title);
    tokens = mprDeserialize(sfmt("{ NAME: '%s', SERVICE: '%s', TITLE: '%s'}", name, app->eroute->serverPrefix, title));
    data = getTemplate(mprJoinPath(app->topComponent, "model.js"), tokens);
    makeEspFile(path, data, "Scaffold Model");
}


/*
    Called with args: table [field:type [, field:type] ...]
 */
static void generateScaffoldMigration(int argc, char **argv)
{
    cchar       *comment, *table;

    if (argc < 2) {
        fail("Bad migration command line");
    }
    if (app->error) {
        return;
    }
    table = sclone(argv[0]);
    comment = sfmt("Create Scaffold %s", spascal(table));
    createMigration(sfmt("create_scaffold_%s", table), table, comment, argc - 1, &argv[1]);
}


/*
    esp generate table name [field:type [, field:type] ...]
 */
static void generateTable(int argc, char **argv)
{
    Edi         *edi;
    cchar       *tableName, *field;
    char        *typeString;
    int         rc, i, type;

    if (app->error) {
        return;
    }
    tableName = sclone(argv[0]);
    if ((edi = app->eroute->edi) == 0) {
        fail("Database not open. Check appweb.conf");
        return;
    }
    edi->flags |= EDI_SUPPRESS_SAVE;
    if ((rc = ediAddTable(edi, tableName)) < 0) {
        if (rc != MPR_ERR_ALREADY_EXISTS) {
            fail("Cannot add table '%s'", tableName);
        }
    } else {
        if ((rc = ediAddColumn(edi, tableName, "id", EDI_TYPE_INT, EDI_AUTO_INC | EDI_INDEX | EDI_KEY)) != 0) {
            fail("Cannot add column 'id'");
        }
    }
    for (i = 1; i < argc && !app->error; i++) {
        field = stok(sclone(argv[i]), ":", &typeString);
        if ((type = ediParseTypeString(typeString)) < 0) {
            fail("Unknown type '%s' for field '%s'", typeString, field);
            break;
        }
        if ((rc = ediAddColumn(edi, tableName, field, type, 0)) != 0) {
            if (rc != MPR_ERR_ALREADY_EXISTS) {
                fail("Cannot add column '%s'", field);
                break;
            } else {
                ediChangeColumn(edi, tableName, field, type, 0);
            }
        }
    }
    edi->flags &= ~EDI_SUPPRESS_SAVE;
    ediSave(edi);
    trace("Update", "Database schema");
}


/*
    Called with args: name [field:type [, field:type] ...]
 */
static void generateScaffoldViews(int argc, char **argv)
{
    MprHash     *tokens;
    cchar       *title, *name, *path, *data;

    if (app->error) {
        return;
    }
    name = sclone(argv[0]);
    title = spascal(name);
    tokens = mprDeserialize(sfmt("{ NAME: '%s', TITLE: '%s', SERVICE: '%s'}", name, title, app->eroute->serverPrefix));

    if (espTestConfig(app->route, "generate.clientView", "true")) {
        path = sfmt("%s/%s/%s-list.html", app->eroute->appDir, name, name);
    } else {
        path = sfmt("%s/%s-list.esp", app->eroute->viewsDir, name);
    }
    data = getTemplate(mprJoinPath(app->topComponent, "list.html"), tokens);
    makeEspFile(path, data, "Scaffold List View");

    if (espTestConfig(app->route, "generate.clientView", "true")) {
        path = sfmt("%s/%s/%s-edit.html", app->eroute->appDir, name, name);
    } else {
        path = sfmt("%s/%s-edit.esp", app->eroute->viewsDir, name);
    }
    data = getTemplate(mprJoinPath(app->topComponent, "edit.html"), tokens);
    makeEspFile(path, data, "Scaffold Edit View");
}


/*
    esp generate scaffold NAME [field:type [, field:type] ...]
 */
static void generateScaffold(int argc, char **argv)
{
    if (argc < 1) {
        usageError();
        return;
    }
    if (app->error) {
        return;
    }
    if (!espTestConfig(app->route, "generate.scaffold", "true")) {
        return;
    }
    if (espTestConfig(app->route, "generate.controller", "true")) {
        generateScaffoldController(argc, argv);
    }
    if (espTestConfig(app->route, "generate.clientController", "true")) {
        generateClientController(argc, argv);
    }
    generateScaffoldViews(argc, argv);
    if (espTestConfig(app->route, "generate.clientModel", "true")) {
        generateClientModel(argc, argv);
    }
    if (espTestConfig(app->route, "generate.migration", "true")) {
        generateScaffoldMigration(argc, argv);
    }
    migrate(0, 0);
}


static void generate(int argc, char **argv)
{
    char    *kind;

    if (argc < 2) {
        usageError();
        return;
    }
    kind = argv[0];

    if (smatch(kind, "app")) {
        generateApp(argc - 1, &argv[1]);

    } else {
        app->routes = getRoutes();
        if (smatch(kind, "controller")) {
            generateController(argc - 1, &argv[1]);

        } else if (smatch(kind, "migration")) {
            generateMigration(argc - 1, &argv[1]);

        } else if (smatch(kind, "scaffold")) {
            generateScaffold(argc - 1, &argv[1]);

        } else if (smatch(kind, "table")) {
            generateTable(argc - 1, &argv[1]);

        } else {
            fatal("Unknown generation kind %s", kind);
        }
    }
    if (!app->error) {
        trace("Task", "Complete");
    }
}


static int reverseSortFiles(MprDirEntry **d1, MprDirEntry **d2)
{
    return !scmp((*d1)->name, (*d2)->name);
}


static int sortFiles(MprDirEntry **d1, MprDirEntry **d2)
{
    return scmp((*d1)->name, (*d2)->name);
}


/*
    esp migrate [forward|backward|NNN]
 */
static void migrate(int argc, char **argv)
{
    MprModule   *mp;
    MprDirEntry *dp;
    Edi         *edi;
    EdiRec      *mig;
    HttpRoute   *route;
    cchar       *command, *file;
    uint64      seq, targetSeq, lastMigration, v;
    int         next, onlyOne, backward, found, i, rc;

    if (app->error) {
        return;
    }
    route = app->route;
    onlyOne = backward = 0;
    targetSeq = 0;
    lastMigration = 0;
    command = 0;

    if ((edi = app->eroute->edi) == 0) {
        fail("Database not open. Check appweb.conf");
        return;
    }
    if (app->rebuild) {
        ediClose(edi);
        mprDeletePath(edi->path);
        if ((app->eroute->edi = ediOpen(edi->path, edi->provider->name, edi->flags | EDI_CREATE)) == 0) {
            fail("Cannot open database %s", edi->path);
            return;
        }
    }
    /*
        Each database has a _EspMigrations table which has a record for each migration applied
     */
    if ((app->migrations = ediReadTable(edi, ESP_MIGRATIONS)) == 0) {
        rc = ediAddTable(edi, ESP_MIGRATIONS);
        rc += ediAddColumn(edi, ESP_MIGRATIONS, "id", EDI_TYPE_INT, EDI_AUTO_INC | EDI_INDEX | EDI_KEY);
        rc += ediAddColumn(edi, ESP_MIGRATIONS, "version", EDI_TYPE_STRING, 0);
        if (rc < 0) {
            fail("Cannot add migration");
            return;
        }
        app->migrations = ediReadTable(edi, ESP_MIGRATIONS);
    }
    if (app->migrations->nrecords > 0) {
        mig = app->migrations->records[app->migrations->nrecords - 1];
        lastMigration = stoi(ediGetFieldValue(mig, "version"));
    }
    app->files = mprGetPathFiles("db/migrations", MPR_PATH_NODIRS);
    mprSortList(app->files, (MprSortProc) (backward ? reverseSortFiles : sortFiles), 0);

    if (argc > 0) {
        command = argv[0];
        if (sstarts(command, "forw")) {
            onlyOne = 1;
        } else if (sstarts(command, "back")) {
            onlyOne = 1;
            backward = 1;
        } else if (*command) {
            /* Find the specified migration, may be a pure sequence number or a filename */
            for (ITERATE_ITEMS(app->files, dp, next)) {
                file = dp->name;
                app->base = mprGetPathBase(file);
                if (smatch(app->base, command)) {
                    targetSeq = stoi(app->base);
                    break;
                } else {
                    if (stoi(app->base) == stoi(command)) {
                        targetSeq = stoi(app->base);
                        break;
                    }
                }
            }
            if (! targetSeq) {
                fail("Cannot find target migration: %s", command);
                return;
            }
            if (lastMigration && targetSeq < lastMigration) {
                backward = 1;
            }
        }
    }

    found = 0;
    for (ITERATE_ITEMS(app->files, dp, next)) {
        file = dp->name;
        app->base = mprGetPathBase(file);
        if (!smatch(mprGetPathExt(app->base), "c") || !isdigit((uchar) *app->base)) {
            continue;
        }
        seq = stoi(app->base);
        if (seq <= 0) {
            continue;
        }
        found = 0;
        mig = 0;
        for (i = 0; i < app->migrations->nrecords; i++) {
            mig = app->migrations->records[i];
            v = stoi(ediGetFieldValue(mig, "version"));
            if (v == seq) {
                found = 1;
                break;
            }
        }
        if (backward) {
            found = !found;
        }
        if (!found) {
            /*
                WARNING: GC may occur while compiling
             */
            compileFile(route, file, ESP_MIGRATION);
            if (app->error) {
                return;
            }
            if ((app->entry = scontains(app->base, "_")) != 0) {
                app->entry = mprTrimPathExt(&app->entry[1]);
            } else {
                app->entry = mprTrimPathExt(app->base);
            }
            app->entry = sfmt("esp_migration_%s", app->entry);
            if ((mp = mprCreateModule(file, app->module, app->entry, edi)) == 0) {
                return;
            }
            if (mprLoadModule(mp) < 0) {
                return;
            }
            if (backward) {
                trace("Migrate", "Reverse %s", app->base);
                if (edi->back(edi) < 0) {
                    fail("Cannot reverse migration");
                    return;
                }
            } else {
                trace("Migrate", "Apply %s ", app->base);
                if (edi->forw(edi) < 0) {
                    fail("Cannot apply migration");
                    return;
                }
            }
            if (backward) {
                assert(mig);
                ediRemoveRec(edi, ESP_MIGRATIONS, ediGetFieldValue(mig, "id"));
            } else {
                mig = ediCreateRec(edi, ESP_MIGRATIONS);
                ediSetField(mig, "version", itos(seq));
                if (ediUpdateRec(edi, mig) < 0) {
                    fail("Cannot update migrations table");
                    return;
                }
            }
            mprUnloadModule(mp);
            if (onlyOne) {
                return;
            }
        }
        if (targetSeq == seq) {
            return;
        }
    }
    if (!onlyOne) {
        trace("Task", "All migrations %s", backward ? "reversed" : "applied");
    }
    app->migrations = 0;
}


static void fixupFile(cchar *path)
{
    HttpRoute   *route;
    MprHash     *tokens;
    ssize       len;
    char        *data, *tmp;

    if ((data = mprReadPathContents(path, &len)) == 0) {
        /* Fail silently */
        return;
    }
    route = app->route;

    //  DEPRECATE ROUTESET and DIR
    tokens = mprDeserialize(sfmt("{ NAME: '%s', TITLE: '%s', DATABASE: '%s', HOME: '%s', DOCUMENTS: '%s', LISTEN: '%s', BINDIR: '%s', ROUTESET: '%s', DIR: '%s' }", 
        app->appName, spascal(app->appName), app->database, route->home, route->documents, app->listen, 
        app->binDir, app->routeSet, route->documents));
    data = stemplate(data, tokens);
    tmp = mprGetTempPath(route->documents);
    if (mprWritePathContents(tmp, data, slen(data), 0644) < 0) {
        fail("Cannot write %s", path);
        return;
    }
    unlink(path);
    if (rename(tmp, path) < 0) {
        fail("Cannot rename %s to %s", tmp, path);
    }
}


/*
    esp generate app NAME|. kind [compponents, ...]
 */
static void generateAppFiles()
{
    EspRoute    *eroute;
    HttpRoute   *route;
    MprJson     *components, *newConfig, *component;
    cchar       *config, *name, *path;
    int         i;

    route = app->route;
    eroute = app->eroute;
    makeEspDir(route->documents);
    app->routeSet = sclone("restful");
    components = mprGetJson(eroute->config, "settings.components", 0);
    for (ITERATE_JSON(components, component, i)) {
        name = component->value;
        path = mprJoinPath(app->componentsDir, name);
        if (!mprPathExists(path, X_OK)) {
            fail("Cannot find component \"%s\"", name);
            return;
        }
        trace("Generate",  "Component: %s", name);
        copyEspDir(path, route->documents);

        /*
            Blend config.json from new component
         */
        config = mprJoinPath(path, "config.json");
        if (mprPathExists(config, R_OK)) {
            if ((newConfig = mprLoadJson(config)) != 0) {
                mprBlendJson(eroute->config, newConfig, 0);
            }
        }
    }
    fixupFile(mprJoinPath(eroute->clientDir, "index.esp"));
    fixupFile(mprJoinPath(eroute->appDir, "main.js"));
    fixupFile(mprJoinPath(eroute->layoutsDir, "default.esp"));

    if (espSaveConfig(app->route) < 0) {
        fail("Cannot save config.json");
    }
    fixupFile(mprJoinPath(route->documents, "config.json"));
    app->topComponent = mprGetJsonValue(eroute->config, "generate.top", 0);
}


static void copyEspDir(cchar *fromDir, cchar *toDir)
{
    MprList     *files;
    MprDirEntry *dp;
    char        *from, *to;
    int         next;

    files = mprGetPathFiles(fromDir, MPR_PATH_DESCEND | MPR_PATH_RELATIVE | MPR_PATH_NODIRS);
    for (next = 0; (dp = mprGetNextItem(files, &next)) != 0 && !app->error; ) {
        if (smatch("config.json", mprGetPathBase(dp->name))) {
            continue;
        }
        from = mprJoinPath(fromDir, dp->name);
        to = mprJoinPath(toDir, dp->name);
        if (mprMakeDir(mprGetPathDir(to), 0755, -1, -1, 1) < 0) {
            fail("Cannot make directory %s", mprGetPathDir(to));
            return;
        }
        if (mprPathExists(to, R_OK) && !app->overwrite) {
            trace("Exists",  "File: %s", mprGetRelPath(to, 0));
        } else {
            vtrace("Create",  "File: %s", mprGetRelPath(to, 0));
            if (mprCopyPath(from, to, 0644) < 0) {
                fail("Cannot copy file %s to %s", from, mprGetRelPath(to, 0));
                return;
            }
        }
    }
}


static void generateHostingConfig()
{
    fixupFile(mprJoinPath(app->route->documents, "appweb.conf"));
    fixupFile(mprJoinPath(app->route->documents, "app.conf"));
}


static void generateAppSrc()
{
    MprHash     *tokens;
    char        *path, *data;

    path = mprJoinPath(app->eroute->srcDir, "app.c");
    tokens = mprDeserialize(sfmt("{ NAME: '%s', TITLE: '%s' }", app->appName, spascal(app->appName)));
    data = getTemplate("server/app.c", tokens);
    makeEspFile(path, data, "Header");
}


static void generateAppDb()
{
    cchar       *dbspec, *ext;
    char        *dbpath;

    if (!app->database) {
        return;
    }
    dbspec = mprGetJsonValue(app->eroute->config, "server.database", 0);
    if (!dbspec || *dbspec == '\0') {
        return;
    }
    ext = app->database;
    if ((smatch(app->database, "sdb") && !BIT_PACK_SDB) || (smatch(app->database, "mdb") && !BIT_PACK_MDB)) {
        fail("Cannot find database provider: \"%s\". Ensure Appweb is configured to support \"%s\"",
                app->database, app->database);
        return;
    }
    dbpath = sfmt("%s/%s.%s", app->eroute->dbDir, app->appName, ext);
    makeEspDir(mprGetPathDir(dbpath));
}


static void makeEspDir(cchar *path)
{
    if (mprPathExists(path, X_OK)) {
        // trace("Exists",  "Directory: %s", path);
    } else {
        if (mprMakeDir(path, 0755, -1, -1, 1) < 0) {
            app->error++;
        } else {
            trace("Create",  "Directory: %s", mprGetRelPath(path, 0));
        }
    }
}


static void makeEspFile(cchar *path, cchar *data, cchar *msg)
{
    bool    exists;

    exists = mprPathExists(path, R_OK);
    if (exists && !app->overwrite) {
        trace("Exists", path);
        return;
    }
    makeEspDir(mprGetPathDir(path));
    if (mprWritePathContents(path, data, slen(data), 0644) < 0) {
        fail("Cannot write %s", path);
        return;
    }
    if (!exists) {
        trace("Create", mprGetRelPath(path, 0));
    } else {
        trace("Overwrite", path);
    }
}


static cchar *getComponents()
{
    MprDirEntry     *dp;
    MprJson         *config;
    MprList         *files, *result;
    cchar           *path;
    int             next;

    result = mprCreateList(0, 0);
    files = mprGetPathFiles(app->componentsDir, 0);
    for (ITERATE_ITEMS(files, dp, next)) {
        path = mprJoinPath(dp->name, "config.json");
        if (mprPathExists(path, R_OK)) {
            if ((config = mprLoadJson(path)) != 0) {
                mprAddItem(result, sfmt("%24s: %s", mprGetJsonValue(config, "name", 0), mprGetJsonValue(config, "description", 0)));
            }
        }
    }
    return mprListToString(result, "\n");
}


static char *getTemplate(cchar *path, MprHash *tokens)
{
    char    *data;

    path = mprJoinPath(app->templatesDir, path);
    if ((data = mprReadPathContents(path, NULL)) == 0) {
        fail("Cannot open template file \"%s\"", path);
    }
    return stemplate(data, tokens);
}


static void usageError()
{
    cchar   *name, *components;

    name = mprGetAppName();
    app->espDir = mprJoinPath(mprGetAppDir(), "../esp");
    app->componentsDir = mprJoinPath(app->espDir, "components");
    components = getComponents();

    mprEprintf("\nESP Usage:\n\n"
    "  %s [options] [commands]\n\n"
    "  Options:\n"
    "    --chdir dir                # Change to the named directory first\n"
    "    --config configFile        # Use named config file instead appweb.conf\n"
    "    --database name            # Database provider 'mdb|sdb' \n"
    "    --flat                     # Compile into a single module\n"
    "    --genlink filename         # Generate a static link module for flat compilations\n"
    "    --keep                     # Keep intermediate source\n"
    "    --listen [ip:]port         # Listen on specified address \n"
    "    --log logFile:level        # Log to file file at verbosity level\n"
    "    --name appName             # Name for the app when compiling flat\n"
    "    --overwrite                # Overwrite existing files \n"
    "    --quiet                    # Don't emit trace \n"
    "    --platform os-arch-profile # Target platform\n"
    "    --rebuild                  # Force a rebuild\n"
    "    --reverse                  # Reverse migrations\n"
    "    --routeName name           # Route name in appweb.conf to use \n"
    "    --routePrefix prefix       # Route prefix in appweb.conf to use \n"
    "    --show                     # Show compile commands\n"
    "    --static                   # Use static linking\n"
    "    --verbose                  # Emit more verbose trace \n"
    "    --why                      # Why compile or skip building\n"
    "\n"
    "  Commands:\n"
    "    esp clean\n"
    "    esp compile\n"
    "    esp compile [pathFilters ...]\n"
    "    esp migrate [forward|backward|NNN]\n"
    "    esp generate app name [components...]\n"
    "    esp generate controller name [action [, action] ...\n"
    "    esp generate migration description model [field:type [, field:type] ...]\n"
    "    esp generate scaffold model [field:type [, field:type] ...]\n"
    "    esp generate table name [field:type [, field:type] ...]\n"
    "    esp run\n"
    "\n"
    "  Components: (for esp generate app)\n%s\n"
    "", name, components);
    app->error = 1;
}


static void fail(cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    va_start(args, fmt);
    msg = sfmtv(fmt, args);
    mprError("%s", msg);
    va_end(args);
    app->error = 1;
}


static void fatal(cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    va_start(args, fmt);
    msg = sfmtv(fmt, args);
    mprFatal("%s", msg);
    va_end(args);
}


static void trace(cchar *tag, cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    if (!app->quiet) {
        va_start(args, fmt);
        msg = sfmtv(fmt, args);
        tag = sfmt("[%s]", tag);
        mprRawLog(0, "%12s %s\n", tag, msg);
        va_end(args);
    }
}


static void vtrace(cchar *tag, cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    if (app->verbose && !app->quiet) {
        va_start(args, fmt);
        msg = sfmtv(fmt, args);
        tag = sfmt("[%s]", tag);
        mprRawLog(0, "%12s %s\n", tag, msg);
        va_end(args);
    }
}

static void why(cchar *path, cchar *fmt, ...)
{
    va_list     args;
    char        *msg;

    if (app->why) {
        va_start(args, fmt);
        msg = sfmtv(fmt, args);
        mprRawLog(0, "%14s %s %s\n", "[Why]", path, msg);
        va_end(args);
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
