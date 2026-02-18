function display_pickup_location(state) {
    var $text;
    if (state.needs_override === true) {
        $text = $(
            "<span>" +
                state.text +
                '</span> <span style="float:right;" title="' +
                __(
                    "This pickup location is not allowed according to circulation rules"
                ) +
                '"><i class="fa fa-exclamation-circle" aria-hidden="true"></i></span>'
        );
    } else {
        $text = $("<span>" + state.text + "</span>");
    }

    return $text;
}

(function ($) {
    /**
     * Generate a Select2 dropdown for pickup locations
     *
     * It expects the select object to contain several data-* attributes
     * - data-pickup-location-source: 'biblio', 'item' or 'hold' (default)
     * - data-patron-id: required for 'biblio' and 'item'
     * - data-biblio-id: required for 'biblio' only
     * - data-item-id: required for 'item' only
     *
     * @return {Object} The Select2 instance
     */

    $.fn.pickup_locations_dropdown = function () {
        var select = $(this);
        var pickup_location_source = $(this).data("pickup-location-source");
        var patron_id = $(this).data("patron-id");
        var biblio_id = $(this).data("biblio-id");
        var item_id = $(this).data("item-id");
        var hold_id = $(this).data("hold-id");

        var url;

        if (pickup_location_source === "biblio") {
            url =
                "/api/v1/biblios/" +
                encodeURIComponent(biblio_id) +
                "/pickup_locations";
        } else if (pickup_location_source === "item") {
            url =
                "/api/v1/items/" +
                encodeURIComponent(item_id) +
                "/pickup_locations";
        } else {
            // hold
            url =
                "/api/v1/holds/" +
                encodeURIComponent(hold_id) +
                "/pickup_locations";
        }

        select.kohaSelect({
            width: "style",
            allowClear: false,
            ajax: {
                url: url,
                delay: 300, // wait 300 milliseconds before triggering the request
                cache: true,
                dataType: "json",
                data: function (params) {
                    var search_term =
                        params.term === undefined ? "" : params.term;
                    var query = {
                        q: JSON.stringify({
                            name: { "-like": "%" + search_term + "%" },
                        }),
                        _order_by: "name",
                        _page: params.page,
                    };

                    if (pickup_location_source !== "hold") {
                        query["patron_id"] = patron_id;
                    }

                    return query;
                },
                processResults: function (data) {
                    var results = [];
                    data.results.forEach(function (pickup_location) {
                        results.push({
                            id: pickup_location.library_id.escapeHtml(),
                            text: pickup_location.name.escapeHtml(),
                            needs_override: pickup_location.needs_override,
                        });
                    });
                    return {
                        results: results,
                        pagination: { more: data.pagination.more },
                    };
                },
            },
            templateResult: display_pickup_location,
        });

        return select;
    };
})(jQuery);

