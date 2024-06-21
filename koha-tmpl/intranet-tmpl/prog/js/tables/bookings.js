/* keep tidy */
// Bookings
var bookings_table;
$(document).ready(function () {
    // Load bookings table on tab selection
    $("#bookings-tab").on("click", function () {
        if (!bookings_table) {
            var today = new Date();
            var bookings_table_url = "/api/v1/bookings";
            bookings_table = $("#bookings_table").kohaTable(
                {
                    ajax: {
                        url: bookings_table_url,
                    },
                    embed: ["biblio", "item", "patron"],
                    columns: [
                        {
                            data: "booking_id",
                            title: __("Booking ID"),
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
                                if (row.item) {
                                    return (
                                        row.item.external_id +
                                        " (" +
                                        row.booking_id +
                                        ")"
                                    );
                                } else {
                                    return null;
                                }
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
                                let result = "";
                                if (CAN_user_circulate_manage_bookings) {
                                    result +=
                                        '<button type="button" class="btn btn-default btn-xs cancel-action" data-toggle="modal" data-target="#cancelBookingModal" data-booking="' +
                                        row.booking_id +
                                        '"><i class="fa fa-trash" aria-hidden="true"></i> ' +
                                        __("Cancel") +
                                        "</button>";
                                }
                                return result;
                            },
                        },
                    ],
                },
                table_settings_bookings_table,
                0,
                {
                    patron_id: patron_borrowernumber,
                    end_date: { ">=": today.toISOString() },
                }
            );
        }
    });
});
