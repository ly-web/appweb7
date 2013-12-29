/*
    espTemplate.c -- Templated web pages with embedded C code.

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "esp.h"

#if BIT_PACK_ESP

/************************************ Defines *********************************/
/*
      ESP lexical analyser tokens
 */
#define ESP_TOK_ERR            -1            /* Any input error */
#define ESP_TOK_EOF             0            /* End of file */
#define ESP_TOK_CODE            1            /* <% text %> */
#define ESP_TOK_PARAM           2            /* @@param */
#define ESP_TOK_FIELD           3            /* @#field */
#define ESP_TOK_VAR             4            /* @!var */
#define ESP_TOK_HOME            5            /* @~ Home ULR */
#define ESP_TOK_SERVER          6            /* @^ Server URL  */
#define ESP_TOK_LITERAL         7            /* literal HTML */
#define ESP_TOK_EXPR            8            /* <%= expression %> */
#define ESP_TOK_CONTROL         9            /* <%@ control */

/**
    ESP page parser structure
    @defgroup EspParse EspParse
    @see
 */
typedef struct EspParse {
    int     lineNumber;                     /**< Line number for error reporting */
    char    *data;                          /**< Input data to parse */
    char    *next;                          /**< Next character in input */
    MprBuf  *token;                         /**< Input token */
} EspParse;

/************************************ Forwards ********************************/

static int getEspToken(EspParse *parse);
static cchar *getDebug();
static cchar *getEnvString(HttpRoute *route, cchar *key, cchar *defaultValue);
static cchar *getArExt(cchar *os);
static cchar *getShlibExt(cchar *os);
static cchar *getShobjExt(cchar *os);
static cchar *getArPath(cchar *os, cchar *arch);
static cchar *getCompilerName(cchar *os, cchar *arch);
static cchar *getCompilerPath(cchar *os, cchar *arch);
static cchar *getLibs(cchar *os);
static cchar *getMappedArch(cchar *arch);
static cchar *getObjExt(cchar *os);
static cchar *getVisualStudio();
static cchar *getWinSDK();
static cchar *getVxCPU(cchar *arch);
static bool matchToken(cchar **str, cchar *token);

/************************************* Code ***********************************/
/*
    Tokens:
    AR          Library archiver (ar)   
    ARLIB       Archive library extension (.a, .lib)
    ARCH        Build architecture (64)
    CC          Compiler (cc)
    DEBUG       Debug compilation options (-g, -Zi -Od)
    GCC_ARCH    ARCH mapped to gcc -arch switches (x86_64)
    INC         Include directory out/inc
    LIBPATH     Library search path
    LIBS        Libraries required to link with ESP
    OBJ         Name of compiled source (out/lib/view-MD5.o)
    MOD         Output module (view_MD5)
    SHLIB       Host Shared library (.lib, .so)
    SHOBJ       Host Shared Object (.dll, .so)
    SRC         Source code for view or controller (already templated)
    TMP         Temp directory
    VS          Visual Studio directory
    WINSDK      Windows SDK directory
 */
