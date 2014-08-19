/**
    appweb.c  -- AppWeb main program

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.

    usage: appweb [options] 
    or:    appweb [options] [documents] [[ip][:port] ...]
            --chroot dir            # Change root to dir (unix only)
            --config configFile     # Use given config file instead 
            --debugger              # Disable timeouts to make debugging easier
            --home path             # Set the home working directory
            --log logFile:level     # Log to file file at verbosity level
            --name uniqueName       # Name for this instance
            --show                  # Show route table
            --trace traceFile:level # Log to file file at verbosity level
            --version               # Output version information
            -v                      # Same as --log stderr:2
            -DIGIT                  # Same as --log stderr:DIGIT
 */

/********************************* Includes ***********************************/

#include    "appweb.h"

/********************************** Locals ************************************/
/*
    Global application object. Provides the top level roots of all data objects for the GC.
 */
typedef struct AppwebApp {
    Mpr         *mpr;
    MprSignal   *traceToggle;
    MprSignal   *statusCheck;
    char        *documents;
    char        *home;
    char        *configFile;
    char        *pathVar;
    int         show;
    int         workers;
} AppwebApp;

static AppwebApp *app;

/***************************** Forward Declarations ***************************/

static int changeRoot(cchar *jail);
static int checkEnvironment(cchar *program);
static int findAppwebConf();
static void loadStaticModules();
static void manageApp(AppwebApp *app, int flags);
static int createEndpoints(int argc, char **argv);
static void usageError();

#if ME_UNIX_LIKE
    #if defined(SIGINFO) || defined(SIGPWR) || defined(SIGRTMIN)
        static void statusCheck(void *ignored, MprSignal *sp);
        static void addSignals();
    #endif
    static void traceHandler(void *ignored, MprSignal *sp);
    static int  unixSecurityChecks(cchar *program, cchar *home);
#elif ME_WIN_LIKE
    static int writePort();
    static long msgProc(HWND hwnd, uint msg, uint wp, long lp);
#endif

/*
    If customize.h does not define, set reasonable defaults.
 */
#ifndef ME_SERVER_ROOT
    #define ME_SERVER_ROOT mprGetCurrentPath()
#endif
#ifndef ME_CONFIG_FILE
    #define ME_CONFIG_FILE NULL
#endif

/*********************************** Code *************************************/

