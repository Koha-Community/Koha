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
    dom: '<"dt-info"i><"top pager"<"table_entries"lp><"table_controls"fB>>tr<"bottom pager"ip>',
    buttons: [
        {
            fade: 100,
            className: "dt_button_clear_filter",
            titleAttr: __("Clear filter"),
            enabled: false,
            text:
                '<i class="fa fa-lg fa-times"></i> <span class="dt-button-text">' +
                __("Clear filter") +
                "</span>",
            available: function (dt) {
                // The "clear filter" button is made available if this test returns true
                if (dt.settings()[0].aanFeatures.f) {
                    // aanFeatures.f is null if there is no search form
                    return true;
                }
            },
            action: function (e, dt, node) {
                dt.search("").draw("page");
                node.addClass("disabled");
            },
        },
    ],
    lengthMenu: [
        [10, 20, 50, 100, -1],
        [10, 20, 50, 100, __("All")],
    ],
    pageLength: 20,
    fixedHeader: true,
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

// Sorting on html contains
// <a href="foo.pl">bar</a> sort on 'bar'
function dt_overwrite_html_sorting_localeCompare() {
    jQuery.fn.dataTableExt.oSort["html-asc"] = function (a, b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if (typeof (a.localeCompare == "function")) {
            return a.localeCompare(b);
        } else {
            return a > b ? 1 : a < b ? -1 : 0;
        }
    };

    jQuery.fn.dataTableExt.oSort["html-desc"] = function (a, b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if (typeof (b.localeCompare == "function")) {
            return b.localeCompare(a);
        } else {
            return b > a ? 1 : b < a ? -1 : 0;
        }
    };

    jQuery.fn.dataTableExt.oSort["num-html-asc"] = function (a, b) {
        var x = a.replace(/<.*?>/g, "");
        var y = b.replace(/<.*?>/g, "");
        x = parseFloat(x);
        y = parseFloat(y);
        return x < y ? -1 : x > y ? 1 : 0;
    };

    jQuery.fn.dataTableExt.oSort["num-html-desc"] = function (a, b) {
        var x = a.replace(/<.*?>/g, "");
        var y = b.replace(/<.*?>/g, "");
        x = parseFloat(x);
        y = parseFloat(y);
        return x < y ? 1 : x > y ? -1 : 0;
    };
}

$.fn.dataTableExt.oSort["num-html-asc"] = function (a, b) {
    var x = a.replace(/<.*?>/g, "");
    var y = b.replace(/<.*?>/g, "");
    x = parseFloat(x);
    y = parseFloat(y);
    return x < y ? -1 : x > y ? 1 : 0;
};

$.fn.dataTableExt.oSort["num-html-desc"] = function (a, b) {
    var x = a.replace(/<.*?>/g, "");
    var y = b.replace(/<.*?>/g, "");
    x = parseFloat(x);
    y = parseFloat(y);
    return x < y ? 1 : x > y ? -1 : 0;
};

