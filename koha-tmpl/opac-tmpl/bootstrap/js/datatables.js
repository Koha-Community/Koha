/* global __ */
// These default options are for translation but can be used
// for any other datatables settings
// To use it, write:
//  $("#table_id").dataTable($.extend(true, {}, dataTableDefaults, {
//      // other settings
//  } ) );
var dataTablesDefaults = {
    language: {
        paginate: {
            first: __("First"),
            last: __("Last"),
            next: __("Next"),
            previous: __("Previous"),
        },
        emptyTable: __("No data available in table"),
        info: __("Showing _START_ to _END_ of _TOTAL_ entries"),
        infoEmpty: __("No entries to show"),
        infoFiltered: __("(filtered from _MAX_ total entries)"),
        lengthMenu: __("Show _MENU_ entries"),
        loadingRecords: __("Loading..."),
        processing: __("Processing..."),
        search: __("Search:"),
        zeroRecords: __("No matching records found"),
        buttons: {
            copyTitle: __("Copy to clipboard"),
            copyKeys: __(
                "Press <i>ctrl</i> or <i>⌘</i> + <i>C</i> to copy the table data<br>to your system clipboard.<br><br>To cancel, click this message or press escape."
            ),
            copySuccess: {
                _: __("Copied %d rows to clipboard"),
                1: __("Copied one row to clipboard"),
            },
            print: __("Print"),
            copy: __("Copy"),
            csv: __("CSV"),
            excel: __("Excel"),
        },
    },
    dom: "t",
    buttons: ["clearFilter", "copy", "csv", "print"],
    paging: false,
    initComplete: function (settings) {
        var tableId = settings.nTable.id;
        state = settings.oLoadedState;
        state &&
            state.search &&
            toggledClearFilter(state.search.search, tableId);
    },
};
DataTable.defaults.column.orderSequence = ["asc", "desc"];

function toggledClearFilter(searchText, tableId) {
    let clear_filter_button = $("#" + tableId + "_wrapper").find(
        ".dt_button_clear_filter"
    );
    if (searchText == "") {
        clear_filter_button.addClass("disabled");
    } else {
        clear_filter_button.removeClass("disabled");
    }
}

(function () {
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
    if (config_exclude_articles_from_sort) {
        var articles = config_exclude_articles_from_sort.split(" ");
        var rpattern = "";
        for (var i = 0; i < articles.length; i++) {
            rpattern += "^" + articles[i] + " ";
            if (i < articles.length - 1) {
                rpattern += "|";
            }
        }
        var re = new RegExp(rpattern, "i");
    }

    jQuery.extend(jQuery.fn.dataTableExt.oSort, {
        "anti-the-pre": function (a) {
            var x = String(a).replace(/<[\s\S]*?>/g, "");
            var y = x.trim();
            var z = y.replace(re, "").toLowerCase();
            return z;
        },

        "anti-the-asc": function (a, b) {
            return a < b ? -1 : a > b ? 1 : 0;
        },

        "anti-the-desc": function (a, b) {
            return a < b ? 1 : a > b ? -1 : 0;
        },
    });
})();

function _dt_buttons(params) {
    let settings = params.settings || {};
    let table_settings = params.table_settings;

    var exportColumns = ":visible:not(.no-export)";

    var export_format = {
        body: function (data, row, column, node) {
            var newnode = $(node);

            if (newnode.find(".no-export").length > 0) {
                newnode = newnode.clone();
                newnode.find(".no-export").remove();
            }

            return newnode.text().replace(/\n/g, " ").trim();
        },
    };

    var export_buttons = [
        {
            extend: "excelHtml5",
            exportOptions: {
                columns: exportColumns,
                format: export_format,
            },
        },
        {
            extend: "csvHtml5",
            exportOptions: {
                columns: exportColumns,
                format: export_format,
            },
        },
        {
            extend: "copyHtml5",
            exportOptions: {
                columns: exportColumns,
                format: export_format,
            },
        },
        {
            extend: "print",
            exportOptions: {
                columns: exportColumns,
                format: export_format,
            },
        },
    ];

    let buttons = [
        {
            fade: 100,
            className: "dt_button_clear_filter",
            titleAttr: __("Clear filter"),
            enabled: false,
            text:
                '<i class="fa fa-lg fa-times" aria-hidden="true"></i> <span class="dt-button-text">' +
                __("Clear filter") +
                "</span>",
            action: function (e, dt, node, config) {
                dt.search("").draw("page");
                node.addClass("disabled");
            },
        },
        {
            extend: "csvHtml5",
            text: __("CSV"),
            exportOptions: {
                columns: exportColumns,
                format: export_format,
            },
        },
        {
            extend: "copyHtml5",
            text: __("Copy"),
            exportOptions: {
                columns: exportColumns,
                format: export_format,
            },
        },
        {
            extend: "print",
            text: __("Print"),
            exportOptions: {
                columns: exportColumns,
                format: export_format,
            },
        },
    ];

    // Retrieving bKohaColumnsUseNames from the options passed to the constructor, not DT's settings
    // But ideally should be retrieved using table.data()
    let use_names = settings.bKohaColumnsUseNames;
    let included_columns = [];
    if (table_settings) {
        if (use_names) {
            // bKohaColumnsUseNames is set, identify columns by their data-colname
            included_columns = table_settings.columns
                .filter(c => !c.cannot_be_toggled)
                .map(c => "[data-colname='%s']".format(c.columnname))
                .join(",");
        } else {
            // Not set, columns are ordered the same than in the columns settings
            included_columns = table_settings.columns
                .map((c, i) => (!c.cannot_be_toggled ? i : null))
                .filter(i => i !== null);
        }
    }
    if (included_columns.length > 0) {
        buttons.push({
            extend: "colvis",
            fade: 100,
            columns: included_columns,
            className: "columns_controls",
            titleAttr: __("Columns settings"),
            text:
                '<i class="fa fa-lg fa-gear" aria-hidden="true"></i> <span class="dt-button-text">' +
                __("Columns") +
                "</span>",
            exportOptions: {
                columns: exportColumns,
            },
        });
    }

    return buttons;
}

