/*
    main.js - Application main script
*/
'use strict';

var app = angular.module('${TITLE}', ['ngAnimate', 'ngResource', 'ngRoute', 'ui.bootstrap']);

/*
    Request routes
 */
app.config(function($routeProvider) {
    $routeProvider.when('/', { 
        templateUrl: '/pages/splash.html',
    });
    $routeProvider.otherwise({ redirectTo: '/' });
});


angular.element(document).ready(function() {
    var http = new XMLHttpRequest();
    http.onload = function() {
        try {
            app.config = JSON.parse(this.responseText);
        } catch(e) {
            console.log("Cannot parse ESP config", this.responseText)
        }
        angular.bootstrap(document, ['${TITLE}']);
    };
    http.open("get", "/esp/config", true);
    http.send();
});
