/*
    Post Controller
 */

'use strict';

/*
    Specify the Post controller and its dependencies.
 */
angular.module('app').controller('PostControl', function (Esp, Post, $location, $routeParams, $scope) {
    angular.extend($scope, $routeParams);

    /*
        Model calling sequence:
            Post.action(input-params, [output], [response-mappings], [success-callback], [failure-callback]);
            Post will set results to [output] and update $rootScope.feedback as appropriate.
     */
    if ($scope.id) {
        Post.get({id: $scope.id}, $scope);

    } else if ($location.path() == "/post/") {
        Post.init(null, $scope);

    } else {
        Post.list(null, $scope, {posts: "data"});
    }

    $scope.remove = function() {
        Post.remove({id: $scope.id}, function(response) {
            $location.path("/");
        });
    };

    $scope.save = function() {
        Post.update($scope.post, $scope, function(response) {
            if (!response.error) {
                $location.path('/');
            }
        });
    };
});

/*
    Setup Post routes
 */
angular.module('app').config(function($routeProvider) {
    var esp = angular.module('esp');
    var Default = {
        controller: 'PostControl',
        resolve: { action: 'Esp' },
    };
    $routeProvider.when('/', angular.extend({}, Default, {templateUrl: esp.url('/app/post/post-list.html')}));
    $routeProvider.when('/post/:id', angular.extend({}, Default, {templateUrl: esp.url('/app/post/post-edit.html')}));
});
