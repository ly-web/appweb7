'use strict';

var app = angular.module('${TITLE}', ['ngResource', 'ui.bootstrap']);

/*
    Routes
 */
app.config(function($routeProvider) {
    $routeProvider.when('/', { 
        templateUrl: '/templates/splash.html',
    });
    $routeProvider.otherwise({ redirectTo: '/' });
});

