/*
    espHandler.c -- ESP Appweb handler

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "appweb.h"
#include    "esp.h"

#if ME_COM_ESP
/************************************* Code ***********************************/
/*
    EspApp /path/to/some*dir/esp.json
    EspApp prefix="/uri/prefix" config="/path/to/esp.json"
 */
static int espAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;
    MprList     *files;
    cchar       *path, *prefix;
    char        *option, *ovalue, *tok;
    int         next;

    if (scontains(value, "=")) {
        path = prefix = 0;
        for (option = maGetNextArg(sclone(value), &tok); option; option = maGetNextArg(tok, &tok)) {
            option = stok(option, " =\t,", &ovalue);
            ovalue = strim(ovalue, "\"'", MPR_TRIM_BOTH);
            if (smatch(option, "prefix")) {
                prefix = ovalue;
            } else if (smatch(option, "config")) {
                path = ovalue;
            } else {
                mprLog("error appweb", 0, "Using deprecated EspApp arguments. Please consult documentation");
                return MPR_ERR_BAD_SYNTAX;
            }
        }
        route = httpCreateInheritedRoute(state->route);
        route->flags |= HTTP_ROUTE_HOSTED;
        if (espLoadApp(route, prefix, path) < 0) {
            return MPR_ERR_CANT_CREATE;
        }
        httpFinalizeRoute(route);
    } else {
        files = mprGlobPathFiles(".", value, 0);
        for (ITERATE_ITEMS(files, path, next)) {
            prefix = mprGetPathBase(mprGetPathDir(mprGetAbsPath(path)));
            route = httpCreateInheritedRoute(state->route);
            route->flags |= HTTP_ROUTE_HOSTED;
            if (espLoadApp(route, prefix, path) < 0) {
                return MPR_ERR_CANT_CREATE;
            }
            httpFinalizeRoute(route);
        }
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
#endif /* ME_COM_ESP */

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