PUBLIC char *espExpandCommand(HttpRoute *route, cchar *command, cchar *source, cchar *module)
{
    MprBuf      *buf;
    MaAppweb    *appweb;
    cchar       *cp, *outputModule, *os, *arch, *profile;
    char        *tmp;
    
    if (command == 0) {
        return 0;
    }
    appweb = MPR->appwebService;
    outputModule = mprTrimPathExt(module);
    maParsePlatform(appweb->platform, &os, &arch, &profile);
    buf = mprCreateBuf(-1, -1);

    for (cp = command; *cp; ) {
        if (*cp == '$') {
            if (matchToken(&cp, "${ARCH}")) {
                /* Target architecture (x86|mips|arm|x64) */
                mprPutStringToBuf(buf, arch);

            } else if (matchToken(&cp, "${ARLIB}")) {
                /* .a, .lib */
                mprPutStringToBuf(buf, getArExt(os));

            } else if (matchToken(&cp, "${GCC_ARCH}")) {
                /* Target architecture mapped to GCC mtune|mcpu values */
                mprPutStringToBuf(buf, getMappedArch(arch));

            } else if (matchToken(&cp, "${INC}")) {
                /* Include directory for the configuration */
                mprPutStringToBuf(buf, mprJoinPath(appweb->platformDir, "inc")); 

            } else if (matchToken(&cp, "${LIBPATH}")) {
                /* Library directory for Appweb libraries for the target */
                mprPutStringToBuf(buf, mprJoinPath(appweb->platformDir, "bin")); 

            } else if (matchToken(&cp, "${LIBS}")) {
                /* Required libraries to link. These may have nested ${TOKENS} */
                mprPutStringToBuf(buf, espExpandCommand(route, getLibs(os), source, module));

            } else if (matchToken(&cp, "${MOD}")) {
                /* Output module path in the cache without extension */
                mprPutStringToBuf(buf, outputModule);

            } else if (matchToken(&cp, "${OBJ}")) {
                /* Output object with extension (.o) in the cache directory */
                mprPutStringToBuf(buf, mprJoinPathExt(outputModule, getObjExt(os)));

            } else if (matchToken(&cp, "${OS}")) {
                /* Target architecture (freebsd|linux|macosx|windows|vxworks) */
                mprPutStringToBuf(buf, os);

            } else if (matchToken(&cp, "${SHLIB}")) {
                /* .dll, .so, .dylib */
                mprPutStringToBuf(buf, getShlibExt(os));

            } else if (matchToken(&cp, "${SHOBJ}")) {
                /* .dll, .so, .dylib */
                mprPutStringToBuf(buf, getShobjExt(os));

            } else if (matchToken(&cp, "${SRC}")) {
                /* View (already parsed into C code) or controller source */
                mprPutStringToBuf(buf, source);

            } else if (matchToken(&cp, "${TMP}")) {
                if ((tmp = getenv("TMPDIR")) == 0) {
                    if ((tmp = getenv("TMP")) == 0) {
                        tmp = getenv("TEMP");
                    }
                }
                mprPutStringToBuf(buf, tmp ? tmp : ".");

            } else if (matchToken(&cp, "${VS}")) {
                mprPutStringToBuf(buf, getVisualStudio());

            } else if (matchToken(&cp, "${VXCPU}")) {
                mprPutStringToBuf(buf, getVxCPU(arch));

            } else if (matchToken(&cp, "${WINSDK}")) {
                mprPutStringToBuf(buf, getWinSDK());

            /*
                These vars can be also be configured from environment variables.
                NOTE: the default esp.conf includes "esp->vxworks.conf" which has EspEnv definitions for the 
                configured VxWorks toolchain.
             */
            } else if (matchToken(&cp, "${AR}")) {
                mprPutStringToBuf(buf, getEnvString(route, "AR", getArPath(os, arch)));

            } else if (matchToken(&cp, "${CC}")) {
                mprPutStringToBuf(buf, getEnvString(route, "CC", getCompilerPath(os, arch)));

            } else if (matchToken(&cp, "${CFLAGS}")) {
                mprPutStringToBuf(buf, getEnvString(route, "CFLAGS", ""));

            } else if (matchToken(&cp, "${DEBUG}")) {
                mprPutStringToBuf(buf, getEnvString(route, "DEBUG", getDebug()));

            } else if (matchToken(&cp, "${LDFLAGS}")) {
                mprPutStringToBuf(buf, getEnvString(route, "LDFLAGS", ""));

            } else if (matchToken(&cp, "${LIB}")) {
                mprPutStringToBuf(buf, getEnvString(route, "LIB", ""));

            } else if (matchToken(&cp, "${LINK}")) {
                mprPutStringToBuf(buf, getEnvString(route, "LINK", ""));

            } else if (matchToken(&cp, "${WIND_BASE}")) {
                mprPutStringToBuf(buf, getEnvString(route, "WIND_BASE", WIND_BASE));

            } else if (matchToken(&cp, "${WIND_HOME}")) {
                mprPutStringToBuf(buf, getEnvString(route, "WIND_HOME", WIND_HOME));

            } else if (matchToken(&cp, "${WIND_HOST_TYPE}")) {
                mprPutStringToBuf(buf, getEnvString(route, "WIND_HOST_TYPE", WIND_HOST_TYPE));

            } else if (matchToken(&cp, "${WIND_PLATFORM}")) {
                mprPutStringToBuf(buf, getEnvString(route, "WIND_PLATFORM", WIND_PLATFORM));

            } else if (matchToken(&cp, "${WIND_GNU_PATH}")) {
                mprPutStringToBuf(buf, getEnvString(route, "WIND_GNU_PATH", WIND_GNU_PATH));

            } else if (matchToken(&cp, "${WIND_CCNAME}")) {
                mprPutStringToBuf(buf, getEnvString(route, "WIND_CCNAME", getCompilerName(os, arch)));

            } else {
                mprPutCharToBuf(buf, *cp++);
            }
        } else {
            mprPutCharToBuf(buf, *cp++);
        }
    }
    mprAddNullToBuf(buf);
    return sclone(mprGetBufStart(buf));
}


