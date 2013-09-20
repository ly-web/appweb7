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
