/*
    post.js - Post model
 */
'use strict';

angular.module('app').factory('Post', function (EspResource) {
    return EspResource.group("post");
});