static int runCommand(HttpRoute *route, MprDispatcher *dispatcher, cchar *command, cchar *csource, cchar *module, char **errMsg)
{
    MprCmd      *cmd;
    MprKey      *var;
    MprList     *elist;
    EspRoute    *eroute;
    cchar       **env, *commandLine;
    char        *err, *out;
    int         rc;

    *errMsg = 0;
    eroute = route->eroute;
    cmd = mprCreateCmd(dispatcher);
    if ((commandLine = espExpandCommand(route, command, csource, module)) == 0) {
        *errMsg = sfmt("Missing EspCompile directive for %s", csource);
        return MPR_ERR_CANT_READ;
    }
    mprTrace(4, "ESP command: %s\n", commandLine);
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
    /*
        WARNING: GC will run here
     */
    mprHold((void*) commandLine);
    rc = mprRunCmd(cmd, commandLine, env, NULL, &out, &err, -1, 0);
    mprRelease((void*) commandLine);

    if (rc != 0) {
        if (err == 0 || *err == '\0') {
            /* Windows puts errors to stdout Ugh! */
            err = out;
        }
        mprError("ESP: Cannot run command: %s, error %s", commandLine, err);
        if (route->flags & HTTP_ROUTE_SHOW_ERRORS) {
            *errMsg = sfmt("Cannot run command: %s, error %s", commandLine, err);
        } else {
            *errMsg = "Cannot compile view";
        }
        return MPR_ERR_CANT_COMPLETE;
    }
    return 0;
}


/*
    Compile a view or controller

    cacheName   MD5 cache name (not a full path)
    source      ESP source file name
    module      Module file name

    WARNING: this routine blocks and runs GC. All parameters must be retained.
 */
PUBLIC bool espCompile(HttpRoute *route, MprDispatcher *dispatcher, cchar *source, cchar *module, cchar *cacheName, int isView, char **errMsg)
{
    MprFile     *fp;
    EspRoute    *eroute;
    cchar       *csource;
    char        *layout, *script, *page, *err;
    ssize       len;

    eroute = route->eroute;
    layout = 0;
    *errMsg = 0;

    if (isView) {
        if ((page = mprReadPathContents(source, &len)) == 0) {
            *errMsg = sfmt("Cannot read %s", source);
            return 0;
        }
        /*
            Use layouts iff there is a source defined on the route. Only MVC/controllers based apps do this.
         */
        if (eroute->layoutsDir) {
            layout = mprJoinPath(eroute->layoutsDir, "default.esp");
        }
        if ((script = espBuildScript(route, page, source, cacheName, layout, NULL, &err)) == 0) {
            *errMsg = sfmt("Cannot build: %s, error: %s", source, err);
            return 0;
        }
        csource = mprJoinPathExt(mprTrimPathExt(module), ".c");
        mprMakeDir(mprGetPathDir(csource), 0775, 0, -1, 1);
        if ((fp = mprOpenFile(csource, O_WRONLY | O_TRUNC | O_CREAT | O_BINARY, 0664)) == 0) {
            *errMsg = sfmt("Cannot open compiled script file %s", csource);
            return 0;
        }
        len = slen(script);
        if (mprWriteFile(fp, script, len) != len) {
            *errMsg = sfmt("Cannot write compiled script file %s", csource);
            mprCloseFile(fp);
            return 0;
        }
        mprCloseFile(fp);
    } else {
        csource = source;
    }
    mprMakeDir(eroute->cacheDir, 0775, -1, -1, 1);

#if BIT_WIN_LIKE
    {
        /*
            Force a clean windows compile by removing the obj, pdb and ilk files
         */
        cchar   *path;
        path = mprReplacePathExt(module, "obj");
        if (mprPathExists(path, F_OK)) {
            mprDeletePath(path);
        }
        path = mprReplacePathExt(module, "pdb");
        if (mprPathExists(path, F_OK)) {
            mprDeletePath(path);
        }
        path = mprReplacePathExt(module, "ilk");
        if (mprPathExists(path, F_OK)) {
            mprDeletePath(path);
        }
    }
#endif
    /* WARNING: GC yield here */
    if (runCommand(route, dispatcher, eroute->compile, csource, module, errMsg) != 0) {
        return 0;
    }
    if (eroute->link) {
        /* WARNING: GC yield here */
        if (runCommand(route, dispatcher, eroute->link, csource, module, errMsg) != 0) {
            return 0;
        }
#if !(BIT_DEBUG && MACOSX)
        /*
            MAC needs the object for debug information
         */
        mprDeletePath(mprJoinPathExt(mprTrimPathExt(module), &BIT_OBJ[1]));
#endif
    }
#if BIT_WIN_LIKE
    {
        /*
            Windows leaves intermediate object in the current directory
         */
        cchar   *path;
        path = mprReplacePathExt(mprGetPathBase(csource), "obj");
        if (mprPathExists(path, F_OK)) {
            mprDeletePath(path);
        }
    }
#endif
    if (!eroute->keepSource && isView) {
        mprDeletePath(csource);
    }
    return 1;
}


