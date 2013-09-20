/*
    esp-input.js - ESP esp-input directive

    Attributes:
        ng-model="MODEL.FIELD"          Angular model field object
        control="Control"               Input control to render (checkbox, text, textarea)
    Attributes:

    ng-model    

    Expands to a datatype specific input element. This directive expects a $scope.schema to describe the datatype.
    <esp-input ng-model="post.title" ...>
 */
app.directive('espInput', function($rootScope, $compile) {
    /*
        MOB new html5 types:

            url
            number max= min= step= 
            tel
            range   min= max=       slider
            date
            week
            time
            color

            required attribute
     */
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
            var field = parts[1];

            scope.$watch('schema', function (val) {
                if (scope.schema && element.parent().length && element.children().length == 0) {
                    var dataType = scope.schema.types[field].type;
                    var astr = '';
                    angular.forEach(attrs.$attr, function(value, key) {
                        astr += ' ' + value + '="' + attrs[key] + '"';
                    });
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
