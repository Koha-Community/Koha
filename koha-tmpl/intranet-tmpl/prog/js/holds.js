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

    if (!patron_page) {
        $(".holds_table .select_hold_all").each(function () {
            var table = $(this).parents(".holds_table");
            var count = $(".select_hold:not(:checked)", table).length;
            $(".select_hold_all", table).prop("checked", !count);
        });
    }

    function updateSelectedHoldsButtonCounters() {
        $(".move_selected_holds").html(
            MSG_MOVE_SELECTED.format(
                $(".holds_table .select_hold:checked").length
            )
        );
        $(".selected_holds_count").html(
            $(".holds_table .select_hold:checked").length
        );
        if (patron_page) {
            var selectedHolds = $(".holds_table .select_hold:checked");
            var hasSelectedHolds = selectedHolds.length > 0;
            var hasMultipleSelectedHolds = selectedHolds.length >= 2;

            $(".cancel_selected_holds, .suspend_selected_holds").prop(
                "disabled",
                !hasSelectedHolds
            );
            $(".group_selected_holds").prop(
                "disabled",
                !hasMultipleSelectedHolds
            );
        }
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

    updateSelectedHoldsButtonCounters();

    $(".holds_table .select_hold_all").click(function () {
        var table;
        if (!patron_page) {
            table = $(this).parents(".holds_table");
        } else {
            table = $(".holds_table:not(.fixedHeader-floating)");
        }

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
            if (!patron_page) {
                biblionumbers.forEach(function (biblionumber) {
                    $("#cancel_modal_form #inputs").append(
                        '<input type="hidden" name="biblionumber" value="' +
                            biblionumber +
                            '">'
                    );
                });
                $("#cancel_modal_form #inputs").append(
                    '<input type="hidden" name="op" value="cud-cancel_bulk">'
                );
                let hold_ids = $(".holds_table .select_hold:checked")
                    .toArray()
                    .map(el => $(el).data("id"))
                    .join(",");
                $("#cancel_modal_form #inputs").append(
                    '<input type="hidden" name="ids" value="' + hold_ids + '">'
                );
            } else {
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
            }

            delete localStorage.selectedHolds;
            $("#cancelModal").modal("show");
        }
        return false;
    });

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
            $(".select_hold:checked").each(function () {
                let reserve_id = $(this).data("id");
                let reserve_biblionumber = $(this).data("biblionumber");
                let reserve_itemnumber = $(this).data("itemnumber");
                let item_level_hold = $(this).data("item_level_hold");
                let item_waiting = $(this).data("waiting");
                let item_intransit = $(this).data("intransit");
                let error_message = $(this).data("item_level_hold")
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
        if ($(".holds_table .select_hold:checked").length) {
            $("#biblioResultMessage").empty();
            $("#move_hold_biblio_selection table tbody").empty();
            $("#moveHoldBiblioModal").modal("show");
            $(".select_hold:checked").each(function () {
                let reserve_id = $(this).data("id");
                let reserve_biblionumber = $(this).data("biblionumber");
                let reserve_itemnumber = $(this).data("itemnumber");
                let item_level_hold = $(this).data("item_level_hold");
                let item_status = $(this).data("status");
                let item_waiting = $(this).data("waiting");
                let item_intransit = $(this).data("intransit");
                let error_message = $(this).data("item_level_hold")
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
