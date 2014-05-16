/*
    appweb.h -- Embedthis Appweb HTTP Web Server header

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

#ifndef _h_APPWEB
#define _h_APPWEB 1

/********************************* Includes ***********************************/

#include    "mpr.h"
#include    "http.h"

#ifdef __cplusplus
extern "C" {
#endif

/********************************* Tunables ***********************************/

#define MA_UNLOAD_TIMEOUT       "5mins"             /**< Default module inactivity unload timeout */

/********************************** Defines ***********************************/
/*
    Pack defaults
 */
#ifndef ME_COM_CGI
    #define ME_COM_CGI 0
#endif
#ifndef ME_COM_DIR
    #define ME_COM_DIR 0
#endif
#ifndef ME_COM_EJS
    #if ME_EJS_PRODUCT
        #define ME_COM_EJS 1
    #else
        #define ME_COM_EJS 0
    #endif
#endif
#ifndef ME_COM_ESP
    #if ME_ESP_PRODUCT
        #define ME_COM_ESP 1
    #else
        #define ME_COM_ESP 0
    #endif
#endif
#ifndef ME_COM_MDB
    #define ME_COM_MDB 0
#endif
#ifndef ME_COM_PHP
    #define ME_COM_PHP 0
#endif
#ifndef ME_COM_SDB
    #define ME_COM_SDB 0
#endif
#ifndef ME_COM_SSL
    #define ME_COM_SSL 0
#endif

#if !DOXYGEN
struct MaAppweb;
struct MaServer;
struct MaState;
#endif

/**
    Singleton Appweb service for the application
    @description There is one instance of MaAppweb per application. It manages a list of HTTP servers running in
        the application.
    @defgroup MaAppweb MaAppweb
    @see Http maAddServer maCreateAppweb maLoadModule 
        maLookupServer maParseInit maRenderDirListing maSetDefaultServer maStartAppweb maStopAppweb 
    @stability Internal
 */
typedef struct MaAppweb {
    struct MaServer     *defaultServer;         /**< Default server object */
    MprList             *servers;               /**< List of server objects */
    MprHash             *directives;            /**< Config file directives */
    Http                *http;                  /**< Http service object */
    int                 staticLink;             /**< Target platform is using a static linking */
} MaAppweb;

/**
    Add a server
    @description Add a server to the list of appweb managed web servers
    @param appweb Appweb object created via #maCreateAppweb
    @param server MaServer object
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC void maAddServer(MaAppweb *appweb, struct MaServer *server);

/** 
    Create the Appweb object.
    @description Appweb uses a singleton Appweb object to manage multiple web servers instances.
    @return A Http object. Use mprFree to close and release.
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC MaAppweb *maCreateAppweb();

/**
    Load an appweb module
    @description Load an appweb module. If the module is already loaded, this call will return successfully without
        reloading. Modules can be dynamically loaded or may also be pre-loaded using static linking.
    @param appweb Appweb object created via #maCreateAppweb
    @param name User name. Must be defined in the system password file.
    @param libname Library path name
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC int maLoadModule(MaAppweb *appweb, cchar *name, cchar *libname);

/**
    Lookup a server
    @description Lookup a server by name and return the MaServer object
    @param appweb Appweb object created via #maCreateAppweb
    @param name Server name
    @return MaServer object
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC struct MaServer *maLookupServer(MaAppweb *appweb, cchar *name);

/**
    Test if a directory listing should be rendered for the request.
    @param conn Connection object
    @return True if a directory listing is configured to be rendered for this request.
    @ingroup MaAppweb
    @stability Internal
    @internal
 */
PUBLIC bool maRenderDirListing(HttpConn *conn);

/**
    Initialize the config file parser.
    @param appweb Appweb object created via #maCreateAppweb
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaAppweb
    @stability Internal
    @internal
 */
PUBLIC int maParseInit(MaAppweb *appweb);

/**
    Set the default server
    @param appweb Appweb object created via #maCreateAppweb
    @param server MaServer object
    @ingroup MaAppweb
    @stability Internal
 */
PUBLIC void maSetDefaultServer(MaAppweb *appweb, struct MaServer *server);

/**
    Start Appweb services
    @description This starts listening for requests on all configured servers.
    @param appweb Appweb object created via #maCreateAppweb
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC int maStartAppweb(MaAppweb *appweb);

/**
    Stop Appweb services
    @description This stops listening for requests on all configured servers. Shutdown is somewhat graceful.
    @param appweb Appweb object created via #maCreateAppweb
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC int maStopAppweb(MaAppweb *appweb);

/*
    Internal
 */
PUBLIC int maCgiHandlerInit(Http *http, MprModule *mp);
PUBLIC int maDirHandlerInit(Http *http, MprModule *mp);
PUBLIC int maEjsHandlerInit(Http *http, MprModule *mp);
PUBLIC int maEspHandlerInit(Http *http, MprModule *mp);
PUBLIC int maPhpHandlerInit(Http *http, MprModule *mp);
PUBLIC int maSslModuleInit(Http *http, MprModule *mp);
PUBLIC int maOpenDirHandler(Http *http);
PUBLIC int maOpenFileHandler(Http *http);

/*
    This is exported from slink.c which is either manually created or generated locally
 */
PUBLIC void appwebStaticInitialize();

/********************************** MaServer **********************************/
/**
    Appweb server object. 
    @description An application may have any number of HTTP servers, each managed by an MaServer instance.
    @stability Evolving
    @defgroup MaServer MaServer
    @see MaServer maAddEndpoint maConfigureServer maCreateServer maParseConfig maRunSimpleWebServer 
        maRunWebServer maServiceWebServer maSetServerAddress maSetServerHome maStartServer maStopServer 
        maValidateServer maWriteAuthFile
    @stability Internal
 */
typedef struct MaServer {
    char            *name;                  /**< Unique name for this server */
    MaAppweb        *appweb;                /**< Appweb control object */
    Http            *http;                  /**< Http service object (copy of appweb->http) */
    HttpLimits      *limits;                /**< Limits for this server */
    MprList         *endpoints;             /**< List of HttpEndpoints */
    HttpHost        *defaultHost;           /**< Default host for this server */
} MaServer;

/**
    Add a listening endpoint
    @param server Server object to modify
    @param endpoint Listening endpoint to add to the server
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC void maAddEndpoint(MaServer *server, HttpEndpoint *endpoint);

#define MA_NO_MODULES 0x1                   /**< Configure server but do not load modules */

/** 
    Configure a web server.
    @description This will configure a web server based on either a configuration file or using the supplied
        IP address and port. 
    @param server MaServer object created via #maCreateServer
    @param configFile File name of the Appweb configuration file (appweb.conf) that defines the web server configuration.
    @param home Admin directory for the server. This overrides the value in the config file.
    @param documents Default directory for web documents to serve. This overrides the value in the config file.
    @param ip IP address to listen on. This overrides the value specified in the config file.
    @param port Port address to listen on. This overrides the value specified in the config file.
    @param flags Set to MA_NO_MODULES to suppress loading modules. Otherwise set to zero.
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaServer
    @stability Stable
 */
PUBLIC int maConfigureServer(MaServer *server, cchar *configFile, cchar *home, cchar *documents, cchar *ip, int port, int flags);

/** 
    Create a MaServer object
    @description Create new MaServer object. This routine creates a bare MaServer object, loads any required static
        modules  and performs minimal configuration. To use the server object created, more configuration will be 
        required before starting Http services.
        If you want a one-line embedding of Appweb, use #maRunWebServer or #maRunSimpleWebServer.
    @param appweb Http object returned from #maCreateAppweb
    @param name Name of the web server. This name is used as the initial server name.
    @return MaServer A newly created MaServer object. Use mprFree to free and release.
    @ingroup MaServer
    @stability Stable
 */
PUBLIC MaServer *maCreateServer(MaAppweb *appweb, cchar *name);

/** 
    Get the default authentication object for the server
    @description The server has a default host, which in turn has a default route. Each route has an authentication
        object to control access to server resources. This call retrieves that authentication object for use with the
        HttpAuth APIs.
    @param server MaServer object
    @return HttpAuth object
    @ingroup MaServer
    @stability Stable
 */
PUBLIC HttpAuth *maGetDefaultAuth(MaServer *server);

/**
    Parse an Appweb configuration file
    @description Parse the configuration file and configure the server. This creates a default host and route
        and then configures the server based on config file directives.
    @param server MaServer object created via #maCreateServer
    @param path Configuration file pathname.
    @param flags Parse control flags. Reserved. Set to zero.
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC int maParseConfig(MaServer *server, cchar *path, int flags);

/** 
    Create and run a simple web server listening on a single IP address.
    @description Create a simple web server without using a configuration file. The server is created to listen on
        the specified IP address and port. This routine provides a one-line embedding of Appweb. If you want to 
        use a config file, try the #maRunWebServer instead. 
    @param ip IP address on which to listen. Set to "0.0.0.0" to listen on all interfaces.
    @param port Port number to listen to
    @param home Home directory for the web server
    @param documents Directory containing the documents to serve.
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaServer
    @stability Stable
 */
PUBLIC int maRunSimpleWebServer(cchar *ip, int port, cchar *home, cchar *documents);

/** 
    Run a web client request
    @description Create a web server configuration based on the supplied config file. This routine provides 
        a one-line embedding of Appweb. If you don't want to use a config file, try the #maRunSimpleWebServer 
        instead.
    @param method HTTP method to invoke
    @param uri URI to request
    @param data Optional data to send with request. Set to null for GET requests.
    @param response Output parameter to receive the HTTP request response.
    @param err Output parameter to receive any error messages.
    @ingroup MaServer
    @see httpRequest
    @stability Evolving
 */
PUBLIC int maRunWebClient(cchar *method, cchar *uri, cchar *data, char **response, char **err);

/** 
    Create and run a web server based on a configuration file
    @description Create a web server configuration based on the supplied config file. This routine provides 
        a one-line embedding of Appweb. If you don't want to use a config file, try the #maRunSimpleWebServer 
        instead. 
    @param configFile File name of the Appweb configuration file (appweb.conf) that defines the web server configuration.
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaServer
    @stability Stable
 */
PUBLIC int maRunWebServer(cchar *configFile);

/**
    Set the server listen address
    @description Set the internet addresses for all endpoints managed by the server
    @param server MaServer object created via #maCreateServer
    @param ip IP address to set for the server
    @param port Port number to use for the server
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC void maSetServerAddress(MaServer *server, cchar *ip, int port);

/**
    Start a server
    @param server Object created via #maCreateServer
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC int maStartServer(MaServer *server);

/**
    Stop a server
    @param server Object created via #maCreateServer
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC void maStopServer(MaServer *server);

/**
    Validate the configuration of a server
    @param server Server object to validate
    @return True if the configuration is valid
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC bool maValidateServer(MaServer *server);

/**
    Save the authorization configuration to a file
    AuthFile schema:
        User name password abilities...
        Role name abilities...
    @param auth Auth object allocated by #httpCreateAuth.
    @param path Path name of file
    @return "Zero" if successful, otherwise a negative MPR error code
    @ingroup HttpAuth
    @stability Internal
    @internal 
 */
PUBLIC int maWriteAuthFile(HttpAuth *auth, char *path);

/******************************************************************************/
/*
    State flags
 */
#define MA_PARSE_NON_SERVER     0x1     /**< Command file being parsed by a utility program */

/**
    Current configuration parse state
    @stability Evolving
    @defgroup MaState MaState
    @see MaDirective MaState maAddDirective maArchiveLog maPopState maPushState maTokenize
    @stability Internal
 */
typedef struct MaState {
    MaAppweb    *appweb;
    Http        *http;
    MaServer    *server;                /**< Current server */
    HttpHost    *host;                  /**< Current host */
    HttpAuth    *auth;                  /**< Quick alias for route->auth */
    HttpRoute   *route;                 /**< Current route */
    MprFile     *file;                  /**< Config file handle */
    char        *key;                   /**< Current directive being parsed */
    char        *configDir;             /**< Directory containing config file */
    char        *filename;              /**< Config file name */
    char        *endpoints;             /**< Virtual host endpoints */
    int         lineNumber;             /**< Current line number */
    int         enabled;                /**< True if the current block is enabled */
    int         flags;                  /**< Parsing flags */
    struct MaState *prev;               /**< Previous (inherited) state */
    struct MaState *top;                /**< Top level state */
    struct MaState *current;            /**< Current state */
} MaState;

/**
    Appweb configuration file directive parsing callback function
    @description Directive callbacks are invoked to parse a directive. Directive callbacks are registered using
        #maAddDirective.
    @param state Current config parse state.
    @param key Directive key name
    @param value Directive key value
    @return Zero if successful, otherwise a negative Mpr error code. See the Appweb log for diagnostics.
    @ingroup MaAppweb
    @stability Stable
 */
typedef int (MaDirective)(MaState *state, cchar *key, cchar *value);

/**
    Define a new appweb configuration file directive
    @description The appweb configuration file parse is extensible. New directives can be registered by this call. When
        encountered in the config file, the given callback proc will be invoked to parse.
    @param appweb Appweb object created via #maCreateAppweb
    @param directive Directive name
    @param proc Directive callback procedure of the type #MaDirective. 
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC void maAddDirective(MaAppweb *appweb, cchar *directive, MaDirective proc);

//  MOB DOC
PUBLIC int maParseFile(MaState *state, cchar *path);

/**
    Pop the state 
    @description This is used when parsing config files to handle nested include files and block level directives
    @param state Current state
    @return The next lower level state object
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC MaState *maPopState(MaState *state);

/**
    Push the state 
    @description This is used when parsing config files to handle nested include files and block level directives
    @param state Current state
    @return The state passed as a parameter which becomes the new top level state
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC MaState *maPushState(MaState *state);

/**
    Tokenize a string based on route data
    @description This is a utility routine to parse a string into tokens given a format specifier. 
    Mandatory tokens can be specified with "%" format specifier. Optional tokens are specified with "?" format. 
    Values wrapped in quotes will have the outermost quotes trimmed.
    @param state Current config parsing state
    @param str String to expand
    @param fmt Format string specifier
    Supported tokens:
    <ul>
    <li>%B - Boolean. Parses: on/off, true/false, yes/no.</li>
    <li>%N - Number. Parses numbers in base 10.</li>
    <li>%S - String. Removes quotes.</li>
    <li>%P - Path string. Removes quotes and expands ${PathVars}. Resolved relative to host->dir (ServerRoot).</li>
    <li>%W - Parse words into a list</li>
    <li>%! - Optional negate. Set value to HTTP_ROUTE_NOT present, otherwise zero.</li>
    </ul>
    @return True if the string can be successfully parsed.
    @ingroup MaAppweb
    @stability Stable
 */
PUBLIC bool maTokenize(MaState *state, cchar *str, cchar *fmt, ...);

/**
    Get the argument in a directive
    @description Break into arguments. Args may be quoted. An outer quoting of the entire arg is removed.
    @param s String to examine
    @param tok Next token reference
    @return Reference to the next token. (Not allocate
    @ingroup MaAppweb
    @stability Evolving
*/
PUBLIC char *maGetNextArg(char *s, char **tok);

#ifdef __cplusplus
} /* extern C */
#endif

/*
    Permit overrides
 */
#include "customize.h"

#endif /* _h_APPWEB */

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