MAIN(appweb, int argc, char **argv, char **envp)
{
    Mpr     *mpr;
    cchar   *argp, *jail;
    char    *logSpec, *traceSpec;
    int     argind;

    jail = 0;
    logSpec = 0;
    traceSpec = 0;

    if ((mpr = mprCreate(argc, argv, MPR_USER_EVENTS_THREAD)) == NULL) {
        exit(1);
    }
    if ((app = mprAllocObj(AppwebApp, manageApp)) == NULL) {
        exit(2);
    }
    mprAddRoot(app);
    mprAddStandardSignals();
#if ME_ROM
    extern MprRomInode romFiles[];
    mprSetRomFileSystem(romFiles);
#endif
    if (httpCreate(HTTP_CLIENT_SIDE | HTTP_SERVER_SIDE) == 0) {
        exit(3);
    }
    app->mpr = mpr;
    app->workers = -1;
    app->home = sclone(ME_SERVER_ROOT);
    app->documents = app->home;
    argc = mpr->argc;
    argv = (char**) mpr->argv;

    for (argind = 1; argind < argc; argind++) {
        argp = argv[argind];
        if (*argp != '-') {
            break;
        }
        if (smatch(argp, "--config") || smatch(argp, "--conf")) {
            if (argind >= argc) {
                usageError();
            }
            app->configFile = sclone(argv[++argind]);

#if ME_UNIX_LIKE
        } else if (smatch(argp, "--chroot")) {
            if (argind >= argc) {
                usageError();
            }
            jail = mprGetAbsPath(argv[++argind]);
#endif

        } else if (smatch(argp, "--debugger") || smatch(argp, "-D")) {
            mprSetDebugMode(1);

        } else if (smatch(argp, "--exe")) {
            if (argind >= argc) {
                usageError();
            }
            mpr->argv[0] = mprGetAbsPath(argv[++argind]);
            mprSetAppPath(mpr->argv[0]);
            mprSetModuleSearchPath(NULL);

        } else if (smatch(argp, "--home")) {
            if (argind >= argc) {
                usageError();
            }
            app->home = sclone(argv[++argind]);
            if (chdir(app->home) < 0) {
                mprLog("error appweb", 0, "Cannot change directory to %s", app->home);
                exit(4);
            }

        } else if (smatch(argp, "--log") || smatch(argp, "-l")) {
            if (argind >= argc) {
                usageError();
            }
            logSpec = argv[++argind];

        } else if (smatch(argp, "--name") || smatch(argp, "-n")) {
            if (argind >= argc) {
                usageError();
            }
            mprSetAppName(argv[++argind], 0, 0);

        } else if (smatch(argp, "--threads")) {
            if (argind >= argc) {
                usageError();
            }
            app->workers = atoi(argv[++argind]);

        } else if (smatch(argp, "--show") || smatch(argp, "-s")) {
            app->show = 1;

        } else if (smatch(argp, "--trace") || smatch(argp, "-t")) {
            if (argind >= argc) {
                usageError();
            }
            traceSpec = argv[++argind];

        } else if (smatch(argp, "--verbose") || smatch(argp, "-v")) {
            if (!logSpec) {
                logSpec = sfmt("stderr:2");
            }
            if (!traceSpec) {
                traceSpec = sfmt("stderr:2");
            }

        } else if (smatch(argp, "--version") || smatch(argp, "-V")) {
            mprPrintf("%s\n", ME_VERSION);
            exit(0);

        } else if (*argp == '-' && isdigit((uchar) argp[1])) {
            if (!logSpec) {
                logSpec = sfmt("stderr:%d", (int) stoi(&argp[1]));
            }
            if (!traceSpec) {
                traceSpec = sfmt("stderr:%d", (int) stoi(&argp[1]));
            }

        } else if (smatch(argp, "-?") || scontains(argp, "-help")) {
            usageError();
            exit(5);

        } else if (*argp == '-') {
            mprLog("error appweb", 0, "Unknown switch \"%s\"", argp);
            usageError();
            exit(5);
        }
    }
    app->home = mprGetAbsPath(app->home);
    if (logSpec) {
        mprStartLogging(logSpec, MPR_LOG_CONFIG | MPR_LOG_CMDLINE);
    }
    if (traceSpec) {
        httpStartTracing(traceSpec);
    }
    if (mprStart() < 0) {
        mprLog("error appweb", 0, "Cannot start MPR");
        mprDestroy();
        return MPR_ERR_CANT_INITIALIZE;
    }
    if (checkEnvironment(argv[0]) < 0) {
        exit(6);
    }
    if (argc == argind && !app->configFile) {
        if (findAppwebConf() < 0) {
            exit(7);
        }
    }
    loadStaticModules();

    if (jail && changeRoot(jail) < 0) {
        exit(8);
    }
    if (createEndpoints(argc - argind, &argv[argind]) < 0) {
        return MPR_ERR_CANT_INITIALIZE;
    }
    appwebStaticInitialize();

    httpSetEndpointStartLevel(0);
    if (httpStartEndpoints() < 0) {
        mprLog("error appweb", 0, "Cannot start HTTP service, exiting.");
        exit(9);
    }
    if (app->show) {
        httpLogRoutes(0, 0);
    }
    mprServiceEvents(-1, 0);

    mprLog("info appweb", 1, "Stopping Appweb ...");
    mprDestroy();
    return mprGetExitStatus();
}


static void manageApp(AppwebApp *app, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(app->traceToggle);
        mprMark(app->statusCheck);
        mprMark(app->documents);
        mprMark(app->configFile);
        mprMark(app->pathVar);
        mprMark(app->home);
    }
}


/*
    Move into a chroot jail
 */
static int changeRoot(cchar *jail)
{
#if ME_UNIX_LIKE
    if (chdir(app->home) < 0) {
        mprLog("error appweb", 0, "Cannot change directory to %s", app->home);
        return MPR_ERR_CANT_INITIALIZE;
    }
    if (chroot(jail) < 0) {
        if (errno == EPERM) {
            mprLog("error appweb", 0, "Must be super user to use the --chroot option");
        } else {
            mprLog("error appweb", 0, "Cannot change change root directory to %s, errno %d", jail, errno);
        }
        return MPR_ERR_CANT_INITIALIZE;
    } else {
        mprLog("info appweb", 2, "Chroot to: \"%s\"", jail);
    }
#endif
    return 0;
}


static void loadStaticModules()
{
#if ME_STATIC
    /*
        If doing a static build, must now reference required modules to force the linker to include them.
        On linux we cannot lookup symbols with dlsym(), so we must invoke explicitly here.

        Add your modules here if you are doing a static link.
     */
    Http *http = HTTP;
#if ME_COM_CGI
    maCgiHandlerInit(http, mprCreateModule("cgiHandler", 0, 0, http));
#endif
#if ME_COM_ESP
    maEspHandlerInit(http, mprCreateModule("espHandler", 0, 0, http));
#endif
#if ME_COM_EJS
    maEspHandlerInit(http, mprCreateModule("ejsHandler", 0, 0, http));
#endif
#if ME_COM_PHP
    maPhpHandlerInit(http, mprCreateModule("phpHandler", 0, 0, http));
#endif
#if ME_COM_SSL
    maSslModuleInit(http, mprCreateModule("sslModule", 0, 0, http));
#endif
#endif /* ME_STATIC */
}


