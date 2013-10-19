/*
    main.js - Application main script
*/
'use strict';

var app = angular.module('${TITLE}', ['ngAnimate', 'ngResource', 'ngRoute', 'ui.bootstrap', 'esp']);

/*
    Request routes
 */
app.config(function($routeProvider) {
    $routeProvider.when('/', { 
        templateUrl: '/pages/splash.html',
    });
    $routeProvider.otherwise({ redirectTo: '/' });
});


/*
    Load ESP configuration once the app is fully loaded
    Use explicit bootstrap rather than ng-app in index.esp so that ESP can retrieve the config.json first.
 */
angular.element(document).ready(function() {
    var http = new XMLHttpRequest();
    http.onload = function() {
        try {
            angular.module('esp').config = JSON.parse(this.responseText);
        } catch(e) {
            console.log("Cannot parse ESP config", this.responseText)
        }
        angular.bootstrap(document, ['${TITLE}']);
    };
    http.open("GET", "/esp/config", true);
    http.send();
});
