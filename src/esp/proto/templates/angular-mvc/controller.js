/*
    ${TITLE} Controller
 */

'use strict';

app.controller('${TITLE}Control', function ($rootScope, $scope, $location, $routeParams, ${TITLE}) {
    if ($routeParams.id) {
        ${TITLE}.get({id: $routeParams.id}, function(response) {
            // $scope.data = response.data;
            $scope.schema = response.schema;
            $scope.${NAME} = response.data;
            $scope.action = "Edit";
        });
    } else if ($location.path() == "${SERVICE}/${NAME}/") {
        $scope.action = "Create";
        $scope.${NAME} = new ${TITLE}();
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
            $location.path("/");
        });
    };

    $scope.save = function() {
        ${TITLE}.save($scope.${NAME}, function(response) {
            if (!response.error) {
                $location.path('/');
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
