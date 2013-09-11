/*
    post.js - Post model
 */
'use strict';

app.factory('Post', function ($resource) {
    return $resource('/service/post/:id', {
        id: '@id'
    }, {
        'create': { 'method': 'POST',   url: '/service/post' },
        'edit':   { 'method': 'GET',    url: '/service/post/:id/edit' },
        'get':    { 'method': 'GET',    url: '/service/post/:id' },
        'init':   { 'method': 'GET',    url: '/service/post/init' },
        'list':   { 'method': 'GET',    url: '/service/post/list' },
        'remove': { 'method': 'DELETE', url: '/service/post/:id' },
        'update': { 'method': 'POST',   url: '/service/post/:id' },
    });
});
