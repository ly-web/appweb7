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
    cchar       *listen;                /* Listen endpoint for "esp run" */
    cchar       *platform;              /* Target platform os-arch-profile (lower) */
    MprFile     *flatFile;              /* Output file for flat compilations */
    MprList     *flatItems;             /* Items to invoke from Init */

    /*
        GC retention
     */
    MprList     *routes;                /* Routes to process */
    MprList     *files;                 /* List of files to process */
    MprList     *build;                 /* Items to build */
    MprList     *slink;                 /* List of items for static link */
    MprHash     *targets;               /* Command line targets */
    EdiGrid     *migrations;            /* Migrations table */

    cchar       *command;               /* Compilation or link command */
    cchar       *cacheName;             /* MD5 name of cached component */
    cchar       *csource;               /* Name of "C" source for page or service */
    cchar       *genlink;               /* Static link resolution file */
    cchar       *routeName;             /* Name of route to use for ESP configuration */
    cchar       *routePrefix;           /* Route prefix to use for ESP configuration */
    cchar       *routeSet;              /* Desired route set package */
    cchar       *module;                /* Compiled module name */
    cchar       *base;                  /* Base filename */
    cchar       *entry;                 /* Module entry point */

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
#if DEPRECATE || 1
    int         legacy;                 /* Legacy MVC mode - pre 4.4.0 */
#endif
} App;

static App       *app;                  /* Top level application object */
static Esp       *esp;                  /* ESP control object */
static Http      *http;                 /* HTTP service object */
static MaAppweb  *appweb;               /* Appweb service object */
static int       nextMigration;         /* Sequence number for next migration */

/*
    CompileFile flags
 */
#define ESP_SERVICE     0x1             /* Service controller */
#define ESP_VIEW        0x2             /* Service view */
#define ESP_PAGE        0x4             /* Stand-alone ESP page */
#define ESP_MIGRATION   0x8             /* Database migration */
#define ESP_SRC         0x10            /* Files in services/src */

#define ESP_FOUND_TARGET 1

#define ESP_MIGRATIONS  "_EspMigrations"

/********************************* Templates **********************************/

static cchar *AppSrc = "\
/*\n\
    app.c -- ${TITLE} Module Source\n\
\n\
    This module is loaded when Appweb starts up.\n\
 */\n#include \"esp.h\"\n\
\n\
/*\n\
    This base for services is called before processing each request\n\
 */\n\
static void base(HttpConn *conn) {\n\
}\n\
\n\
ESP_EXPORT int esp_app_${NAME}(HttpRoute *route, MprModule *module)\n\
{\n\
    espDefineBase(route, base);\n\
    return 0;\n\
}\n\
";


static cchar *ServiceHeader = "\
/*\n\
    ${NAME} Service\n\
 */\n#include \"esp.h\"\n\
\n\
";


static cchar *ServiceFooter = "\
ESP_EXPORT int esp_module_${NAME}(HttpRoute *route, MprModule *module) \n\
{\n\
${DEFINE_ACTIONS}    return 0;\n\
}\n";


static cchar *ScaffoldServiceHeader = "\
/*\n\
    ${NAME} service\n\
 */\n#include \"esp.h\"\n\
\n\
static void create${TITLE}() { \n\
    EdiRec *rec;\n\
    rec = createRec(\"${NAME}\", params());\n\
    renderResult(updateRec(rec));\n\
}\n\
\n\
static void get${TITLE}() { \n\
    renderRec(readRec(\"${NAME}\", param(\"id\")));\n\
}\n\
\n\
static void index${TITLE}() {\n\
    renderGrid(readTable(\"${NAME}\"));\n\
}\n\
\n\
static void remove${TITLE}() { \n\
    renderResult(removeRec(\"${NAME}\", param(\"id\")));\n\
}\n\
\n\
static void update${TITLE}() { \n\
    EdiRec *rec;\n\
    rec = setFields(readRec(\"${NAME}\", param(\"id\")), params());\n\
    renderResult(updateRec(rec));\n\
}\n\
\n\
";

#if DEPRECATE || 1
/*
    Deprecated in 4.4
 */
static cchar *LegacyScaffoldServiceHeader = "\
/*\n\
    ${NAME} service\n\
 */\n#include \"esp.h\"\n\
\n\
static void create() { \n\
    if (updateRec(createRec(\"${NAME}\", params()))) {\n\
        flash(\"inform\", \"New ${NAME} created\");\n\
        renderView(\"${NAME}-list\");\n\
    } else {\n\
        renderView(\"${NAME}-edit\");\n\
    }\n\
}\n\
\n\
static void destroy() { \n\
    if (removeRec(\"${NAME}\", param(\"id\"))) {\n\
        flash(\"inform\", \"${TITLE} removed\");\n\
    }\n\
    renderView(\"${NAME}-list\");\n\
}\n\
\n\
static void edit() { \n\
    readRec(\"${NAME}\", param(\"id\"));\n\
}\n\
\n\
static void list() { }\n\
\n\
static void init() { \n\
    createRec(\"${NAME}\", 0);\n\
    renderView(\"${NAME}-edit\");\n\
}\n\
\n\
static void show() { \n\
    readRec(\"${NAME}\", param(\"id\"));\n\
    renderView(\"${NAME}-edit\");\n\
}\n\
\n\
static void update() { \n\
    if (updateFields(\"${NAME}\", params())) {\n\
        flash(\"inform\", \"${TITLE} updated successfully.\");\n\
        renderView(\"${NAME}-list\");\n\
    } else {\n\
        renderView(\"${NAME}-edit\");\n\
    }\n\
}\n\
\n\
";
#endif

