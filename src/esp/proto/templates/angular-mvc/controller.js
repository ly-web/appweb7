/*
    ${TITLE} Controller
 */

'use strict';

app.controller('${TITLE}Control', function ($rootScope, $scope, $location, $routeParams, ${TITLE}) {
    if ($routeParams.id) {
        ${TITLE}.get({id: $routeParams.id}, function(response) {
            $scope.schema = response.schema;
            $scope.data = response.data;
            $scope.${NAME} = response.data;
            $scope.action = "Edit";
        });
    } else if ($location.path() == "${SERVICE}/${NAME}/") {
        $scope.action = "Create";
        $scope.data = $scope.${NAME} = {};
        ${TITLE}.init({id: $routeParams.id}, function(response) {
            $scope.schema = response.schema;
        });
    } else {
        $scope.list = ${TITLE}.list({}, function(response) {
            $scope.${NAME}s = response;
        });
    }
    $scope.routeParams = $routeParams;

    $scope.remove = function() {
        ${TITLE}.remove({id: $scope.${NAME}.id}, function(response) {
            $rootScope.feedback = response.feedback;
            if (!response.error) {
                $rootScope.feedback.inform = "Deleted ${TITLE}";
                $location.path("/");
            } else {
                $rootScope.feedback.error = $rootScope.feedback.error || "Cannot Delete ${TITLE}";
            }
        });
    };

    $scope.save = function() {
        ${TITLE}.save($scope.${NAME}, function(response) {
            $rootScope.feedback = response.feedback;
            if (!response.error) {
                $rootScope.feedback.inform = $scope.routeParams.id ? "Updated ${TITLE}" : "Created New ${TITLE}";
                $location.path('/');
            } else {
                $scope.fieldErrors = response.fieldErrors;
                $rootScope.feedback.error = $rootScope.feedback.error || "Cannot Save ${TITLE}";
            }
        });
    };

    $scope.click = function(index) {
        $location.path('${SERVICE}/${NAME}/' + $scope.${NAME}s.data[index].id);
    };
});

app.config(function($routeProvider) {
    $routeProvider.when('/', {
        templateUrl: '/app/${NAME}/${NAME}-list.html',
        controller: '${TITLE}Control',
    });
    $routeProvider.when('${SERVICE}/${NAME}/:id', {
        templateUrl: '/app/${NAME}/${NAME}-edit.html',
        controller: '${TITLE}Control',
    });
});
