/*
    Documentation for angular-esp

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */
module esp.angular {
    /**
        Esp Angular service object.
        As an Angular service, there is only one instance of "Esp".
        The Esp service is typically defined via the angular injector. It is also aliased in $$rootScope.Esp.
        @stability prototype
     */
    class Esp {
        /**
            Determine if the user authorized to perform the given task.
            The user's abilities are defined by the server and passed to the client when the user logs in.
            @note: this is advisory only to provide hints in the UI. It is the server's repsonsibility to
            restrict user abilities as appropriate. We allow !user because auto-login will not set these.
            @param task Required task string
            @return True if the user has the ability to perform the requested task.
         */
        public static function can(task: String): Boolean { return true }

        /**
            Get a CSS class suitable for displaying or hiding UI components based on the user's abilities.
            Return enabled|disabled depending on if the user is authorized for a given task
            @param task Required task string
            @return "enabled" if the user has the ability to perform the requested task. Otherwise return "disabled".
         */
        public static function canClass(task: String): String { return "" }

//  MOB - rename getLoginStep
//  MOB - perhaps this should be boolean: Esp.authenticated
        /**
            Determine the user's current login state
            @return "Login" if the user is logged out. Return "logout" if the user is logged out.
         */
        public static function getLoginState(): String { return true }

//  MOB - should this be an attribute directive?    esp-nav-class="edit"
        /**
            Determine if the user is authorized to access a UI element
            @param uri Name of URI to test for access
            @param ability Required ability to access the uri
            @return CSS classes describing the user's ability to access the URI element. If the user can access the URI,
                the class "enabled" will be returned, otherwise "disabled" will be returned. If the URI is the current 
                application URI, then "active" will also be returned regardless of whether the user is authorized for
                the URI or not.
            Return "active" if the user is authorized for the specified tab
         */
        public static function navClass(uri: String, ability:String): String { return "" }

        /**
            Map a string to TitleCase
            @param str String to convert
            @return A titlecase string where the first letter of each word is capitalized.
         */
        public static function titlecase(str: String): String  { return "" }

        /**
            Set an information feedback message.
            The application may define how it displays feedback messages. By default, informational messages are 
            cleared wherenver a user clicks or navigates in the application.
            @param msg Message to display
         */
        public static function inform(msg: String): Void {}

        /**
            Set an error feedback message.
            The application may define how it displays feedback messages. By default, error messages are 
            persistent and are only cleared when the user performs a new operation in the application.
            @param msg Message to display
         */
        public static function error(msg: String): Void {}

        /**
            Authenticated user information
            @options abc
            @options def
         */
        public static var user: Object
    }

/*
    Document http interceptor. 
        - Sets feedback based on http error codes
        - Reidrects to $routeProvider.login 

    checkAuth
 */

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
