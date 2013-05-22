'use strict';

var app = angular.module('${TITLE}', ['ngResource', 'ui.bootstrap']);

/*
    Routes
 */
app.config(function($routeProvider) {
    $routeProvider.when('/', { 
        templateUrl: '/partials/splash.html',
    });
    $routeProvider.otherwise({ redirectTo: '/' });
});

