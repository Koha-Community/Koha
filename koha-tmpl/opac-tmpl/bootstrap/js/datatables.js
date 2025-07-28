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

function _dt_default_ajax(params) {
    let default_filters = params.default_filters;
    let options = params.options;

    if (
        !options.criteria ||
        ["contains", "starts_with", "ends_with", "exact"].indexOf(
            options.criteria.toLowerCase()
        ) === -1
    )
        options.criteria = "contains";
    options.criteria = options.criteria.toLowerCase();

    return {
        type: "GET",
        cache: true,
        dataSrc: "data",
        beforeSend: function (xhr, settings) {
            this._xhr = xhr;
            if (options.embed) {
                xhr.setRequestHeader(
                    "x-koha-embed",
                    Array.isArray(options.embed)
                        ? options.embed.join(",")
                        : options.embed
                );
            }
        },
        dataFilter: function (data, type) {
            var json = { data: JSON.parse(data) };
            if ((total = this._xhr.getResponseHeader("x-total-count"))) {
                json.recordsTotal = total;
                json.recordsFiltered = total;
            }
            if ((total = this._xhr.getResponseHeader("x-base-total-count"))) {
                json.recordsTotal = total;
            }
            if ((draw = this._xhr.getResponseHeader("x-koha-request-id"))) {
                json.draw = draw;
            }

            return JSON.stringify(json);
        },
        data: function (data, settings) {
            var length = data.length;
            var start = data.start;

            let api = new $.fn.dataTable.Api(settings);
            const global_search = api.search();

            var dataSet = {
                _page: Math.floor(start / length) + 1,
                _per_page: length,
            };

            function build_query(col, value) {
                var parts = [];
                var attributes = col.data.split(":");
                for (var i = 0; i < attributes.length; i++) {
                    var part = {};
                    var attr = attributes[i];
                    let default_build = true;
                    let criteria = options.criteria;
                    if (value.match(/^\^(.*)\$$/)) {
                        value = value.replace(/^\^/, "").replace(/\$$/, "");
                        criteria = "exact";
                    } else {
                        // escape SQL LIKE special characters %
                        value = value.replace(/(\%|\\)/g, "\\$1");
                    }

                    let built_value;
                    if (col.type == "date") {
                        let rfc3339 = $date_to_rfc3339(value);
                        if (rfc3339 != "Invalid Date") {
                            built_value = rfc3339;
                        }
                    }

                    if (col.datatype !== undefined) {
                        default_build = false;
                        let coded_datatype =
                            col.datatype.match(/^coded_value:(.*)/);
                        if (col.datatype == "related-object") {
                            let query_term = value;

                            if (criteria != "exact") {
                                query_term = {
                                    like:
                                        (["contains", "ends_with"].indexOf(
                                            criteria
                                        ) !== -1
                                            ? "%"
                                            : "") +
                                        value +
                                        (["contains", "starts_with"].indexOf(
                                            criteria
                                        ) !== -1
                                            ? "%"
                                            : ""),
                                };
                            }

                            part = {
                                [col.related + "." + col.relatedKey]:
                                    col.relatedValue,
                                [col.related + "." + col.relatedSearchOn]:
                                    query_term,
                            };
                        } else if (
                            coded_datatype &&
                            coded_datatype.length > 1
                        ) {
                            if (global_search.length || value.length) {
                                coded_datatype = coded_datatype[1];
                                const search_value = value.length
                                    ? value
                                    : global_search;
                                const regex = new RegExp(
                                    `^${search_value}`,
                                    "i"
                                );
                                if (
                                    coded_values &&
                                    coded_values.hasOwnProperty(coded_datatype)
                                ) {
                                    let codes = [
                                        ...coded_values[
                                            coded_datatype
                                        ].entries(),
                                    ]
                                        .filter(([label]) => regex.test(label))
                                        .map(([, code]) => code);

                                    if (codes.length) {
                                        part[
                                            !attr.includes(".")
                                                ? "me." + attr
                                                : attr
                                        ] = codes;
                                    } else {
                                        // Coded value not found using the description, fallback to code
                                        default_build = true;
                                    }
                                } else {
                                    console.log(
                                        "coded datatype %s not supported yet".format(
                                            coded_datatype
                                        )
                                    );
                                }
                            } else {
                                default_build = true;
                            }
                        } else {
                            console.log(
                                "datatype %s not supported yet".format(
                                    col.datatype
                                )
                            );
                        }
                    }
                    if (default_build) {
                        let value_part;
                        if (criteria === "exact") {
                            value_part = built_value
                                ? [value, built_value]
                                : value;
                        } else {
                            let like = {
                                like:
                                    (["contains", "ends_with"].indexOf(
                                        criteria
                                    ) !== -1
                                        ? "%"
                                        : "") +
                                    value +
                                    (["contains", "starts_with"].indexOf(
                                        criteria
                                    ) !== -1
                                        ? "%"
                                        : ""),
                            };
                            value_part = built_value
                                ? [like, built_value]
                                : like;
                        }

                        part[!attr.includes(".") ? "me." + attr : attr] =
                            value_part;
                    }

                    if (Object.keys(part).length) parts.push(part);
                }
                return parts;
            }

            var filter = data.search.value;
            // Build query for each column filter
            var and_query_parameters = settings.aoColumns
                .filter(function (col) {
                    return (
                        col.bSearchable &&
                        typeof col.data == "string" &&
                        data.columns[col.idx].search.value != ""
                    );
                })
                .map(function (col) {
                    var value = data.columns[col.idx].search.value;
                    return build_query(col, value);
                })
                .map(function r(e) {
                    return $.isArray(e) ? $.map(e, r) : e;
                });

            // Build query for the global search filter
            var or_query_parameters = settings.aoColumns
                .filter(function (col) {
                    return col.bSearchable && filter != "";
                })
                .map(function (col) {
                    var value = filter;
                    return build_query(col, value);
                })
                .map(function r(e) {
                    return $.isArray(e) ? $.map(e, r) : e;
                });

            if (default_filters) {
                let additional_filters = {};
                for (f in default_filters) {
                    let k;
                    let v;
                    if (typeof default_filters[f] === "function") {
                        let val = default_filters[f]();
                        if (val != undefined && val != "") {
                            k = f;
                            v = val;
                        }
                    } else {
                        k = f;
                        v = default_filters[f];
                    }

                    // Pass to -or if you want a separate OR clause
                    // It's not the usual DBIC notation!
                    if (f == "-or") {
                        if (v) or_query_parameters.push(v);
                    } else if (f == "-and") {
                        if (v) and_query_parameters.push(v);
                    } else if (v) {
                        additional_filters[k] = v;
                    }
                }
                if (Object.keys(additional_filters).length) {
                    and_query_parameters.push(additional_filters);
                }
            }
            query_parameters = and_query_parameters;
            if (or_query_parameters.length) {
                query_parameters.push(or_query_parameters);
            }

            if (query_parameters.length) {
                query_parameters = JSON.stringify(
                    query_parameters.length === 1
                        ? query_parameters[0]
                        : { "-and": query_parameters }
                );
                dataSet.q = query_parameters;
            }

            dataSet._match = options.criteria;

            if (data["draw"] !== undefined) {
                settings.ajax.headers = { "x-koha-request-id": data.draw };
            }

            if (options.columns) {
                var order = data.order;
                var orderArray = new Array();
                order.forEach(function (e, i) {
                    var order_col = e.column;
                    var order_by = options.columns[order_col].data;
                    order_by = order_by.split(":");
                    var order_dir = e.dir == "asc" ? "+" : "-";
                    Array.prototype.push.apply(
                        orderArray,
                        order_by.map(
                            x => order_dir + (!x.includes(".") ? "me." + x : x)
                        )
                    );
                });
                dataSet._order_by = orderArray
                    .filter((v, i, a) => a.indexOf(v) === i)
                    .join(",");
            }

            return dataSet;
        },
    };
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

    const export_format_spreadsheet = {
        body: function (data, row, column, node) {
            const newnode = node.cloneNode(true);
            const no_export_nodes = newnode.querySelectorAll(".no-export");
            no_export_nodes.forEach(child => {
                child.parentNode.removeChild(child);
            });
            //Note: innerHTML is the same thing as the data variable,
            //minus the ".no-export" nodes that we've removed
            //Note: See dataTables.buttons.js for original function usage
            let str = DataTable.Buttons.stripData(newnode.innerHTML, {
                decodeEntities: false,
                stripHtml: true,
                stripNewlines: true,
                trim: true,
                escapeExcelFormula: true,
            });
            //Note: escapeExcelFormula only works from Buttons 3.2.0+, so
            //we add a workaround for now
            const unsafeCharacters = /^[=+\-@\t\r]/;
            if (unsafeCharacters.test(str)) {
                str = "'" + str;
            }
            return str;
        },
    };

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
                format: export_format_spreadsheet,
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
    $.fn.kohaTable = function (
        options = {},
        table_settings = undefined,
        add_filters,
        default_filters
    ) {
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

            if (options.ajax && !options.bKohaAjaxSVC) {
                options.ajax = Object.assign(
                    {},
                    options.ajax,
                    _dt_default_ajax({ default_filters, options })
                );
                options.serverSide = true;
                options.processing = true;
                options.pagingType = "full_numbers";
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
            {
                targets: ["dtr-control-col"],
                className: "dtr-control",
                orderable: false,
                createdCell: function (td) {
                    $(td)
                        .attr(
                            "aria-label",
                            __("Expand or collapse row details")
                        )
                        .attr("title", __("Expand or collapse row details"));
                },
            },
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
