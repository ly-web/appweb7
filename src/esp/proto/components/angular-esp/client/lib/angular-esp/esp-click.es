/*
    esp-click directive

    <tag esp-click="URL" ... />

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */
module esp.angular.click {
    /**
        This directive implements the esp-click HTML attribute. Similar to the href attribute, it only redirects
        if the authorized user has the required abilities to access the route. The abilities are registered when
        the controller routes are declared.

        If the user does not have the required abilities, the message "Insufficient Privilege" is displayed in the
        feedback area. Otherwise the user is redirected to the requested URL.
     */
    class EspClick {
        /**
            The esp-click attribute takes one parameter in the form o
            @param url The 
        */
        public static function espClick(url: String): Void {}
    }
}


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