/* global __ borrowernumber SuspendHoldsIntranet */
$(document).ready(function () {
    let patron_page = holds_table_patron_page();
    function suspend_hold(hold_ids, end_date) {
        var params = { hold_ids: hold_ids };
        if (end_date !== null && end_date !== "") params.end_date = end_date;

        return $.ajax({
            method: "POST",
            url: "/api/v1/holds/suspension_bulk",
            contentType: "application/json",
            data: JSON.stringify(params),
        });
    }

    function resume_hold(hold_id) {
        return $.ajax({
            method: "DELETE",
            url: "/api/v1/holds/" + encodeURIComponent(hold_id) + "/suspension",
        }).done(function () {
            if ($(".select_hold_all").prop("checked")) {
                $(".select_hold_all").click();
            }
        });
    }

    var holdsTable;

    // Don't load holds table unless it is clicked on
    $("#holds-tab").on("click", function () {
        load_holds_table();
    });

    // If the holds tab is preselected on load, we need to load the table
    if ($("#holds-tab").parent().hasClass("active")) {
        load_holds_table();
    }

    function load_holds_table() {
        var holds = new Array();
        if (!holdsTable) {
            var title;
            holdsTable = $("#holds-table").kohaTable(
                {
                    autoWidth: false,
                    dom: '<"table_controls"B>rt',
                    columns: [
                        {
                            orderable: false,
                            data: function (oObj) {
                                return (
                                    '<input type="checkbox" class="select_hold" data-id="' +
                                    oObj.reserve_id +
                                    (oObj.hold_group_id
                                        ? '" data-hold-group-id="' +
                                          oObj.hold_group_id +
                                          '"'
                                        : '"') +
                                    '" data-borrowernumber="' +
                                    borrowernumber +
                                    '" data-biblionumber="' +
                                    oObj.biblionumber +
                                    '">'
                                );
                            },
                        },
                        {
                            data: {
                                _: "reservedate_formatted",
                                sort: "reservedate",
                            },
                        },
                        ...(DisplayAddHoldGroups
                            ? [
                                  {
                                      data: function (oObj) {
                                          title = "";
                                          if (oObj.visual_hold_group_id) {
                                              var link =
                                                  '<a class="hold-group" href="/cgi-bin/koha/reserve/hold-group.pl?hold_group_id=' +
                                                  oObj.hold_group_id +
                                                  '">' +
                                                  oObj.visual_hold_group_id +
                                                  "</a>";

                                              title =
                                                  "<span>" + link + "</span>";
                                          }

                                          return title;
                                      },
                                  },
                              ]
                            : []),
                        {
                            data: function (oObj) {
                                title =
                                    "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber=" +
                                    oObj.biblionumber +
                                    "'>" +
                                    (oObj.title ? oObj.title.escapeHtml() : "");

                                $.each(oObj.subtitle, function (index, value) {
                                    title += " " + value.escapeHtml();
                                });

                                title +=
                                    " " +
                                    oObj.part_number +
                                    " " +
                                    oObj.part_name;

                                if (oObj.enumchron) {
                                    title +=
                                        " (" +
                                        oObj.enumchron.escapeHtml() +
                                        ")";
                                }

                                title += "</a>";

                                if (oObj.author) {
                                    title +=
                                        " " +
                                        __("by _AUTHOR_").replace(
                                            "_AUTHOR_",
                                            oObj.author.escapeHtml()
                                        );
                                }

                                if (oObj.itemnotes) {
                                    var span_class = "";
                                    if (
                                        flatpickr.formatDate(
                                            new Date(oObj.issuedate),
                                            "Y-m-d"
                                        ) == ymd
                                    ) {
                                        span_class = "circ-hlt";
                                    }
                                    title +=
                                        " - <span class='" +
                                        span_class +
                                        "'>" +
                                        oObj.itemnotes.escapeHtml() +
                                        "</span>";
                                }

                                if (oObj.is_hold_group_target) {
                                    var link = __("target of hold group");
                                    title +=
                                        '<br><span class="fw-bold fst-italic">(' +
                                        link +
                                        ")</span>";
                                }

                                return title;
                            },
                        },
                        {
                            data: function (oObj) {
                                return (
                                    (oObj.itemcallnumber &&
                                        oObj.itemcallnumber.escapeHtml()) ||
                                    ""
                                );
                            },
                        },
                        {
                            data: function (oObj) {
                                var data = "";
                                if (oObj.itemtype) {
                                    data += oObj.itemtype_description;
                                }
                                return data;
                            },
                        },
                        {
                            data: function (oObj) {
                                var data = "";
                                if (oObj.barcode) {
                                    data +=
                                        " <a href='/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=" +
                                        oObj.biblionumber +
                                        "&itemnumber=" +
                                        oObj.itemnumber +
                                        "#item" +
                                        oObj.itemnumber +
                                        "'>" +
                                        oObj.barcode.escapeHtml() +
                                        "</a>";
                                }
                                return data;
                            },
                        },
                        {
                            data: function (oObj) {
                                if (
                                    oObj.branches.length > 1 &&
                                    oObj.found !== "W" &&
                                    oObj.found !== "T"
                                ) {
                                    var branchSelect =
                                        "<select priority=" +
                                        oObj.priority +
                                        ' class="hold_location_select" data-hold-id="' +
                                        oObj.reserve_id +
                                        '" reserve_id="' +
                                        oObj.reserve_id +
                                        '" name="pick-location" data-pickup-location-source="hold">';
                                    for (
                                        var i = 0;
                                        i < oObj.branches.length;
                                        i++
                                    ) {
                                        var selectedbranch;
                                        var setbranch;
                                        if (oObj.branches[i].selected) {
                                            selectedbranch =
                                                " selected='selected' ";
                                            setbranch = __(" (current) ");
                                        } else if (
                                            oObj.branches[i].pickup_location ==
                                            0
                                        ) {
                                            continue;
                                        } else {
                                            selectedbranch = "";
                                            setbranch = "";
                                        }
                                        branchSelect +=
                                            '<option value="' +
                                            oObj.branches[
                                                i
                                            ].branchcode.escapeHtml() +
                                            '"' +
                                            selectedbranch +
                                            ">" +
                                            oObj.branches[
                                                i
                                            ].branchname.escapeHtml() +
                                            setbranch +
                                            "</option>";
                                    }
                                    branchSelect += "</select>";
                                    return branchSelect;
                                } else {
                                    return oObj.branchcode.escapeHtml() || "";
                                }
                            },
                        },
                        {
                            data: {
                                _: "expirationdate_formatted",
                                sort: "expirationdate",
                            },
                        },
                        {
                            data: function (oObj) {
                                if (
                                    oObj.priority &&
                                    parseInt(oObj.priority) &&
                                    parseInt(oObj.priority) > 0
                                ) {
                                    return oObj.priority;
                                } else {
                                    return "";
                                }
                            },
                        },
                        {
                            data: function (oObj) {
                                return (
                                    (oObj.reservenotes &&
                                        oObj.reservenotes.escapeHtml()) ||
                                    ""
                                );
                            },
                        },
                        {
                            data: function (oObj) {
                                return (
                                    '<a class="cancel-hold deny" title="Cancel hold" data-borrowernumber="' +
                                    borrowernumber +
                                    '" data-biblionumber="' +
                                    oObj.biblionumber +
                                    '" data-id="' +
                                    oObj.reserve_id +
                                    '" href="#">  <i class="fa fa-trash" aria-label="Cancel hold"></i></a>'
                                );
                            },
                        },
                        {
                            orderable: false,
                            visible: SuspendHoldsIntranet,
                            data: function (oObj) {
                                holds[oObj.reserve_id] = oObj; //Store holds for later use

                                if (oObj.found) {
                                    return "";
                                } else if (oObj.suspend == 1) {
                                    return (
                                        "<a class='hold-resume btn btn-default btn-xs' data-hold-id='" +
                                        oObj.reserve_id +
                                        "'>" +
                                        "<i class='fa fa-play'></i> " +
                                        __("Resume") +
                                        "</a>"
                                    );
                                } else {
                                    const link = Object.assign(
                                        document.createElement("a"),
                                        {
                                            className:
                                                "hold-suspend btn btn-default btn-xs",
                                            textContent: " " + __("Suspend"),
                                        }
                                    );
                                    link.setAttribute(
                                        "data-hold-id",
                                        oObj.reserve_id
                                    );
                                    link.setAttribute(
                                        "data-hold-title",
                                        oObj.title
                                    );
                                    const icon = Object.assign(
                                        document.createElement("i"),
                                        {
                                            className: "fa fa-pause",
                                        }
                                    );
                                    link.prepend(icon);
                                    return link.outerHTML;
                                }
                            },
                        },
                        {
                            data: function (oObj) {
                                var data = "";

                                if (oObj.suspend == 1) {
                                    data +=
                                        "<p>" +
                                        __(
                                            "Hold is <strong>suspended</strong>"
                                        );
                                    if (oObj.suspend_until) {
                                        data +=
                                            " " +
                                            __("until %s").format(
                                                oObj.suspend_until_formatted
                                            );
                                    }
                                    data += "</p>";
                                }

                                if (oObj.itemtype_limit) {
                                    data += __("Next available %s item").format(
                                        oObj.itemtype_limit
                                    );
                                }

                                if (oObj.item_group_id) {
                                    data += __(
                                        "Next available item group <strong>%s</strong> item"
                                    ).format(oObj.item_group_description);
                                }

                                if (oObj.barcode) {
                                    data += "<em>";
                                    if (oObj.found == "W") {
                                        if (oObj.waiting_here) {
                                            data += __(
                                                "Item is <strong>waiting here</strong>"
                                            );
                                            if (oObj.desk_name) {
                                                data +=
                                                    ", " +
                                                    __("at %s").format(
                                                        oObj.desk_name.escapeHtml()
                                                    );
                                            }
                                        } else {
                                            data += __(
                                                "Item is <strong>waiting</strong>"
                                            );
                                            data +=
                                                " " +
                                                __("at %s").format(
                                                    oObj.waiting_at
                                                );
                                            if (oObj.desk_name) {
                                                data +=
                                                    ", " +
                                                    __("at %s").format(
                                                        oObj.desk_name.escapeHtml()
                                                    );
                                            }
                                        }
                                    } else if (
                                        oObj.found == "T" &&
                                        oObj.transferred
                                    ) {
                                        data += __(
                                            "Item is <strong>in transit</strong> from %s since %s"
                                        ).format(
                                            oObj.from_branch,
                                            oObj.date_sent
                                        );
                                    } else if (
                                        oObj.found == "T" &&
                                        oObj.not_transferred
                                    ) {
                                        data += __(
                                            "Item hasn't been transferred yet from %s"
                                        ).format(oObj.not_transferred_by);
                                    }
                                    data += "</em>";
                                }
                                return data;
                            },
                        },
                    ],
                    paging: false,
                    processing: true,
                    serverSide: false,
                    ajax: {
                        url: "/cgi-bin/koha/svc/holds",
                        data: function (d) {
                            d.borrowernumber = borrowernumber;
                        },
                    },
                    bKohaAjaxSVC: true,
                },
                table_settings_holds_table
            );

            $("#holds-table").on("draw.dt", function () {
                $(".hold-suspend").on("click", function () {
                    var hold_id = $(this).data("hold-id");
                    var hold_title = $(this).data("hold-title");
                    $("#suspend-modal-title").text(hold_title);
                    $("#suspend-modal-submit").data("hold-id", hold_id);
                    $("#suspend-modal").modal("show");
                });

                $(".hold-resume").on("click", function () {
                    var hold_id = $(this).data("hold-id");
                    resume_hold(hold_id)
                        .success(function () {
                            holdsTable.api().ajax.reload();
                        })
                        .error(function (jqXHR, textStatus, errorThrown) {
                            if (jqXHR.status === 404) {
                                alert(__("Unable to resume, hold not found"));
                            } else {
                                alert(
                                    __(
                                        "Your request could not be processed. Check the logs for details."
                                    )
                                );
                            }
                            holdsTable.api().ajax.reload();
                        });
                });

                $(".hold_location_select").each(function () {
                    $(this).pickup_locations_dropdown();
                });

                $(".hold_location_select").on("change", function () {
                    $(this).prop("disabled", true);
                    var cur_select = $(this);
                    var res_id = $(this).attr("reserve_id");
                    $(this).after(
                        '<div id="updating_reserveno' +
                            res_id +
                            '" class="waiting"><img src="/intranet-tmpl/prog/img/spinner-small.gif" alt="" /><span class="waiting_msg"></span></div>'
                    );
                    var api_url =
                        "/api/v1/holds/" +
                        encodeURIComponent(res_id) +
                        "/pickup_location";
                    $.ajax({
                        method: "PUT",
                        url: api_url,
                        data: JSON.stringify({
                            pickup_library_id: $(this).val(),
                        }),
                        headers: { "x-koha-override": "any" },
                        success: function (data) {
                            holdsTable.api().ajax.reload();
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            alert(
                                "There was an error:" +
                                    textStatus +
                                    " " +
                                    errorThrown
                            );
                            cur_select.prop("disabled", false);
                            $("#updating_reserveno" + res_id).remove();
                            cur_select.val(
                                cur_select
                                    .children('option[selected="selected"]')
                                    .val()
                            );
                        },
                    });
                });
            });

            if ($("#holds-table").length) {
                $("#holds-table_processing").position({
                    of: $("#holds-table"),
                    collision: "none",
                });
            }
        }
    }

    $("#suspend-modal-clear-date").on("click", function () {
        $("#suspend-modal-until").flatpickr().clear();
    });

    $("#suspend-modal-submit").on("click", function (e) {
        e.preventDefault();
        let selected_holds;
        if (!$(this).data("hold-id")) {
            selected_holds = get_selected_holds_data();
        } else {
            selected_holds =
                "[" + JSON.stringify({ hold: $(this).data("hold-id") }) + "]";
            $(this).removeData("hold-id");
        }

        var suspend_until_date = $("#suspend-modal-until").val();
        if (suspend_until_date !== null)
            suspend_until_date = $date(suspend_until_date, {
                dateformat: "rfc3339",
            });

        const hold_ids = JSON.parse(selected_holds).map(hold => hold.hold);
        try {
            suspend_hold(hold_ids, suspend_until_date)
                .success(function () {
                    holdsTable.api().ajax.reload();
                })
                .done(function () {
                    if ($("#suspend-modal-until").length) {
                        $("#suspend-modal-until").flatpickr().clear(); // clean the input
                    }
                    $("#suspend-modal").modal("hide");
                    $(".select_hold_all").click();
                });
        } catch (error) {
            if (error.status === 404) {
                alert(__("Unable to suspend, hold not found."));
            } else {
                alert(
                    __(
                        "Your request could not be processed. Check the logs for details."
                    )
                );
            }
        }
    });

    function toggle_suspend(node, inputs) {
        let reserve_id = $(node).data("reserve-id");
        let biblionumber = $(node).data("biblionumber");
        let suspendForm = $("#hold-actions-form").attr({
            action: "request.pl",
            method: "post",
        });
        let sus_bn = $("<input />").attr({
            type: "hidden",
            name: "biblionumber",
            value: biblionumber,
        });
        let sus_ri = $("<input />").attr({
            type: "hidden",
            name: "reserve_id",
            value: reserve_id,
        });
        inputs.push(sus_bn, sus_ri);
        suspendForm.append(inputs);
        $("#hold-actions-form").submit();
        return false;
    }
    $(".suspend-hold").on("click", function (e) {
        e.preventDefault();
        let reserve_id = $(this).data("reserve-id");
        let suspend_until = $("#suspend_until_" + reserve_id).val();
        let inputs = [
            $("<input />").attr({
                type: "hidden",
                name: "op",
                value: "cud-suspend",
            }),
            $("<input />").attr({
                type: "hidden",
                name: "suspend_until",
                value: suspend_until,
            }),
        ];
        return toggle_suspend(this, inputs);
    });

    var MSG_SUSPEND_SELECTED_HOLDS = __("selected holds");

    $(".suspend_selected_holds").click(function (e) {
        e.preventDefault();
        if (!$(".holds_table .select_hold:checked").length) {
            return false;
        }
        $("#suspend-modal-title").html(MSG_SUSPEND_SELECTED_HOLDS);
        $("#suspend-modal").modal("show");
        return false;
    });

    $(".unsuspend-hold").on("click", function (e) {
        e.preventDefault();
        let inputs = [
            $("<input />").attr({
                type: "hidden",
                name: "op",
                value: "cud-unsuspend",
            }),
        ];
        return toggle_suspend(this, inputs);
    });

    var MSG_MOVE_SELECTED = __("Move selected (%s)");
    var MSG_CANCEL_ALERT = __(
        "This action will cancel <span class='badge bg-danger'>%s</span> hold(s)."
    );

    // Confirm cancellation of hold
    let cancel_link;
    $(document).on("click", ".cancel-hold", function (e) {
        e.preventDefault;
        cancel_link = $(this);
        $("#cancel_modal_form #inputs").empty();
        let reserve_id = cancel_link.data("id");
        let biblionumber = cancel_link.data("biblionumber");
        if (!patron_page) {
            $("#cancel_modal_form #inputs").append(
                '<input type="hidden" name="reserve_id" value="' +
                    reserve_id +
                    '">'
            );
            $("#cancel_modal_form #inputs").append(
                '<input type="hidden" name="biblionumber" value="' +
                    biblionumber +
                    '">'
            );
            $("#cancel_modal_form #inputs").append(
                '<input type="hidden" name="op" value="cud-cancel">'
            );
        } else {
            _append_patron_page_cancel_hold_modal_data({
                hold: reserve_id,
                biblionumber: biblionumber,
                borrowernumber: cancel_link.data("borrowernumber"),
            });
        }
        $("#cancelModal").modal("show");
        return false;
    });

    if (
        !localStorage.selectedHolds ||
        document.referrer.replace(/\?.*/, "") !==
            document.location.origin + document.location.pathname
    ) {
        localStorage.selectedHolds = [];
    }

    $(".holds_table .select_hold").each(function () {
        if (localStorage.selectedHolds.includes($(this).data("id"))) {
            $(this).prop("checked", true);
        }
    });

    function updateSelectedHoldsButtonCounters() {
        $(".move_selected_holds").html(
            MSG_MOVE_SELECTED.format(
                $(".holds_table .select_hold:checked").length
            )
        );
        $(".selected_holds_count").html(
            $(".holds_table .select_hold:checked").length
        );
        var selectedHolds = $(".holds_table .select_hold:checked");
        var hasSelectedHolds = selectedHolds.length > 0;
        var hasMultipleSelectedHolds = selectedHolds.length >= 2;

        $(".cancel_selected_holds, .suspend_selected_holds").prop(
            "disabled",
            !hasSelectedHolds
        );
        $(".group_selected_holds").prop("disabled", !hasMultipleSelectedHolds);
    }

    function updateMoveButtons(table) {
        var checked_holds = $(".select_hold:checked", table);
        var checked_count = checked_holds.length;

        var item_level_count = checked_holds.filter(function () {
            return $(this).attr("data-item_level_hold") !== "";
        }).length;

        var record_level_count = checked_holds.filter(function () {
            return $(this).attr("data-item_level_hold") === "";
        }).length;

        $(".move_hold_item").toggleClass("disabled", item_level_count <= 0);
        $(".move_hold_biblio").toggleClass("disabled", record_level_count <= 0);
        $(".move_selected_holds").prop("disabled", !checked_count);
    }

    if (holds_table_patron_page()) {
        updateSelectedHoldsButtonCounters();

        $(".holds_table .select_hold_all").click(function () {
            var table = $(".holds_table:not(.fixedHeader-floating)");

            var checked_count = $(".select_hold:checked", table).length;
            $(".select_hold", table).prop("checked", !checked_count);
            $(this).prop("checked", !checked_count);

            updateMoveButtons(table);

            updateSelectedHoldsButtonCounters();
            $("#cancel_hold_alert").html(
                MSG_CANCEL_ALERT.format(
                    $(".holds_table .select_hold:checked").length
                )
            );
            $("#cancel_hold_alert").show();
            localStorage.selectedHolds =
                "[" +
                $(".holds_table .select_hold:checked")
                    .toArray()
                    .map(el =>
                        JSON.stringify({
                            hold: $(el).data("id"),
                            borrowernumber: $(el).data("borrowernumber"),
                            biblionumber: $(el).data("biblionumber"),
                        })
                    )
                    .join(",") +
                "]";
        });

        $(".holds_table").on("click", ".select_hold", function () {
            var table = $(this).parents(".holds_table");
            var count = $(".select_hold:not(:checked)", table).length;
            $(".select_hold_all", table).prop("checked", !count);

            updateMoveButtons(table);

            updateSelectedHoldsButtonCounters();
            $("#cancel_hold_alert").html(
                MSG_CANCEL_ALERT.format(
                    $(".holds_table .select_hold:checked").length
                )
            );
            $("#cancel_hold_alert").show();
            localStorage.selectedHolds =
                "[" +
                $(".holds_table .select_hold:checked")
                    .toArray()
                    .map(el =>
                        JSON.stringify({
                            hold: $(el).data("id"),
                            borrowernumber: $(el).data("borrowernumber"),
                            biblionumber: $(el).data("biblionumber"),
                        })
                    )
                    .join(",") +
                "]";
        });

        $(".cancel_selected_holds").click(function (e) {
            e.preventDefault();
            if ($(".holds_table .select_hold:checked").length) {
                $("#cancel_modal_form #inputs").empty();
                $("#cancel_modal_form #inputs").append(
                    '<input type="hidden" name="op" value="cud-cancelall">'
                );
                let hold_data =
                    "[" +
                    $(".holds_table .select_hold:checked")
                        .toArray()
                        .map(el =>
                            JSON.stringify({
                                hold: $(el).data("id"),
                                borrowernumber: $(el).data("borrowernumber"),
                                biblionumber: $(el).data("biblionumber"),
                            })
                        )
                        .join(",") +
                    "]";
                JSON.parse(hold_data).forEach(function (hold) {
                    _append_patron_page_cancel_hold_modal_data(hold);
                });
                delete localStorage.selectedHolds;
                $("#cancelModal").modal("show");
            }
            return false;
        });
    }
    $("#itemSearchForm").on("submit", function (event) {
        event.preventDefault();
        $("#move_hold_item_confirm").prop("disabled", true);

        let externalID = $("#external_id").val();
        let apiUrl = `/api/v1/items?external_id=${encodeURIComponent(externalID)}`;

        $.ajax({
            url: apiUrl,
            method: "GET",
            dataType: "json",
            success: function (data) {
                // Filter for exact matches only
                let exactMatches = data.filter(
                    item => item.external_id === externalID
                );
                if (exactMatches.length > 0) {
                    let resultHtml = "";
                    $.each(exactMatches, function (index, item) {
                        resultHtml += `
                            <div class="alert alert-success">
                                <strong>Biblionumber:</strong> ${item.biblio_id} <br>
                                <strong>Item:</strong> ${item.external_id} <br>
                                <input id="new_itemnumber_${item.item_id}" name="new_itemnumber" type="checkbox" value="${item.item_id}">
                                <label for="new_itemnumber_${item.item_id}">${__("Move all selected item level holds to this item")}</label>
                                <input id="new_biblionumber_${item.item_id}" name="new_biblionumber" type="hidden" value="${item.biblio_id}">
                            </div>
                            <hr />
                        `;
                    });
                    $("#itemResultMessage").html(resultHtml);
                } else {
                    $("#itemResultMessage").html(`
                        <div class="alert alert-warning">${__("No item found with barcode: %s").format(externalID)}.</div>
                    `);
                }
            },
        });
    });

    $("#biblioSearchForm").on("submit", function (event) {
        event.preventDefault();
        $("#move_hold_biblio_confirm").prop("disabled", true);

        let biblioID = parseInt($("#biblio_id").val());

        if (Number.isNaN(biblioID)) {
            $("#biblioResultMessage").html(
                '<div class="alert alert-warning">' +
                    __("%s is not a valid biblionumber").format(
                        $("#biblio_id").val()
                    ) +
                    "</div>"
            );
            return;
        }

        let apiUrl = `/api/v1/biblios?q={"biblio_id":"${encodeURIComponent(biblioID)}"}`;
        $.ajax({
            url: apiUrl,
            method: "GET",
            dataType: "json",
            headers: {
                Accept: "application/json",
            },
            success: function (data) {
                // Filter for exact matches only
                let exactMatches = data.filter(
                    item => item.biblio_id === biblioID
                );

                if (exactMatches.length > 0) {
                    let resultHtml = "";
                    $.each(exactMatches, function (index, item) {
                        resultHtml += `
                            <div class="alert alert-success">
                                <strong>Biblionumber:</strong> ${item.biblio_id} <br>
                                <input id="new_biblionumber_${item.biblio_id}" name="new_biblionumber" type="checkbox" value="${item.biblio_id}">
                                <label for="new_biblionumber_${item.biblio_id}">${__("Move all selected record level holds to this record")}</label>
                            </div>
                            <hr />
                        `;
                    });
                    $("#biblioResultMessage").html(resultHtml);
                } else {
                    $("#biblioResultMessage").html(`
                        <div class="alert alert-warning">${__("No record found with biblionumber: %s").format(externalID)}.</div>
                    `);
                }
            },
        });
    });

    $(document).on("change", 'input[name="new_itemnumber"]', function () {
        $('input[name="new_itemnumber"]').not(this).prop("checked", false);
        if ($('input[name="new_itemnumber"]:checked').length) {
            $("#move_hold_item_confirm").prop("disabled", false);
        } else {
            $("#move_hold_item_confirm").prop("disabled", true);
        }
    });

    $(document).on("change", 'input[name="new_biblionumber"]', function () {
        $('input[name="new_biblionumber"]').not(this).prop("checked", false);
        if ($('input[name="new_biblionumber"]:checked').length) {
            $("#move_hold_biblio_confirm").prop("disabled", false);
        } else {
            $("#move_hold_biblio_confirm").prop("disabled", true);
        }
    });

    $(".move_hold_item").click(function (e) {
        e.preventDefault();
        $("#move_hold_item_confirm").prop("disabled", true);
        if ($(".holds_table .select_hold:checked").length) {
            $("#itemResultMessage").empty();
            $("#move_hold_item_selection table tbody").empty();
            $("#moveHoldItemModal").modal("show");
            const selectedHolds =
                JSON.parse(localStorage.selectedHolds) ||
                $(".select_hold:checked");
            $(selectedHolds).each(function () {
                let reserve_id = this.hold || $(this).data("id");
                let reserve_biblionumber =
                    this.biblionumber || $(this).data("biblionumber");
                let reserve_itemnumber =
                    this.itemnumber || $(this).data("itemnumber");
                let item_level_hold =
                    this.item_level_hold || $(this).data("item_level_hold");
                let item_waiting = this.waiting || $(this).data("waiting");
                let item_intransit =
                    this.intransit || $(this).data("intransit");
                let error_message =
                    this.item_level_hold || $(this).data("item_level_hold")
                        ? ""
                        : __(
                              "Cannot move a waiting, in transit, or record level hold"
                          );
                let found_status = $(this).data("found");
                if (item_level_hold && (!item_waiting || !item_intransit)) {
                    $("#move_hold_item_selection table").append(
                        `<tr><td><input type="checkbox" name="move_hold_id" value="${reserve_id}" checked /></td><td>${reserve_id}</td><td>${__("Biblionumber:")} <a target="_blank" href="/cgi-bin/koha/reserve/request.pl?biblionumber=${reserve_biblionumber}">${reserve_biblionumber}</a> ${__("Itemnumber:")} <a target="_blank" href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=${reserve_biblionumber}#item${reserve_itemnumber}">${reserve_itemnumber}</a></td><td>${error_message}</td></tr>`
                    );
                } else {
                    $("#move_hold_item_selection table").append(
                        `<tr><td><input type="checkbox" name="move_hold_id" value="${reserve_id}" disabled /></td><td>${reserve_id}</td><td>Biblionumber: <a target="_blank" href="/cgi-bin/koha/reserve/request.pl?biblionumber=${reserve_biblionumber}">${reserve_biblionumber}</a> ${__("Itemnumber:")} <a target="_blank" href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=${reserve_biblionumber}#item${reserve_itemnumber}">${reserve_itemnumber}</a></td><td>${error_message}</td></tr>`
                    );
                }
            });
        }
    });

    $(".move_hold_biblio").click(function (e) {
        e.preventDefault();
        $("#move_hold_biblio_confirm").prop("disabled", true);
        const selectedHolds =
            JSON.parse(localStorage.selectedHolds || "[]") ||
            $(".select_hold:checked");
        if (selectedHolds.length) {
            $("#biblioResultMessage").empty();
            $("#move_hold_biblio_selection table tbody").empty();
            $("#moveHoldBiblioModal").modal("show");
            $(selectedHolds).each(function () {
                let reserve_id = this.hold || $(this).data("id");
                let reserve_biblionumber =
                    this.biblionumber || $(this).data("biblionumber");
                let reserve_itemnumber =
                    this.itemnumber || $(this).data("itemnumber");
                let item_level_hold =
                    this.item_level_hold || $(this).data("item_level_hold");
                let item_status = this.status || $(this).data("status");
                let item_waiting = this.waiting || $(this).data("waiting");
                let item_intransit =
                    this.intransit || $(this).data("intransit");
                let error_message =
                    this.item_level_hold || $(this).data("item_level_hold")
                        ? __(
                              "Cannot move a waiting, in transit, or item level hold"
                          )
                        : "";
                let found_status = $(this).data("found");
                if (!item_level_hold && (!item_waiting || !item_intransit)) {
                    $("#move_hold_biblio_selection table").append(
                        `<tr><td><input type="checkbox" name="move_hold_id" value="${reserve_id}" checked /><td>${reserve_id}</td><td>${__("Biblionumber:")} <a target="_blank" href="/cgi-bin/koha/reserve/request.pl?biblionumber=${reserve_biblionumber}">${reserve_biblionumber}</a></td><td>${error_message}</td></tr>`
                    );
                } else {
                    $("#move_hold_biblio_selection table").append(
                        `<tr><td><input type="checkbox" name="move_hold_id" value="${reserve_id}" disabled /><td>${reserve_id}</td><td>${__("Biblionumber:")} <a target="_blank" href="/cgi-bin/koha/reserve/request.pl?biblionumber=${reserve_biblionumber}">${reserve_biblionumber}</a></td><td>${error_message}</td></tr>`
                    );
                }
            });
        }
    });

    function _append_patron_page_cancel_hold_modal_data(hold) {
        $("#cancel_modal_form #inputs").append(
            '<input type="hidden" name="rank-request" value="del">'
        );
        $("#cancel_modal_form #inputs").append(
            '<input type="hidden" name="biblionumber" value="' +
                hold.biblionumber +
                '">'
        );
        $("#cancel_modal_form #inputs").append(
            '<input type="hidden" name="borrowernumber" value="' +
                hold.borrowernumber +
                '">'
        );
        $("#cancel_modal_form #inputs").append(
            '<input type="hidden" name="reserve_id" value="' + hold.hold + '">'
        );
    }

    $(".group_selected_holds").click(function (e) {
        if ($(".holds_table .select_hold:checked").length > 1) {
            let selected_holds = get_selected_holds_data();
            const group_ids = JSON.parse(selected_holds)
                .filter(hold => hold.hold_group_id)
                .map(hold => hold.hold_group_id);

            if (group_ids.length > 0) {
                $("#group-modal .modal-body").prepend(
                    '<div class="alert alert-warning">' +
                        __(
                            "Already grouped holds will be moved to the new group"
                        ) +
                        "</div>"
                );
            }

            $("#group-modal").modal("show");
        }
        return false;
    });

    if (holds_table_patron_page()) {
        $("#cancelModalConfirmBtn").click(function (e) {
            e.preventDefault();
            let formInputs = {};
            formInputs["reserve_id"] = $(
                "#cancel_modal_form :input[name='reserve_id']"
            )
                .map(function () {
                    return $(this).val();
                })
                .get();
            formInputs["cancellation-reason"] = $(
                "#cancel_modal_form :input[name='cancellation-reason']"
            ).val();
            cancel_holds(
                formInputs["reserve_id"],
                formInputs["cancellation-reason"]
            )
                .success(function () {
                    holdsTable.api().ajax.reload();
                })
                .fail(function (jqXHR) {
                    $("#cancelModal .modal-body").prepend(
                        '<div class="alert alert-danger">' +
                            jqXHR.responseJSON.error +
                            "</div>"
                    );
                    $("#cancelModalConfirmBtn").prop("disabled", true);
                })
                .done(function () {
                    $("#cancelModal").modal("hide");
                    if ($(".select_hold_all").prop("checked")) {
                        $(".select_hold_all").click();
                    }
                });
        });
    }

    function cancel_holds(hold_ids, cancellation_reason) {
        return $.ajax({
            method: "DELETE",
            url: "/api/v1/holds/cancellation_bulk",
            contentType: "application/json",
            data: JSON.stringify({
                hold_ids: hold_ids,
                cancellation_reason: cancellation_reason,
            }),
        });
    }
    if (holds_table_patron_page()) {
        $("#cancelModal").on("hidden.bs.modal", function () {
            $("#cancelModal .modal-body .alert-danger").remove();
            $("#cancelModalConfirmBtn").prop("disabled", false);
            if (holdsTable) {
                holdsTable.api().ajax.reload();
            }
        });
    }

    $("#group-modal-submit").click(function (e) {
        e.preventDefault();
        let selected_holds = get_selected_holds_data();

        const hold_ids = JSON.parse(selected_holds).map(hold => hold.hold);

        try {
            group_holds(hold_ids)
                .success(function () {
                    holdsTable.api().ajax.reload();
                })
                .fail(function (jqXHR) {
                    $("#group-modal .modal-body").prepend(
                        '<div class="alert alert-danger">' +
                            jqXHR.responseJSON.error +
                            "</div>"
                    );
                    $("#group-modal-submit").prop("disabled", true);
                })
                .done(function () {
                    $("#group-modal").modal("hide");
                    $(".select_hold_all").click();
                });
        } catch (error) {
            if (error.status === 404) {
                alert(__("Unable to group, hold not found."));
            } else {
                alert(
                    __(
                        "Your request could not be processed. Check the logs for details."
                    )
                );
            }
        }
        return false;
    });

    function group_holds(hold_ids) {
        return $.ajax({
            method: "POST",
            url: "/api/v1/patrons/" + borrowernumber + "/hold_groups",
            contentType: "application/json",
            data: JSON.stringify({ hold_ids: hold_ids, force_grouped: true }),
        });
    }

    $("#group-modal").on("hidden.bs.modal", function () {
        $("#group-modal .modal-body .alert-warning").remove();
        $("#group-modal .modal-body .alert-danger").remove();
        $("#group-modal-submit").prop("disabled", false);
    });

    function get_selected_holds_data() {
        return (
            "[" +
            $(".holds_table .select_hold:checked")
                .toArray()
                .map(el =>
                    JSON.stringify({
                        hold: $(el).data("id"),
                        borrowernumber: $(el).data("borrowernumber"),
                        biblionumber: $(el).data("biblionumber"),
                        hold_group_id: $(el).data("hold-group-id"),
                    })
                )
                .join(",") +
            "]"
        );
    }
});