(function () {
    /*
     * Natural Sort algorithm for Javascript - Version 0.7 - Released under MIT license
     * Author: Jim Palmer (based on chunking idea from Dave Koelle)
     * Contributors: Mike Grier (mgrier.com), Clint Priest, Kyle Adams, guillermo
     * See: http://js-naturalsort.googlecode.com/svn/trunk/naturalSort.js
     */
    function naturalSort(a, b) {
        var re = /(^-?[0-9]+(\.?[0-9]*)[df]?e?[0-9]?$|^0x[0-9a-f]+$|[0-9]+)/gi,
            sre = /(^[ ]*|[ ]*$)/g,
            dre =
                /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/,
            hre = /^0x[0-9a-f]+$/i,
            ore = /^0/,
            // convert all to strings and trim()
            x = a.toString().replace(sre, "") || "",
            y = b.toString().replace(sre, "") || "",
            // chunk/tokenize
            xN = x
                .replace(re, "\0$1\0")
                .replace(/\0$/, "")
                .replace(/^\0/, "")
                .split("\0"),
            yN = y
                .replace(re, "\0$1\0")
                .replace(/\0$/, "")
                .replace(/^\0/, "")
                .split("\0"),
            // numeric, hex or date detection
            xD =
                parseInt(x.match(hre), 10) ||
                (xN.length != 1 && x.match(dre) && Date.parse(x)),
            yD =
                parseInt(y.match(hre), 10) ||
                (xD && y.match(dre) && Date.parse(y)) ||
                null;
        // first try and sort Hex codes or Dates
        if (yD)
            if (xD < yD) return -1;
            else if (xD > yD) return 1;
        // natural sorting through split numeric strings and default strings
        for (
            var cLoc = 0, numS = Math.max(xN.length, yN.length);
            cLoc < numS;
            cLoc++
        ) {
            // find floats not starting with '0', string or 0 if not defined (Clint Priest)
            var oFxNcL =
                (!(xN[cLoc] || "").match(ore) && parseFloat(xN[cLoc])) ||
                xN[cLoc] ||
                0;
            var oFyNcL =
                (!(yN[cLoc] || "").match(ore) && parseFloat(yN[cLoc])) ||
                yN[cLoc] ||
                0;
            // handle numeric vs string comparison - number < string - (Kyle Adams)
            if (isNaN(oFxNcL) !== isNaN(oFyNcL)) return isNaN(oFxNcL) ? 1 : -1;
            // rely on string comparison if different types - i.e. '02' < 2 != '02' < '2'
            else if (typeof oFxNcL !== typeof oFyNcL) {
                oFxNcL += "";
                oFyNcL += "";
            }
            if (oFxNcL < oFyNcL) return -1;
            if (oFxNcL > oFyNcL) return 1;
        }
        return 0;
    }

    jQuery.extend(jQuery.fn.dataTableExt.oSort, {
        "natural-asc": function (a, b) {
            return naturalSort(a, b);
        },

        "natural-desc": function (a, b) {
            return naturalSort(a, b) * -1;
        },
    });
})();

