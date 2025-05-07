$(document).ready(function () {
    // Display the modal containing request supplier metadata
    $("#ill-request-display-log").on("click", function (e) {
        e.preventDefault();
        $("#requestLog").modal("show");
    });

    // Toggle request attributes in Illview
    $("#toggle_requestattributes").on("click", function (e) {
        e.preventDefault();
        $("#requestattributes").toggleClass("content_hidden");
    });

    // Toggle new comment form in Illview
    $("#toggle_addcomment").on("click", function (e) {
        e.preventDefault();
        $("#addcomment").toggleClass("content_hidden");
    });

    // Handle filter by status for defined ILLRequestsTabs
    $("div#ill-list-tabs a[id^='ill-list-tab'").on("click", function (e) {
        e.preventDefault();
        var select_status_el = $("form#illfilter_form select#illfilter_status");
        var tab_statuses = $(this).children("span").attr("data-statuses");

        // Check if multipleSelect is already initialized
        var msInitialized = isMultipleSelectInitialized(select_status_el);

        // First, reset all options to enabled state
        $("#illfilter_status option").each(function () {
            $(this).prop("disabled", false);
        });

        // Deselect all options first
        if (msInitialized) {
            select_status_el.multipleSelect("uncheckAll");
        } else {
            select_status_el.val([]);
        }

        if (tab_statuses) {
            // Get array of status codes from the tab
            var statusCodes = tab_statuses.split("|");

            // Make non-tab statuses read-only by disabling them
            $("#illfilter_status option").each(function () {
                if (!statusCodes.includes($(this).val())) {
                    $(this).prop("disabled", true);
                }
            });

            // Select all statuses assigned to the tab
            if (msInitialized) {
                select_status_el.multipleSelect("setSelects", statusCodes);
                select_status_el.multipleSelect("refresh");
            } else {
                select_status_el.val(statusCodes);
            }
        }

        // If multipleSelect is already initialized, refresh the control
        if (msInitialized) {
            select_status_el.multipleSelect("refresh");
        }

        // Trigger DataTables redraw with filtering
        filter();
    });

    // Helper function to check if the multipleSelect plugin is already initialized
    function isMultipleSelectInitialized(element) {
        return (
            $(element).hasClass("ms-parent") ||
            $(element).next().hasClass("ms-parent")
        );
    }

    // Filter partner list
    // Record the list of all options
    var ill_partner_options = $("#partners > option");
    $("#partner_filter").keyup(function () {
        var needle = $("#partner_filter").val();
        var regex = new RegExp(needle, "i");
        var filtered = [];
        ill_partner_options.each(function () {
            if (
                needle.length == 0 ||
                $(this).is(":selected") ||
                $(this).text().match(regex)
            ) {
                filtered.push($(this));
            }
        });
        $("#partners").empty().append(filtered);
    });

    // Display the modal containing request supplier metadata
    $("#ill-request-display-metadata").on("click", function (e) {
        e.preventDefault();
        $("#dataPreview").modal("show");
    });

    function display_extended_attribute(row, type) {
        var arr = $.grep(row.extended_attributes, x => x.type === type);
        if (arr.length > 0) {
            return escape_str(arr[0].value);
        }

        return "";
    }

    function display_request_status(row) {
        let status = row._strings.status.str;
        let status_alias = row._strings.status_av
            ? row._strings.status_av.str
                ? row._strings.status_av.str
                : row._strings.status_av.code
            : null;

        let status_label =
            status +
            (status_alias
                ? " <i><strong>" + status_alias + "</strong></i>"
                : "");

        return status_label;
    }

    // Possible prefilters: borrowernumber, batch_id
    // see ill/ill-requests.pl and members/ill-requests.pl
    let additional_prefilters = {};
    if (prefilters) {
        let prefilters_array = prefilters.split("&");
        prefilters_array.forEach(prefilter => {
            let prefilter_split = prefilter.split("=");
            additional_prefilters[prefilter_split[0]] = prefilter_split[1];
        });
    }

    let borrower_prefilter = additional_prefilters["borrowernumber"] || null;
    let batch_id_prefilter = additional_prefilters["batch_id"] || null;

    let additional_filters = {
        "me.backend": function () {
            let backend = $("#illfilter_backend").val();
            if (!backend) return "";
            return { "=": backend };
        },
        "me.branchcode": function () {
            let branchcode = $("#illfilter_branchname").val();
            if (!branchcode) return "";
            return { "=": branchcode };
        },
        "me.borrowernumber": function () {
            return borrower_prefilter ? { "=": borrower_prefilter } : "";
        },
        "me.batch_id": function () {
            return batch_id_prefilter ? { "=": batch_id_prefilter } : "";
        },
        "-or": function () {
            let patron = $("#illfilter_patron").val();
            let status = $("#illfilter_status").val();
            let status_alias = $("#illfilter_status_alias").val();
            let filters = [];
            let status_sub_or = [];
            let subquery_and = [];

            if (!patron && !status && !status_alias) return "";

            if (patron) {
                let patronquery = buildPatronSearchQuery(patron, {
                    table_prefix: "patron",
                });
                subquery_and.push(patronquery);
            }

            if (status && status.length > 0) {
                subquery_and.push({ "me.status": { "=": status } });
            }
            if (status_alias) {
                if (status_alias === "null") {
                    subquery_and.push({ "me.status_alias": { "=": null } });
                } else {
                    subquery_and.push({
                        "me.status_alias": { "=": status_alias },
                    });
                }
            }

            filters.push({ "-and": subquery_and });

            return filters;
        },
        "me.placed": function () {
            if (Object.keys(additional_prefilters).length && borrower_prefilter)
                return "";
            let placed_start = $("#illfilter_dateplaced_start").get(0)
                ._flatpickr.selectedDates[0];
            let placed_end = $("#illfilter_dateplaced_end").get(0)._flatpickr
                .selectedDates[0];
            if (!placed_start && !placed_end) return "";
            return {
                ...(placed_start && { ">=": placed_start }),
                ...(placed_end && { "<=": placed_end }),
            };
        },
        "me.updated": function () {
            if (Object.keys(additional_prefilters).length && borrower_prefilter)
                return "";
            let updated_start = $("#illfilter_datemodified_start").get(0)
                ._flatpickr.selectedDates[0];
            let updated_end = $("#illfilter_datemodified_end").get(0)._flatpickr
                .selectedDates[0];
            if (!updated_start && !updated_end) return "";
            // set selected datetime hours and minutes to the end of the day
            // to grab any request updated during that day
            let updated_end_value = new Date(updated_end);
            updated_end_value.setHours(updated_end_value.getHours() + 23);
            updated_end_value.setMinutes(updated_end_value.getMinutes() + 59);
            return {
                ...(updated_start && { ">=": updated_start }),
                ...(updated_end && { "<=": updated_end_value }),
            };
        },
        "-and": function () {
            let keyword = $("#illfilter_keyword").val();
            if (!keyword) return "";

            let filters = [];
            let subquery_and = [];

            const search_fields =
                "me.illrequest_id,me.biblio_id,me.due_date,me.branchcode,library.name,me.status,me.status_alias,me.placed,me.replied,me.updated,me.completed,me.medium,me.accessurl,me.cost,me.price_paid,me.notesopac,me.notesstaff,me.orderid,me.backend";
            let sub_or = [];
            search_fields.split(",").forEach(function (attr) {
                sub_or.push({
                    [attr]: { like: "%" + keyword + "%" },
                });
            });
            subquery_and.push(sub_or);
            filters.push({ "-and": subquery_and });

            let patronquery = buildPatronSearchQuery(keyword, {
                table_prefix: "patron",
            });
            filters.push(patronquery);

            const extended_attributes =
                "title,type,author,article_title,pages,issue,volume,year";
            let extended_sub_or = [];
            subquery_and = [];
            extended_sub_or.push({
                "extended_attributes.type": extended_attributes.split(","),
                "extended_attributes.value": { like: "%" + keyword + "%" },
            });
            subquery_and.push(extended_sub_or);

            filters.push({ "-and": subquery_and });
            return filters;
        },
    };

    let external_filter_nodes = {
        illfilter_keyword: "#illfilter_keyword",
        illfilter_backend: "#illfilter_backend",
        illfilter_status: "#illfilter_status",
        illfilter_dateplaced_start: "#illfilter_dateplaced_start",
        illfilter_dateplaced_end: "#illfilter_dateplaced_end",
        illfilter_datemodified_start: "#illfilter_datemodified_start",
        illfilter_datemodified_end: "#illfilter_datemodified_end",
        illfilter_branchname: "#illfilter_branchname",
        illfilter_patron: "#illfilter_patron",
    };

    let table_id = "#ill-requests";

    if (borrower_prefilter) {
        table_id += "-patron-" + borrower_prefilter;
    } else if (batch_id_prefilter) {
        table_id += "-batch-" + batch_id_prefilter;
    }

    var ill_requests_table = $(table_id).kohaTable(
        {
            ajax: {
                url: "/api/v1/ill/requests",
            },
            embed: [
                "+strings",
                "biblio",
                "comments+count",
                "extended_attributes",
                "ill_batch",
                "library",
                "id_prefix",
                "patron",
            ],
            order: [[0, "desc"]],
            stateSave: true, // remember state on page reload
            columns: [
                {
                    data: "ill_request_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/ill/ill-requests.pl?' +
                            "op=illview&amp;illrequest_id=" +
                            encodeURIComponent(data) +
                            '">' +
                            escape_str(row.id_prefix) +
                            escape_str(data) +
                            "</a>"
                        );
                    },
                },
                {
                    data: "ill_batch.name", // batch
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return row.ill_batch
                            ? '<a href="/cgi-bin/koha/ill/ill-requests.pl?batch_id=' +
                                  row.ill_batch.ill_batch_id +
                                  '">' +
                                  row.ill_batch.name +
                                  "</a>"
                            : "";
                    },
                },
                {
                    data: "", // author
                    orderable: false,
                    render: function (data, type, row, meta) {
                        const author = display_extended_attribute(
                            row,
                            "author"
                        );
                        if (author) return author;
                        const articleAuthor = display_extended_attribute(
                            row,
                            "article_author"
                        );
                        if (articleAuthor) return articleAuthor;
                        return "";
                    },
                },
                {
                    data: "", // title
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return display_extended_attribute(row, "title");
                    },
                },
                {
                    data: "", // article_title
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return display_extended_attribute(row, "article_title");
                    },
                },
                {
                    data: "", // issue
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return display_extended_attribute(row, "issue");
                    },
                },
                {
                    data: "", // volume
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return display_extended_attribute(row, "volume");
                    },
                },
                {
                    data: "", // year
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return display_extended_attribute(row, "year");
                    },
                },
                {
                    data: "", // pages
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return display_extended_attribute(row, "pages");
                    },
                },
                {
                    data: "", // type
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return display_extended_attribute(row, "type");
                    },
                },
                {
                    data: "ill_backend_request_id",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(data);
                    },
                },
                {
                    data: "patron.firstname:patron.surname:patron.cardnumber",
                    render: function (data, type, row, meta) {
                        return row.patron
                            ? $patron_to_html(row.patron, {
                                  display_cardnumber: true,
                                  url: true,
                              })
                            : "";
                    },
                },
                {
                    data: "biblio_id",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        if (data === null) {
                            return "";
                        }
                        return $biblio_to_html(row.biblio, {
                            biblio_id_only: 1,
                            link: 1,
                        });
                    },
                },
                {
                    data: "library.name",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(data);
                    },
                },
                {
                    data: "status",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return display_request_status(row);
                    },
                },
                {
                    data: "requested_date",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(data);
                    },
                },
                {
                    data: "timestamp",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(data);
                    },
                },
                {
                    data: "replied_date",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(data);
                    },
                },
                {
                    data: "completed_date",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(data);
                    },
                },
                {
                    data: "access_url",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a target="_blank" href="' +
                            data +
                            '">' +
                            escape_str(data) +
                            "</a>"
                        );
                    },
                },
                {
                    data: "cost",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(data);
                    },
                },
                {
                    data: "paid_price",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(data);
                    },
                },
                {
                    data: "comments_count",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        return escape_str(data);
                    },
                },
                {
                    data: "opac_notes",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(data);
                    },
                },
                {
                    data: "staff_notes",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        if (data?.length > 100) {
                            data = data.substr(0, 100) + "...";
                        }

                        return data;
                    },
                },
                {
                    data: "ill_backend_id",
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(data);
                    },
                },
                {
                    data: "ill_request_id",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        return render_table_actions(data);
                    },
                },
            ],
        },
        table_settings,
        null,
        additional_filters,
        undefined,
        external_filter_nodes
    );

    $("#illfilter_form").on("submit", filter);

    function render_table_actions(data) {
        let actions_string = "";
        ill_table_actions.forEach(ill_table_action => {
            let link_data = ill_table_action.append_column_data_to_link
                ? encodeURIComponent(data)
                : "";
            let link_text = ill_table_action.button_link_translatable_text
                ? eval(ill_table_action.button_link_translatable_text)
                : ill_table_action.button_link_text;
            actions_string += `<a class="${ill_table_action.button_class}" href="${ill_table_action.button_link}${link_data}">${link_text}</a>`;
        });
        return actions_string;
    }

    function redrawTable() {
        let table_dt = ill_requests_table.DataTable();
        table_dt.draw();
    }

    function filter() {
        redrawTable();
        return false;
    }

    function clearSearch() {
        let filters = [
            "illfilter_backend",
            "illfilter_branchname",
            "illfilter_patron",
            "illfilter_keyword",
        ];
        filters.forEach(filter => {
            $("#" + filter).val("");
        });

        // For status filter, check if we have an active tab with defined statuses
        var activeTabWithStatuses = $(
            "div#ill-list-tabs a.active span[data-statuses]"
        ).attr("data-statuses");

        if (activeTabWithStatuses) {
            // If an active tab with statuses exists, select all its non-disabled options
            var statusCodes = activeTabWithStatuses.split("|");

            // Check if multipleSelect is initialized
            if (isMultipleSelectInitialized($("#illfilter_status"))) {
                // First uncheck all
                $("#illfilter_status").multipleSelect("uncheckAll");
                // Then select all enabled (non-disabled) options
                $("#illfilter_status").multipleSelect(
                    "setSelects",
                    statusCodes
                );
                $("#illfilter_status").multipleSelect("refresh");
            } else {
                // If multipleSelect is not initialized, use standard select methods
                $("#illfilter_status").val(statusCodes);
            }
        } else {
            // If no active tab with statuses, clear the status filter completely
            if (isMultipleSelectInitialized($("#illfilter_status"))) {
                $("#illfilter_status").multipleSelect("uncheckAll");
                $("#illfilter_status").multipleSelect("refresh");
            } else {
                $("#illfilter_status").prop("selectedIndex", 0);
            }
        }

        // Reset status alias filter
        $("#illfilter_status_alias").prop("selectedIndex", 0);

        //Clear flatpickr date filters
        $(
            "#illfilter_form > fieldset > ol > li:nth-child(4) > span > a"
        ).click();
        $(
            "#illfilter_form > fieldset > ol > li:nth-child(5) > span > a"
        ).click();
        $(
            "#illfilter_form > fieldset > ol > li:nth-child(6) > span > a"
        ).click();
        $(
            "#illfilter_form > fieldset > ol > li:nth-child(7) > span > a"
        ).click();

        redrawTable();
    }

    function addStatusOptions(statuses) {
        $("#illfilter_status").children().remove();
        statuses
            .sort((a, b) => a.str.localeCompare(b.str))
            .forEach(function (status) {
                $("#illfilter_status").append(
                    '<option value="' +
                        status.code +
                        '">' +
                        status.str +
                        "</option>"
                );
            });
        $("select#illfilter_status").multipleSelect({
            placeholder: __("Please select ..."),
            selectAllText: __("Select all"),
            allSelected: __("All selected"),
            countSelected: __("# of % selected"),
            noMatchesFound: __("No matches found"),
            styler: function (value) {
                // Apply styling to disabled options
                var option = $(`#illfilter_status option[value='${value}']`);
                if (option.prop("disabled")) {
                    return { opacity: "0.6", cursor: "not-allowed" };
                }
            },
        });
    }

    function addStatusAliasOptions(status_aliases) {
        $("#illfilter_status_alias").parent().remove();
        if (status_aliases.length !== 0) {
            $("#illfilter_status")
                .parent()
                .after(function () {
                    return (
                        '<li><label for="illfilter_status_alias">' +
                        ill_status_aliases +
                        ':</label> <select name="illfilter_status_alias" id="illfilter_status_alias"></select></li>'
                    );
                });
            $("#illfilter_status_alias").append(
                '<option value="">' +
                    ill_all_status_aliases +
                    "</option>" +
                    '<option value="null">' +
                    ill_no_status_alias +
                    "</option>"
            );
            status_aliases
                .sort((a, b) => a.str.localeCompare(b.str))
                .forEach(function (status_alias) {
                    $("#illfilter_status_alias").append(
                        '<option value="' +
                            status_alias.code +
                            '">' +
                            status_alias.str +
                            "</option>"
                    );
                });
        }
    }

    function populateStatusFilter(params) {
        if (params.backend_statuses) {
            if (params.backend_statuses.statuses) {
                addStatusOptions(params.backend_statuses.statuses);
            }
            if (params.backend_statuses.status_aliases) {
                addStatusAliasOptions(params.backend_statuses.status_aliases);
            }
        } else if (params.backend) {
            let backend_id = params.backend || "";
            $.ajax({
                type: "GET",
                url: "/api/v1/ill/backends/" + backend_id,
                headers: {
                    "x-koha-embed": "statuses+strings",
                },
                success: function (response) {
                    addStatusOptions(
                        response.statuses.filter(
                            status => status.type == "ill_status"
                        )
                    );
                    addStatusAliasOptions(
                        response.statuses.filter(status => status.type == "av")
                    );
                },
            });
        }
    }

    function populateBackendFilter() {
        $.ajax({
            type: "GET",
            url: "/api/v1/ill/backends",
            headers: {
                "x-koha-embed": "statuses+strings",
            },
            success: function (backends) {
                backends
                    .sort((a, b) =>
                        a.ill_backend_id.localeCompare(b.ill_backend_id)
                    )
                    .forEach(function (backend) {
                        if (
                            $(
                                "#illfilter_backend option[value=" +
                                    backend.ill_backend_id +
                                    "]"
                            ).length == 0
                        ) {
                            $("#illfilter_backend").append(
                                '<option value="' +
                                    backend.ill_backend_id +
                                    '">' +
                                    backend.ill_backend_id +
                                    "</option>"
                            );
                        }
                    });

                let all_existing_statuses = [];
                backends.forEach(backend => {
                    let existing_statuses = backend.statuses;
                    existing_statuses
                        .filter(status => status.type == "ill_status")
                        .forEach(existing_status => {
                            let index =
                                all_existing_statuses
                                    .map(function (e) {
                                        return e.code;
                                    })
                                    .indexOf(existing_status.code) || false;
                            if (index == -1) {
                                all_existing_statuses.push(existing_status);
                            }
                        });
                });

                let all_existing_status_aliases = [];
                backends.forEach(backend => {
                    let existing_status_aliases = backend.statuses;
                    existing_status_aliases
                        .filter(status => status.type == "av")
                        .forEach(existing_status_aliases => {
                            let index =
                                all_existing_status_aliases
                                    .map(function (e) {
                                        return e.code;
                                    })
                                    .indexOf(existing_status_aliases.code) ||
                                false;
                            if (index == -1) {
                                all_existing_status_aliases.push(
                                    existing_status_aliases
                                );
                            }
                        });
                });

                populateStatusFilter({
                    backend_statuses: {
                        statuses: all_existing_statuses,
                        status_aliases: all_existing_status_aliases,
                    },
                });
            },
        });
    }

    $("#illfilter_backend").change(function () {
        var selected_backend = $("#illfilter_backend option:selected").val();
        if (selected_backend && selected_backend.length > 0) {
            populateStatusFilter({ backend: selected_backend });
        } else {
            populateBackendFilter();
        }
    });
    populateBackendFilter();

    // Clear all filters
    $(".clear_search").click(function () {
        clearSearch();
    });
});
