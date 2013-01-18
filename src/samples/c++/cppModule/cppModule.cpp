/*
    simpleModule.c - Create a simple AppWeb dynamically loadable module
  
    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */
 
/******************************* Includes *****************************/

#include    "appweb.h"

/********************************* Code *******************************/
/* 
    Parse any module specific configuration directives from the appweb.conf config file.
 */

static int customConfigKey(MaState *state, cchar *key, cchar *value)
{
    /*
        Do something with value.
     */
    return 0;
}


#ifdef __cplusplus 
extern "C" {
#endif

/*
    Module load initialization. This is called when the module is first loaded.
 */
int maSimpleModuleInit(Http *http, MprModule *mp)
{
    HttpStage   *stage;
    MaAppweb    *appweb;

    /*
        Create a stage so we can process configuration file data
     */
    if ((stage = httpCreateStage(http, "simpleModule", 0, mp)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    appweb = (MaAppweb*) httpGetContext(http);
    maAddDirective(appweb, "CustomConfigKey", customConfigKey);
    return 0;
}

#ifdef __cplusplus 
}
#endif


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
