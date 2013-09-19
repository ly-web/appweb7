/*
    esp-input.js - ESP esp-input directive

    Expands to a datatype specific input element. This directive expects a $scope.schema to describe the datatype.
    <esp-input ng-model="post.title" ...>
 */
app.directive('espInput', function($rootScope, $compile) {
    return {
        restrict: 'E',
        replace: true,
        link: function (scope, element, attrs) {
            var name = attrs.ngModel;
            var parts = name.split('.');
            var field = parts[1];

            scope.$watch('schema', function (val) {
                if (scope.schema) {
                    if (element.children().length == 0) {
                        var type = scope.schema.types[field].type;
                        var tag;
                        if (type == 'text') {
                            tag = 'textarea';
                        } else {
                            tag = 'input';
                        }
                        var astr = '';
                        angular.forEach(attrs.$attr, function(value, key){
                            astr += ' ' + value + '="' + attrs[key] + '"';
                        });
                        var input = '<' + tag + astr + '>';
                        var newelt = angular.element(input);
                        element.replaceWith(newelt);
                        $compile(newelt)(scope);
                    }
                }
            });
        },
    }
});
