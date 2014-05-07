/*
    ${UCONTROLLER} Controller (esp-angular-mvc)
 */

'use strict';

/*
    Specify the ${UCONTROLLER} controller and its dependencies.
 */
angular.module('app').controller('${UCONTROLLER}Control', function (Esp, ${UCONTROLLER}, $location, $routeParams, $scope) {
    angular.extend($scope, $routeParams);

    /*
        Model calling sequence:
            ${UCONTROLLER}.action(input-params, [output], [response-mappings], [success-callback], [failure-callback]);
            ${UCONTROLLER} will set results to [output] and update $rootScope.feedback as appropriate.
     */
    if ($scope.id) {
        ${UCONTROLLER}.get({id: $scope.id}, $scope);

    } else if ($location.path() == "/${CONTROLLER}/") {
        ${UCONTROLLER}.init(null, $scope);

    } else {
        ${UCONTROLLER}.list(null, $scope, {${LIST}: "data"});
    }

    $scope.remove = function() {
        ${UCONTROLLER}.remove({id: $scope.id}, function(response) {
            $location.path("/");
        });
    };

    $scope.save = function() {
        ${UCONTROLLER}.update($scope.${CONTROLLER}, $scope, function(response) {
            if (!response.error) {
                $location.path('/');
            }
        });
    };
});

/*
    Setup ${UCONTROLLER} routes
 */
angular.module('app').config(function($routeProvider) {
    var esp = angular.module('esp');
    var Default = {
        controller: '${UCONTROLLER}Control',
        resolve: { action: 'Esp' },
    };
    $routeProvider.when('/', angular.extend({}, Default, {templateUrl: esp.url('/app/${CONTROLLER}/${CONTROLLER}-list.html')}));
    $routeProvider.when('/${CONTROLLER}/list', angular.extend({}, Default, {templateUrl: esp.url('/app/${CONTROLLER}/${CONTROLLER}-list.html')}));
    $routeProvider.when('/${CONTROLLER}/:id', angular.extend({}, Default, {templateUrl: esp.url('/app/${CONTROLLER}/${CONTROLLER}-edit.html')}));
});
