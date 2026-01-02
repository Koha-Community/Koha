$(document).ready(function () {
    var getLinks = function (row) {
        if (!row.links || row.links.length === 0) {
            return false;
        }
        return row.links.map(function (link) {
            return (
                '<a href="' +
                link.url +
                '" target="_blank">' +
                link.text +
                "</a>"
            );
        });
    };

    window.doSearch = function () {
        // In case the source doesn't supply data required for DT to calculate
        // pagination, we need to do it ourselves
        var ownPagination = false;
        var directionSet = false;
        var start = 0;
        var forward = true; // true == forward, false == backwards
        // Arbitrary starting value, it will be corrected by the first
        // page of results
        var pageSize = 20;

        var tableTmpl = {
            ajax: {
                cache: true, // Prevent DT appending a "_" cache param
            },
            columns: [
                // defaultContent prevents DT from choking if
                // the API response doesn't return a column
                {
                    title: "Source",
                    data: "source",
                    defaultContent: "",
                },
                {
                    data: "title",
                    defaultContent: "",
                },
                {
                    data: "author",
                    defaultContent: "",
                },
                {
                    data: "isbn",
                    defaultContent: "",
                },
                {
                    data: "issn",
                    defaultContent: "",
                },
                {
                    data: "date",
                    defaultContent: "",
                },
            ],
        };

        // render functions don't get copied across when we make a dereferenced
        // copy of them, so we have to reattach them once we have a copy
        // Here we store them
        var renders = {
            title: function (data, type, row) {
                var links = getLinks(row);
                if (links) {
                    return row.title + " - " + links.join(", ");
                } else if (row.url) {
                    return (
                        '<a href="' +
                        row.url +
                        '" target="_blank">' +
                        row.title +
                        "</a>"
                    );
                } else {
                    return row.title;
                }
            },
            source: function (data, type, row) {
                return row.opac_url
                    ? '<a href="' +
                          row.opac_url +
                          '" target="_blank">' +
                          row.source +
                          "</a>"
                    : row.source;
            },
        };

        services.forEach(function (service) {
            // Create a deferenced copy of our table definition object
            var tableDef = JSON.parse(JSON.stringify(tableTmpl));
            // Iterate the table's columns array and add render functions
            // as necessary
            tableDef.columns.forEach(function (column) {
                if (renders[column.data]) {
                    column.render = renders[column.data];
                }
            });
            tableDef.ajax.dataSrc = function (json) {
                let data = json.data;
                var results = data.results.search_results;
                // The source appears to be returning it's own pagination
                // data
                if (
                    data.hasOwnProperty("recordsFiltered") ||
                    data.hasOwnProperty("recordsTotal")
                ) {
                    return results;
                }
                // Set up our own pagination values based on what we just
                // got back
                ownPagination = true;
                directionSet = false;
                pageSize = results.length;
                // These values are completely arbitrary, but they enable
                // us to display pagination links
                (data.recordsFiltered = 5000), (data.recordsTotal = 5000);

                return results;
            };
            tableDef.ajax.data = function (data) {
                // Datatables sends a bunch of superfluous params
                // that we don't want to litter our API schema
                // with, so just remove them from the request
                if (data.hasOwnProperty("columns")) {
                    delete data.columns;
                }
                if (data.hasOwnProperty("draw")) {
                    delete data.draw;
                }
                if (data.hasOwnProperty("order")) {
                    delete data.order;
                }
                if (data.hasOwnProperty("search")) {
                    delete data.search;
                }
                // If we're handling our own pagination, set the properties
                // that DT will send in the request
                if (ownPagination) {
                    start = forward ? start + pageSize : start - pageSize;
                    data.start = start;
                    data["length"] = pageSize;
                }
                // We may need to restrict the service IDs being queries, this
                // needs to be handled in the plugin's API module
                var restrict = $("#service_id_restrict").attr(
                    "data-service_id_restrict_ids"
                );
                if (restrict && restrict.length > 0) {
                    data.restrict = restrict;
                }
            };
            // Add any datatables config options passed from the service
            // to the table definition
            tableDef.ajax.url = service.endpoint + metadata;
            if (service.hasOwnProperty("datatablesConfig")) {
                var conf = service.datatablesConfig;
                for (var key in conf) {
                    // The config from the service definition comes from a Perl
                    // hashref, therefore can't contain true/false, so we
                    // special case it
                    if (conf.hasOwnProperty(key)) {
                        if (conf[key] == "false") {
                            // Special case false values
                            tableDef[key] = false;
                        } else if (conf[key] == "true") {
                            // Special case true values
                            tableDef[key] = true;
                        } else {
                            // Copy the property value
                            tableDef[key] = conf[key];
                        }
                    }
                }
            }
            // Create event watchers for the "next" and "previous" pagination
            // links, this enables us to set the direction the next request is
            // going in when we're doing our own pagination. We use "hover"
            // because the click event is caught after the request has been
            // sent
            tableDef.drawCallback = function () {
                $(
                    ".dt-paging-button.next:not(.disabled)",
                    this.api().table().container()
                ).on("hover", function () {
                    forward = true;
                    directionSet = true;
                });
                $(
                    ".dt-paging-button.previous:not(.disabled)",
                    this.api().table().container()
                ).on("hover", function () {
                    forward = false;
                    directionSet = true;
                });
            };
            // Initialise the table
            // Since we're not able to use the columns settings in core,
            // we need to mock the object that it would return
            var table_settings = {
                columns: [
                    {
                        cannot_be_modified: 0,
                        cannot_be_toggled: 0,
                        columnname: "source",
                        is_hidden: 0,
                    },
                    {
                        cannot_be_modified: 0,
                        cannot_be_toggled: 0,
                        columnname: "title",
                        is_hidden: 0,
                    },
                    {
                        cannot_be_modified: 0,
                        cannot_be_toggled: 0,
                        columnname: "author",
                        is_hidden: 0,
                    },
                    {
                        cannot_be_modified: 0,
                        cannot_be_toggled: 0,
                        columnname: "isbn",
                        is_hidden: 0,
                    },
                    {
                        cannot_be_modified: 0,
                        cannot_be_toggled: 0,
                        columnname: "issn",
                        is_hidden: 0,
                    },
                    {
                        cannot_be_modified: 0,
                        cannot_be_toggled: 0,
                        columnname: "date",
                        is_hidden: 0,
                    },
                ],
            };
            // Hide pagination buttons if appropriate
            tableDef.drawCallback = function () {
                var pagination = $(this)
                    .closest(".dt-container")
                    .find(".dt-paging");
                pagination.toggle(this.api().page.info().pages > 1);
            };
            $("#" + service.id).kohaTable(tableDef, table_settings);
        });
    };
});
