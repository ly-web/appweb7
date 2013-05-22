'use strict';

;(function() {
    window.esp = {
        titles: function(schema) {
            var titles = []
            for (var col in schema) {
                if (col == "id") continue;
                titles.push(col.charAt(0).toUpperCase() + col.substr(1).toLowerCase());
            } 
            return titles;
        },

        columns: function(schema) {
            var columns = []
            for (var col in schema) {
                if (col == "id") continue;
                columns.push(col);
            } 
            return columns;
        }
    }

})(); 
