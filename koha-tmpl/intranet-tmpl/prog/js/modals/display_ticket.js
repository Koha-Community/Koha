$(document).ready(function () {
    document.addEventListener("click", function (event) {
        const detailTrigger = event.target.closest(".detail-trigger");
        if (detailTrigger) {
            event.preventDefault();

            // Find the main trigger button in the same row
            const mainTrigger = detailTrigger
                .closest("tr")
                .querySelector(".main-trigger");

            // Trigger a click on the main trigger if it exists
            if (mainTrigger) {
                mainTrigger.click();
            }
        }
    });

    $("#ticketDetailsModal").on("show.bs.modal", function (event) {
        let modal = $(this);
        let button = $(event.relatedTarget);
        let ticket_id = button.data("concern");
        let resolved = button.data("resolved");
        let assignee = button.data("assignee");
        modal.find(".modal-footer input").val(ticket_id);

        if (resolved) {
            $("#resolveTicket").hide();
        } else {
            $("#resolveTicket").show();
        }

        let title = $("#title_" + ticket_id).text();
        let detail = $("#detail_" + ticket_id).text();

        // Display ticket details
        let display = '<div class="list-group">';
        display +=
            '<div class="list-group-item list-group-item-secondary d-flex justify-content-between align-items-start">';
        display += '<div class="ms-2 me-auto">';
        display += '<div class="fw-bold">' + title + "</div>";
        display += '<div class="wrapfix">' + detail + "</div>";
        display += "</div>";
        if (assignee) {
            display += "<span>";
            display +=
                '<label class="label strong">' +
                __("Assignee") +
                "</label>: " +
                "<span>" +
                assignee +
                "</span>";
            display += "</span>";
        }
        display += "</div>";
        display +=
            '<div id="concern-updates" class="list-group-item list-group-item-info">';
        display += "<span>" + __("Loading updates . . .") + "</span>";
        display += "</div>";
        display += "</div>";

        let details = modal.find("#concern-details");
        details.html(display);

        // Load any existing updates
        $.ajax({
            url: "/api/v1/tickets/" + ticket_id + "/updates",
            method: "GET",
            headers: {
                "x-koha-embed": ["user", "assignee", "+strings"],
            },
        })
            .success(function (data) {
                let updates_display = $("#concern-updates");
                let updates = "";
                data.forEach(function (item, index) {
                    if (item.public) {
                        updates +=
                            '<div class="list-group-item list-group-item-success d-flex flex-column">';
                    } else {
                        updates +=
                            '<div class="list-group-item list-group-item-warning d-flex flex-column">';
                    }
                    updates += '<div class="d-flex">';
                    updates +=
                        '<div class="flex-grow-1 mb-0 wrapfix">' +
                        item.message +
                        "</div>";
                    updates += '<div class="d-flex flex-column ms-3 text-end">';
                    if (item.public) {
                        updates +=
                            '<span class="mb-1">' + __("Public") + "</span>";
                    } else {
                        updates +=
                            '<span class="mb-1">' + __("Private") + "</span>";
                    }
                    if (item.status) {
                        updates += '<span class="mb-1">';
                        updates += item._strings.status
                            ? escape_str(item._strings.status.str)
                            : "";
                        updates += "</span>";
                    }
                    if (item.assignee) {
                        updates += '<span class="mb-1">';
                        updates += $patron_to_html(item.assignee, {
                            display_cardnumber: false,
                            url: true,
                        });
                        updates += "</span>";
                    }
                    updates += "</div>";
                    updates += "</div>";
                    updates +=
                        '<div class="text-end text-muted small mt-2">' +
                        $patron_to_html(item.user, {
                            display_cardnumber: false,
                            url: true,
                        }) +
                        " (" +
                        $datetime(item.date) +
                        ")" +
                        "</div>";
                    updates += "</div>";
                });
                updates_display.replaceWith(updates);
            })
            .error(function () {});

        // Clear any previously entered update message
        $("#update_message").val("");
        $("#public").prop("checked", false);

        // Patron select2
        $("#assignee_id").kohaSelect({
            dropdownParent: $(".modal-content", "#ticketDetailsModal"),
            width: "50%",
            dropdownAutoWidth: true,
            allowClear: true,
            minimumInputLength: 3,
            ajax: {
                url: "/api/v1/patrons",
                delay: 250,
                dataType: "json",
                headers: {
                    "x-koha-embed": "library",
                },
                data: function (params) {
                    let q = buildPatronSearchQuery(params.term);
                    let query = {
                        q: JSON.stringify(q),
                        _page: params.page,
                        _order_by: "+me.surname,+me.firstname",
                    };
                    return query;
                },
                processResults: function (data, params) {
                    let results = [];
                    data.results.forEach(function (patron) {
                        patron.id = patron.patron_id;
                        results.push(patron);
                    });
                    return {
                        results: results,
                        pagination: { more: data.pagination.more },
                    };
                },
            },
            templateResult: function (patron) {
                if (patron.library_id == loggedInLibrary) {
                    loggedInClass = "ac-currentlibrary";
                } else {
                    loggedInClass = "";
                }

                let $patron = $("<span></span>")
                    .append(
                        "" +
                            (patron.surname
                                ? escape_str(patron.surname) + ", "
                                : "") +
                            (patron.firstname
                                ? escape_str(patron.firstname) + " "
                                : "") +
                            (patron.cardnumber
                                ? " (" + escape_str(patron.cardnumber) + ")"
                                : "") +
                            "<small>" +
                            (patron.date_of_birth
                                ? ' <span class="age_years">' +
                                  $get_age(patron.date_of_birth) +
                                  " " +
                                  __("years") +
                                  "</span>"
                                : "") +
                            (patron.library
                                ? ' <span class="ac-library">' +
                                  escape_str(patron.library.name) +
                                  "</span>"
                                : "") +
                            "</small>"
                    )
                    .addClass(loggedInClass);
                return $patron;
            },
            templateSelection: function (patron) {
                if (!patron.surname) {
                    return patron.text;
                }
                return (
                    escape_str(patron.surname) +
                    ", " +
                    escape_str(patron.firstname)
                );
            },
            placeholder: __("Search for a patron"),
        });
    });

    $("#ticketDetailsModal").on("click", ".updateSubmit", function (e) {
        let clicked = $(this);
        let ticket_id = $("#ticket_id").val();
        let assignee_id = $("#assignee_id").val();
        let params = {
            public: $("#public").is(":checked"),
            message: $("#update_message").val(),
            user_id: logged_in_user_borrowernumber,
            status: clicked.data("status"),
            assignee_id: assignee_id,
        };

        $("#comment-spinner").show();

        $.ajax({
            url: "/api/v1/tickets/" + ticket_id + "/updates",
            method: "POST",
            data: JSON.stringify(params),
            ontentType: "application/json; charset=utf-8",
        })
            .success(function () {
                $("#comment-spinner").hide();
                $("#ticketDetailsModal").modal("hide");
                $("#table_concerns")
                    .DataTable()
                    .ajax.reload(function (data) {
                        $("#concern_action_result_dialog").hide();
                        $("#concern_delete_success")
                            .html(
                                __("Concern #%s updated successfully.").format(
                                    ticket_id
                                )
                            )
                            .show();
                    });
            })
            .error(function () {
                $("#concern_update_error")
                    .html(
                        __(
                            "Error resolving concern #%s. Check the logs for details."
                        ).format(ticket_id)
                    )
                    .show();
            });
    });

    $("#ticketDetailsModal").on("click", ".resolveSubmit", function (e) {
        let clicked = $(this);
        let ticket_id = $("#ticket_id").val();
        let params = {
            public: $("#public").is(":checked"),
            message: $("#update_message").val(),
            user_id: logged_in_user_borrowernumber,
            state: "resolved",
            status: clicked.data("resolution"),
        };

        $("#resolve-spinner").show();

        $.ajax({
            url: "/api/v1/tickets/" + ticket_id + "/updates",
            method: "POST",
            data: JSON.stringify(params),
            ontentType: "application/json; charset=utf-8",
        })
            .success(function () {
                $("#resolve-spinner").hide();
                $("#ticketDetailsModal").modal("hide");
                $("#table_concerns")
                    .DataTable()
                    .ajax.reload(function (data) {
                        $("#concern_action_result_dialog").hide();
                        $("#concern_delete_success")
                            .html(
                                __("Concern #%s updated successfully.").format(
                                    ticket_id
                                )
                            )
                            .show();
                    });
            })
            .error(function () {
                $("#concern_update_error")
                    .html(
                        __(
                            "Error resolving concern #%s. Check the logs for details."
                        ).format(ticket_id)
                    )
                    .show();
            });
    });
});
