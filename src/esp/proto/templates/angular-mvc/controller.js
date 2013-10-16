/*
    ${TITLE} Controller
 */

'use strict';

app.controller('${TITLE}Control', function (Esp, ${TITLE}, $location, $routeParams, $scope) {
    angular.extend($scope, $routeParams);
    /*
        Resource calling sequence:
            Resource.action(input-params, [output], [response-mappings], [success-callback], [failure-callback]);
            Resources will set results to [output] and update $rootScope.feedback as appropriate.
     */
    if ($scope.id) {
        ${TITLE}.get({id: $scope.id}, $scope);

    } else if ($location.path() == "/${NAME}/") {
        ${TITLE}.init(null, $scope);

    } else {
        ${TITLE}.list(null, $scope, {${LIST}: "data"});
    }

    $scope.remove = function() {
        ${TITLE}.remove({id: $scope.id}, function(response) {
            $location.path("/");
        });
    };

    $scope.save = function() {
        ${TITLE}.update($scope.${NAME}, $scope, function(response) {
            if (!response.error) {
                $location.path('/');
            }
        });
    };
});

app.config(function($routeProvider) {
    var Default = {
        controller: '${TITLE}Control',
        resolve: { action: 'Esp' },
    };
    $routeProvider.when('/', angular.extend({}, Default, {templateUrl: '/app/${NAME}/${NAME}-list.html'}));
    $routeProvider.when('/${NAME}/:id', angular.extend({}, Default, {templateUrl: '/app/${NAME}/${NAME}-edit.html'}));
});