static char *fixMultiStrings(cchar *str)
{
    cchar   *cp;
    char    *buf, *bp;
    ssize   len;
    int     count, bquote, quoted;

    for (count = 0, cp = str; *cp; cp++) {
        if (*cp == '\n' || *cp == '"') {
            count++;
        }
    }
    len = slen(str);
    if ((buf = mprAlloc(len + (count * 3) + 1)) == 0) {
        return 0;
    }
    bquote = quoted = 0;
    for (cp = str, bp = buf; *cp; cp++) {
        if (*cp == '`') {
            *bp++ = '"';
            quoted = !quoted;
        } else if (quoted) {
            if (*cp == '\n') {
                *bp++ = '\\';
            } else if (*cp == '"') {
                *bp++ = '\\';
            } else if (*cp == '\\' && cp[1] != '\\') {
                bquote++;
            }
            *bp++ = *cp;
        } else {
            *bp++ = *cp;
        }
    }
    *bp = '\0';
    return buf;
}


static char *joinLine(cchar *str, ssize *lenp)
{
    cchar   *cp;
    char    *buf, *bp;
    ssize   len;
    int     count, bquote;

    for (count = 0, cp = str; *cp; cp++) {
        if (*cp == '\n') {
            count++;
        }
    }
    len = slen(str);
    if ((buf = mprAlloc(len + (count * 3) + 1)) == 0) {
        return 0;
    }
    bquote = 0;
    for (cp = str, bp = buf; *cp; cp++) {
        if (*cp == '\n') {
            *bp++ = '\\';
            *bp++ = 'n';
            *bp++ = '\\';
        } else if (*cp == '\r') {
            *bp++ = '\\';
            *bp++ = 'r';
            continue;
        } else if (*cp == '\\' && cp[1] != '\\') {
            bquote++;
        }
        *bp++ = *cp;
    }
    *bp = '\0';
    *lenp = len - bquote;
    return buf;
}


/*
    Convert an ESP web page into C code
    Directives:
        <%@ include "file"  Include an esp file
        <%@ layout "file"   Specify a layout page to use. Use layout "" to disable layout management
        <%@ content         Mark the location to substitute content in a layout page

        <%                  Begin esp section containing C code
        <%^ global          Put esp code at the global level
        <%^ start           Put esp code at the start of the function
        <%^ end             Put esp code at the end of the function

        <%=                 Begin esp section containing an expression to evaluate and substitute
        <%= [%fmt]          Begin a formatted expression to evaluate and substitute. Format is normal printf format.
                            Use %S for safe HTML escaped output.
        %>                  End esp section
        -%>                 End esp section and trim trailing newline

        @@var               Substitue the value of a parameter. 
        @!var               Substitue the value of a variable. Var can also be simple expressions (without spaces)
        @#field             Lookup the current record for the value of the field.
        @~                  Home URL for the application
        @|                  Top level server side URL

 */
