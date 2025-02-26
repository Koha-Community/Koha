/* global __ */
// These default options are for translation but can be used
// for any other datatables settings
// To use it, write:
//  $("#table_id").dataTable($.extend(true, {}, dataTableDefaults, {
//      // other settings
//  } ) );
var dataTablesDefaults = {
    "language": {
        "paginate": {
            "first"    : __("First"),
            "last"     : __("Last"),
            "next"     : __("Next"),
            "previous" : __("Previous")
        },
        "emptyTable"       : __("No data available in table"),
        "info"             : __("Showing _START_ to _END_ of _TOTAL_ entries"),
        "infoEmpty"        : __("No entries to show"),
        "infoFiltered"     : __("(filtered from _MAX_ total entries)"),
        "lengthMenu"       : __("Show _MENU_ entries"),
        "loadingRecords"   : __("Loading..."),
        "processing"       : __("Processing..."),
        "search"           : __("Search:"),
        "zeroRecords"      : __("No matching records found"),
        buttons: {
            "copyTitle"     : __("Copy to clipboard"),
            "copyKeys"      : __("Press <i>ctrl</i> or <i>⌘</i> + <i>C</i> to copy the table data<br>to your system clipboard.<br><br>To cancel, click this message or press escape."),
            "copySuccess": {
                _: __("Copied %d rows to clipboard"),
                1: __("Copied one row to clipboard"),
            },
            "print": __("Print"),
            "copy": __("Copy"),
            "csv": __("CSV"),
            "excel": __("Excel")
        }
    },
    "dom": 't',
    "buttons": [
        'clearFilter', 'copy', 'csv', 'print'
    ],
    "paginate": false,
    initComplete: function( settings) {
        var tableId = settings.nTable.id
        // When the DataTables search function is triggered,
        // enable or disable the "Clear filter" button based on
        // the presence of a search string
        $("#" + tableId ).on( 'search.dt', function ( e, settings ) {
            if( settings.oPreviousSearch.sSearch == "" ){
                $("#" + tableId + "_wrapper").find(".dt_button_clear_filter").addClass("disabled");
            } else {
                $("#" + tableId + "_wrapper").find(".dt_button_clear_filter").removeClass("disabled");
            }
        });
    }
};
DataTable.defaults.column.orderSequence = ['asc', 'desc'];

$.fn.dataTable.ext.buttons.clearFilter = {
    fade: 100,
    className: "dt_button_clear_filter",
    titleAttr: __("Clear filter"),
    enabled: false,
    text: '<i class="fa fa-lg fa-times"></i> <span class="dt-button-text">' + __("Clear filter") + '</span>',
    available: function ( dt ) {
        // The "clear filter" button is made available if this test returns true
        if( dt.settings()[0].aanFeatures.f ){ // aanFeatures.f is null if there is no search form
            return true;
        }
    },
    action: function ( e, dt, node ) {
        dt.search( "" ).draw("page");
        node.addClass("disabled");
    }
};

(function() {

    /* Plugin to allow text sorting to ignore articles
     *
     * In DataTables config:
     *     "aoColumns": [
     *        { "sType": "anti-the" },
     *      ]
     * Based on the plugin found here:
     * http://datatables.net/plug-ins/sorting#anti_the
     * Modified to exclude HTML tags from sorting
     * Extended to accept a string of space-separated articles
     * from a configuration file (in English, "a," "an," and "the")
     */

    var config_exclude_articles_from_sort = __("a an the");
    if (config_exclude_articles_from_sort){
        var articles = config_exclude_articles_from_sort.split(" ");
        var rpattern = "";
        for( var i=0; i<articles.length; i++){
            rpattern += "^" + articles[i] + " ";
            if(i < articles.length - 1){ rpattern += "|"; }
        }
        var re = new RegExp(rpattern, "i");
    }

    jQuery.extend( jQuery.fn.dataTableExt.oSort, {
        "anti-the-pre": function ( a ) {
            var x = String(a).replace( /<[\s\S]*?>/g, "" );
            var y = x.trim();
            var z = y.replace(re, "").toLowerCase();
            return z;
        },

        "anti-the-asc": function ( a, b ) {
            return ((a < b) ? -1 : ((a > b) ? 1 : 0));
        },

        "anti-the-desc": function ( a, b ) {
            return ((a < b) ? 1 : ((a > b) ? -1 : 0));
        }
    });

}());
