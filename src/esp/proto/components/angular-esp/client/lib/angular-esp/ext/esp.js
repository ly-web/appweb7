/*
    esp.js - Esp Angular Extension
 */
'use strict';

/*
    The Esp service provide a central place for ESP state.
    It places a "Esp" object on the $rootScope that is inherited by all $scopes.
    Alternatively, injecting the Esp service provides direct access using the Esp service object.
 */
app.factory('Esp', function($document, $http, $rootScope, $location, SessionStore) {
    var Esp = $http.get('/esp/config').success(function(data) {
        Esp.config = data;
        /* Fix for Angular. ng-click is looking for Esp.then and not finding Esp.$$v */
        Esp.then = undefined;
        $rootScope.Esp = Esp;
    }).error(function() {
        console.log("Cannot fetch configuration");
    });

    /*
        Is this user authorized to perform the given task
        Note: this is advisory only to provide hints in the UI. It is the server's repsonsibility to
        restrict user abilities as appropriate. We allow !user because auto-login will not set these.
     */
    Esp.can = function(task) {
        var user = Esp.user
        return !user || (user.abilities && user.abilities[task]);
    };

    /*
        Return enabled|disabled depending on if the user is authorized for a given task
     */
    Esp.canClass = function(task) {
        return Esp.can(task) ? "enabled" : "disabled";
    };

    /*
        Determine the current login state
     */
    Esp.getLoginState = function() {
        return (Esp.user && Esp.user.name) ? "Logout" : "Login";
    };

    /*
        Return "active" if the user is authorized for the specified tab
     */
    Esp.navClass = function(tab, ability) {
        var classes = [];
        if (tab == $location.path()) {
            classes.push('active');
        } else if (tab != "/" && $location.path().indexOf(tab) >= 0) {
            classes.push('active');
        }
        if (ability) {
            classes.push(Esp.canClass(ability));
        }
        return classes.join(' ');
    };

    /*
        Map a string to TitleCase
     */
    Esp.titlecase = function (str) {
        var words = str.split(/[ \.]/g);
        for (var i = 0; i < words.length; i++) {
            words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1);
        }
        return words.join(' ');
    };

    Esp.inform = function (str) {
        $rootScope.feedback = { inform: str };
    };

    Esp.error = function (str) {
        $rootScope.feedback = { error: str };
    };

    /*
        Remember the referrer in route changes
     */
    $rootScope.$on("$routeChangeSuccess", function(scope, current, previous) {
        $rootScope.referrer = previous;
    });

    /*
        Whenever the user clicks something, clear the feedback
     */
    $document.bind("click", function(event){
        $rootScope.feedback = {};
        return true;
    });

    /*
        Recover the user session information. The server still validates incase this is stale.
     */
    Esp.user = SessionStore.get('user');
    return Esp;
});


/*
    Define an Http interceptor to redirect 401 responses to the login page
 */
app.config(function($httpProvider, $routeProvider) {
    var interceptor = ['$location', '$q', '$rootScope', '$window', function($location, $q, $rootScope, $window) {
        function success(response) {
            if (response.feedback) {
                $rootScope.feedback = response.feedback;
            }
            return response;
        }
        function error(response) {
            if (response <= 0 || response.status >= 500) {
                $rootScope.feedback = { warning: "Server Error. Please Retry." };
            } else if (response.status === 401) {
                $location.path($routeProvider.login);
            } else if (response.status >= 400) {
                $rootScope.feedback = { warning: "Request Error: " + response.status + ", for " + response.config.url};
            } else if (response.feedback) {
                $rootScope.feedback = response.feedback;
            }
            return $q.reject(response);
        }
        return function(promise) {
            return promise.then(success, error);
        }
    }];
    $httpProvider.responseInterceptors.push(interceptor);
});


//  MOB - why is this a global function? Can it be Esp.checkAuth?
/*
    Route resolve function for routes to verify the user's defined abilities
 */
function checkAuth($q, $location, $rootScope, $route, Esp) {
    var requiredAbilities = $route.current.$$route.abilities;
    var user = Esp.user
    for (var ability in requiredAbilities) {
        if (user && user.abilities && user.abilities[ability] == null) {
            if ($location.path() != "/") {
                $rootScope.feedback = { inform: "Insufficient Privilege"};
                $location.path(Esp.lastLocation || "/");
                return $q.reject($rootScope.feedback);
            }
        }
    }
    Esp.lastLocation = $location.path();
    if (user) {
        user.lastAccess = Date.now();
    }
    return true;
}