PUBLIC char *espBuildScript(HttpRoute *route, cchar *page, cchar *path, cchar *cacheName, cchar *layout, 
        EspState *state, char **err)
{
    EspRoute    *eroute;
    EspState    top;
    EspParse    parse;
    MprBuf      *body;
    char        *control, *incText, *where, *layoutCode, *bodyCode;
    char        *rest, *include, *line, *fmt, *layoutPage, *incCode, *token;
    ssize       len;
    int         tid;

    assert(page);

    *err = 0;
    eroute = route->eroute;
    if (!state) {
        assert(cacheName);
        state = &top;
        memset(state, 0, sizeof(EspParse));
        state->global = mprCreateBuf(0, 0);
        state->start = mprCreateBuf(0, 0);
        state->end = mprCreateBuf(0, 0);
    }
    body = mprCreateBuf(0, 0);
    parse.data = (char*) page;
    parse.next = parse.data;
    parse.lineNumber = 0;
    parse.token = mprCreateBuf(0, 0);
    tid = getEspToken(&parse);

    while (tid != ESP_TOK_EOF) {
        token = mprGetBufStart(parse.token);
#if KEEP
        if (state->lineNumber != lastLine) {
            mprPutToBuf(script, "\n# %d \"%s\"\n", state->lineNumber, path);
        }
#endif
        switch (tid) {
        case ESP_TOK_CODE:
            if (*token == '^') {
                for (token++; *token && isspace((uchar) *token); token++) ;
                where = stok(token, " \t\r\n", &rest);
                if (rest == 0) {
                    ;
                } else if (scmp(where, "global") == 0) {
                    mprPutStringToBuf(state->global, rest);

                } else if (scmp(where, "start") == 0) {
                    mprPutToBuf(state->start, "%s  ", rest);

                } else if (scmp(where, "end") == 0) {
                    mprPutToBuf(state->end, "%s  ", rest);
                }
            } else {
                mprPutStringToBuf(body, fixMultiStrings(token));
            }
            break;

        case ESP_TOK_CONTROL:
            control = stok(token, " \t\r\n", &token);
            if (scmp(control, "content") == 0) {
                mprPutStringToBuf(body, ESP_CONTENT_MARKER);

            } else if (scmp(control, "include") == 0) {
                if (token == 0) {
                    token = "";
                }
                token = strim(token, " \t\r\n\"", MPR_TRIM_BOTH);
                token = mprNormalizePath(token);
                if (token[0] == '/') {
                    include = sclone(token);
                } else {
                    include = mprJoinPath(mprGetPathDir(path), token);
                }
                if ((incText = mprReadPathContents(include, &len)) == 0) {
                    *err = sfmt("Cannot read include file: %s", include);
                    return 0;
                }
                /* Recurse and process the include script */
                if ((incCode = espBuildScript(route, incText, include, NULL, NULL, state, err)) == 0) {
                    return 0;
                }
                mprPutStringToBuf(body, incCode);

            } else if (scmp(control, "layout") == 0) {
                token = strim(token, " \t\r\n\"", MPR_TRIM_BOTH);
                if (*token == '\0') {
                    layout = 0;
                } else {
                    token = mprNormalizePath(token);
                    if (token[0] == '/') {
                        layout = sclone(token);
                    } else {
                        layout = mprJoinPath(eroute->layoutsDir ? eroute->layoutsDir : mprGetPathDir(path), token);
                    }
                    if (!mprPathExists(layout, F_OK)) {
                        *err = sfmt("Cannot access layout page %s", layout);
                        return 0;
                    }
                }

            } else {
                *err = sfmt("Unknown control %s at line %d", control, state->lineNumber);
                return 0;
            }
            break;

        case ESP_TOK_ERR:
            return 0;

        case ESP_TOK_EXPR:
            /* <%= expr %> */
            if (*token == '%') {
                fmt = stok(token, ": \t\r\n", &token);
                if (token == 0) { 
                    token = "";
                }
                /* Default without format is safe. If users want a format and safe, use %S or renderSafe() */
                token = strim(token, " \t\r\n;", MPR_TRIM_BOTH);
                mprPutToBuf(body, "  espRender(conn, \"%s\", %s);\n", fmt, token);
            } else {
                token = strim(token, " \t\r\n;", MPR_TRIM_BOTH);
                mprPutToBuf(body, "  espRenderSafeString(conn, %s);\n", token);
            }
            break;

        case ESP_TOK_FIELD:
            /* @#field -- field in the current record */
            token = strim(token, " \t\r\n;", MPR_TRIM_BOTH);
            mprPutToBuf(body, "  espRenderSafeString(conn, getField(getRec(), \"%s\"));\n", token);
            break;

        case ESP_TOK_PARAM:
            /* @@var -- variable in (param || session) - Safe render */
            token = strim(token, " \t\r\n;", MPR_TRIM_BOTH);
            mprPutToBuf(body, "  espRenderVar(conn, \"%s\");\n", token);
            break;

        case ESP_TOK_VAR:
            /* @!var -- string variable */
            token = strim(token, " \t\r\n;", MPR_TRIM_BOTH);
            mprPutToBuf(body, "  espRenderString(conn, %s);\n", token);
            break;

        case ESP_TOK_HOME:
            /* @~ Home URL */
            mprPutToBuf(body, "  espRenderString(conn, conn->rx->route->prefix);");
            break;

        case ESP_TOK_SERVER:
            /* @^ Server URL */
            mprPutToBuf(body, "  espRenderString(conn, sjoin(conn->rx->route->prefix ? conn->rx->route->prefix : \"\", conn->rx->route->serverPrefix, NULL));");
            break;

        case ESP_TOK_LITERAL:
            line = joinLine(token, &len);
            mprPutToBuf(body, "  espRenderBlock(conn, \"%s\", %d);\n", line, len);
            break;

        default:
            return 0;
        }
        tid = getEspToken(&parse);
    }
    mprAddNullToBuf(body);

    if (layout && mprPathExists(layout, R_OK)) {
        if ((layoutPage = mprReadPathContents(layout, &len)) == 0) {
            *err = sfmt("Cannot read layout page: %s", layout);
            return 0;
        }
        if ((layoutCode = espBuildScript(route, layoutPage, layout, NULL, NULL, state, err)) == 0) {
            return 0;
        }
#if BIT_DEBUG
        if (!scontains(layoutCode, ESP_CONTENT_MARKER)) {
            *err = sfmt("Layout page is missing content marker: %s", layout);
            return 0;
        }
#endif
        bodyCode = sreplace(layoutCode, ESP_CONTENT_MARKER, mprGetBufStart(body));
    } else {
        bodyCode = mprGetBufStart(body);
    }
    if (state == &top) {
        path = mprGetRelPath(path, route->documents);
        if (mprGetBufLength(state->start) > 0) {
            mprPutCharToBuf(state->start, '\n');
        }
        if (mprGetBufLength(state->end) > 0) {
            mprPutCharToBuf(state->end, '\n');
        }
        mprAddNullToBuf(state->global);
        mprAddNullToBuf(state->start);
        mprAddNullToBuf(state->end);
        bodyCode = sfmt(\
            "/*\n   Generated from %s\n */\n"\
            "#include \"esp.h\"\n"\
            "%s\n"\
            "static void %s(HttpConn *conn) {\n"\
            "%s%s%s"\
            "}\n\n"\
            "%s int esp_%s(HttpRoute *route, MprModule *module) {\n"\
            "   espDefineView(route, \"%s\", %s);\n"\
            "   return 0;\n"\
            "}\n",
            path, mprGetBufStart(state->global), cacheName, mprGetBufStart(state->start), bodyCode, mprGetBufStart(state->end),
            ESP_EXPORT_STRING, cacheName, mprGetPortablePath(path), cacheName);
        mprTrace(6, "Create ESP script: \n%s\n", bodyCode);
    }
    return bodyCode;
}


