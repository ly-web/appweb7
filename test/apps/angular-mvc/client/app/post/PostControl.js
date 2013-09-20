/*
    Post Controller
 */

'use strict';

app.controller('PostControl', function ($rootScope, $scope, $location, $routeParams, Post) {
    if ($routeParams.id) {
        Post.get({id: $routeParams.id}, function(response) {
            $scope.data = response.data;
            $scope.schema = response.schema;
            $scope.post = $scope.data;
            $scope.action = "Edit";
        });
    } else if ($location.path() == "/service/post/") {
        $scope.action = "Create";
        $scope.post = new Post();
        Post.init({id: $routeParams.id}, function(response) {
            $scope.schema = response.schema;
        });
    } else {
        $scope.list = Post.list({}, function(response) {
            $scope.posts = response;
        });
    }
    $scope.routeParams = $routeParams;

    $scope.remove = function() {
        Post.remove({id: $scope.post.id}, function(response) {
            $location.path("/");
        });
    };

    $scope.save = function() {
        Post.save($scope.post, function(response) {
            if (!response.error) {
                $location.path('/');
            }
        });
    };

    $scope.click = function(index) {
        $location.path('/service/post/' + $scope.posts.data[index].id);
    };
});

app.config(function($routeProvider) {
    $routeProvider.when('/', {
        templateUrl: '/app/post/post-list.html',
        controller: 'PostControl',
    });
    $routeProvider.when('/service/post/:id', {
        templateUrl: '/app/post/post-edit.html',
        controller: 'PostControl',
    });
});
