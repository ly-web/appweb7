/*
    esp-resource.js - Esp wrapper for $resource

    Provides resourceGroup() and resource() methods on the EspResource service.
    MOB - DOC
 */
'use strict';

app.factory('EspResource', function (Esp, $resource) {
    var ResourceGroupActions = {
        'create': { 'method': 'POST',   url: '/:prefix/:controller' },
        'edit':   { 'method': 'GET',    url: '/:prefix/:controller/:id/edit' },
        'get':    { 'method': 'GET',    url: '/:prefix/:controller/:id' },
        'init':   { 'method': 'GET',    url: '/:prefix/:controller/init' },
        'list':   { 'method': 'GET',    url: '/:prefix/:controller/list' },
        'remove': { 'method': 'DELETE', url: '/:prefix/:controller/:id' },
        'update': { 'method': 'POST',   url: '/:prefix/:controller/:id' },
    };  
    var ResourceActions = {
        'create': { 'method': 'POST',   url: '/:prefix/:controller' },
        'edit':   { 'method': 'GET',    url: '/:prefix/:controller/edit' },
        'get':    { 'method': 'GET',    url: '/:prefix/:controller' },
        'init':   { 'method': 'GET',    url: '/:prefix/:controller/init' },
        'remove': { 'method': 'DELETE', url: '/:prefix/:controller' },
        'update': { 'method': 'POST',   url: '/:prefix/:controller' },
    };
    var DefaultParams = {
        id: '@id',
        prefix: function() {
            return Esp.config.settings.routePrefix.slice(1);
        },
    };
    return {
        resourceGroup: function(controller, params, actions) {
            actions = angular.extend({}, ResourceGroupActions, actions);
            params = angular.extend({}, DefaultParams, params);
            params.controller = controller;
            return $resource("/:prefix/:controller/:id", params, actions);
        },
        resource: function(controller, params, actions) {
            actions = angular.extend({}, ResourceActions, actions);
            params = angular.extend({}, DefaultParams, params);
            params.controller = controller;
            return $resource("/:prefix/:controller", params, actions);
        }
    };
});