async function load_patron_holds_table(biblio_id, split_data) {
    const { name: split_name, value: split_value } = split_data;
    let table_class = `patron_holds_table_${biblio_id}_${split_value}`;
    const table_id = `#` + table_class;
    let url = `/api/v1/holds/?q={"me.biblio_id":${biblio_id}`;

    if (split_name === "branch" && split_value !== "any") {
        url += `, "me.pickup_library_id":"${split_value}"`;
    } else if (split_name === "itemtype" && split_value !== "any") {
        url += `, "me.itemtype":"${split_value}"`;
    } else if (split_name === "branch_itemtype") {
        const [branch, itemtype] = split_value.split("_");
        url +=
            itemtype === "any"
                ? `, "me.pickup_library_id":"${branch}"`
                : `, "me.pickup_library_id":"${branch}", "me.itemtype":"${itemtype}"`;
    }

    url += "}";
    const totalHolds = $(table_id).data("total-holds");
    const totalHoldsSelect = parseInt(totalHolds) + 1;
    var holdsQueueTable = $(table_id).kohaTable(
        {
            language: {
                infoFiltered: "",
            },
            ajax: {
                url: url,
            },
            embed: ["patron", "item", "item_group", "item_level_holds_count"],
            columnDefs: [
                {
                    targets: [2, 3],
                    className: "dt-body-nowrap",
                },
            ],
            columns: [
                {
                    data: "hold_id",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        return (
                            '<input type="checkbox" class="select_hold ' +
                            table_class +
                            '" data-id="' +
                            data +
                            '" data-borrowernumber="' +
                            row.patron_id +
                            '" data-biblionumber="' +
                            biblio_id +
                            '" data-itemnumber="' +
                            row.item_id +
                            '" data-hold-group-id="' +
                            row.hold_group_id +
                            '" data-item_level_hold="' +
                            row.item_level_holds_count +
                            '" data-waiting="' +
                            (row.status === "W" ? "1" : "") +
                            '" data-intransit="' +
                            (row.status === "T" ? "1" : "") +
                            '" data-status="' +
                            (row.status ? row.status : "") +
                            '"/>'
                        );
                    },
                },
                {
                    data: "priority",
                    orderable: true,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        let select =
                            '<select name="rank-request" class="rank-request ' +
                            table_class +
                            '" data-id="' +
                            row.hold_id;
                        if (
                            CAN_user_reserveforothers_modify_holds_priority &&
                            split_name == "any"
                        ) {
                            for (var i = 0; i < totalHoldsSelect; i++) {
                                let selected;
                                let value;
                                let desc;
                                if (data == i && row.status == "T") {
                                    select += '" disabled="disabled">';
                                    selected = " selected='selected' ";
                                    value = "T";
                                    desc = "In transit";
                                } else if (data == i && row.status == "P") {
                                    select += '" disabled="disabled">';
                                    selected = " selected='selected' ";
                                    value = "P";
                                    desc = "In processing";
                                } else if (data == i && row.status == "W") {
                                    select += '" disabled="disabled">';
                                    selected = " selected='selected' ";
                                    value = "W";
                                    desc = "Waiting";
                                } else if (data == i && !row.status) {
                                    select += '">';
                                    selected = " selected='selected' ";
                                    value = data;
                                    desc = data;
                                } else {
                                    if (i != 0) {
                                        select += '">';
                                        value = i;
                                        desc = i;
                                    } else {
                                        select += '">';
                                    }
                                }
                                if (value) {
                                    select +=
                                        '<option value="' +
                                        value +
                                        '"' +
                                        selected +
                                        ">" +
                                        desc +
                                        "</option>";
                                }
                            }
                        } else {
                            if (row.status == "T") {
                                select +=
                                    '" disabled="disabled"><option value="T" selected="selected">In transit</option></select>';
                            } else if (row.status == "P") {
                                select +=
                                    '" disabled="disabled"><option value="P" selected="selected">In processing</option></select>';
                            } else if (row.status == "W") {
                                select +=
                                    '" disabled="disabled"><option value="W" selected="selected">Waiting</option></select>';
                            } else {
                                if (
                                    HoldsSplitQueue !== "nothing" &&
                                    HoldsSplitQueueNumbering === "virtual"
                                ) {
                                    let virtualPriority =
                                        meta.settings._iDisplayStart +
                                        meta.row +
                                        1;
                                    select +=
                                        '" disabled="disabled"><option value="' +
                                        data +
                                        '" selected="selected">' +
                                        virtualPriority +
                                        "</option></select>";
                                } else {
                                    select +=
                                        '" disabled="disabled"><option value="' +
                                        data +
                                        '" selected="selected">' +
                                        data +
                                        "</option></select>";
                                }
                            }
                        }
                        select += "</select>";
                        return select;
                    },
                },
                {
                    data: "",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        if (row.status || !CAN_user_reserveforothers_modify_holds_priority) {
                            return null;
                        }
                        let buttons =
                            '<a class="hold-arrow move-hold ' +
                            table_class +
                            '" title="Move hold up" href="#" data-move-hold="up" data-priority="' +
                            row.priority +
                            '" reserve_id="' +
                            row.hold_id +
                            '"><i class="fa fa-lg icon-move-hold-up" aria-hidden="true"></i></a>';
                        buttons +=
                            '<a class="hold-arrow move-hold ' +
                            table_class +
                            '" title="Move hold to top" href="#" data-move-hold="top" data-priority="' +
                            row.priority +
                            '" reserve_id="' +
                            row.hold_id +
                            '"><i class="fa fa-lg icon-move-hold-top" aria-hidden="true"></i></a>';
                        buttons +=
                            '<a class="hold-arrow move-hold ' +
                            table_class +
                            '" title="Move hold to bottom" href="#" data-move-hold="bottom" data-priority="' +
                            row.priority +
                            '" reserve_id="' +
                            row.hold_id +
                            '"><i class="fa fa-lg icon-move-hold-bottom" aria-hidden="true"></i></a>';
                        buttons +=
                            '<a class="hold-arrow move-hold ' +
                            table_class +
                            '" title="Move hold down" href="#" data-move-hold="down" data-priority="' +
                            row.priority +
                            '" reserve_id="' +
                            row.hold_id +
                            '"><i class="fa fa-lg icon-move-hold-down" aria-hidden="true"></i></a>';
                        return buttons;
                    },
                },
                {
                    data: "patron.cardnumber",
                    orderable: true,
                    searchable: true,
                    render: function (data, type, row, meta) {
                        if (data == null) {
                            let library = libraries.find(
                                library => library._id == row.pickup_library_id
                            );
                            return __("A patron from library %s").format(
                                library.name
                            );
                        } else {
                            return (
                                '<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=' +
                                row.patron.patron_id +
                                '">' +
                                data +
                                "</a>"
                            );
                        }
                    },
                },
                {
                    data: "notes",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        return data;
                    },
                },
                {
                    data: "hold_date",
                    orderable: true,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        if (AllowHoldDateInFuture) {
                            return (
                                '<input type="text" class="holddate ' +
                                table_class +
                                '" value="' +
                                $date(data, { dateformat: "rfc3339" }) +
                                '" size="10" name="hold_date" data-id="' +
                                row.hold_id +
                                '" data-current-date="' +
                                data +
                                '"/>'
                            );
                        } else {
                            return $date(data);
                        }
                    },
                },
                {
                    data: "expiration_date",
                    orderable: true,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        return (
                            '<input type="text" class="expirationdate ' +
                            table_class +
                            '" value="' +
                            $date(data, { dateformat: "rfc3339" }) +
                            '" size="10" name="expiration_date" data-id="' +
                            row.hold_id +
                            '" data-current-date="' +
                            data +
                            '"/>'
                        );
                    },
                },
                {
                    data: "pickup_library_id",
                    orderable: true,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        var branchSelect =
                            "<select priority=" +
                            row.priority +
                            ' class="hold_location_select ' +
                            table_class +
                            '" data-id="' +
                            row.hold_id +
                            '" reserve_id="' +
                            row.hold_id +
                            '" name="pick-location" data-pickup-location-source="hold">';
                        var libraryname;
                        for (var i = 0; i < libraries.length; i++) {
                            var selectedbranch;
                            var setbranch;
                            if (libraries[i]._id == data) {
                                selectedbranch = " selected='selected' ";
                                setbranch = __(" (current) ");
                                libraryname = libraries[i]._str;
                            } else if (libraries[i].pickup_location == false) {
                                continue;
                            } else {
                                selectedbranch = "";
                                setbranch = "";
                            }
                            branchSelect +=
                                '<option value="' +
                                libraries[i]._id.escapeHtml() +
                                '"' +
                                selectedbranch +
                                ">" +
                                libraries[i]._str.escapeHtml() +
                                setbranch +
                                "</option>";
                        }
                        branchSelect += "</select>";
                        if (row.status == "T") {
                            return __(
                                "Item being transferred to <strong>%s</strong>"
                            ).format(libraryname);
                        } else if (row.status == "P") {
                            return __(
                                "Item being processed at <strong>%s</strong>"
                            ).format(libraryname);
                        } else if (row.status == "W") {
                            return __(
                                "Item waiting at <strong>%s</strong> since %s"
                            ).format(libraryname, $date(row.waiting_date));
                        } else {
                            return branchSelect;
                        }
                    },
                },
                {
                    data: "",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        const group_hold_message = row.hold_group_id
                            ? `<div>(${__("part of")} <a href="/cgi-bin/koha/reserve/hold-group.pl?hold_group_id=${row.hold_group_id}" class="hold-group">${__("hold group")}</a>)</div>`
                            : "";

                        // Handle status cases
                        if (row.status) {
                            return `<a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=${row.biblio_id}&itemnumber=${row.item_id}">${row.item.external_id}</a>${group_hold_message}`;
                        }

                        // Handle item level holds
                        if (row.item_level) {
                            const barcode =
                                row.item.external_id || __("No barcode");
                            const itemLink = `<a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=${row.biblio_id}&itemnumber=${row.item_id}">${barcode.escapeHtml ? barcode.escapeHtml() : barcode}</a>`;

                            if (row.item_level_holds_count >= 2) {
                                return `${__("Only item")} ${itemLink}${group_hold_message}`;
                            }

                            return `<select id="change_hold_type" class="change_hold_type ${table_class}" data-id="${row.hold_id}">
                                <option value="" selected>${__("Only item")} ${barcode}</option>
                                <option value="">${__("Next available")}</option>
                            </select>${group_hold_message}`;
                        }

                        // Handle item group
                        if (row.item_group_id) {
                            return (
                                __(
                                    "Next available item from group <strong>%s</strong>"
                                ).format(row.item_group.description) +
                                group_hold_message
                            );
                        }

                        // Default: Next available
                        let message = __("Next available");
                        if (row.non_priority) {
                            message += `<br/><i>${__("Non priority hold")}</i>`;
                        }
                        return message + group_hold_message;
                    },
                },
                {
                    data: "",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        if (row.status || !CAN_user_reserveforothers_modify_holds_priority) {
                            return null;
                        } else {
                            if (row.lowest_priority) {
                                return (
                                    '<a class="hold-arrow toggle-lowest-priority ' +
                                    table_class +
                                    '" title="Remove lowest priority" href="#" data-op="cud-setLowestPriority" data-borrowernumber="' +
                                    row.patron_id +
                                    '" data-biblionumber="' +
                                    biblio_id +
                                    '" data-reserve_id="' +
                                    row.hold_id +
                                    '" data-date="' +
                                    row.hold_date +
                                    '"><i class="fa fa-lg fa-rotate-90 icon-unset-lowest" aria-hidden="true"></i></a>'
                                );
                            } else {
                                return (
                                    '<a class="hold-arrow toggle-lowest-priority ' +
                                    table_class +
                                    '" title="Set lowest priority" href="#" data-op="cud-setLowestPriority" data-borrowernumber="' +
                                    row.patron_id +
                                    '" data-biblionumber="' +
                                    biblio_id +
                                    '" data-reserve_id="' +
                                    row.hold_id +
                                    '" data-date="' +
                                    row.hold_date +
                                    '"><i class="fa fa-lg fa-rotate-90 icon-set-lowest" aria-hidden="true"></i></a>'
                                );
                            }
                        }
                    },
                },
                {
                    data: "hold_id",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        return (
                            '<a class="cancel-hold deny ' +
                            table_class +
                            '" title="Cancel hold" data-id="' +
                            data +
                            '" data-biblionumber="' +
                            biblio_id +
                            '" data-borrowernumber="' +
                            row.patron_id +
                            '" href="#"><i class="fa fa-trash" aria-label="Cancel hold"></i></a>'
                        );
                    },
                },
                {
                    data: "hold_id",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        if (row.status) {
                            var link_value =
                                row.status == "T"
                                    ? __("Revert transit status")
                                    : __("Revert waiting status");
                            return (
                                '<a class="btn btn-default submit-form-link" href="#" id="revert_hold_' +
                                data +
                                '" data-op="cud-move" data-where="down" data-first_priority="1" data-last_priority="' +
                                totalHolds +
                                '" data-prev_priority="0" data-next_priority="1" data-borrowernumber="' +
                                row.patron_id +
                                '" data-biblionumber="' +
                                biblio_id +
                                '" data-itemnumber="' +
                                row.item_id +
                                '" data-reserve_id="' +
                                row.hold_id +
                                '" data-date="' +
                                row.hold_date +
                                '" data-action="request.pl" data-method="post">' +
                                link_value +
                                "</a>"
                            );
                        } else {
                            let td = "";
                            if (SuspendHoldsIntranet) {
                                td +=
                                    '<button class="btn btn-default btn-xs toggle-suspend ' +
                                    table_class +
                                    '" data-id="' +
                                    data +
                                    '" data-biblionumber="' +
                                    biblio_id +
                                    '" data-suspended="' +
                                    row.suspended +
                                    '">';
                                if (row.suspended) {
                                    td +=
                                        '<i class="fa fa-play" aria-hidden="true"></i> ' +
                                        __("Unsuspend") +
                                        "</button>";
                                } else {
                                    td +=
                                        '<i class="fa fa-pause" aria-hidden="true"></i> ' +
                                        __("Suspend") +
                                        "</button>";
                                }
                                if (AutoResumeSuspendedHolds) {
                                    if (row.suspended) {
                                        td +=
                                            '<label for="suspend_until_' +
                                            data +
                                            '">' +
                                            __("Suspend on") +
                                            " </label>";
                                    } else {
                                        td +=
                                            '<label for="suspend_until_' +
                                            data +
                                            '">' +
                                            __("Suspend until") +
                                            " </label>";
                                    }
                                    td +=
                                        '<input type="text" name="suspend_until_' +
                                        data +
                                        '" data-id="' +
                                        data +
                                        '" size="10" value="' +
                                        $date(row.suspended_until, {
                                            dateformat: "rfc3339",
                                        }) +
                                        '" class="suspenddate ' +
                                        table_class +
                                        '" data-flatpickr-futuredate="true" data-suspend-date="' +
                                        row.suspended_until +
                                        '" />';
                                }
                                return td;
                            } else {
                                return null;
                            }
                        }
                    },
                },
                {
                    data: "hold_id",
                    orderable: false,
                    searchable: false,
                    render: function (data, type, row, meta) {
                        if (row.status == "W" || row.status == "T") {
                            return (
                                '<a class="btn btn-default btn-xs printholdslip ' +
                                table_class +
                                '" data-reserve_id="' +
                                data +
                                '">' +
                                __("Print slip") +
                                "</a>"
                            );
                        } else {
                            return "";
                        }
                    },
                },
            ],
        },
        hold_table_settings
    );
    holdsQueueTable.api().page(0).draw(false);
    // Clear selectedHolds on page load
    localStorage.removeItem("selectedHolds");
    $(table_id).on("draw.dt", function () {
        function updateMSGCounters() {
            var MSG_CANCEL_SELECTED = __("Cancel selected (%s)");
            var MSG_MOVE_SELECTED = __("Move selected (%s)");
            var MSG_CANCEL_ALERT = __(
                "This action will cancel <span class='badge bg-danger'>%s</span> hold(s)."
            );
            var selectedCount = JSON.parse(
                localStorage.selectedHolds || "[]"
            ).length;
            $(".cancel_selected_holds").html(
                MSG_CANCEL_SELECTED.format(selectedCount)
            );
            $(".move_selected_holds").html(
                MSG_MOVE_SELECTED.format(selectedCount)
            );
            $("#cancel_hold_alert").html(
                MSG_CANCEL_ALERT.format(selectedCount)
            );
            if (selectedCount > 0) {
                $("#cancel_hold_alert").show();
            } else {
                $("#cancel_hold_alert").hide();
            }
        }

        function updateMoveButtons() {
            var checked_holds = JSON.parse(localStorage.selectedHolds || "[]");
            var checked_count = checked_holds.length;

            var item_level_count = checked_holds.filter(function (hold) {
                return hold.item_level_hold > 0;
            }).length;

            var record_level_count = checked_holds.filter(function (hold) {
                return hold.item_level_hold === 0;
            }).length;

            $(".move_hold_item").toggleClass("disabled", item_level_count <= 0);
            $(".move_hold_biblio").toggleClass(
                "disabled",
                record_level_count <= 0
            );
            $(".move_selected_holds").prop("disabled", !checked_count);
        }

        // Always deselect the "select all" checkbox when the page changes
        $(".holds_table .select_hold_all").prop("checked", false);
        updateMSGCounters();
        $(".holds_table .select_hold." + table_class).each(function () {
            const selected = JSON.parse(localStorage.selectedHolds || "[]");
            const holdId = $(this).data("id");
            if (selected.some(s => s.hold === holdId)) {
                $(this).prop("checked", true);
                $(this).parent().parent().addClass("selected");
                var table = $(this).closest(".holds_table");
                var count = $(
                    ".select_hold." + table_class + ":not(:checked)",
                    table
                ).length;
                $(".select_hold_all." + table_class, table).prop(
                    "checked",
                    !count
                );
            }
        });
        $(".holds_table .select_hold_all").on("click", function () {
            var table = $(this).closest(".holds_table");
            var isChecked = $(this).prop("checked");
            var allCheckboxes = table
                .DataTable()
                .rows({ search: "applied" })
                .nodes();
            let selected = JSON.parse(localStorage.selectedHolds || "[]");
            let pageHolds = [];

            $("input.select_hold", allCheckboxes).each(function () {
                let hold_data = {
                    hold: $(this).data("id"),
                    borrowernumber: $(this).data("borrowernumber"),
                    biblionumber: $(this).data("biblionumber"),
                    itemnumber: $(this).data("itemnumber"),
                    waiting: $(this).data("waiting"),
                    intransit: $(this).data("intransit"),
                    status: $(this).data("status"),
                    item_level_hold: $(this).data("item_level_hold"),
                    hold_group_id: $(this).data("hold-group-id"),
                };
                pageHolds.push(hold_data);
            });

            if (isChecked) {
                // Add all page holds to the selection, avoiding duplicates
                pageHolds.forEach(hold => {
                    if (!selected.some(s => s.hold === hold.hold)) {
                        selected.push(hold);
                    }
                });
                $("input.select_hold", allCheckboxes).prop("checked", true);
                $("input.select_hold", allCheckboxes).each(function () {
                    $(this).parent().parent().addClass("selected");
                });
            } else {
                // Remove all page holds from the selection
                const pageIds = pageHolds.map(h => h.hold);
                selected = selected.filter(s => !pageIds.includes(s.hold));
                $("input.select_hold", allCheckboxes).prop("checked", false);
                $("input.select_hold", allCheckboxes).each(function () {
                    $(this).parent().parent().removeClass("selected");
                });
            }

            localStorage.selectedHolds = JSON.stringify(selected);
            updateMoveButtons();
            updateMSGCounters();
        });
        $(".holds_table .select_hold").on("click", function () {
            let selected = JSON.parse(localStorage.selectedHolds || "[]");
            const hold_data = {
                hold: $(this).data("id"),
                borrowernumber: $(this).data("borrowernumber"),
                biblionumber: $(this).data("biblionumber"),
                itemnumber: $(this).data("itemnumber"),
                waiting: $(this).data("waiting"),
                intransit: $(this).data("intransit"),
                status: $(this).data("status"),
                item_level_hold: $(this).data("item_level_hold"),
                hold_group_id: $(this).data("hold-group-id"),
            };
            if ($(this).is(":checked")) {
                if (!selected.some(s => s.hold === hold_data.hold)) {
                    selected.push(hold_data);
                }
            } else {
                selected = selected.filter(s => s.hold !== hold_data.hold);
            }
            localStorage.selectedHolds = JSON.stringify(selected);
            updateMoveButtons();
            updateMSGCounters();
            var table = $(this).parents(".holds_table");
            var count = $(".select_hold:not(:checked)", table).length;
            $(".select_hold_all", table).prop("checked", !count);
            $(this).parent().parent().toggleClass("selected");
        });
        $(".cancel-hold." + table_class).on("click", function (e) {
            e.preventDefault;
            cancel_link = $(this);
            $("#cancel_modal_form #inputs").empty();
            let reserve_id = cancel_link.data("id");
            let biblionumber = cancel_link.data("biblionumber");
            _append_patron_page_cancel_hold_modal_data({
                hold: reserve_id,
                biblionumber: biblionumber,
                borrowernumber: cancel_link.data("borrowernumber"),
            });
            $("#cancelModal").modal("show");
        });
        $(".cancel_selected_holds").click(function (e) {
            e.preventDefault();
            const selectedHolds = JSON.parse(
                localStorage.selectedHolds || "[]"
            );
            if (selectedHolds.length) {
                $("#cancel_modal_form #inputs").empty();

                selectedHolds.forEach(function (hold) {
                    _append_patron_page_cancel_hold_modal_data(hold);
                });

                //delete localStorage.selectedHolds;
                $("#cancelModal").modal("show");
            }
            return false;
        });
        function _append_patron_page_cancel_hold_modal_data(hold) {
            $("#cancel_modal_form #inputs").append(
                '<input type="hidden" name="rank-request" value="del">'
            );
            $("#cancel_modal_form #inputs").append(
                '<input type="hidden" name="biblionumber" value="' +
                    hold.biblionumber +
                    '">'
            );
            $("#cancel_modal_form #inputs").append(
                '<input type="hidden" name="borrowernumber" value="' +
                    hold.borrowernumber +
                    '">'
            );
            $("#cancel_modal_form #inputs").append(
                '<input type="hidden" name="reserve_id" value="' +
                    hold.hold +
                    '">'
            );
        }
        // Remove any previously attached handlers
        $("#cancelModalConfirmBtn").off("click");
        // Attach the handler to the button
        $("#cancelModalConfirmBtn").one("click", function (e) {
            e.preventDefault();
            let formInputs = {};
            formInputs["reserve_id"] = $(
                "#cancel_modal_form :input[name='reserve_id']"
            )
                .map(function () {
                    return $(this).val();
                })
                .get();
            formInputs["cancellation-reason"] = $(
                "#cancel_modal_form :input[name='cancellation-reason']"
            ).val();
            cancel_holds(
                formInputs["reserve_id"],
                formInputs["cancellation-reason"]
            )
                .success(function () {
                    holdsQueueTable.api().ajax.reload(null, false);
                })
                .fail(function (jqXHR) {
                    $("#cancelModal .modal-body").prepend(
                        '<div class="alert alert-danger">' +
                            jqXHR.responseJSON.error +
                            "</div>"
                    );
                    $("#cancelModalConfirmBtn").prop("disabled", true);
                })
                .done(function () {
                    $("#cancelModal").modal("hide");
                    if ($(".select_hold_all").prop("checked")) {
                        $(".select_hold_all").click();
                    }
                });
        });
        function cancel_holds(hold_ids, cancellation_reason) {
            return $.ajax({
                method: "DELETE",
                url: "/api/v1/holds/cancellation_bulk",
                contentType: "application/json",
                data: JSON.stringify({
                    hold_ids: hold_ids,
                    cancellation_reason: cancellation_reason,
                }),
            });
        }
        $(
            ".holddate." + table_class + ", .expirationdate." + table_class
        ).flatpickr({
            onReady: function (selectedDates, dateStr, instance) {
                $(instance.altInput)
                    .wrap("<span class='flatpickr_wrapper'></span>")
                    .after(
                        $("<a/>")
                            .attr("href", "#")
                            .addClass("clear_date")
                            .addClass("fa fa-times")
                            .addClass("ps-2")
                            .on("click", function (e) {
                                e.preventDefault();
                                instance.clear();
                            })
                            .attr("aria-hidden", true)
                    );
            },
            onChange: function (selectedDates, dateStr, instance) {
                let hold_id = $(instance.input).attr("data-id");
                let fieldname = $(instance.input).attr("name");
                let current_date = $(instance.input).attr("data-current-date");
                dateStr = dateStr ? dateStr : null;
                let req =
                    fieldname == "hold_date"
                        ? { hold_date: dateStr }
                        : { expiration_date: dateStr };
                if (current_date != dateStr) {
                    $.ajax({
                        method: "PATCH",
                        url: "/api/v1/holds/" + encodeURIComponent(hold_id),
                        contentType: "application/json",
                        data: JSON.stringify(req),
                        success: function (data) {
                            holdsQueueTable.api().ajax.reload(null, false);
                            $(instance.input).attr(
                                "data-current-date",
                                dateStr
                            );
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            holdsQueueTable.api().ajax.reload(null, false);
                        },
                    });
                }
            },
        });
        $(".suspenddate." + table_class).flatpickr({
            onReady: function (selectedDates, dateStr, instance) {
                $(instance.altInput)
                    .wrap("<span class='flatpickr_wrapper'></span>")
                    .after(
                        $("<a/>")
                            .attr("href", "#")
                            .addClass("clear_date")
                            .addClass("fa fa-times")
                            .addClass("ps-2")
                            .on("click", function (e) {
                                e.preventDefault();
                                instance.clear();
                            })
                            .attr("aria-hidden", true)
                    );
            },
            onChange: function (selectedDates, dateStr, instance) {
                let hold_id = $(instance.input).attr("data-id");
                let current_date = $(instance.input).attr("data-suspend-date");
                dateStr = dateStr ? dateStr : null;
                if (current_date != dateStr) {
                    let params =
                        dateStr !== null && dateStr !== ""
                            ? JSON.stringify({ end_date: dateStr })
                            : null;
                    $.ajax({
                        method: "POST",
                        url:
                            "/api/v1/holds/" +
                            encodeURIComponent(hold_id) +
                            "/suspension",
                        contentType: "application/json",
                        data: params,
                        success: function (data) {
                            holdsQueueTable.api().ajax.reload(null, false);
                            $(instance.input).attr(
                                "data-suspend-date",
                                dateStr
                            );
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            holdsQueueTable.api().ajax.reload(null, false);
                        },
                    });
                }
            },
        });
        $(".toggle-suspend." + table_class).one("click", function (e) {
            e.preventDefault();
            const hold_id = $(this).data("id");
            const suspended = $(this).attr("data-suspended");
            const input = $(
                `.suspenddate.` + table_class + `[data-id="${hold_id}"]`
            );
            const method = suspended == "true" ? "DELETE" : "POST";
            let end_date = input.val() && method == "POST" ? input.val() : null;
            let params =
                end_date !== null && end_date !== ""
                    ? JSON.stringify({ end_date: end_date })
                    : null;
            $.ajax({
                method: method,
                url:
                    "/api/v1/holds/" +
                    encodeURIComponent(hold_id) +
                    "/suspension",
                contentType: "application/json",
                data: params,
                success: function (data) {
                    holdsQueueTable.api().ajax.reload(null, false);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    holdsQueueTable.api().ajax.reload(null, false);
                    alert(
                        "There was an error:" + textStatus + " " + errorThrown
                    );
                },
            });
        });
        $(".rank-request." + table_class).on("change", function (e) {
            e.preventDefault();
            const hold_id = $(this).data("id");
            let priority = e.target.value;
            // Replace select with spinner
            const $select = $(this);
            const $spinner = $(
                '<img class="rank-spinner" src="/intranet-tmpl/prog/img/spinner-small.gif" alt="Loading..." style="display:block;margin:0 auto;vertical-align:middle;">'
            );
            $select.hide().after($spinner);
            $.ajax({
                method: "PUT",
                url:
                    "/api/v1/holds/" +
                    encodeURIComponent(hold_id) +
                    "/priority",
                data: JSON.stringify(priority),
                success: function (data) {
                    holdsQueueTable.api().ajax.reload(null, false);
                    $spinner.remove();
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    alert(
                        "There was an error:" + textStatus + " " + errorThrown
                    );
                    $select.show();
                    $spinner.remove();
                },
            });
        });
        $(".move-hold." + table_class).one("click", function (e) {
            e.preventDefault();
            let toPosition = $(this).attr("data-move-hold");
            let priority = $(this).attr("data-priority");
            var res_id = $(this).attr("reserve_id");
            var moveTo;
            const $spinner = $(
                '<img class="rank-spinner" src="/intranet-tmpl/prog/img/spinner-small.gif" alt="Loading..." style="display:block;margin:0 auto;vertical-align:middle;">'
            );
            if (toPosition == "up") {
                moveTo = parseInt(priority) - 1;
            }
            if (toPosition == "down") {
                moveTo = parseInt(priority) + 1;
            }
            if (toPosition == "top") {
                moveTo = 1;
            }
            if (toPosition == "bottom") {
                moveTo = totalHolds;
            }
            $(this).parent().html($spinner);
            $.ajax({
                method: "PUT",
                url:
                    "/api/v1/holds/" + encodeURIComponent(res_id) + "/priority",
                data: JSON.stringify(moveTo),
                success: function (data) {
                    $spinner.remove();
                    holdsQueueTable.api().ajax.reload(null, false);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $spinner.remove();
                    alert(
                        "There was an error:" + textStatus + " " + errorThrown
                    );
                },
            });
        });
        $(".toggle-lowest-priority." + table_class).one("click", function (e) {
            e.preventDefault();
            var res_id = $(this).attr("data-reserve_id");
            $.ajax({
                method: "PUT",
                url:
                    "/api/v1/holds/" +
                    encodeURIComponent(res_id) +
                    "/lowest_priority",
                success: function (data) {
                    holdsQueueTable.api().ajax.reload(null, false);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    alert(
                        "There was an error:" + textStatus + " " + errorThrown
                    );
                },
            });
        });
        $(".hold_location_select." + table_class).on("change", function () {
            $(this).prop("disabled", true);
            var cur_select = $(this);
            var res_id = $(this).attr("reserve_id");
            $(this).after(
                '<div id="updating_reserveno' +
                    res_id +
                    '" class="waiting"><img src="/intranet-tmpl/prog/img/spinner-small.gif" alt="" /><span class="waiting_msg"></span></div>'
            );
            let api_url =
                "/api/v1/holds/" +
                encodeURIComponent(res_id) +
                "/pickup_location";
            $.ajax({
                method: "PUT",
                url: api_url,
                data: JSON.stringify({ pickup_library_id: $(this).val() }),
                headers: { "x-koha-override": "any" },
                success: function (data) {
                    holdsQueueTable.api().ajax.reload(null, false);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    alert(
                        "There was an error:" + textStatus + " " + errorThrown
                    );
                    cur_select.prop("disabled", false);
                    $("#updating_reserveno" + res_id).remove();
                    cur_select.val(
                        cur_select.children('option[selected="selected"]').val()
                    );
                },
            });
        });
        $(".change_hold_type." + table_class).on("change", function () {
            $(this).prop("disabled", true);
            var cur_select = $(this);
            var hold_id = $(this).attr("data-id");
            $(this).after(
                '<div id="updating_holdno' +
                    hold_id +
                    '" class="waiting"><img src="/intranet-tmpl/prog/img/spinner-small.gif" alt="" /><span class="waiting_msg"></span></div>'
            );
            let api_url = "/api/v1/holds/" + encodeURIComponent(hold_id);
            $.ajax({
                method: "PATCH",
                url: api_url,
                data: JSON.stringify({ item_id: null, item_level: false }),
                headers: { "x-koha-override": "any" },
                contentType: "application/json",
                success: function (data) {
                    holdsQueueTable.api().ajax.reload(null, false);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    alert(
                        "There was an error:" + textStatus + " " + errorThrown
                    );
                    cur_select.prop("disabled", false);
                    $("#updating_holdno" + hold_id).remove();
                    cur_select.val(
                        cur_select.children('option[selected="selected"]').val()
                    );
                },
            });
        });
        $(".printholdslip." + table_class).one("click", function () {
            var reserve_id = $(this).attr("data-reserve_id");
            window.open(
                "/cgi-bin/koha/circ/hold-transfer-slip.pl?reserve_id=" +
                    reserve_id
            );
            return false;
        });
        updateMSGCounters();
    });
}