static cchar *ScaffoldServiceFooter = "\
ESP_EXPORT int esp_module_${NAME}(HttpRoute *route, MprModule *module) \n\
{\n\
    espDefineAction(route, \"${NAME}-create\", create${TITLE});\n\
    espDefineAction(route, \"${NAME}-get\", get${TITLE});\n\
    espDefineAction(route, \"${NAME}-index\", index${TITLE});\n\
    espDefineAction(route, \"${NAME}-remove\", remove${TITLE});\n\
    espDefineAction(route, \"${NAME}-update\", update${TITLE});\n\
${DEFINE_ACTIONS}    return 0;\n\
}\n";


static cchar *ScaffoldListView = "\
<h2>${TITLE} List</h2>\n\
    <div class=\"span4\">\n\
    <table class=\"table table-striped table-bordered table-hover table-condensed\">\n\
        <thead><tr><th ng-repeat=\"header in ${NAME}s.schema.headers\" ng-click=\"click($index)\">{{header}}</th></tr></thead>\n\
        <tbody>\n\
            <tr ng-repeat=\"${NAME} in ${NAME}s.data\" ng-click=\"click($index)\">\n\
                <td ng-repeat=\"column in ${NAME}s.schema.columns\">{{${NAME}[column]}}</td>\n\
            </tr>\n\
        </tbody>\n\
    </table>\n\
    <button class=\"btn btn-primary\" ng-click=\"goto('/service/${NAME}/')\">New ${TITLE}</button>\n\
</div>\n\
";


static cchar *ScaffoldEditView =  "\
<form name=\"${NAME}Form\" ng-controller='${TITLE}Control'>\n\
    <fieldset>\n\
        <legend>{{action}} ${TITLE}</legend>\n\
        <label>Title</label> <input type='text' ng-model='${NAME}.title'></input>\n\
        <label>Body</label> <textarea type='text' ng-model='${NAME}.body' cols='160' rows='4'></textarea>\n\
    </fieldset>\n\
    <button class=\"btn btn-primary\" ng-click='save()'>OK</button>\n\
    <button class=\"btn\" ng-click='goto(\"/\")'>Cancel</button>\n\
    <button class=\"btn\" ng-show=\"action=='Edit'\" ng-click='remove({{${NAME}.id}})'>Delete</button>\n\
</form>\n\
";


#if DEPRECATE || 1
/*
    Deprecated in 4.4
 */
static cchar *LegacyScaffoldServiceFooter = "\
ESP_EXPORT int esp_module_${NAME}(HttpRoute *route, MprModule *module) \n\
{\n\
    espDefineAction(route, \"${NAME}-create\", create);\n\
    espDefineAction(route, \"${NAME}-destroy\", destroy);\n\
    espDefineAction(route, \"${NAME}-edit\", edit);\n\
    espDefineAction(route, \"${NAME}-init\", init);\n\
    espDefineAction(route, \"${NAME}-list\", list);\n\
    espDefineAction(route, \"${NAME}-show\", show);\n\
    espDefineAction(route, \"${NAME}-update\", update);\n\
${DEFINE_ACTIONS}    return 0;\n\
}\n";

static cchar *LegacyScaffoldListView = "\
<h1>${TITLE} List</h1>\n\
\n\
<% table(readTable(\"${NAME}\"), \"{data-esp-click: '@edit'}\"); %>\n\
<% buttonLink(\"New ${TITLE}\", \"@init\", 0); %>\n\
";


static cchar *LegacyScaffoldEditView =  "\
<h1><%= hasRec() ? \"Edit\" : \"Create\" %> ${TITLE}</h1>\n\
\n\
<% form(0, 0); %>\n\
    <table border=\"0\">\n\
    <% {\n\
        char    *name, *uname;\n\
        int     next;\n\
        MprList *cols = getColumns(NULL);\n\
        for (ITERATE_ITEMS(cols, name, next)) {\n\
            if (smatch(name, \"id\")) continue;\n\
            uname = spascal(name);\n\
    %>\n\
            <tr><td><% render(uname); %></td><td><% input(name, 0); %></td></tr>\n\
        <% } %>\n\
    <% } %>\n\
    </table>\n\
    <% button(\"commit\", \"OK\", 0); %>\n\
    <% buttonLink(\"Cancel\", \"@\", 0); %>\n\
    <% if (hasRec()) buttonLink(\"Delete\", \"@destroy\", \"{data-esp-method: 'DELETE'}\"); %>\n\
<% endform(); %>\n\
";
#endif


static cchar *ScaffoldController = "\
/*\n\
    ${TITLE} Controller\n\
 */\n\
\n\
'use strict';\n\
\n\
app.controller('${TITLE}Control', function ($rootScope, $scope, $location, $routeParams, ${TITLE}) {\n\
    if ($routeParams.id) {\n\
        ${TITLE}.get({id: $routeParams.id}, function(response) {\n\
            $scope.${NAME} = response.data;\n\
            $scope.action = \"Edit\";\n\
        });\n\
    } else if ($location.path() == \"/service/${NAME}/\") {\n\
        $scope.action = \"Create\";\n\
        $scope.${NAME} = new ${TITLE}();\n\
    } else {\n\
        $scope.list = ${TITLE}.index({}, function(response) {\n\
            $scope.list = response;\n\
        });\n\
    }\n\
    $scope.routeParams = $routeParams;\n\
\n\
    $scope.remove = function() {\n\
        ${TITLE}.remove({id: $scope.${NAME}.id}, function(response) {\n\
            $location.path(\"/\");\n\
        });\n\
    };\n\
\n\
    $scope.save = function() {\n\
        ${TITLE}.save($scope.${NAME}, function(response) {\n\
            if (response.success) {\n\
                $location.path('/');\n\
            }\n\
        });\n\
    };\n\
\n\
    $scope.click = function(index) {\n\
        $location.path('/service/${NAME}/' + $scope.${NAME}s.data[index].id);\n\
    };\n\
});\n\
\n\
app.config(function($routeProvider) {\n\
    $routeProvider.when('/', {\n\
        templateUrl: '/${APPDIR}/${NAME}/list.html',\n\
        controller: '${TITLE}Control',\n\
    });\n\
    $routeProvider.when('/service/${NAME}/:id', {\n\
        templateUrl: '/${APPDIR}/${NAME}/edit.html',\n\
        controller: '${TITLE}Control',\n\
    });\n\
});\n\
";