static int createEndpoints(int argc, char **argv)
{
    char    *ip;
    int     argind, port, secure;

    ip = 0;
    port = -1;
    argind = 0;

    mprGC(MPR_GC_FORCE | MPR_GC_COMPLETE);

    if (argc == 0) {
        if (maParseConfig(app->configFile, 0) < 0) {
            return MPR_ERR_CANT_CREATE;
        }
    } else {
        app->documents = sclone(argv[argind++]);
        if (argind == argc) {
            if (maConfigureServer(NULL, app->home, app->documents, NULL, ME_HTTP_PORT, 0) < 0) {
                return MPR_ERR_CANT_CREATE;
            }
        } else while (argind < argc) {
            mprParseSocketAddress(argv[argind++], &ip, &port, &secure, 80);
            if (maConfigureServer(NULL, app->home, app->documents, ip, port, 0) < 0) {
                return MPR_ERR_CANT_CREATE;
            }
        }
    }
    if (app->workers >= 0) {
        mprSetMaxWorkers(app->workers);
    }
    
#if ME_WIN_LIKE
    writePort();
#elif ME_UNIX_LIKE
    addSignals();
#endif
    mprGC(MPR_GC_FORCE | MPR_GC_COMPLETE);
    return 0;
}


/*
    If ME_CONFIG_FILE is defined, use that as the base name for appweb.conf. Otherwise, use
    "programName.conf". Search order is:

        "."/BASE
        ME_SERVER_ROOT/BASE
        EXE/../BASE
        EXE/../appweb.conf
 */
static int findAppwebConf()
{
    char    *base, *filename;

    if (ME_CONFIG_FILE) {
        base = sclone(ME_CONFIG_FILE);
    } else {
        base = mprJoinPathExt(mprGetAppName(), ".conf");
    }
#if !ME_ROM
    filename = base;
    if (!mprPathExists(filename, R_OK)) {
        filename = mprJoinPath(app->home, base);
        if (!mprPathExists(filename, R_OK)) {
            filename = mprJoinPath(mprGetPathParent(mprGetAppDir()), base);
            if (!mprPathExists(filename, R_OK)) {
                filename = mprJoinPath(mprGetPathParent(mprGetAppDir()), "appweb.conf");
                if (!mprPathExists(filename, R_OK)) {
                    mprError("Cannot find config file %s", base);
                    return MPR_ERR_CANT_OPEN;
                }
            }
        }
    }
#endif
    app->configFile = filename;
    return 0;
}


static void usageError(Mpr *mpr)
{
    cchar   *name;

    name = mprGetAppName();

    mprEprintf("\n%s Usage:\n\n"
        "  %s [options]\n"
        "  %s [options] documents ip[:port] ...\n\n"
        "  Without [documents ip:port], %s will read the appweb.conf configuration file.\n\n"
        "  Options:\n"
        "    --config configFile     # Use named config file instead appweb.conf\n"
        "    --chroot directory      # Change root directory to run more securely (Unix)\n"
        "    --debugger              # Disable timeouts to make debugging easier\n"
        "    --exe path              # Set path to Appweb executable on Vxworks\n"
        "    --home directory        # Change to directory to run\n"
        "    --log logFile:level     # Log to file at verbosity level (0-5)\n"
        "    --name uniqueName       # Unique name for this instance\n"
        "    --show                  # Show route table\n"
        "    --trace traceFile:level # Trace to file at verbosity level (0-5)\n"
        "    --verbose               # Same as --log stderr:2\n"
        "    --version               # Output version information\n"
        "    --DIGIT                 # Same as --log stderr:DIGIT\n\n",
        mprGetAppTitle(), name, name, name);
    exit(10);
}


/*
    Security checks. Make sure we are staring with a safe environment
 */
static int checkEnvironment(cchar *program)
{
#if ME_UNIX_LIKE
    char   *home;
    home = mprGetCurrentPath();
    if (unixSecurityChecks(program, home) < 0) {
        return -1;
    }
    app->pathVar = sjoin("PATH=", getenv("PATH"), ":", mprGetAppDir(), NULL);
    putenv(app->pathVar);
#endif
    return 0;
}


#if ME_UNIX_LIKE
static void addSignals()
{
    app->traceToggle = mprAddSignalHandler(SIGUSR2, traceHandler, 0, 0, MPR_SIGNAL_AFTER);

    /*
        Signal to dump memory stats. Must configure with ./configure --set mprAllocCheck=true
     */
#if defined(SIGINFO)
    app->statusCheck = mprAddSignalHandler(SIGINFO, statusCheck, 0, 0, MPR_SIGNAL_AFTER);
#elif defined(SIGPWR)
    app->statusCheck = mprAddSignalHandler(SIGPWR, statusCheck, 0, 0, MPR_SIGNAL_AFTER);
#elif defined(SIGRTMIN)
    app->statusCheck = mprAddSignalHandler(SIGRTMIN, statusCheck, 0, 0, MPR_SIGNAL_AFTER);
#endif
}


