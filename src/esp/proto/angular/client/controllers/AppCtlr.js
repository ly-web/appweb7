'use strict';

/*
    Application controller. This is the top level application controller. 
 */
app.controller('AppCtrl', function($scope, $location) {
    /*
        Change the URL. This can be used in view partials.
     */
    $scope.goto = function(url) {
        $location.path(url);
    };
});
