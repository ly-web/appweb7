/*
    post.js - Post model
 */
'use strict';

angular.module('app').factory('Post', function (EspResource) {
    /*
        Create a RESTful factor for the post resource
     */
    return EspResource.group("post");
});
