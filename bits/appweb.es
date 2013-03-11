/*
    Support functions for Embedthis Appweb

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

require ejs.tar
require ejs.unix

public function startService() {
    if (Config.OS != 'windows' && App.uid != 0) {
        trace('Skip', 'Must be root to install Appweb daemon')
        return
    }
    if (!bit.cross) {
        stopService(true)
        trace('Run', 'appman install enable start')
        Cmd([bit.prefixes.bin.join('appman' + bit.globals.EXE), 'install', 'enable', 'start'])
        if (bit.platform.os == 'windows') {
            Cmd([bit.prefixes.bin.join('appwebMonitor' + bit.globals.EXE)], {detach: true})
        }
    }
}


public function stopService(quiet: Boolean = false) {
    if (Config.OS != 'windows' && App.uid != 0) {
        return
    }
    if (!bit.cross) {
        if (!quiet) {
            trace('Stop', bit.settings.title)                                                     
        }
        if (bit.platform.os == 'windows') {
            Cmd([bit.prefixes.bin.join('appwebMonitor'), '--stop'])
        }
        let appman = Cmd.locate(bit.prefixes.bin.join('appman'))
        if (appman) {
            Cmd([appman, '--continue', 'stop', 'disable', 'uninstall'])
        }
    }
}


/*
    @copy   default
  
    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.
    Copyright (c) Michael O'Brien, 1993-2013. All Rights Reserved.
  
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
