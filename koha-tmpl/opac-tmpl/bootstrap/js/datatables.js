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
        "zeroRecords"      : window.MSG_DT_ZERO_RECORDS || "No matching records found",
        buttons: {
            "copyTitle"     : window.MSG_DT_COPY_TO_CLIPBOARD || "Copy to clipboard",
            "copyKeys"      : window.MSG_DT_COPY_KEYS || "Press <i>ctrl</i> or <i>⌘</i> + <i>C</i> to copy the table data<br>to your system clipboard.<br><br>To cancel, click this message or press escape.",
            "copySuccess": {
                _: window.MSG_DT_COPIED_ROWS || "Copied %d rows to clipboard",
                1: window.MSG_DT_COPIED_ONE_ROW || "Copied one row to clipboard",
            },
            "print": __("Print")
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

$.fn.dataTable.ext.buttons.clearFilter = {
    fade: 100,
    className: "dt_button_clear_filter",
    titleAttr: window.MSG_CLEAR_FILTER,
    enabled: false,
    text: '<i class="fa fa-lg fa-times"></i> <span class="dt-button-text">' + window.MSG_CLEAR_FILTER + '</span>',
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

    var config_exclude_articles_from_sort = window.CONFIG_EXCLUDE_ARTICLES_FROM_SORT || "a an the";
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

(function($) {

    $.fn.api = function(options, columns_settings, add_filters) {
        var settings = null;
        if(options) {
            if(!options.criteria || ['contains', 'starts_with', 'ends_with', 'exact'].indexOf(options.criteria.toLowerCase()) === -1) options.criteria = 'contains';
            options.criteria = options.criteria.toLowerCase();
            settings = $.extend(true, {}, dataTablesDefaults, {
                        'deferRender': true,
                        "paging": true,
                        'serverSide': true,
                        'searching': true,
                        'processing': true,
                        'language': {
                            'emptyTable': (options.emptyTable) ? options.emptyTable : "No data available in table"
                        },
                        'pagingType': 'full',
                        'ajax': {
                            'type': 'GET',
                            'cache': true,
                            'dataSrc': 'data',
                            'beforeSend': function(xhr, settings) {
                                this._xhr = xhr;
                                if(options.embed) {
                                    xhr.setRequestHeader('x-koha-embed', Array.isArray(options.embed)?options.embed.join(','):options.embed);
                                }
                            },
                            'dataFilter': function(data, type) {
                                var json = {data: JSON.parse(data)};
                                if(total = this._xhr.getResponseHeader('x-total-count')) {
                                    json.recordsTotal = total;
                                    json.recordsFiltered = total;
                                }
                                if(total = this._xhr.getResponseHeader('x-base-total-count')) {
                                    json.recordsTotal = total;
                                }
                                return JSON.stringify(json);
                            },
                            'data': function( data, settings ) {
                                var length = data.length;
                                var start  = data.start;

                                var dataSet = {
                                    _page: Math.floor(start/length) + 1,
                                    _per_page: length
                                };

                                var filter = data.search.value;
                                var query_parameters = settings.aoColumns
                                .filter(function(col) {
                                    return col.bSearchable && typeof col.data == 'string' && (data.columns[col.idx].search.value != '' || filter != '')
                                })
                                .map(function(col) {
                                    var part = {};
                                    var value = data.columns[col.idx].search.value != '' ? data.columns[col.idx].search.value : filter;
                                    part[!col.data.includes('.')?'me.'+col.data:col.data] = options.criteria === 'exact'?value:{like: (['contains', 'ends_with'].indexOf(options.criteria) !== -1?'%':'')+value+(['contains', 'starts_with'].indexOf(options.criteria) !== -1?'%':'')};
                                    return part;
                                });

                                if(query_parameters.length) {
                                    query_parameters = JSON.stringify(query_parameters.length === 1?query_parameters[0]:query_parameters);
                                    dataSet.q = query_parameters;
                                    delete options.query_parameters;
                                } else {
                                    delete options.query_parameters;
                                }

                                dataSet._match = options.criteria;

                                if(options.columns) {
                                    var order = data.order;
                                    order.forEach(function (e,i) {
                                        var order_col      = e.column;
                                        var order_by       = options.columns[order_col].data;
                                        var order_dir      = e.dir == 'asc' ? '+' : '-';
                                        dataSet._order_by = order_dir + (!order_by.includes('.')?'me.'+order_by:order_by);
                                    });
                                }

                                return dataSet;
                            }
                        }
                    }, options);
        }

        var counter = 0;
        var hidden_ids = [];
        var included_ids = [];

        $(columns_settings).each( function() {
            var named_id = $( 'thead th[data-colname="' + this.columnname + '"]', this ).index( 'th' );
            var used_id = settings.bKohaColumnsUseNames ? named_id : counter;
            if ( used_id == -1 ) return;

            if ( this['is_hidden'] == "1" ) {
                hidden_ids.push( used_id );
            }
            if ( this['cannot_be_toggled'] == "0" ) {
                included_ids.push( used_id );
            }
            counter++;
        });

        var exportColumns = ":visible:not(.noExport)";
        if( settings.hasOwnProperty("exportColumns") ){
            // A custom buttons configuration has been passed from the page
            exportColumns = settings["exportColumns"];
        }

        var export_format = {
            body: function ( data, row, column, node ) {
                var newnode = $(node);

                if ( newnode.find(".noExport").length > 0 ) {
                    newnode = newnode.clone();
                    newnode.find(".noExport").remove();
                }

                return newnode.text().replace( /\n/g, ' ' ).trim();
            }
        };

        var export_buttons = [
            {
                extend: 'excelHtml5',
                text: __("Excel"),
                exportOptions: {
                    columns: exportColumns,
                    format:  export_format
                },
            },
            {
                extend: 'csvHtml5',
                text: __("CSV"),
                exportOptions: {
                    columns: exportColumns,
                    format:  export_format
                },
            },
            {
                extend: 'copyHtml5',
                text: __("Copy"),
                exportOptions: {
                    columns: exportColumns,
                    format:  export_format
                },
            },
            {
                extend: 'print',
                text: __("Print"),
                exportOptions: {
                    columns: exportColumns,
                    format:  export_format
                },
            }
        ];

        settings[ "buttons" ] = [
            {
                fade: 100,
                className: "dt_button_clear_filter",
                titleAttr: __("Clear filter"),
                enabled: false,
                text: '<i class="fa fa-lg fa-times"></i> <span class="dt-button-text">' + __("Clear filter") + '</span>',
                action: function ( e, dt, node ) {
                    dt.search( "" ).draw("page");
                    node.addClass("disabled");
                }
            }
        ];

        if( included_ids.length > 0 ){
            settings[ "buttons" ].push(
                {
                    extend: 'colvis',
                    fade: 100,
                    columns: included_ids,
                    className: "columns_controls",
                    titleAttr: __("Columns settings"),
                    text: '<i class="fa fa-lg fa-gear"></i> <span class="dt-button-text">' + __("Columns") + '</span>',
                    exportOptions: {
                        columns: exportColumns
                    }
                }
            );
        }

        settings[ "buttons" ].push(
            {
                extend: 'collection',
                autoClose: true,
                fade: 100,
                className: "export_controls",
                titleAttr: __("Export or print"),
                text: '<i class="fa fa-lg fa-download"></i> <span class="dt-button-text">' + __("Export") + '</span>',
                buttons: export_buttons
            }
        );

        $(".dt_button_clear_filter, .columns_controls, .export_controls").tooltip();

        return $(this).dataTable(settings);
    };

})(jQuery);
