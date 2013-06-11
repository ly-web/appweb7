/*
    Esp.js - Esp state
 */
'use strict';

/*
    The Esp service provide a central place for ESP state.
    It places a "esp" object on the $rootScope that is inherited by all $scopes.
    Alternatively, injecting the Esp service provides direct access using the Esp service object.
 */
app.factory('Esp', function($rootScope, $location, SessionStore) {
    /*
        Define the Esp object and store in the $rootScope so all views can utilize.
     */
	var Esp = $rootScope.Esp = {}

    Esp.user = SessionStore.get('user');

    /*
     Change the URL. This can be used in view partials
     */
    Esp.goto = function(url) {
        $location.path(url);
    };

    /*
     Is this user authorized to perform the given task
     */
    Esp.can = function(task) {
        var user = Esp.user
        return (user && user.abilities && user.abilities[task]);
    };

    /*
     Return enabled|disabled depending on if the user is authorized for a given task
     */
    Esp.canClass = function(task) {
        var c = Esp.can(task);
        //  MOB - bootstrap classes
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

    return Esp;
});

/*
 Startup initialization. Fetch the application settings file config.json.
 */
app.run(function($rootScope, $http, Esp) {
    $http.get('config.json').success(function(data) {
        Esp.config = data;
    }).error(function() {
            console.log("Cannot fetch config.json");
        });
});

/*
    Define an Http interceptor to redirect 401 responses to the login page
 */
app.config(function($httpProvider, $routeProvider) {
    var interceptor = ['$location', '$q', '$rootScope', '$window', function($location, $q, $rootScope, $window) {
        function success(response) {
            return response;
        }
        //  MOB - should keep a queue of outstanding requests to retry
        function error(response) {
            if (response.status === 401) {
                $location.path($routeProvider.login);
                $rootScope.feedback = response.data.feedback;

            } else if (response.status >= 500) {
                $rootScope.feedback = { warning: "Server Error. Please Retry." };

            } else if (response.status >= 400) {
                $rootScope.feedback = { warning: "Request Error: " + response.status + ". Please Retry." };
            }
            return $q.reject(response);
        }
        return function(promise) {
            return promise.then(success, error);
        }
    }];
    $httpProvider.responseInterceptors.push(interceptor);
});

/*
    Route resolve function for routes to verify the user's defined abilities
 */
function checkAuth($q, $location, $rootScope, $route, Esp) {
    var requiredAbilities = $route.current.$$route.abilities;
    var user = Esp.user
    for (var ability in requiredAbilities) {
        if (!user || !user.abilities || user.abilities[ability] == null) {
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


