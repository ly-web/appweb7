/*
    esp-fixnum.js - Titlecase Filter

    This filter caps the first letter of each word

    number | fixnum
 */

angular.module('esp.fixnum', [])
.filter('fixnum', function () {
    return function (n, len) {
        var num = parseInt(n, 10);
        len = parseInt(len, 10);
        if (isNaN(num) || isNaN(len)) {
            return n;
        }
        num = '' + num;
        while (num.length < len) {
            num = '0' + num;
        }
        return num;
    };
});