static bool addChar(EspParse *parse, int c)
{
    if (mprPutCharToBuf(parse->token, c) < 0) {
        return 0;
    }
    mprAddNullToBuf(parse->token);
    return 1;
}


static char *eatSpace(EspParse *parse, char *next)
{
    for (; *next && isspace((uchar) *next); next++) {
        if (*next == '\n') {
            parse->lineNumber++;
        }
    }
    return next;
}


static char *eatNewLine(EspParse *parse, char *next)
{
    for (; *next && isspace((uchar) *next); next++) {
        if (*next == '\n') {
            parse->lineNumber++;
            next++;
            break;
        }
    }
    return next;
}


/*
    Get the next ESP input token. input points to the next input token.
    parse->token will hold the parsed token. The function returns the token id.
 */
static int getEspToken(EspParse *parse)
{
    char    *start, *end, *next;
    int     tid, done, c, t;

    start = next = parse->next;
    end = &start[slen(start)];
    mprFlushBuf(parse->token);
    tid = ESP_TOK_LITERAL;

    for (done = 0; !done && next < end; next++) {
        c = *next;
        switch (c) {
        case '<':
            if (next[1] == '%' && ((next == start) || next[-1] != '\\')) {
                next += 2;
                if (mprGetBufLength(parse->token) > 0) {
                    next -= 3;
                } else {
                    next = eatSpace(parse, next);
                    if (*next == '=') {
                        /*
                            <%= directive
                         */
                        tid = ESP_TOK_EXPR;
                        next = eatSpace(parse, ++next);
                        while (next < end && !(*next == '%' && next[1] == '>' && next[-1] != '\\')) {
                            if (*next == '\n') parse->lineNumber++;
                            if (!addChar(parse, *next++)) {
                                return ESP_TOK_ERR;
                            }
                        }

                    } else if (*next == '@') {
                        tid = ESP_TOK_CONTROL;
                        next = eatSpace(parse, ++next);
                        while (next < end && !(*next == '%' && next[1] == '>' && next[-1] != '\\')) {
                            if (*next == '\n') parse->lineNumber++;
                            if (!addChar(parse, *next++)) {
                                return ESP_TOK_ERR;
                            }
                        }
                        
                    } else {
                        tid = ESP_TOK_CODE;
                        while (next < end && !(*next == '%' && next[1] == '>' && next[-1] != '\\')) {
                            if (*next == '\n') parse->lineNumber++;
                            if (!addChar(parse, *next++)) {
                                return ESP_TOK_ERR;
                            }
                        }
                    }
                    if (*next && next > start && next[-1] == '-') {
                        /* Remove "-" */
                        mprAdjustBufEnd(parse->token, -1);
                        mprAddNullToBuf(parse->token);
                        next = eatNewLine(parse, next + 2) - 1;
                    } else {
                        next++;
                    }
                }
                done++;
            } else {
                if (!addChar(parse, c)) {
                    return ESP_TOK_ERR;
                }                
            }
            break;

        case '@':
            if ((next == start) || next[-1] != '\\') {
                t = next[1];
                if (t == '~') {
                    next += 2;
                    if (mprGetBufLength(parse->token) > 0) {
                        next -= 3;
                    } else {
                        tid = ESP_TOK_HOME;
                        if (!addChar(parse, c)) {
                            return ESP_TOK_ERR;
                        }
                        next--;
                    }
                    done++;

                } else if (t == BIT_SERVER_PREFIX_CHAR) {
                    next += 2;
                    if (mprGetBufLength(parse->token) > 0) {
                        next -= 3;
                    } else {
                        tid = ESP_TOK_SERVER;
                        if (!addChar(parse, c)) {
                            return ESP_TOK_ERR;
                        }
                        next--;
                    }
                    done++;

                } else if (t == '@' || t == '#' || t == '!') {
                    next += 2;
                    if (mprGetBufLength(parse->token) > 0) {
                        next -= 3;
                    } else {
                        if (t == '!') {
                           tid = ESP_TOK_VAR;
                        } else if (t == '#') {
                            tid = ESP_TOK_FIELD;
                        } else {
                            tid = ESP_TOK_PARAM;
                        }
                        next = eatSpace(parse, next);
                        while (isalnum((uchar) *next) || *next == '_') {
                            if (*next == '\n') parse->lineNumber++;
                            if (!addChar(parse, *next++)) {
                                return ESP_TOK_ERR;
                            }
                        }
                        next--;
                    }
                    done++;
                }
            }
            break;

        case '\n':
            parse->lineNumber++;
            /* Fall through */

        case '\r':
        default:
            if (c == '\"' || c == '\\') {
                if (!addChar(parse, '\\')) {
                    return ESP_TOK_ERR;
                }
            }
            if (!addChar(parse, c)) {
                return ESP_TOK_ERR;
            }
            break;
        }
    }
    if (mprGetBufLength(parse->token) == 0) {
        tid = ESP_TOK_EOF;
    }
    parse->next = next;
    return tid;
}


