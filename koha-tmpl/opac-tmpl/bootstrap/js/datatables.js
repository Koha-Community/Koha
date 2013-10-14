// These default options are for translation but can be used
// for any other datatables settings
// MSG_DT_* variables comes from datatables-strings.inc
// To use it, write:
//  $("#table_id").dataTable($.extend(true, {}, dataTableDefaults, {
//      // other settings
//  } ) );
var dataTablesDefaults = {
    "oLanguage": {
        "oPaginate": {
            "sFirst"    : window.MSG_DT_FIRST || "First",
            "sLast"     : window.MSG_DT_LAST || "Last",
            "sNext"     : window.MSG_DT_NEXT || "Next",
            "sPrevious" : window.MSG_DT_PREVIOUS || "Previous"
        },
        "sEmptyTable"       : window.MSG_DT_EMPTY_TABLE || "No data available in table",
        "sInfo"             : window.MSG_DT_INFO || "Showing _START_ to _END_ of _TOTAL_ entries",
        "sInfoEmpty"        : window.MSG_DT_INFO_EMPTY || "No entries to show",
        "sInfoFiltered"     : window.MSG_DT_INFO_FILTERED || "(filtered from _MAX_ total entries)",
        "sLengthMenu"       : window.MSG_DT_LENGTH_MENU || "Show _MENU_ entries",
        "sLoadingRecords"   : window.MSG_DT_LOADING_RECORDS || "Loading...",
        "sProcessing"       : window.MSG_DT_PROCESSING || "Processing...",
        "sSearch"           : window.MSG_DT_SEARCH || "Search:",
        "sZeroRecords"      : window.MSG_DT_ZERO_RECORDS || "No matching records found"
    },
    // "aaSorting": [$(" - select row position of th -")],
    "sDom": 't',
    "bPaginate": false,
    // "fnHeaderCallback": function() {
    //     return $('th.sorting.nosort,th.sorting_desc.nosort,th.sorting_asc.nosort').removeClass("sorting sorting_desc sorting_asc").unbind("click");
    // }
};

/* Plugin to allow sorting on data stored in a span's title attribute
 *
 * Ex: <td><span title="[% ISO_date %]">[% formatted_date %]</span></td>
 *
 * In DataTables config:
 *     "aoColumns": [
 *        { "sType": "title-string" },
 *      ]
 * http://datatables.net/plug-ins/sorting#hidden_title_string
 */
jQuery.extend( jQuery.fn.dataTableExt.oSort, {
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

    if(CONFIG_EXCLUDE_ARTICLES_FROM_SORT){
        var articles = CONFIG_EXCLUDE_ARTICLES_FROM_SORT.split(" ");
        var rpattern = "";
        for(i=0;i<articles.length;i++){
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