static cchar *MigrationTemplate = "\
/*\n\
    ${COMMENT}\n\
 */\n#include \"esp.h\"\n\
\n\
static int forward(Edi *db) {\n\
${FORWARD}    return 0;\n\
}\n\
\n\
static int backward(Edi *db) {\n\
${BACKWARD}    return 0;\n\
}\n\
\n\
ESP_EXPORT int esp_migration_${NAME}(Edi *db)\n\
{\n\
    ediDefineMigration(db, forward, backward);\n\
    return 0;\n\
}\n\
";

static cchar *ModelTemplate = "\
/*\n\
    ${NAME}.js - ${TITLE} model\n\
 */\n\
'use strict';\n\
\n\
app.factory('${TITLE}', function ($resource) {\n\
    return $resource('/service/${NAME}/:id', { id: '@id' }, {\n\
        'index':  { 'method': 'GET' },\n\
    });\n\
});\n\
";

/***************************** Forward Declarations ***************************/

static void clean(MprList *routes);
static void compile(MprList *routes);
static void compileItems(HttpRoute *route);
static void compileFlat(HttpRoute *route);
static void copyEspDir(cchar *fromDir, cchar *toDir);
static void createMigration(HttpRoute *route, cchar *name, cchar *table, cchar *comment, int fieldCount, char **fields);
static HttpRoute *createRoute(cchar *dir);
static void fail(cchar *fmt, ...);
static bool findConfigFile(bool mvc);
static bool findDefaultConfigFile();
static MprHash *getTargets(int argc, char **argv);
static HttpRoute *getMvcRoute();
static MprList *getRoutes();
static void generate(int argc, char **argv);
static void generateApp(int argc, char **argv);
static void generateAppDb(HttpRoute *route);
static void generateAppFiles(HttpRoute *route, int argc, char **argv);
static void generateAppConfigFile(HttpRoute *route);
static void generateAppSrc(HttpRoute *route);
static void generateMigration(HttpRoute *route, int argc, char **argv);
static void initialize();
static void makeEspDir(cchar *dir);
static void makeEspFile(cchar *path, cchar *data, cchar *msg);
static void manageApp(App *app, int flags);
static void migrate(HttpRoute *route, int argc, char **argv);
static void process(int argc, char **argv);
static bool readConfig(bool mvc);
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

