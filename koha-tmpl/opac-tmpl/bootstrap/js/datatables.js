// These default options are for translation but can be used
// for any other datatables settings
// MSG_DT_* variables comes from datatables.inc
// To use it, write:
//  $("#table_id").dataTable($.extend(true, {}, dataTableDefaults, {
//      // other settings
//  } ) );
var dataTablesDefaults = {
    "language": {
        "paginate": {
            "first"    : window.MSG_DT_FIRST || "First",
            "last"     : window.MSG_DT_LAST || "Last",
            "next"     : window.MSG_DT_NEXT || "Next",
            "previous" : window.MSG_DT_PREVIOUS || "Previous"
        },
        "emptyTable"       : window.MSG_DT_EMPTY_TABLE || "No data available in table",
        "info"             : window.MSG_DT_INFO || "Showing _START_ to _END_ of _TOTAL_ entries",
        "infoEmpty"        : window.MSG_DT_INFO_EMPTY || "No entries to show",
        "infoFiltered"     : window.MSG_DT_INFO_FILTERED || "(filtered from _MAX_ total entries)",
        "lengthMenu"       : window.MSG_DT_LENGTH_MENU || "Show _MENU_ entries",
        "loadingRecords"   : window.MSG_DT_LOADING_RECORDS || "Loading...",
        "processing"       : window.MSG_DT_PROCESSING || "Processing...",
        "search"           : window.MSG_DT_SEARCH || "Search:",
        "zeroRecords"      : window.MSG_DT_ZERO_RECORDS || "No matching records found"
    },
    // "sorting": [$(" - select row position of th -")],
    "dom": 't',
    "paginate": false,
    // "fnHeaderCallback": function() {
    //     return $('th.sorting.nosort,th.sorting_desc.nosort,th.sorting_asc.nosort').removeClass("sorting sorting_desc sorting_asc").unbind("click");
    // }
};

/* Plugin to allow sorting on data stored in a span's title attribute
 *
 * Ex: <td><span title="[% ISO_date %]">[% formatted_date %]</span></td>
 *
 * In DataTables config:
 *     "columns": [
 *        { "type": "title-string" },
 *      ]
 * http://datatables.net/plug-ins/sorting#hidden_title_string
 */
jQuery.extend( jQuery.fn.dataTableExt.sort, {
    "title-string-pre": function ( a ) {
        return a.match(/title="(.*?)"/)[1].toLowerCase();
    },

    "title-string-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "title-string-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
} );

/* Plugin to allow sorting numerically on data stored in a span's title attribute
 *
 * Ex: <td><span title="[% total %]">Total: [% total %]</span></td>
 *
 * In DataTables config:
 *     "columns": [
 *        { "type": "title-numeric" }
 *     ]
 * http://legacy.datatables.net/plug-ins/sorting#hidden_title
 */
jQuery.extend( jQuery.fn.dataTableExt.sort, {
    "title-numeric-pre": function ( a ) {
        var x = a.match(/title="*(-?[0-9\.]+)/)[1];
        return parseFloat( x );
    },

    "title-numeric-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "title-numeric-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
} );

(function() {

    /* Plugin to allow text sorting to ignore articles
     *
     * In DataTables config:
     *     "columns": [
     *        { "type": "anti-the" },
     *      ]
     * Based on the plugin found here:
     * http://datatables.net/plug-ins/sorting#anti_the
     * Modified to exclude HTML tags from sorting
     * Extended to accept a string of space-separated articles
     * from a configuration file (in English, "a," "an," and "the")
     */

    if(CONFIG_EXCLUDE_ARTICLES_FROM_SORT){
        var articles = CONFIG_EXCLUDE_ARTICLES_FROM_SORT.split(" ");
        var rpattern = "";
        for(i=0;i<articles.length;i++){
            rpattern += "^" + articles[i] + " ";
            if(i < articles.length - 1){ rpattern += "|"; }
        }
        var re = new RegExp(rpattern, "i");
    }

    jQuery.extend( jQuery.fn.dataTableExt.sort, {
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
