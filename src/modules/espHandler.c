/*
    espHandler.c -- ESP Appweb handler

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "appweb.h"
#include    "esp.h"

/************************************* Code ***********************************/
/*
    EspApp pattern...*.esp
 */
static int espAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;
    MprList     *files;
    cchar       *path, *prefix;
    int         next;

    if (scontains(value, "=")) {
        mprLog("error appweb", 0, "Using deprecated form of EspApp. Please consult documentation");
        return MPR_ERR_BAD_SYNTAX;
    }
    state->route = route = httpCreateInheritedRoute(state->route);
    route->flags |= HTTP_ROUTE_HOSTED;

    files = mprGlobPathFiles(".", value, 0);
    for (ITERATE_ITEMS(files, path, next)) {
        prefix = mprGetPathBase(mprGetPathDir(mprGetAbsPath(path)));
        if (*prefix != '/') {
            prefix = sjoin("/", prefix, NULL);
        }
        prefix = stemplate(prefix, route->vars);
        httpSetRoutePrefix(route, prefix);
        httpSetRoutePattern(route, sfmt("^%s.*$", prefix), 0);

        if (espLoadApp(route, path) < 0) {
            return MPR_ERR_CANT_CREATE;
        }
        httpFinalizeRoute(route);
    }
    return 0;
}


/*
    Loadable module configuration
 */
PUBLIC int httpEspInit(Http *http, MprModule *module)
{
    if (espOpen(module) < 0) {
        return MPR_ERR_CANT_CREATE;
    }
    maAddDirective("EspApp", espAppDirective);

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
