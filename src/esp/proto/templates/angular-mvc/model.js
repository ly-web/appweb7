/*
    ${NAME}.js - ${TITLE} model
 */
'use strict';

app.factory('${TITLE}', function ($resource) {
    return $resource('${SERVICE}/${NAME}/:id', {
        id: '@id'
    }, {
        'create': { 'method': 'POST',   url: '${SERVICE}/${NAME}' },
        'edit':   { 'method': 'GET',    url: '${SERVICE}/${NAME}/:id/edit' },
        'get':    { 'method': 'GET',    url: '${SERVICE}/${NAME}/:id' },
        'init':   { 'method': 'GET',    url: '${SERVICE}/${NAME}/init' },
        'list':   { 'method': 'GET',    url: '${SERVICE}/${NAME}/list' },
        'remove': { 'method': 'DELETE', url: '${SERVICE}/${NAME}/:id' },
        'update': { 'method': 'POST',   url: '${SERVICE}/${NAME}/:id' },
    });
});
