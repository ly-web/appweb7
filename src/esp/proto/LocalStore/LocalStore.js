/*
    LocalStore.js - Local storage service
 */
'use strict';

app.factory('LocalStore', function() {
    return {
        get: function (key) {
            return JSON.parse(localStorage.getItem(key) || '[]');
        },
        put: function (key, value) {
            localStorage.setItem(key, JSON.stringify(value));
        },
        remove: function (key, value) {
            localStorage.removeItem(key);
        }
    };
});
