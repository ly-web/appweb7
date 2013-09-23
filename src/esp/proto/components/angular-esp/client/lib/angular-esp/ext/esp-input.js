/*
    esp-input.js - ESP esp-input directive

    Attributes:
        ng-model="MODEL.FIELD"          Angular model field object
        control="Control"               Input control to render (checkbox, text, textarea)

    Expands to a datatype specific input element. This directive expects a $scope.schema to describe the datatype.
    <esp-input ng-model="post.title" ...>
 */
app.directive('espInput', function($filter, $rootScope, $compile) {
    var dataTypeToTagType = {
        binary: 'text',
        bool: 'checkbox',
        date: 'date',
        float: 'text',
        int: 'text',
        string: 'text',
        text: '',
    }
    var dataTypeToTag = {
        binary: 'input',
        bool: 'input',
        date: 'input',
        float: 'input',
        int: 'input',
        string: 'input',
        text: 'textarea',
    }
    return {
        restrict: 'E',
        replace: true,
        link: function (scope, element, attrs) {
            var name = attrs.ngModel;
            var parts = name.split('.');
            var model = parts[0];
            var field = parts[1];

            scope.$watch('schema', function (val) {
                if (scope.schema && element.parent().length && element.children().length == 0) {
                    var dataType = scope.schema.types[field].type;
                    var astr = '';
                    angular.forEach(attrs.$attr, function(avalue, key) {
                        astr += ' ' + avalue + '="' + attrs[key] + '"';
                    });
                    var value = scope[model][field];
                    if (dataType == 'date') {
                        /* Convert to RFC3399 date as required for HTML5 date input controls */
                        value = Date.parse(value);
                        value = $filter('date')(value, 'yyyy-MM-dd');
                        scope[model][field] = value;
                    }
                    var tag, type;
                    if (attrs.control) {
                        type = attrs.control;
                        if (type == 'textarea') { 
                            tag = textarea; 
                        }
                    } else {
                        tag = dataTypeToTag[dataType] || "input";
                        type = dataTypeToTagType[dataType] || "text";
                    }
                    if (type == 'checkbox') {
                        astr = astr.replace(/form-control/, '');
                    }
                    input = '<' + tag + ' type="' + type + '"' + astr + '>';
                    if (type == 'checkbox') {
                        input = '<label class="checkbox">' + input + '</label>';
                    }
                    var newelt = angular.element(input);
                    element.replaceWith(newelt);
                    $compile(newelt)(scope);
                }
            });
        },
    }
});