#if DEPRECATE || 1
        } else if (smatch(argp, "legacy")) {
            /*
                Old style MVC directory layout using "static" instead of "client". Deprecated in 4.4.0.
             */
            app->legacy = 1;
#endif

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
        mprMark(app->listen);
        mprMark(app->module);
        mprMark(app->mpr);
        mprMark(app->base);
        mprMark(app->migrations);
        mprMark(app->entry);
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


static HttpRoute *createRoute(cchar *dir)
{
    HttpRoute   *route;
    EspRoute    *eroute;

    if ((route = httpCreateRoute(NULL)) == 0) {
        return 0;
    }
#if DEPRECATE || 1
    if (app->legacy) {
        route->flags |= HTTP_ROUTE_LEGACY_MVC;
    }
#endif
    if ((eroute = mprAllocObj(EspRoute, espManageEspRoute)) == 0) {
        return 0;
    }
    route->eroute = eroute;
    eroute->route = route;
    httpSetRouteDir(route, dir);
    espSetMvcDirs(eroute);
    return route;
}


static void initialize()
{
    app->currentDir = mprGetCurrentPath();
    app->binDir = mprGetAppDir();
#if DEPRECATE || 1
    if (mprPathExists("static", X_OK) && !mprPathExists("client", X_OK)) {
        app->legacy = 1;
    }
#endif
    httpCreate(HTTP_SERVER_SIDE | HTTP_UTILITY);
}


static MprHash *getTargets(int argc, char **argv)
{
    MprHash     *targets;
    int         i;

    targets = mprCreateHash(0, 0);
    for (i = 0; i < argc; i++) {
        mprAddKey(targets, mprGetAbsPath(argv[i]), NULL);
    }
    return targets;
}


static MprList *getRoutes()
{
    HttpHost    *host;
    HttpRoute   *route, *rp, *parent;
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
    routes = mprCreateList(0, 0);

    /*
        Filter ESP routes. Go in reverse order to locate outermost routes first.
     */
    for (prev = -1; (route = mprGetPrevItem(host->routes, &prev)) != 0; ) {
        mprTrace(3, "Check route name %s, prefix %s", route->name, route->startWith);

        if ((eroute = route->eroute) == 0 || !eroute->compile) {
            /* No ESP configuration for compiling */
            continue;
        }
        if (routeName) {
            if (!smatch(routeName, route->name)) {
                continue;
            }
        } else if (routePrefix) {
            if (route->startWith == 0 || !smatch(routePrefix, route->startWith)) {
                continue;
            }
        }
        parent = route->parent;
        if (parent && parent->eroute &&
            ((EspRoute*) parent->eroute)->compile && smatch(route->dir, parent->dir) && parent->startWith) {
            /*
                Use the parent instead if it has the same directory and is not the default route
                This is for MVC apps with a prefix of "/" and a directory the same as the default route.
             */
            continue;
        }
        if (!requiredRoute(route)) {
            continue;
        }
        /*
            Check for routes with a duplicate base directory
         */
        rp = 0;
        for (ITERATE_ITEMS(routes, rp, nextRoute)) {
            if (sstarts(route->dir, rp->dir)) {
                if (!rp->startWith && route->sourceName) {
                    /* Replace the default route with this route. This is for MVC Apps with prefix of "/" */
                    mprRemoveItem(routes, rp);
                    rp = 0;
                }
                break;
            }
        }
        if (rp) {
            continue;
        }
        if (mprLookupItem(routes, route) < 0) {
            mprTrace(2, "Compiling route dir: %s name: %s prefix: %s", route->dir, route->name, route->startWith);
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
    return routes;
}


//  MOB - rename
static HttpRoute *getMvcRoute()
{
    HttpHost    *host;
    HttpRoute   *route, *parent;
    EspRoute    *eroute;
    cchar       *routeName, *routePrefix;
    int         prev;

    if ((host = mprGetFirstItem(http->hosts)) == 0) {
        fail("Cannot find default host");
        return 0;
    }
    routeName = app->routeName;
    routePrefix = app->routePrefix ? app->routePrefix : 0;

    /*
        Filter ESP routes and find the ...
        Go in reverse order to locate outermost routes first.
     */
    for (prev = -1; (route = mprGetPrevItem(host->routes, &prev)) != 0; ) {
        mprTrace(3, "Check route name %s, prefix %s", route->name, route->startWith);
        if ((eroute = route->eroute) == 0 || !eroute->compile) {
            /* No ESP configuration for compiling */
            continue;
        }
        if (!route->startWith) {
            continue;
        }
        if (routeName) {
            if (!smatch(routeName, route->name)) {
                continue;
            }
        } else if (routePrefix) {
            if (route->startWith == 0 || !smatch(routePrefix, route->startWith)) {
                continue;
            }
        }
        parent = route->parent;
        if (parent && ((EspRoute*) parent->eroute)->compile && smatch(route->dir, parent->dir) && parent->startWith) {
            /*
                Use the parent instead if it has the same directory and is not the default route
                This is for MVC apps with a prefix of "/" and a directory the same as the default route.
             */
            continue;
        }
        if (!requiredRoute(route)) {
            continue;
        }
        break;
    }
    if (route == 0) {
        if (routeName) {
            fail("Cannot find ESP configuration in %s for route %s", app->configFile, routeName);
        } else if (routePrefix) {
            fail("Cannot find ESP configuration in %s for route prefix %s", app->configFile, routePrefix);
        } else {
            fail("Cannot find ESP configuration in %s", app->configFile);
        }
    } else {
        mprLog(1, "Using route dir: %s, name: %s, prefix: %s", route->dir, route->name, route->startWith);
    }
    return route;
}


static bool readConfig(bool mvc)
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

    if (!findConfigFile(mvc) || app->error) {
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
    HttpRoute   *route;
    cchar       *cmd;

    assert(argc >= 1);

    initialize();

    cmd = argv[0];
    if (smatch(cmd, "generate")) {
        if (smatch(argv[1], "app")) {
            if (argc < 3) {
                usageError();
                return;
            }
            generateApp(argc - 2, &argv[2]);
            return;
        }
        readConfig(1);
        generate(argc - 1, &argv[1]);

    } else {
        if (smatch(cmd, "migrate")) {
            readConfig(1);
            route = getMvcRoute();
            migrate(route, argc - 1, &argv[1]);

        } else if (smatch(cmd, "clean")) {
            readConfig(0);
            app->targets = getTargets(argc - 1, &argv[1]);
            app->routes = getRoutes();
            clean(app->routes);

        } else if (smatch(cmd, "compile")) {
            readConfig(0);
            app->targets = getTargets(argc - 1, &argv[1]);
            app->routes = getRoutes();
            compile(app->routes);

        } else if (smatch(cmd, "run")) {
            readConfig(1);
            run(argc - 1, &argv[1]);

        } else {
            if (cmd && *cmd) {
                fail("Unknown command %s", cmd);
            } else {
                usageError();
            }
        }
    }
}


static void clean(MprList *routes)
{
    MprList         *files;
    MprDirEntry     *dp;
    HttpRoute       *route;
    EspRoute        *eroute;
    char            *path;
    int             next, nextFile;

    if (app->error) {
        return;
    }
    for (ITERATE_ITEMS(routes, route, next)) {
        eroute = route->eroute;
        if (eroute->cacheDir) {
            trace("clean", "Route \"%s\" at %s", route->name, route->dir);
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
    EspRoute    *eroute;
    MprCmd      *cmd;
    MprList     *elist;
    MprKey      *var;
    cchar       **env;
    char        *err, *out;

    eroute = route->eroute;
    cmd = mprCreateCmd(0);
    if ((app->command = espExpandCommand(eroute, command, csource, module)) == 0) {
        fail("Missing EspCompile directive for %s", csource);
        return MPR_ERR_CANT_READ;
    }
    mprTrace(4, "ESP command: %s\n", app->command);
    if (eroute->env) {
        elist = mprCreateList(0, 0);
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
    cchar       *defaultLayout, *page, *layout, *data, *prefix, *lpath;
    char        *err, *quote, *script, *canonical;
    ssize       len;
    int         recompile;

    if (app->error) {
        return;
    }
    eroute = route->eroute;
    defaultLayout = 0;
    if (kind == ESP_SRC) {
        prefix = "app_";
    } else if (kind == ESP_SERVICE) {
        prefix = "service_";
    } else if (kind == ESP_MIGRATION) {
        prefix = "migration_";
    } else {
        prefix = "view_";
    }
    canonical = mprGetPortablePath(mprGetRelPath(source, route->dir));
    app->cacheName = mprGetMD5WithPrefix(canonical, slen(canonical), prefix);
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
    if (kind & (ESP_SERVICE | ESP_MIGRATION | ESP_SRC)) {
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
            mprAddItem(app->flatItems, sfmt("esp_module_%s", mprTrimPathExt(mprGetPathBase(source))));
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
#if UNUSED
        if (eroute->archive) {
            vtrace("Archive", "%s", mprGetRelPath(mprTrimPathExt(app->module), NULL));
            if (runEspCommand(route, eroute->archive, app->csource, app->module) < 0) {
                return;
            }
#if !(BIT_DEBUG && MACOSX)
            /*
                MAC needs the object for debug information
             */
            mprDeletePath(mprJoinPathExt(mprTrimPathExt(app->module), BIT_OBJ));
#endif
        } else
#endif
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
    esp compile [flat | service_names | page_names]
        [] - compile services and pages separately into cache
        [service_names/page_names] - compile single file
        [app] - compile all files into a single source file with one init that calls all sub-init files

    esp compile path/name.ejs ...
        [service_names/page_names] - compile single file

    esp compile static
        use makerom code and compile static into a file in cache

 */
static void compile(MprList *routes)
{
    HttpRoute   *route;
    EspRoute    *eroute;
    MprFile     *file;
    MprKey      *kp;
    cchar       *name;
    int         next;

    if (app->error) {
        return;
    }
    for (ITERATE_KEYS(app->targets, kp)) {
        kp->type = 0;
    }
    if (app->flat && app->genlink) {
        app->slink = mprCreateList(0, 0);
    }
    for (ITERATE_ITEMS(routes, route, next)) {
        eroute = route->eroute;
        mprMakeDir(eroute->cacheDir, 0755, -1, -1, 1);
        mprTrace(2, "Build with route \"%s\" at %s", route->name, route->dir);
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
            name = app->appName ? app->appName : mprGetPathBase(route->dir);
            mprWriteFileFmt(file, "extern int esp_app_%s(HttpRoute *route, MprModule *module);", name);
            eroute = route->eroute;
            mprWriteFileFmt(file, "    /* SOURCE %s */\n",
                mprGetRelPath(mprJoinPath(eroute->cacheDir, sjoin(name, ".c", NULL)), NULL));
        }
        mprWriteFileFmt(file, "\nPUBLIC void appwebStaticInitialize()\n{\n");
        for (ITERATE_ITEMS(app->slink, route, next)) {
            name = app->appName ? app->appName : mprGetPathBase(route->dir);
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
    Allow a route that is responsible for a target
 */
static bool requiredRoute(HttpRoute *route)
{
    MprKey  *kp;

    if (app->targets == 0 || mprGetHashLength(app->targets) == 0) {
        return 1;
    }
    for (ITERATE_KEYS(app->targets, kp)) {
        if (mprIsParentPathOf(route->dir, kp->key)) {
            kp->type = ESP_FOUND_TARGET;
            return 1;
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


static void compileItems(HttpRoute *route)
{
    EspRoute    *eroute;
    MprDirEntry *dp;
    cchar       *path;
    int         next;

    eroute = route->eroute;

    if (eroute->servicesDir) {
        assert(eroute);
        app->files = mprGetPathFiles(eroute->servicesDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (selectResource(path, "c")) {
                compileFile(route, path, ESP_SERVICE);
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
        app->files = mprGetPathFiles(route->dir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (selectResource(path, "esp")) {
                compileFile(route, path, ESP_PAGE);
            }
        }
        /*
            Stand-alone services
         */
        if (route->sourceName) {
            path = mprJoinPath(route->dir, route->sourceName);
            compileFile(route, path, ESP_SERVICE);
        }
    }
}


static void compileFlat(HttpRoute *route)
{
    EspRoute    *eroute;
    MprDirEntry *dp;
    MprKeyValue *kp;
    cchar       *name;
    char        *path, *line;
    int         next, kind;

    eroute = route->eroute;
    name = app->appName ? app->appName : mprGetPathBase(route->dir);

    /*
        Flat ... Catenate all source
     */
    app->flatItems = mprCreateList(-1, 0);
    app->flatPath = mprJoinPath(eroute->cacheDir, sjoin(name, ".c", NULL));

    app->build = mprCreateList(0, 0);
    if (eroute->servicesDir) {
        app->files = mprGetPathFiles(eroute->servicesDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "c")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "service"));
            }
        }
    }
    if (eroute->viewsDir) {
        app->files = mprGetPathFiles(eroute->viewsDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            mprAddItem(app->build, mprCreateKeyPair(path, "view"));
        }
    }
    if (eroute->clientDir) {
        app->files = mprGetPathFiles(eroute->clientDir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "esp")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "page"));
            }
        }
    }
    if (!eroute->servicesDir && !eroute->clientDir) {
        /* MOB - better way to detect MV apps */
        app->files = mprGetPathFiles(route->dir, MPR_PATH_DESCEND);
        for (next = 0; (dp = mprGetNextItem(app->files, &next)) != 0 && !app->error; ) {
            path = dp->name;
            if (smatch(mprGetPathExt(path), "esp")) {
                mprAddItem(app->build, mprCreateKeyPair(path, "page"));
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
            if (smatch(kp->value, "service")) {
                kind = ESP_SERVICE;
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


static void generateApp(int argc, char **argv)
{
    HttpRoute   *route;
    cchar       *dir, *name;

    name = argv[0];
    if (smatch(name, ".")) {
        dir = mprGetCurrentPath();
        name = mprGetPathBase(dir);
        if (chdir(mprGetPathParent(dir)) < 0) {
            fail("Cannot change directory to %s", mprGetPathParent(dir));
            return;
        }
    }
    if (!findDefaultConfigFile()) {
        return;
    }
    route = createRoute(name);
    app->appName = sclone(name);
    makeEspDir(route->dir);
    generateAppFiles(route, argc - 1, &argv[1]);
    generateAppConfigFile(route);
    generateAppSrc(route);
    generateAppDb(route);
}


/*
    esp migration description table [field:type [, field:type] ...]

    The description is used to name the migration
 */
static void generateMigration(HttpRoute *route, int argc, char **argv)
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
    createMigration(route, name, table, stem, argc - 2, &argv[2]);
}


//  MOB - what if table already exists?

static void createMigration(HttpRoute *route, cchar *name, cchar *table, cchar *comment, int fieldCount, char **fields)
{
    EspRoute    *eroute;
    MprHash     *tokens;
    MprList     *files;
    MprDirEntry *dp;
    cchar       *dir, *seq, *forward, *backward, *data, *path, *def, *field, *tail, *typeDefine;
    char        *typeString;
    int         i, type, next;

    eroute = route->eroute;
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
    dir = mprJoinPath(eroute->dbDir, "migrations");
    makeEspDir(dir);

    path = sfmt("%s/%s_%s.c", dir, seq, name, ".c");

    tokens = mprDeserialize(sfmt("{ NAME: %s, COMMENT: '%s', FORWARD: '%s', BACKWARD: '%s' }",
        name, comment, forward, backward));
    data = stemplate(MigrationTemplate, tokens);

    files = mprGetPathFiles("db/migrations", MPR_PATH_RELATIVE);
    tail = sfmt("%s.c", name);
    for (ITERATE_ITEMS(files, dp, next)) {
        if (sends(dp->name, tail)) {
            if (!app->overwrite) {
                fail("A migration with the same description already exists: %s", dp->name);
                return;
            }
            mprDeletePath(mprJoinPath("db/migrations/", dp->name));
        }
    }
    makeEspFile(path, data, "Migration");
}


/*
    esp generate service name [action [, action] ...]
 */
static void generateService(HttpRoute *route, int argc, char **argv)
{
    EspRoute    *eroute;
    MprHash     *tokens;
    cchar       *defines, *name, *path, *data, *title, *action;
    int         i;

    if (argc < 1) {
        usageError();
        return;
    }
    if (app->error) {
        return;
    }
    eroute = route->eroute;
    name = sclone(argv[0]);
    title = spascal(name);
    path = mprJoinPathExt(mprJoinPath(eroute->servicesDir, name), ".c");
    defines = sclone("");
    for (i = 1; i < argc; i++) {
        action = argv[i];
        defines = sjoin(defines, sfmt("    espDefineAction(route, \"%s-%s\", %s);\n", name, action, action), NULL);
    }
    tokens = mprDeserialize(sfmt("{ NAME: %s, TITLE: %s, DEFINE_ACTIONS: '%s' }", name, title, defines));

    data = stemplate(ServiceHeader, tokens);
    for (i = 1; i < argc; i++) {
        action = argv[i];
        data = sjoin(data, sfmt("static void %s() {\n}\n\n", action), NULL);
    }
    data = sjoin(data, stemplate(ServiceFooter, tokens), NULL);
    makeEspFile(path, data, "Service");
}


static void generateScaffoldService(HttpRoute *route, int argc, char **argv)
{
    EspRoute    *eroute;
    MprHash     *tokens;
    cchar       *defines, *name, *path, *data, *title;

    if (app->error) {
        return;
    }
    eroute = route->eroute;
    name = sclone(argv[0]);
    title = spascal(name);

    path = mprJoinPathExt(mprJoinPath(eroute->servicesDir, name), ".c");
    defines = sclone("");
    tokens = mprDeserialize(sfmt("{ NAME: %s, TITLE: %s, DEFINE_ACTIONS: '%s' }", name, title, defines));

    if (!app->legacy) {
        data = stemplate(ScaffoldServiceHeader, tokens);
        data = sjoin(data, stemplate(ScaffoldServiceFooter, tokens), NULL);
#if DEPRECATE || 1
    } else {
        data = stemplate(LegacyScaffoldServiceHeader, tokens);
        data = sjoin(data, stemplate(LegacyScaffoldServiceFooter, tokens), NULL);
#endif
    }
    makeEspFile(path, data, "Scaffold");
}


/*
    Angular style only
 */
static void generateScaffoldController(HttpRoute *route, int argc, char **argv)
{
    EspRoute    *eroute;
    MprHash     *tokens;
    cchar       *defines, *name, *path, *data, *title;

    if (app->error) {
        return;
    }
    eroute = route->eroute;
    name = sclone(argv[0]);
    title = spascal(name);

    path = mprJoinPathExt(mprJoinPath(eroute->appDir, sfmt("%s/%sControl", name, title)), "js");
    defines = sclone("");
    tokens = mprDeserialize(sfmt("{ APPDIR: %s, NAME: %s, TITLE: %s, DEFINE_ACTIONS: '%s' }",
        eroute->appDir, name, title, defines));
    data = stemplate(ScaffoldController, tokens);
    makeEspFile(path, data, "Controller Scaffold");
}


/*
    Called with args: table [field:type [, field:type] ...]
 */
static void generateScaffoldMigration(HttpRoute *route, int argc, char **argv)
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
    createMigration(route, sfmt("create_scaffold_%s", table), table, comment, argc - 1, &argv[1]);
}


/*
    Angular only
 */
static void generateScaffoldModel(HttpRoute *route, int argc, char **argv)
{
    EspRoute    *eroute;
    MprHash     *tokens;
    cchar       *title, *name, *path, *data;

    if (app->error) {
        return;
    }
    eroute = route->eroute;
    name = sclone(argv[0]);
    title = spascal(name);

    path = sfmt("%s/%s/%s.js", eroute->appDir, name, title);
    tokens = mprDeserialize(sfmt("{ NAME: %s, TITLE: %s}", name, title));
    data = stemplate(ModelTemplate, tokens);
    makeEspFile(path, data, "Scaffold Model");
}

/*
    esp generate table name [field:type [, field:type] ...]
 */
static void generateTable(HttpRoute *route, int argc, char **argv)
{
    EspRoute    *eroute;
    Edi         *edi;
    cchar       *tableName, *field;
    char        *typeString;
    int         rc, i, type;

    if (app->error) {
        return;
    }
    eroute = route->eroute;
    tableName = sclone(argv[0]);
    if ((edi = eroute->edi) == 0) {
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
static void generateScaffoldViews(HttpRoute *route, int argc, char **argv)
{
    EspRoute    *eroute;
    MprHash     *tokens;
    cchar       *title, *name, *path, *data;

    if (app->error) {
        return;
    }
    eroute = route->eroute;
    name = sclone(argv[0]);
    title = spascal(name);

    if (!app->legacy) {
        tokens = mprDeserialize(sfmt("{ NAME: %s, TITLE: %s}", name, title));
        //  MOB - should have definition for appDir
        path = sfmt("%s/%s/list.html", eroute->appDir, name);
        data = stemplate(ScaffoldListView, tokens);
        makeEspFile(path, data, "Scaffold List Partial");

        path = sfmt("%s/%s/edit.html", eroute->appDir, name);
        data = stemplate(ScaffoldEditView, tokens);
        makeEspFile(path, data, "Scaffold Edit Partial");

#if DEPRECATE || 1
    } else {
        tokens = mprDeserialize(sfmt("{ NAME: %s, TITLE: %s, }", name, title));
        path = sfmt("%s/%s-list.esp", eroute->viewsDir, name);
        data = stemplate(LegacyScaffoldListView, tokens);
        makeEspFile(path, data, "Scaffold Index View");

        path = sfmt("%s/%s-edit.esp", eroute->viewsDir, name);
        data = stemplate(LegacyScaffoldEditView, tokens);
        makeEspFile(path, data, "Scaffold Edit View");
#endif
    }
}


/*
    esp generate scaffold NAME [field:type [, field:type] ...]
 */
static void generateScaffold(HttpRoute *route, int argc, char **argv)
{
    if (argc < 1) {
        usageError();
        return;
    }
    if (app->error) {
        return;
    }
    if (!app->legacy) {
        generateScaffoldModel(route, argc, argv);
        generateScaffoldController(route, argc, argv);
    }
    generateScaffoldMigration(route, argc, argv);
    generateScaffoldService(route, argc, argv);
    generateScaffoldViews(route, argc, argv);
    migrate(route, 0, 0);
}


static void generate(int argc, char **argv)
{
    HttpRoute   *route;
    char        *kind;

    if (argc < 2) {
        usageError();
        return;
    }
    kind = argv[0];

    if (smatch(kind, "service") || smatch(kind, "controller")) {
        route = getMvcRoute();
        generateService(route, argc - 1, &argv[1]);

    } else if (smatch(kind, "migration")) {
        route = getMvcRoute();
        generateMigration(route, argc - 1, &argv[1]);

    } else if (smatch(kind, "scaffold")) {
        route = getMvcRoute();
        generateScaffold(route, argc - 1, &argv[1]);

    } else if (smatch(kind, "table")) {
        route = getMvcRoute();
        generateTable(route, argc - 1, &argv[1]);

    } else {
        mprError("Unknown generation kind %s", kind);
        usageError();
        return;
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
static void migrate(HttpRoute *route, int argc, char **argv)
{
    MprModule   *mp;
    MprDirEntry *dp;
    EspRoute    *eroute;
    Edi         *edi;
    EdiRec      *mig;
    cchar       *command, *file;
    int         next, onlyOne, backward, found, i;
    uint64      seq, targetSeq, lastMigration, v;

    if (app->error) {
        return;
    }
    onlyOne = backward = 0;
    targetSeq = 0;
    lastMigration = 0;
    command = 0;

    eroute = route->eroute;
    if ((edi = eroute->edi) == 0) {
        fail("Database not open. Check appweb.conf");
        return;
    }
    if (app->rebuild) {
        ediClose(edi);
        mprDeletePath(edi->path);
        if ((eroute->edi = ediOpen(edi->path, edi->provider->name, edi->flags | EDI_CREATE)) == 0) {
            fail("Cannot open database %s", edi->path);
        }
    }
    /*
        Each database has a _EspMigrations table which has a record for each migration applied
     */
    if ((app->migrations = ediReadTable(edi, ESP_MIGRATIONS)) == 0) {
        //  MOB - rc
        //  MOB - autosave is on
        //  MOB - must unlink if either of these fail
        ediAddTable(edi, ESP_MIGRATIONS);
        ediAddColumn(edi, ESP_MIGRATIONS, "id", EDI_TYPE_INT, EDI_AUTO_INC | EDI_INDEX | EDI_KEY);
        ediAddColumn(edi, ESP_MIGRATIONS, "version", EDI_TYPE_STRING, 0);
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
                //  MOB RC
                edi->back(edi);
            } else {
                trace("Migrate", "Apply %s ", app->base);
                //  MOB RC
                edi->forw(edi);
            }
            if (backward) {
                assert(mig);
                ediDeleteRow(edi, ESP_MIGRATIONS, ediGetFieldValue(mig, "id"));
            } else {
                //  MOB - must test return codes
                mig = ediCreateRec(edi, ESP_MIGRATIONS);
                ediSetField(mig, "version", itos(seq));
                ediUpdateRec(edi, mig);
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


static void fixupFile(HttpRoute *route, cchar *path)
{
    ssize   len;
    char    *data, *tmp;

    if ((data = mprReadPathContents(path, &len)) == 0) {
        /* Fail silently */
        return;
    }
    //  MOB - Use stemplate and tokens.
    data = sreplace(data, "${NAME}", app->appName);
    data = sreplace(data, "${TITLE}", spascal(app->appName));
    data = sreplace(data, "${DATABASE}", app->database);
    data = sreplace(data, "${DIR}", route->dir);
    data = sreplace(data, "${LISTEN}", app->listen);
    data = sreplace(data, "${BINDIR}", app->binDir);
    data = sreplace(data, "${ROUTESET}", app->routeSet);
    tmp = mprGetTempPath(route->dir);
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
    esp generate app NAME|. kind compponents
 */
static void generateAppFiles(HttpRoute *route, int argc, char **argv)
{
    EspRoute    *eroute;
    cchar       *proto, *path;
    char        *argvbuf[1];
    int         i;

    eroute = route->eroute;
#if DEPRECATE || 1
    if (argc > 0 && smatch(argv[0], "legacy")) {
        app->legacy = 1;
    }
#endif
    if (argc == 0) {
        /* Default kind is Angular */
        argvbuf[0] = "angular";
        argv = argvbuf;
        argc = 1;
    }
    app->routeSet = sclone("restful");

    /*
        The first component is the primary application component. There should be a route-set for it.
     */
    proto = mprJoinPath(app->binDir, "esp-proto");
    for (i = 0; i < argc; i++) {
        path = mprJoinPath(proto, argv[i]);
        copyEspDir(path, route->dir);
    }
    fixupFile(route, mprJoinPath(eroute->clientDir, "index.esp"));
    fixupFile(route, mprJoinPath(eroute->appDir, "main.js"));
    fixupFile(route, mprJoinPath(eroute->layoutsDir, "default.esp"));
}


static void copyEspDir(cchar *fromDir, cchar *toDir)
{
    MprList     *files;
    MprDirEntry *dp;
    char        *from, *to;
    int         next;

    files = mprGetPathFiles(fromDir, MPR_PATH_DESCEND | MPR_PATH_RELATIVE | MPR_PATH_NODIRS);
    for (next = 0; (dp = mprGetNextItem(files, &next)) != 0 && !app->error; ) {
        from = mprJoinPath(fromDir, dp->name);
        to = mprJoinPath(toDir, dp->name);
        if (mprMakeDir(mprGetPathDir(to), 0755, -1, -1, 1) < 0) {
            fail("Cannot make directory %s", mprGetPathDir(to));
            return;
        }
        if (mprPathExists(to, R_OK) && !app->overwrite) {
            trace("Exists",  "File: %s", mprGetRelPath(to, 0));
        } else {
            trace("Create",  "File: %s", mprGetRelPath(to, 0));
            if (mprCopyPath(from, to, 0644) < 0) {
                fail("Cannot copy file %s to %s", from, mprGetRelPath(to, 0));
                return;
            }
        }
    }
}


static void generateAppConfigFile(HttpRoute *route)
{
    fixupFile(route, mprJoinPath(route->dir, "appweb.conf"));
    fixupFile(route, mprJoinPath(route->dir, "app.conf"));
}


#if UNUSED
static void generateAppHeader(HttpRoute *route)
{
    MprHash *tokens;
    char    *path, *data;

    path = mprJoinPath(route->dir, mprJoinPathExt("esp-app", "h"));
    tokens = mprDeserialize(sfmt("{ NAME: %s, TITLE: %s }", app->appName, spascal(app->appName)));
    data = stemplate(AppHeader, tokens);
    makeEspFile(path, data, "Header");
}
#endif


static void generateAppSrc(HttpRoute *route)
{
    EspRoute    *eroute;
    MprHash     *tokens;
    char        *path, *data;

    eroute = route->eroute;
    path = mprJoinPath(eroute->srcDir, "app.c");
    tokens = mprDeserialize(sfmt("{ NAME: %s, TITLE: %s }", app->appName, spascal(app->appName)));
    data = stemplate(AppSrc, tokens);
    makeEspFile(path, data, "Header");
}


static void generateAppDb(HttpRoute *route)
{
    EspRoute    *eroute;
    cchar       *ext;
    char        *dbpath, buf[1];

    if (!app->database) {
        return;
    }
    eroute = route->eroute;
    ext = app->database;
    if ((smatch(app->database, "sdb") && !BIT_PACK_SDB) || (smatch(app->database, "mdb") && !BIT_PACK_MDB)) {
        fail("Cannot find database provider: \"%s\". Ensure Appweb is configured to support \"%s\"",
                app->database, app->database);
        return;
    }
    dbpath = sfmt("%s/%s.%s", eroute->dbDir, app->appName, ext);
    makeEspDir(mprGetPathDir(dbpath));
    if (mprWritePathContents(dbpath, buf, 0, 0664) < 0) {
        return;
    }
    trace("Create", "Database: %s", mprGetRelPath(dbpath, 0));
}


/*
    Search strategy is:

    [--config path] : ./appweb.conf : [parent]/appweb.conf
 */
static bool findConfigFile(bool mvc)
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
    return 1;
}


static bool findDefaultConfigFile()
{
    app->configFile = mprJoinPath(mprGetAppDir(), "esp.conf");
    if (!mprPathExists(app->configFile, R_OK)) {
        fail("Cannot open config file %s", app->configFile);
        return 0;
    }
    return 1;
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


//  MOB msg UNUSED
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
    //  MOB - msg UNUSED
    msg = sfmt("%s: %s", msg, path);
    if (!exists) {
        trace("Create", mprGetRelPath(path, 0));
    } else {
        trace("Overwrite", path);
    }
}


static void usageError(Mpr *mpr)
{
    cchar   *name;

    name = mprGetAppName();

    mprEprintf("\nESP Usage:\n\n"
    "  %s [options] [commands]\n\n"
    "  Options:\n"
    "    --chdir dir                # Change to the named directory first\n"
    "    --config configFile        # Use named config file instead appweb.conf\n"
    "    --database name            # Database provider 'mdb|sdb' \n"
    "    --flat                     # Compile into a single module\n"
    "    --genlink                  # Generate a static link module for flat compilations\n"
    "    --keep                     # Keep intermediate source\n"
#if DEPRECATE || 1
    "    --legacy                   # Generate legacy style apps (default)\n"
#endif
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
    "    --verbose                  # Emit verbose trace \n"
    "    --why                      # Why compile or skip\n"
    "\n"
    "  Commands:\n"
    "    esp clean\n"
    "    esp compile\n"
    "    esp compile [pathFilters ...]\n"
    "    esp migrate [forward|backward|NNN]\n"
    "    esp generate app name [components...]\n"
    "    esp generate service name [action [, action] ...\n"
    "    esp generate migration description model [field:type [, field:type] ...]\n"
    "    esp generate scaffold model [field:type [, field:type] ...]\n"
    "    esp generate table name [field:type [, field:type] ...]\n"
    "    esp run\n"
    "", name);
#if UNUSED && KEEP
    "    --static               # Compile static content into C code\n"
#endif
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
