/*
    main.js - Application main script.
*/
'use strict';

var app = angular.module('${TITLE}', ['ngAnimate', 'ngResource', 'ngRoute', 'ui.bootstrap']);

/*
    Request routes
 */
app.config(function($routeProvider) {
    $routeProvider.when('/', { 
        templateUrl: '/templates/splash.html',
    });
    $routeProvider.otherwise({ redirectTo: '/' });
});