/*
    SIGUSR2 will toggle trace from level 2 to 4
 */
static void traceHandler(void *ignored, MprSignal *sp)
{
    int     level;

    level = mprGetLogLevel() > 2 ? 2 : 4;
    mprLog("info appweb", 0, "Change log and trace level to %d", level);
    mprSetLogLevel(level);
    httpSetTraceLevel(level);
}


/*
    SIGINFO|SIGPWR|SIGRTMIN will dump memory stats
    For detailed memory stats, use: ./configure --set memoryCheck=true
 */
static void statusCheck(void *ignored, MprSignal *sp)
{
    mprLog(0, 0, "%s", httpStatsReport(0));
    if (MPR->heap->track) {
        mprPrintMem("MPR Memory Report", MPR_MEM_DETAIL);
    } else {
        mprPrintMem("MPR Memory Report", 0);
    }
}


/*
    Security checks. Make sure we are staring with a safe environment
 */
static int unixSecurityChecks(cchar *program, cchar *home)
{
#if !ME_ROM
    struct stat     sbuf;

    if (((stat(home, &sbuf)) != 0) || !(S_ISDIR(sbuf.st_mode))) {
        mprLog("error appweb", 0, "Cannot access directory: %s", home);
        return MPR_ERR_BAD_STATE;
    }
    if ((sbuf.st_mode & S_IWOTH) || (sbuf.st_mode & S_IWGRP)) {
        mprLog("error appweb", 0, "Security risk %s is writeable by others", home);
    }

    /*
        Should always convert the program name into a fully qualified path. Otherwise this fails.
     */
    if (*program == '/') {
        if ((stat(program, &sbuf)) != 0) {
            mprLog("error appweb", 0, "Cannot access program: %s", program);
            return MPR_ERR_BAD_STATE;
        }
        if ((sbuf.st_mode & S_IWOTH) || (sbuf.st_mode & S_IWGRP)) {
            mprLog("error appweb", 0, "Security risk, %s is writeable by others", program);
        }
        if (sbuf.st_mode & S_ISUID) {
            mprLog("error appweb", 0, "Security risk, %s is setuid", program);
        }
        if (sbuf.st_mode & S_ISGID) {
            mprLog("error appweb", 0, "Security risk, %s is setgid", program);
        }
    }
#endif /* !ME_ROM */
    return 0;
}
#endif /* ME_UNIX_LIKE */


#if ME_WIN_LIKE
/*
    Write the port so the monitor can manage
 */ 
static int writePort()
{
    HttpEndpoint    *endpoint;
    char            numBuf[16], *path;
    int             fd, len;

    if ((endpoint = mprGetFirstItem(HTTP->endpoints)) == 0) {
        mprLog("error appweb", 0, "No configured endpoints");
        return MPR_ERR_CANT_ACCESS;
    }
    //  FUTURE - should really go to a ME_LOG_DIR (then fix uninstall.sh)
    path = mprJoinPath(mprGetAppDir(), "../.port.log");
    if ((fd = open(path, O_CREAT | O_WRONLY | O_TRUNC, 0666)) < 0) {
        mprLog("error appweb", 0, "Could not create port file %s", path);
        return MPR_ERR_CANT_CREATE;
    }
    fmt(numBuf, sizeof(numBuf), "%d", endpoint->port);

    len = (int) strlen(numBuf);
    numBuf[len++] = '\n';
    if (write(fd, numBuf, len) != len) {
        mprLog("error appweb", 0, "Write to file %s failed", path);
        return MPR_ERR_CANT_WRITE;
    }
    close(fd);
    return 0;
}
#endif /* ME_WIN_LIKE */


#if VXWORKS
/*
    VxWorks link resolution
 */
PUBLIC int _cleanup() {
    return 0;
}
PUBLIC int _exit() {
    return 0;
}

/*
    Create a routine to pull in the GCC support routines for double and int64 manipulations. Do this
    incase any modules reference these routines. Without this, the modules have to reference them. Which leads to
    multiple defines if two modules include them.
 */
double  __dummy_appweb_floating_point_resolution(double a, double b, int64 c, int64 d, uint64 e, uint64 f) {
    /*
        Code to pull in moddi3, udivdi3, umoddi3, etc .
     */
    a = a / b; a = a * b; c = c / d; c = c % d; e = e / f; e = e % f;
    c = (int64) a;
    d = (uint64) a;
    a = (double) c;
    a = (double) e;
    if (a == b) {
        return a;
    } return b;
}

#endif

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