static cchar *getEnvString(HttpRoute *route, cchar *key, cchar *defaultValue)
{
    EspRoute    *eroute;
    cchar       *value;

    eroute = route->eroute;
    if (!eroute || !eroute->env || (value = mprLookupKey(eroute->env, key)) == 0) {
        if ((value = getenv(key)) == 0) {
            if (defaultValue) {
                value = defaultValue;
            } else {
                value = sfmt("${%s}", key);
            }
        }
    }
    return value;
}


static cchar *getShobjExt(cchar *os)
{
    if (smatch(os, "macosx")) {
        return ".dylib";
    } else if (smatch(os, "windows")) {
        return ".dll";
    } else if (smatch(os, "vxworks")) {
        return ".out";
    } else {
        return ".so";
    }
}


static cchar *getShlibExt(cchar *os)
{
    if (smatch(os, "macosx")) {
        return ".dylib";
    } else if (smatch(os, "windows")) {
        return ".lib";
    } else if (smatch(os, "vxworks")) {
        return ".a";
    } else {
        return ".so";
    }
}


static cchar *getObjExt(cchar *os)
{
    if (smatch(os, "windows")) {
        return ".obj";
    }
    return ".o";
}


static cchar *getArExt(cchar *os)
{
    if (smatch(os, "windows")) {
        return ".lib";
    }
    return ".a";
}


static cchar *getCompilerName(cchar *os, cchar *arch)
{
    cchar       *name;

    name = "gcc";
    if (smatch(os, "vxworks")) {
        if (smatch(arch, "x86") || smatch(arch, "i586") || smatch(arch, "i686") || smatch(arch, "pentium")) {
            name = "ccpentium";
        } else if (scontains(arch, "86")) {
            name = "cc386";
        } else if (scontains(arch, "ppc")) {
            name = "ccppc";
        } else if (scontains(arch, "xscale") || scontains(arch, "arm")) {
            name = "ccarm";
        } else if (scontains(arch, "68")) {
            name = "cc68k";
        } else if (scontains(arch, "sh")) {
            name = "ccsh";
        } else if (scontains(arch, "mips")) {
            name = "ccmips";
        }
    } else if (smatch(os, "macosx")) {
        name = "clang";
    }
    return name;
}


static cchar *getVxCPU(cchar *arch)
{
    char   *cpu, *family;

    family = stok(sclone(arch), ":", &cpu);
    if (!cpu || *cpu == '\0') {
        if (smatch(family, "i386")) {
            cpu = "I80386";
        } else if (smatch(family, "i486")) {
            cpu = "I80486";
        } else if (smatch(family, "x86") | sends(family, "86")) {
            cpu = "PENTIUM";
        } else if (scaselessmatch(family, "mips")) {
            cpu = "MIPS32";
        } else if (scaselessmatch(family, "arm")) {
            cpu = "ARM7TDMI";
        } else if (scaselessmatch(family, "ppc")) {
            cpu = "PPC";
        } else {
            cpu = (char*) arch;
        }
    }
    return supper(cpu);
}


static cchar *getDebug()
{
    MaAppweb    *appweb;
    int         debug;

    appweb = MPR->appwebService;
    debug = sends(appweb->platform, "-debug") || sends(appweb->platform, "-xcode") || 
        sends(appweb->platform, "-mine") || sends(appweb->platform, "-vsdebug");
    if (scontains(appweb->platform, "windows-")) {
        return (debug) ? "-DBIT_DEBUG -Zi -Od" : "-Os";
    }
    return (debug) ? "-DBIT_DEBUG -g" : "-O2";
}


