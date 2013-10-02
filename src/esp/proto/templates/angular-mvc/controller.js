/*
    ${TITLE} Controller
 */

'use strict';

app.controller('${TITLE}Control', function (Esp, $rootScope, $scope, $location, $routeParams, ${TITLE}) {
    if ($routeParams.id) {
        $scope.${NAME} = ${TITLE}.get({id: $routeParams.id}, function(response) {
            angular.extend($scope, response, {action: "Edit"});
        });
    } else if ($location.path() == "/${NAME}/") {
        $scope.${NAME} = ${TITLE}.init({}, function(response) {
            angular.extend($scope, response, {action: "Create"});
        });
    } else {
        $scope.${TABLE} = ${TITLE}.list({}, function(response) {
            angular.extend($scope, response);
        });
    }

    $scope.remove = function() {
        ${TITLE}.remove($scope.${NAME}, function(response) {
            if (response.error) {
                Esp.error("Cannot Delete ${TITLE}");
            } else {
                Esp.inform("Deleted ${TITLE}");
                $location.path("/");
            }
        });
    };

    $scope.save = function() {
        ${TITLE}.save($scope.${NAME}, function(response) {
            if (response.error) {
                $scope.fieldErrors = response.fieldErrors;
                Esp.error("Cannot Save ${TITLE}");
            } else {
                Esp.inform($routeParams.id ? "Updated ${TITLE}" : "Created New ${TITLE}");
                $location.path('/');
            }
        });
    };
});

app.config(function($routeProvider) {
    $routeProvider.when('/', {
        templateUrl: '/app/${NAME}/${NAME}-list.html',
        controller: '${TITLE}Control',
        resolve: { action: 'Esp' },
    });
    $routeProvider.when('/${NAME}/:id', {
        templateUrl: '/app/${NAME}/${NAME}-edit.html',
        controller: '${TITLE}Control',
        resolve: { action: 'Esp' },
    });
});