function _dt_visibility(table_settings, table_dt) {
    let hidden_ids = [];
    if (table_settings) {
        var columns_settings = table_settings.columns;
        let i = 0;
        let use_names = $(table_dt.table().node()).data("bKohaColumnsUseNames");
        if (use_names) {
            let hidden_columns = table_settings.columns.filter(
                c => c.is_hidden
            );
            if (!hidden_columns.length) return [];
            table_dt
                .columns(
                    hidden_columns
                        .map(c => "[data-colname='%s']".format(c.columnname))
                        .join(",")
                )
                .every(function () {
                    hidden_ids.push(this.index());
                });
        } else {
            $(columns_settings).each(function (i, c) {
                if (c.is_hidden == "1") {
                    hidden_ids.push(i);
                }
            });
        }
    }
    return hidden_ids;
}

(function ($) {
    /**
     * Create a new dataTables instance that uses the Koha RESTful API's as a data source
     * @param  {Object}  options                      Please see the dataTables settings documentation for further
     *                                                details
     * @param  {string}  [options.criteria=contains]  A koha specific extension to the dataTables settings block that
     *                                                allows setting the 'comparison operator' used in searches
     *                                                Supports `contains`, `starts_with`, `ends_with` and `exact` match
     * @param  {string}  [options.columns.*.type      Data type the field is stored in so we may impose some additional
     *                                                manipulation to search strings. Supported types are currently 'date'
     * @param  {Object}  table_settings               The arrayref as returned by TableSettings.GetTableSettings function
     *                                                available from the columns_settings template toolkit include
     * @return {Object}                               The dataTables instance
     */
    $.fn.kohaTable = function (options = {}, table_settings = undefined) {
        // Early return if the node does not exist
        if (!this.length) return;

        if (options) {
            // Don't redefine the default initComplete
            if (options.initComplete) {
                let our_initComplete = options.initComplete;
                options.initComplete = function (settings, json) {
                    our_initComplete(settings, json);
                    dataTablesDefaults.initComplete(settings, json);
                };
            }
        }

        var settings = $.extend(
            true,
            {},
            dataTablesDefaults,
            {
                searching: true,
                language: {
                    emptyTable: options.emptyTable
                        ? options.emptyTable
                        : __("No data available in table"),
                },
            },
            options
        );

        settings["buttons"] = _dt_buttons({ settings, table_settings });

        if (table_settings) {
            if (
                table_settings.hasOwnProperty("default_display_length") &&
                table_settings["default_display_length"] != null
            ) {
                settings["pageLength"] =
                    table_settings["default_display_length"];
            }
            if (
                table_settings.hasOwnProperty("default_sort_order") &&
                table_settings["default_sort_order"] != null
            ) {
                settings["order"] = [
                    [table_settings["default_sort_order"], "asc"],
                ];
            }
        }

        var default_column_defs = [
            { targets: ["string-sort"], type: "string" },
            { targets: ["anti-the"], type: "anti-the" },
            { targets: ["no-sort"], orderable: false, searchable: false },
        ];
        if (settings["columnDefs"] === undefined) {
            settings["columnDefs"] = default_column_defs;
        } else {
            settings["columnDefs"] =
                settings["columnDefs"].concat(default_column_defs);
        }

        $(this).data("bKohaColumnsUseNames", settings.bKohaColumnsUseNames);
        var table = $(this).dataTable(settings);

        var table_dt = table.DataTable();

        table_dt.on("search.dt", function (e, settings) {
            // When the DataTables search function is triggered,
            // enable or disable the "Clear filter" button based on
            // the presence of a search string
            toggledClearFilter(table_dt.search(), settings.nTable.id);
        });

        let hidden_ids = _dt_visibility(table_settings, table_dt);
        table_dt
            .on("column-visibility.dt", function () {
                if (typeof columnsInit == "function") {
                    // This function can be created separately and used to trigger
                    // an event after the DataTable has loaded AND column visibility
                    // has been updated according to the table's configuration
                    columnsInit();
                }
            })
            .columns(hidden_ids)
            .visible(false);

        return table;
    };
})(jQuery);