static cchar *getLibs(cchar *os)
{
    cchar       *libs;

    if (smatch(os, "windows")) {
        libs = "\"${LIBPATH}\\libmod_esp${SHLIB}\" \"${LIBPATH}\\libappweb.lib\" \"${LIBPATH}\\libhttp.lib\" \"${LIBPATH}\\libmpr.lib\"";
    } else {
#if LINUX
        /* 
            Fedora interprets $ORIGN relative to the shared library and not the application executable
            So loading compiled apps fails to locate libmod_esp.so. 
            Since building a shared library, can omit libs and resolve at load time.
         */
        libs = "";
#else
        libs = "-lmod_esp -lappweb -lpcre -lhttp -lmpr -lpthread -lm";
#endif
    }
    return libs;
}


static bool matchToken(cchar **str, cchar *token)
{
    ssize   len;

    len = slen(token);
    if (sncmp(*str, token, len) == 0) {
        *str += len;
        return 1;
    }
    return 0;
}


static cchar *getMappedArch(cchar *arch)
{
    if (smatch(arch, "x64")) {
        arch = "x86_64";
    } else if (smatch(arch, "x86")) {
        arch = "i686";
    }
    return arch;
}


static cchar *getWinSDK()
{
#if WINDOWS
    char *versions[] = { "8.0", "7.1", "7.0A", "7.0", 0 };
    /*
        MS has made a big mess of where and how the windows SDKs are installed. The registry key at 
        HKLM/Software/Microsoft/Microsoft SDKs/Windows/CurrentInstallFolder can't be trusted and often
        points to the old 7.X SDKs even when 8.X is installed and active. MS have also moved the 8.X
        SDK to Windows Kits, while still using the old folder for some bits. So the old-reliable
        CurrentInstallFolder registry key is now unusable. So we must scan for explicit SDK versions 
        listed above. Ugh!
     */
    cchar   *path, *key, **vp;

    for (vp = versions; *vp; vp++) {
        key = sfmt("HKLM\\SOFTWARE%s\\Microsoft\\Microsoft SDKs\\Windows\\v%s", (BIT_64) ? "\\Wow6432Node" : "", *vp);
        if ((path = mprReadRegistry(key, "InstallationFolder")) != 0) {
            break;
        }
    }
    if (!path) {
        /* Old Windows SDK 7 registry location */
        path = mprReadRegistry("HKLM\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows", "CurrentInstallFolder");
    }
    if (!path) {
        path = "${WINSDK}";
    }
    return strim(path, "\\", MPR_TRIM_END);
#else
    return "";
#endif
}


static cchar *getVisualStudio()
{
#if WINDOWS
    cchar   *path;
    int     v;
    for (v = 13; v >= 8; v--) {
        if ((path = mprReadRegistry(ESP_VSKEY, sfmt("%d.0", v))) != 0) {
            path = strim(path, "\\", MPR_TRIM_END);
            break;
        }
    }
    if (!path) {
        path = "${VS}";
    }
    return path;
#else
    return "";
#endif
}


static cchar *getArPath(cchar *os, cchar *arch)
{
#if WINDOWS
    /* 
        Get the real system architecture (32 or 64 bit)
     */
    MaAppweb *appweb = MPR->appwebService;
    cchar *path = getVisualStudio();
    if (scontains(appweb->platform, "-x64-")) {
        int is64BitSystem = smatch(getenv("PROCESSOR_ARCHITECTURE"), "AMD64") || getenv("PROCESSOR_ARCHITEW6432");
        if (is64BitSystem) {
            path = mprJoinPath(path, "VC/bin/amd64/lib.exe");
        } else {
            /* Cross building on a 32-bit system */
            path = mprJoinPath(path, "VC/bin/x86_amd64/lib.exe");
        }
    } else {
        path = mprJoinPath(path, "VC/bin/lib.exe");
    }
    return path;
#else
    return "ar";
#endif
}


static cchar *getCompilerPath(cchar *os, cchar *arch)
{
#if WINDOWS
    /* 
        Get the real system architecture (32 or 64 bit)
     */
    MaAppweb *appweb = MPR->appwebService;
    cchar *path = getVisualStudio();
    if (scontains(appweb->platform, "-x64-")) {
        int is64BitSystem = smatch(getenv("PROCESSOR_ARCHITECTURE"), "AMD64") || getenv("PROCESSOR_ARCHITEW6432");
        if (is64BitSystem) {
            path = mprJoinPath(path, "VC/bin/amd64/cl.exe");
        } else {
            /* Cross building on a 32-bit system */
            path = mprJoinPath(path, "VC/bin/x86_amd64/cl.exe");
        }
    } else {
        path = mprJoinPath(path, "VC/bin/cl.exe");
    }
    return path;
#else
    return getCompilerName(os, arch);
#endif
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
