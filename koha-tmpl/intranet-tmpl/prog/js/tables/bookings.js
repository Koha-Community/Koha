/* global __ $biblio_to_html $date AdditionalFilters BookingsTable patron_borrowernumber table_settings_bookings_table */

// Bookings
var bookings_table;
$(document).ready(function () {
    if (!$("#bookings_table").length) {
        return;
    }

    const af = AdditionalFilters.init([
        "filter-completed",
        "filter-cancelled",
    ]).onChange(() => {
        if (bookings_table) {
            bookings_table.DataTable().ajax.reload();
        }
    });

    const additional_filters = {
        patron_id: patron_borrowernumber,
        ...af.build({
            status: ({ filters, isNotApplied }) => {
                const defaults = ["new", "issued"];
                const filtered = [...defaults];
                if (isNotApplied(filters["filter-cancelled"])) {
                    filtered.push("cancelled");
                }
                if (isNotApplied(filters["filter-completed"])) {
                    filtered.push("completed");
                }
                return { "-in": filtered };
            },
        }),
    };

    // Load bookings table on page load
    if (window.location.hash === "#bookings_panel") {
        loadBookingsTable();
    }
    // Load bookings table on tab selection
    $("#bookings-tab").on("click", function () {
        loadBookingsTable();
    });

    function loadBookingsTable() {
        if (!bookings_table) {
            var bookings_table_url = "/api/v1/bookings";
            bookings_table = $("#bookings_table").kohaTable(
                {
                    ajax: {
                        url: bookings_table_url,
                    },
                    embed: ["biblio", "item", "item.checkout", "patron"],
                    createdRow: function (row, data) {
                        BookingsTable.highlightRow(data, row);
                    },
                    columns: [
                        {
                            data: "booking_id",
                            title: __("Booking ID"),
                        },
                        {
                            data: "",
                            title: __("Status"),
                            name: "status",
                            searchable: false,
                            orderable: false,
                            render: function (data, type, row, meta) {
                                return BookingsTable.statusBadge(row);
                            },
                        },
                        {
                            data: "biblio.title",
                            title: __("Title"),
                            searchable: true,
                            orderable: true,
                            render: function (data, type, row, meta) {
                                return $biblio_to_html(row.biblio, {
                                    link: "bookings",
                                });
                            },
                        },
                        {
                            data: "item.external_id",
                            title: __("Item"),
                            searchable: true,
                            orderable: true,
                            defaultContent: __("Any item"),
                            render: function (data, type, row, meta) {
                                return BookingsTable.itemContent(row);
                            },
                        },
                        {
                            data: "start_date",
                            title: __("Start date"),
                            searchable: true,
                            orderable: true,
                            render: function (data, type, row, meta) {
                                return $date(row.start_date);
                            },
                        },
                        {
                            data: "end_date",
                            title: __("End date"),
                            searchable: true,
                            orderable: true,
                            render: function (data, type, row, meta) {
                                return $date(row.end_date);
                            },
                        },
                        {
                            data: "",
                            title: __("Actions"),
                            class: "actions",
                            searchable: false,
                            orderable: false,
                            render: function (data, type, row, meta) {
                                return BookingsTable.actionsContent(row);
                            },
                        },
                    ],
                },
                table_settings_bookings_table,
                0,
                additional_filters
            );
        }
    }
});