(function () {
    /* Plugin to allow text sorting to ignore articles
     *
     * In DataTables config:
     *     "data": [
     *        { "type": "anti-the" },
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
        for (i = 0; i < articles.length; i++) {
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

// Remove string between NSB NSB characters
$.fn.dataTableExt.oSort["nsb-nse-asc"] = function (a, b) {
    var pattern = new RegExp("\x88.*\x89");
    a = a.replace(pattern, "");
    b = b.replace(pattern, "");
    return a > b ? 1 : a < b ? -1 : 0;
};
$.fn.dataTableExt.oSort["nsb-nse-desc"] = function (a, b) {
    var pattern = new RegExp("\x88.*\x89");
    a = a.replace(pattern, "");
    b = b.replace(pattern, "");
    return b > a ? 1 : b < a ? -1 : 0;
};

/* Define two custom functions (asc and desc) for basket callnumber sorting */
jQuery.fn.dataTableExt.oSort["callnumbers-asc"] = function (x, y) {
    var x_array = x.split("<div>");
    var y_array = y.split("<div>");

    /* Pop the first elements, they are empty strings */
    x_array.shift();
    y_array.shift();

    x_array = jQuery.map(x_array, function (a) {
        return parse_callnumber(a);
    });
    y_array = jQuery.map(y_array, function (a) {
        return parse_callnumber(a);
    });

    x_array.sort();
    y_array.sort();

    x = x_array.shift();
    y = y_array.shift();

    if (!x) {
        x = "";
    }
    if (!y) {
        y = "";
    }

    return x < y ? -1 : x > y ? 1 : 0;
};

jQuery.fn.dataTableExt.oSort["callnumbers-desc"] = function (x, y) {
    var x_array = x.split("<div>");
    var y_array = y.split("<div>");

    /* Pop the first elements, they are empty strings */
    x_array.shift();
    y_array.shift();

    x_array = jQuery.map(x_array, function (a) {
        return parse_callnumber(a);
    });
    y_array = jQuery.map(y_array, function (a) {
        return parse_callnumber(a);
    });

    x_array.sort();
    y_array.sort();

    x = x_array.pop();
    y = y_array.pop();

    if (!x) {
        x = "";
    }
    if (!y) {
        y = "";
    }

    return x < y ? 1 : x > y ? -1 : 0;
};

function parse_callnumber(html) {
    var array = html.split('<span class="callnumber">');
    if (array[1]) {
        array = array[1].split("</span>");
        return array[0];
    } else {
        return "";
    }
}

// see http://www.datatables.net/examples/advanced_init/footer_callback.html
function footer_column_sum(api, column_numbers) {
    // Remove the formatting to get integer data for summation
    var intVal = function (i) {
        if (typeof i === "number") {
            if (isNaN(i)) return 0;
            return i;
        } else if (typeof i === "string") {
            var value = i.replace(/[a-zA-Z ,.]/g, "") * 1;
            if (isNaN(value)) return 0;
            return value;
        }
        return 0;
    };

    for (var indice = 0; indice < column_numbers.length; indice++) {
        var column_number = column_numbers[indice];

        var total = 0;
        var cells = api
            .column(column_number, { page: "current" })
            .nodes()
            .to$()
            .find("span.total_amount");
        var budgets_totaled = [];
        $(cells).each(function () {
            budgets_totaled.push($(this).data("self_id"));
        });
        $(cells).each(function () {
            if (
                $(this).data("parent_id") &&
                $.inArray($(this).data("parent_id"), budgets_totaled) > -1
            ) {
                return;
            } else {
                total += intVal($(this).html());
            }
        });
        total /= 100; // Hard-coded decimal precision

        // Update footer
        $(api.column(column_number).footer()).html(total.format_price());
    }
}

function filterDataTable(table, column, term) {
    if (column) {
        table.column(column).search(term).draw("page");
    } else {
        table.search(term).draw("page");
    }
}

jQuery.fn.dataTable.ext.errMode = function (settings, note, message) {
    if (settings && settings.jqXHR) {
        console.log(
            "Got %s (%s)".format(
                settings.jqXHR.status,
                settings.jqXHR.statusText
            )
        );
        alert(
            __(
                "Something went wrong when loading the table.\n%s: %s. \n%s"
            ).format(
                settings.jqXHR.status,
                settings.jqXHR.statusText,
                settings.jqXHR.responseJSON &&
                    settings.jqXHR.responseJSON.errors
                    ? settings.jqXHR.responseJSON.errors
                          .map(m => m.message)
                          .join("\n")
                    : ""
            )
        );
    } else {
        alert(__("Something went wrong when loading the table."));
    }
    console.log(message);
};

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

                let criteria = options.criteria;
                if (value.match(/^\^(.*)\$$/)) {
                    value = value.replace(/^\^/, "").replace(/\$$/, "");
                    criteria = "exact";
                } else {
                    // escape SQL LIKE special characters %
                    value = value.replace(/(\%|\\)/g, "\\$1");
                }

                for (var i = 0; i < attributes.length; i++) {
                    var part = {};
                    var attr = attributes[i];
                    let default_build = true;

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

                                // Escape all regex metachars . * + ? ^ $ { } ( ) | [ ] \
                                const regex = new RegExp(
                                    "^" +
                                        search_value.replace(
                                            /[.*+?^${}()|[\]\\]/g,
                                            "\\$&"
                                        ),
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
                        if (typeof v === "string") {
                            additional_filters[k] = v
                                .replace(/^\^/, "")
                                .replace(/\$$/, "");
                        } else {
                            additional_filters[k] = v;
                        }
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

function build_url_with_state(dt, table_settings) {
    let table_key = "DataTables_%s_%s_%s".format(
        table_settings.module,
        table_settings.page,
        table_settings.table
    );

    let state = JSON.stringify(dt.state());
    delete state.time;
    let searchParams = new URLSearchParams(window.location.search);
    searchParams.set(table_key + "_state", btoa(state));

    return (
        window.location.origin +
        window.location.pathname +
        "?" +
        searchParams.toString() +
        window.location.hash
    );
}

function _dt_buttons(params) {
    let settings = params.settings || {};
    let table_settings = params.table_settings;

    var exportColumns = ":visible:not(.no-export)";

    const export_format_spreadsheet = {
        body: function (data, row, column, node) {
            var newnode = $(node);

            if (newnode.find(".no-export").length > 0) {
                newnode = newnode.clone();
                newnode.find(".no-export").remove();
            }
            let trimmed_str = newnode.text().replace(/\n/g, " ").trim();
            const unsafeCharacters = /^[=+\-@\t\r]/;
            if (unsafeCharacters.test(trimmed_str)) {
                trimmed_str = "'" + trimmed_str;
            }
            return trimmed_str;
        },
    };

    const export_format_print = {
        body: function (data, row, column, node) {
            const newnode = node.cloneNode(true);
            const no_export_nodes = newnode.querySelectorAll(".no-export");
            no_export_nodes.forEach(child => {
                child.parentNode.removeChild(child);
            });
            //Note: innerHTML is the same thing as the data variable,
            //minus the ".no-export" nodes that we've removed
            //Note: See dataTables.buttons.js for original function usage
            const str = DataTable.Buttons.stripData(newnode.innerHTML, {
                decodeEntities: false,
                stripHtml: true,
                stripNewlines: true,
                trim: true,
            });
            return str;
        },
    };

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
                format: export_format_spreadsheet,
            },
        },
        {
            extend: "csvHtml5",
            exportOptions: {
                columns: exportColumns,
                format: export_format_spreadsheet,
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
                format: export_format_print,
            },
        },
    ];

    let buttons = [];
    buttons.push({
        fade: 100,
        className: "dt_button_clear_filter",
        titleAttr: __("Clear filter"),
        enabled: false,
        text:
            '<i class="fa fa-lg fa-remove"></i> <span class="dt-button-text">' +
            __("Clear filter") +
            "</span>",
        action: function (e, dt, node, config) {
            dt.search("").draw("page");
            node.addClass("disabled");
        },
    });

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
                '<i class="fa fa-lg fa-gear"></i> <span class="dt-button-text">' +
                __("Columns") +
                "</span>",
            exportOptions: {
                columns: exportColumns,
            },
        });
    }

    buttons.push({
        extend: "collection",
        autoClose: true,
        fade: 100,
        className: "export_controls",
        titleAttr: __("Export or print"),
        text:
            '<i class="fa fa-lg fa-download"></i> <span class="dt-button-text">' +
            __("Export") +
            "</span>",
        buttons: export_buttons,
    });

    if (table_settings) {
        const writeToClipboard = async (text, node) => {
            await navigator.clipboard.writeText(text);
            $(node)
                .tooltip({ trigger: "manual", title: __("Copied!") })
                .tooltip("show");
        };
        buttons.push({
            autoClose: true,
            fade: 100,
            className: "copyConditions_controls",
            titleAttr: __("Copy shareable link"),
            text:
                '<i class="fa fa-lg fa-copy"></i> <span class="dt-button-text">' +
                __("Copy shareable link") +
                "</span>",
            action: function (e, dt, node, config) {
                const url = build_url_with_state(dt, table_settings);

                if (navigator.clipboard && navigator.clipboard.writeText) {
                    writeToClipboard(url, node);
                }
            },
        });
    }

    if (table_settings && CAN_user_parameters_manage_column_config) {
        let href =
            "/cgi-bin/koha/admin/columns_settings.pl?module=%s&page=%s&table=%s".format(
                table_settings.module,
                table_settings.page,
                table_settings.table
            );
        buttons.push({
            tag: "a",
            attr: { href },
            className: "dt_button_configure_table",
            fade: 100,
            titleAttr: __("Configure table"),
            text:
                '<i class="fa fa-lg fa-wrench"></i> <span class="dt-button-text">' +
                __("Configure") +
                "</span>",
            action: function () {
                window.location = href;
            },
        });
    }

    return buttons;
}

