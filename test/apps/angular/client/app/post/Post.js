/*
    Post.js - Post model (esp-angular-mvc)
 */
'use strict';

angular.module('app').factory('Post', function (EspResource) {
    return EspResource.group("post");
});
