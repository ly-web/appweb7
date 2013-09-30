/*
    esp-field-errors.js - ESP esp-field-errors directive

    <esp-field-errors ng-model="post.title" ...>
 */
app.directive('espFieldErrors', function($filter, $rootScope, $compile) {
    return {
        restrict: 'E',
        template: '<div class="form-error ng-cloak" ng-show="fieldErrors">\n' + 
                  '  <h2>The Post has errors that prevent it being saved.</h2>\n' +
                  '  <p>There were problems with the following fields:</p>\n' +
                  '  <ul ng-repeat="msg in fieldErrors">\n' +
                  '    <li>{{msg}}</li>\n'
    };
});