function _dt_force_visibility(table_settings, table_dt, state) {
    var columns_settings = table_settings.columns;
    let i = 0;
    let force_vis_columns = table_settings.columns.filter(
        c => c.force_visibility
    );
    if (!force_vis_columns.length) return state;

    let use_names = $(table_dt.table().node()).data("bKohaColumnsUseNames");
    if (use_names) {
        table_dt
            .columns(
                force_vis_columns
                    .map(c => "[data-colname='%s']".format(c.columnname))
                    .join(",")
            )
            .every(function () {
                state.columns[this.index()].visible =
                    table_settings.columns.find(
                        c =>
                            c.columnname ==
                            this.header().getAttribute("data-colname")
                    ).is_hidden
                        ? false
                        : true;
            });
    } else {
        throw new Error(
            "Cannot force column visibility without bKohaColumnsUseNames!"
        );
    }
    return state;
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

function _dt_on_visibility(add_filters, table_node, table_dt) {
    // FIXME REPLACE ME
    if (typeof columnsInit == "function") {
        // This function can be created separately and used to trigger
        // an event after the DataTable has loaded AND column visibility
        // has been updated according to the table's configuration
        columnsInit();
    }
}

function _dt_add_filters(table_node, table_dt, filters_options = {}) {
    if (!$(table_node).length) return;

    $(table_node).find("thead tr:eq(1)").remove(); // Remove if one exists already
    $(table_node)
        .find("thead tr")
        .clone()
        .appendTo($(table_node).find("thead"));

    let visibility = table_dt.columns().visible();
    let columns = table_dt.settings()[0].aoColumns;
    table_dt.columns().every(function () {
        var column = this;
        let i = column.index();
        var visible_i = table_dt.column.index("fromData", i);
        let th = $(table_node).find(
            "thead tr:eq(1) th:eq(%s)".format(visible_i)
        );
        let col = table_dt.settings()[0].aoColumns[i];
        var is_searchable = col.bSearchable;
        $(this)
            .removeClass("sorting")
            .removeClass("sorting_asc")
            .removeClass("sorting_desc");
        $(this).data("th-id", i);
        if (is_searchable || col.dataFilter) {
            let input_type = "input";
            let existing_search = column.search();
            if (col.dataFilter) {
                input_type = "select";
                let filter_type = $(th).data("filter");
                let select = $(
                    '<select class="dt-select-filter"><option value=""></option></select'
                );

                if (typeof filters_options[col.dataFilter] === "function") {
                    filters_options[col.dataFilter] =
                        filters_options[col.dataFilter](table_dt);
                }
                $(filters_options[col.dataFilter])
                    .filter(function () {
                        return this._id !== "" && this._str !== "";
                    })
                    .each(function () {
                        let optionValue = this._id;

                        if (
                            table_dt.settings()[0].ajax !== null &&
                            $(table_node)?.attr("id") !== "item_search"
                        ) {
                            optionValue = `^${this._id}$`;
                        }

                        let o = $(
                            `<option value="${optionValue}">${this._str}</option>`
                        );

                        // Compare with lc, or selfreg won't match ^SELFREG$ for instance, see bug 32517
                        // This is only for category, we might want to apply it only in this case.
                        existing_search = existing_search.toLowerCase();
                        if (
                            existing_search === this._id ||
                            (existing_search &&
                                this._id.toLowerCase().match(existing_search))
                        ) {
                            o.prop("selected", "selected");
                        }
                        o.appendTo(select);
                    });
                $(th).html(select);
            } else {
                var title = $(th).text();
                if (existing_search) {
                    $(th).html(
                        '<input type="text" value="%s" style="width: 100%" />'.format(
                            existing_search
                        )
                    );
                } else {
                    var search_title = __("%s search").format(title);
                    $(th).html(
                        '<input type="text" placeholder="%s" style="width: 100%" />'.format(
                            search_title
                        )
                    );
                }
            }
        } else {
            $(th).html("");
        }
    });
    _dt_add_delay_filters(table_dt, table_node);
    table_dt.fixedHeader.adjust();
}

function _dt_add_delay(table_dt, table_node) {
    let delay_ms = 500;

    let search = DataTable.util.debounce(function (val) {
        table_dt.search(val);
        table_dt.draw();
    }, delay_ms);

    $("#" + table_node.attr("id") + "_wrapper")
        .find(".dt-input")
        .unbind()
        .bind("keyup", search(this.value));
}

function _dt_add_delay_filters(table_dt, table_node) {
    let delay_ms = 500;

    let col_input_search = DataTable.util.debounce(function (i, val) {
        table_dt.column(i).search(val).draw();
    }, delay_ms);
    let col_select_search = DataTable.util.debounce(function (
        i,
        val,
        regex_search = true
    ) {
        table_dt.column(i).search(val, regex_search, false).draw();
    }, delay_ms);

    $(table_node)
        .find("thead tr:eq(1) th")
        .each(function (visible_i) {
            var i = table_dt.column.index("fromVisible", visible_i);
            $(this)
                .find("input")
                .unbind()
                .bind("keyup change", function (e) {
                    if (e.keyCode === undefined) return;
                    col_input_search(i, this.value);
                });

            $(this)
                .find("select")
                .unbind()
                .bind("keyup change", function () {
                    col_select_search(i, this.value, false);
                });
        });
}

function _dt_save_restore_state(table_settings, external_filter_nodes = {}) {
    let table_key = "DataTables_%s_%s_%s".format(
        table_settings.module,
        table_settings.page,
        table_settings.table
    );

    let default_save_state = table_settings.default_save_state;
    let default_save_state_search = table_settings.default_save_state_search;

    let stateSaveCallback = function (settings, data) {
        localStorage.setItem(table_key, JSON.stringify(data));
    };

    function set_default(table_settings, table_dt) {
        let columns = new Array(table_dt.columns()[0].length).fill({
            visible: true,
        });
        let hidden_ids = _dt_visibility(table_settings, table_dt);
        hidden_ids.forEach((id, i) => {
            columns[id] = { visible: false };
        });
        // State is not loaded if time is not passed
        return { columns, time: new Date() };
    }
    let stateLoadCallback = function (settings) {
        // Load state from URL
        const url = new URL(window.location.href);
        let state_from_url = url.searchParams.get(table_key + "_state");
        if (state_from_url) {
            $("#" + settings.nTable.id).data("loaded_from_state", true);
            return JSON.parse(atob(state_from_url));
        }

        if (!default_save_state) return set_default(table_settings, this.api());

        let state = localStorage.getItem(table_key);
        if (!state) return set_default(table_settings, this.api());

        state = JSON.parse(state);

        if (default_save_state_search) {
            $("#" + settings.nTable.id).data("loaded_from_state", true);
        } else {
            delete state.search;
            state.columns.forEach(c => delete c.search);
        }

        state = _dt_force_visibility(table_settings, this.api(), state);

        return state;
    };

    let stateSaveParams = function (settings, data) {
        // FIXME Selector in on the whole DOM, we don't know where the filters are
        // If others exist on the same page this will lead to unexpected behaviours
        // Should be safe so far as: patron search use the same code for the different searches
        // but only the main one has the table settings (and so the state saved)
        data.external_filters = Object.keys(external_filter_nodes).reduce(
            (r, k) => {
                let node = $(external_filter_nodes[k]);
                let tag_name = node.prop("tagName");
                if (tag_name == "INPUT" && node.prop("type") == "checkbox") {
                    r[k] = $(external_filter_nodes[k]).prop("checked");
                } else if (tag_name == "INPUT" || tag_name == "SELECT") {
                    r[k] = $(external_filter_nodes[k]).val();
                } else {
                    console.log(
                        "Tag '%s' not supported yet for DT state".format(
                            tag_name
                        )
                    );
                }
                return r;
            },
            {}
        );
    };
    let stateLoadParams = function (settings, data) {
        if (!$("#" + settings.nTable.id).data("loaded_from_state")) return;

        if (data.external_filters) {
            Object.keys(external_filter_nodes).forEach((k, i) => {
                if (data.external_filters.hasOwnProperty(k)) {
                    let node = $(external_filter_nodes[k]);
                    let tag_name = node.prop("tagName");
                    let value = data.external_filters[k];
                    if (
                        tag_name == "INPUT" &&
                        node.prop("type") == "checkbox"
                    ) {
                        node.prop("checked", value);
                    } else if (
                        tag_name == "INPUT" &&
                        node.hasClass("flatpickr")
                    ) {
                        const fp = document.querySelector(
                            external_filter_nodes[k]
                        )._flatpickr;
                        fp.setDate(value);
                    } else if (tag_name == "INPUT" || tag_name == "SELECT") {
                        node.val(value);
                    } else {
                        console.log(
                            "Tag '%s' not supported yet for DT state".format(
                                tag_name
                            )
                        );
                    }
                }
            });
        }
    };

    return {
        stateSave: true,
        stateDuration: 0,
        stateSaveCallback,
        stateLoadCallback,
        stateSaveParams,
        stateLoadParams,
    };
}

function update_search_description(
    table_node,
    table_dt,
    additional_search_descriptions
) {
    let description_node = additional_search_descriptions.node;
    let description_fns =
        additional_search_descriptions.additional_search_descriptions;
    let description = [];
    let global_search = table_dt.search();
    if (global_search.length) {
        description.push(__("Anywhere: %s").format(global_search));
    }
    let additional_searches = [];
    for (f in description_fns) {
        let d = description_fns[f]();
        if (d.length) {
            additional_searches.push(d);
        }
    }
    if (additional_searches.length) {
        description.push(additional_searches.join(", "));
    }
    let column_searches = [];
    table_dt
        .columns()
        .search()
        .each((search, i) => {
            if (search.length) {
                // Retrieve the value from the dropdown list if there is one
                var visible_i = table_dt.column.index("fromData", i);
                let option = $(table_node).find(
                    "thead tr:eq(1) th:eq(%s) select option:selected".format(
                        visible_i
                    )
                );
                if (option.length) {
                    search = $(option).text();
                }

                column_searches.push(
                    "%s=%s".format(
                        table_dt.column(i).header().innerHTML,
                        search
                    )
                );
            }
        });
    if (column_searches.length) {
        description.push(column_searches.join(", "));
    }

    if (description.length) {
        let display = description.length ? "block" : "none";
        let description_str = $(description_node)
            .data("prefix")
            .format(description.join("<br/>"));
        $(description_node).html(description_str).show();
    } else {
        $(description_node).html("").hide();
    }
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
     * @param  {string}  [options.columns.*.datatype  Data type the field is stored in so we may impose some additional
     *                                                manipulation logic to search. Supported types are currently 'related-object',
     *                                                for implementing joins in api search queries, and 'coded_value:TABLE' to allow
     *                                                for clientside translations of description to code to reduce join requirements.
     *                                                See bug 39011 for an example implementation.
     * @param  {Object}  table_settings               The arrayref as returned by TableSettings.GetTableSettings function
     *                                                available from the columns_settings template toolkit include
     * @param  {Boolean} add_filters                  Add a filters row as the top row of the table
     * @param  {Object}  default_filters              Add a set of default search filters to apply at table initialisation
     * @param  {Object}  filters_options              Build selects for the filters row, and pass their value.
     *                                                eg. { 1 => vendors } will build a select with the vendor list in the second column
     * @param  {Object}  show_search_descriptions     Whether or not display the search descriptions when the table is drawn
     *                                                Expect a node in which to place the descriptions. It must have a data-prefix attribute to build the description properly.
     * @param  {Object}  aditional_search_descriptions Pass additional descriptions
     *                                                 eg. { surname => () => { 'Surname with '.format($("#surname_form").val()) } }
     * @return {Object}                               The dataTables instance
     */
    $.fn.kohaTable = function (
        options = {},
        table_settings,
        add_filters,
        default_filters,
        filters_options,
        external_filter_nodes,
        show_search_descriptions,
        additional_search_descriptions
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
                    _dt_default_ajax({ default_filters, options }),
                    options.ajax
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
                paging: true,
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

        if (add_filters) {
            settings["orderCellsTop"] = true;
        }

        if (table_settings) {
            let state_settings = _dt_save_restore_state(
                table_settings,
                external_filter_nodes
            );
            settings = { ...settings, ...state_settings };

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
        $(this).data("bKohaAjaxSVC", settings.bKohaAjaxSVC); // Must not be used for new tables!
        var table = $(this).dataTable(settings);

        var table_dt = table.DataTable();
        if (add_filters) {
            _dt_add_filters(this, table_dt, filters_options);
        }

        table_dt.on("column-visibility.dt", function () {
            if (add_filters) {
                _dt_add_filters(this, table_dt, filters_options);
            }
        });

        table_dt.on("search.dt", function (e, settings) {
            // When the DataTables search function is triggered,
            // enable or disable the "Clear filter" button based on
            // the presence of a search string
            toggledClearFilter(table_dt.search(), settings.nTable.id);
        });

        if (show_search_descriptions !== undefined) {
            table_dt.on("draw", function (e, settings) {
                update_search_description(table, table_dt, {
                    node: show_search_descriptions,
                    additional_search_descriptions,
                });
            });
            update_search_description(table, table_dt, {
                node: show_search_descriptions,
                additional_search_descriptions,
            });
        }

        return table;
    };
})(jQuery);
