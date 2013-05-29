'use strict';

/*
    Application controller. This is the top level application controller. 
 */
app.controller('AppControl', function($scope, $location) {
    /*
        Change the URL. This can be used in templates.
     */
    $scope.goto = function(url) {
        $location.path(url);
    };
});
