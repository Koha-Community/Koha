/* global __ */

function CheckRenewCheckinBoxes() {
    $("#RenewChecked").prop("disabled", !$(".renew:checked").length);
    $("#CheckinChecked").prop("disabled", !$(".checkin:checked").length);
}

function RefreshIssuesTable() {
    var table = $("#issues-table").DataTable();
    var renewchecked = $("input[name=renew]:checked")
        .map(function () {
            return this.value;
        })
        .get();
    var checkinchecked = $("input[name=checkin]:checked")
        .map(function () {
            return this.value;
        })
        .get();
    table.ajax.reload(function () {
        var checkout_count = table.page.info().recordsTotal;
        $(".checkout_count").text(checkout_count);
        renewchecked.forEach(function (item) {
            $('.renew[value="' + item + '"]').prop("checked", true);
        });

        checkinchecked.forEach(function (item) {
            $('.checkin[value="' + item + '"]').prop("checked", true);
        });
        CheckRenewCheckinBoxes();
    });
}

function LoadIssuesTable() {
    $("#issues-table-loading-message").hide();
    $("#issues-table").show();
    $("#issues-table-actions").show();
    var msg_loading = __("Loading... you may continue scanning.");
    if (!AllowCirculate) {
        table_settings_issues_table.columns.find(
            c => c.columnname == "renew"
        ).is_hidden = 42;
        table_settings_issues_table.columns.find(
            c => c.columnname == "checkin"
        ).is_hidden = 1;
    }
    if (!ClaimReturnedLostValue) {
        table_settings_issues_table.columns.find(
            c => c.columnname == "claims_returned"
        ).is_hidden = 1;
    }
    if (!exports_enabled) {
        table_settings_issues_table.columns.find(
            c => c.columnname == "export"
        ).is_hidden = 1;
    }
    issuesTable = $("#issues-table").kohaTable(
        {
            language: {
                emptyTable: msg_loading,
                processing: msg_loading,
            },
            autoWidth: false,
            dom: '<"table_controls"B>rt',
            columns: [
                {
                    data: function (oObj) {
                        return oObj.sort_order;
                    },
                },
                {
                    data: function (oObj) {
                        if (oObj.issued_today) {
                            return (
                                "<strong>" +
                                __("Today's checkouts") +
                                "</strong>"
                            );
                        } else {
                            return (
                                "<strong>" +
                                __("Previous checkouts") +
                                "</strong>"
                            );
                        }
                    },
                },
                {
                    data: "date_due",
                    visible: false,
                },
                {
                    orderData: 2, // Sort on hidden unformatted date due column
                    data: function (oObj) {
                        let date_due_formatted = $datetime(oObj.date_due, {
                            as_due_date: true,
                            no_tz_adjust: true,
                        });
                        var due = oObj.date_due_overdue
                            ? "<span class='overdue'>" +
                              date_due_formatted +
                              "</span>"
                            : oObj.date_due_today
                              ? "<span class='strong'>" +
                                date_due_formatted +
                                "</span>"
                              : date_due_formatted;

                        due =
                            "<span id='date_due_" +
                            oObj.itemnumber +
                            "' class='date_due'>" +
                            due +
                            "</span>";

                        if (oObj.lost && oObj.claims_returned) {
                            due +=
                                "<span class='lost claims_returned'>" +
                                oObj.lost.escapeHtml() +
                                "</span>";
                        } else if (oObj.lost) {
                            due +=
                                "<span class='lost'>" +
                                oObj.lost.escapeHtml() +
                                "</span>";
                        }

                        if (oObj.damaged) {
                            due +=
                                "<span class='dmg'>" +
                                oObj.damaged.escapeHtml() +
                                "</span>";
                        }

                        var patron_note =
                            " <span class='patron_note_" +
                            oObj.itemnumber +
                            "'></span>";
                        due += "<br>" + patron_note;

                        return due;
                    },
                },
                {
                    data: function (oObj) {
                        let title =
                            "<span id='title_" +
                            oObj.itemnumber +
                            "' class='strong'><a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
                            oObj.biblionumber +
                            "'>" +
                            (oObj.title ? oObj.title.escapeHtml() : "");
                        var ymd = flatpickr.formatDate(new Date(), "Y-m-d");

                        $.each(oObj.subtitle, function (index, value) {
                            title += " " + value.escapeHtml();
                        });

                        title += " " + oObj.part_number + " " + oObj.part_name;

                        if (oObj.enumchron) {
                            title +=
                                " <span class='item_enumeration'>(" +
                                oObj.enumchron.escapeHtml() +
                                ")</span>";
                        }

                        title += "</a></span>";

                        if (oObj.author) {
                            title +=
                                " " +
                                __("by _AUTHOR_").replace(
                                    "_AUTHOR_",
                                    " " + oObj.author.escapeHtml()
                                );
                        }

                        if (oObj.itemnotes) {
                            var span_class = "text-muted";
                            if (
                                flatpickr.formatDate(
                                    new Date(oObj.issuedate),
                                    "Y-m-d"
                                ) == ymd
                            ) {
                                span_class = "circ-hlt";
                            }
                            title +=
                                "<span class='divider-dash'> - </span><span class='" +
                                span_class +
                                " item-note-public'>" +
                                oObj.itemnotes.escapeHtml() +
                                "</span>";
                        }

                        if (oObj.itemnotes_nonpublic) {
                            var span_class = "text-danger";
                            if (
                                flatpickr.formatDate(
                                    new Date(oObj.issuedate),
                                    "Y-m-d"
                                ) == ymd
                            ) {
                                span_class = "circ-hlt";
                            }
                            title +=
                                "<span class='divider-dash'> - </span><span class='" +
                                span_class +
                                " item-note-nonpublic'>" +
                                oObj.itemnotes_nonpublic.escapeHtml() +
                                "</span>";
                        }

                        var onsite_checkout = "";
                        if (oObj.onsite_checkout == 1) {
                            onsite_checkout +=
                                " <span class='onsite_checkout'>(" +
                                __("On-site checkout") +
                                ")</span>";
                        }

                        if (oObj.recalled == 1) {
                            title +=
                                "<span class='divider-dash'> - </span><span class='circ-hlt item-recalled'>" +
                                __(
                                    "This item has been recalled and the due date updated"
                                ) +
                                ".</span>";
                        }

                        title +=
                            " " +
                            "<a href='/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=" +
                            oObj.biblionumber +
                            "&itemnumber=" +
                            oObj.itemnumber +
                            "#" +
                            oObj.itemnumber +
                            "'>" +
                            (oObj.barcode ? oObj.barcode.escapeHtml() : "") +
                            "</a>" +
                            onsite_checkout;

                        return title;
                    },
                    type: "anti-the",
                    orderData: [1, 4],
                },
                {
                    data: function (oObj) {
                        return oObj.recordtype_description.escapeHtml();
                    },
                    orderData: [1, 5],
                },
                {
                    data: function (oObj) {
                        return oObj.itemtype_description.escapeHtml();
                    },
                    orderData: [1, 6],
                },
                {
                    data: function (oObj) {
                        return oObj.collection
                            ? oObj.collection.escapeHtml()
                            : "";
                    },
                    orderData: [1, 7],
                },
                {
                    data: function (oObj) {
                        return oObj.location ? oObj.location.escapeHtml() : "";
                    },
                    orderData: [1, 8],
                },
                {
                    data: function (oObj) {
                        return oObj.homebranch
                            ? oObj.homebranch.escapeHtml()
                            : "";
                    },
                    orderData: [1, 9],
                },
                {
                    data: "issuedate",
                    visible: false,
                },
                {
                    orderData: [1, 10], // Sort on hidden unformatted issuedate column
                    data: function (oObj) {
                        return $datetime(oObj.issuedate, {
                            no_tz_adjust: true,
                        });
                    },
                },
                {
                    data: function (oObj) {
                        return oObj.branchname
                            ? oObj.branchname.escapeHtml()
                            : "";
                    },
                    orderData: [1, 12],
                },
                {
                    data: function (oObj) {
                        return oObj.itemcallnumber
                            ? oObj.itemcallnumber.escapeHtml()
                            : "";
                    },
                    orderData: [1, 13],
                },
                {
                    data: function (oObj) {
                        return oObj.copynumber
                            ? oObj.copynumber.escapeHtml()
                            : "";
                    },
                    orderData: [1, 14],
                },
                {
                    data: function (oObj) {
                        if (!oObj.charge) oObj.charge = 0;
                        return (
                            '<span style="text-align: right; display: block;">' +
                            parseFloat(oObj.charge).format_price() +
                            "<span>"
                        );
                    },
                    orderData: [1, 15],
                    className: "nowrap",
                },
                {
                    data: function (oObj) {
                        if (!oObj.fine) oObj.fine = 0;
                        return (
                            '<span style="text-align: right; display: block;">' +
                            parseFloat(oObj.fine).format_price() +
                            "<span>"
                        );
                    },
                    orderData: [1, 16],
                    className: "nowrap",
                },
                {
                    data: function (oObj) {
                        if (!oObj.price) oObj.price = 0;
                        return (
                            '<span style="text-align: right; display: block;">' +
                            parseFloat(oObj.price).format_price() +
                            "<span>"
                        );
                    },
                    orderData: [1, 17],
                    className: "nowrap",
                },
                {
                    orderable: false,
                    data: function (oObj) {
                        var content = "";
                        var msg = "";
                        var span_style = "";
                        var span_class = "";

                        if (oObj.can_renew) {
                            // Do nothing
                        } else if (oObj.can_renew_error == "recalled") {
                            msg +=
                                "<span>" +
                                "<a href='/cgi-bin/koha/recalls/request.pl?biblionumber=" +
                                oObj.biblionumber +
                                "'>" +
                                __("Recalled") +
                                "</a>" +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed-recalled";
                        } else if (oObj.can_renew_error == "booked") {
                            msg +=
                                "<span>" +
                                "<a href='/cgi-bin/koha/bookings/list.pl?biblionumber=" +
                                oObj.biblionumber +
                                "'>" +
                                __("Booked") +
                                "</a>" +
                                "</span>";
                            span_style = "display: none";
                            span_class = "renewals-allowed-booked";
                        } else if (oObj.can_renew_error == "on_reserve") {
                            msg +=
                                "<span>" +
                                "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber=" +
                                oObj.biblionumber +
                                "'>" +
                                __("On hold") +
                                "</a>" +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed-on_reserve";
                        } else if (oObj.can_renew_error == "too_many") {
                            msg +=
                                "<span class='renewals-disabled'>" +
                                __("Not renewable") +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if (oObj.can_renew_error == "too_unseen") {
                            msg +=
                                "<span>" +
                                __("Must be renewed at the library") +
                                "</span>";
                            span_class = "renewals-allowed";
                        } else if (oObj.can_renew_error == "restriction") {
                            msg +=
                                "<span class='renewals-disabled'>" +
                                __("Not allowed: patron restricted") +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if (oObj.can_renew_error == "overdue") {
                            msg +=
                                "<span class='renewals-disabled'>" +
                                __("Not allowed: overdue") +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if (oObj.can_renew_error == "too_soon") {
                            msg +=
                                "<span class='renewals-disabled'>" +
                                __("No renewal before %s").format(
                                    oObj.can_renew_date
                                ) +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if (oObj.can_renew_error == "auto_too_late") {
                            msg +=
                                "<span class='renewals-disabled'>" +
                                __(
                                    "Can no longer be auto-renewed - number of checkout days exceeded"
                                ) +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if (
                            oObj.can_renew_error == "auto_too_much_oweing"
                        ) {
                            msg +=
                                "<span class='renewals-disabled'>" +
                                __(
                                    "Automatic renewal failed, patron has unpaid fines"
                                ) +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if (
                            oObj.can_renew_error == "auto_account_expired"
                        ) {
                            msg +=
                                "<span class='renewals-disabled'>" +
                                __(
                                    "Automatic renewal failed, account expired"
                                ) +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else if (oObj.can_renew_error == "onsite_checkout") {
                            // Don't display something if it's an onsite checkout
                        } else if (
                            oObj.can_renew_error == "item_denied_renewal"
                        ) {
                            content +=
                                "<span class='renewals-disabled'>" +
                                __("Renewal denied by syspref") +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        } else {
                            msg +=
                                "<span class='renewals-disabled'>" +
                                oObj.can_renew_error +
                                "</span>";

                            span_style = "display: none";
                            span_class = "renewals-allowed";
                        }

                        var can_force_renew =
                            oObj.onsite_checkout == 0 &&
                            (oObj.can_renew_error != "on_reserve" ||
                                (oObj.can_renew_error == "on_reserve" &&
                                    AllowRenewalOnHoldOverride))
                                ? true
                                : false;
                        var can_renew =
                            oObj.renewals_remaining > 0 &&
                            (!oObj.can_renew_error ||
                                oObj.can_renew_error == "too_unseen");
                        content += "<span>";
                        if (can_renew || can_force_renew) {
                            content +=
                                "<span style='padding: 0 1em;'>" +
                                oObj.renewals_count +
                                "</span>";
                            content +=
                                "<span class='" +
                                span_class +
                                "' style='" +
                                span_style +
                                "'>" +
                                "<input type='checkbox' ";
                            if (
                                can_renew &&
                                (oObj.date_due_overdue || oObj.date_due_today)
                            ) {
                                content += "checked='checked' ";
                            }
                            if (oObj.can_renew_error == "on_reserve") {
                                content += "data-on-reserve ";
                            }
                            content +=
                                "class='renew' id='renew_" +
                                oObj.itemnumber +
                                "' name='renew' value='" +
                                oObj.itemnumber +
                                "'/>" +
                                "</span>";
                        }
                        content += msg;
                        if (can_renew || can_force_renew) {
                            content += "<span class='renewals-info'>(";
                            content += __x(
                                "{renewals_left} of {renewals_allowed} renewals remaining",
                                {
                                    renewals_left: oObj.renewals_remaining,
                                    renewals_allowed: oObj.renewals_allowed,
                                }
                            );
                            if (UnseenRenewals && oObj.unseen_allowed) {
                                content += __x(
                                    " and {renewals_left} of {renewals_allowed} unseen renewals remaining",
                                    {
                                        renewals_left: oObj.unseen_remaining,
                                        renewals_allowed: oObj.unseen_allowed,
                                    }
                                );
                            }
                            content += ")</span>";
                        }
                        if (oObj.auto_renew) {
                            content += "<span class='renewals-info'>(";
                            content += __("Scheduled for automatic renewal");
                            content += ")</span>";
                        }

                        return content;
                    },
                },
                {
                    orderable: false,
                    data: function (oObj) {
                        if (oObj.can_renew_error == "recalled") {
                            return (
                                "<a href='/cgi-bin/koha/recalls/request.pl?biblionumber=" +
                                oObj.biblionumber +
                                "'>" +
                                __("Recalled") +
                                "</a>"
                            );
                        } else if (oObj.can_renew_error == "on_reserve") {
                            return (
                                "<a href='/cgi-bin/koha/reserve/request.pl?biblionumber=" +
                                oObj.biblionumber +
                                "'>" +
                                __("On hold") +
                                "</a>"
                            );
                        } else if (oObj.materials) {
                            return __("Confirm (%s)").format(
                                oObj.materials.escapeHtml()
                            );
                        } else {
                            return (
                                "<input type='checkbox' class='checkin' id='checkin_" +
                                oObj.itemnumber +
                                "' name='checkin' value='" +
                                oObj.itemnumber +
                                "'></input>"
                            );
                        }
                    },
                },
                {
                    orderable: false,
                    data: function (oObj) {
                        let content = "";

                        if (oObj.return_claim_id) {
                            content =
                                '<span class="badge text-bg-info">' +
                                oObj.return_claim_created_on_formatted +
                                "</span>";
                        } else if (ClaimReturnedLostValue) {
                            content =
                                '<a class="btn btn-default btn-xs claim-returned-btn" data-itemnumber="' +
                                oObj.itemnumber +
                                '"><i class="fa fa-exclamation-circle"></i> ' +
                                __("Claim returned") +
                                "</a>";
                        } else {
                            content =
                                '<a class="btn btn-default btn-xs" disabled="disabled" title="ClaimReturnedLostValue is not set, this feature is disabled"><i class="fa fa-exclamation-circle"></i> ' +
                                __("Claim returned") +
                                "</a>";
                        }
                        return content;
                    },
                },
                {
                    orderable: false,
                    data: function (oObj) {
                        var s =
                            "<input type='checkbox' name='itemnumbers' value='" +
                            oObj.itemnumber +
                            "' style='visibility:hidden;' />";

                        s +=
                            "<input type='checkbox' class='export' id='export_" +
                            oObj.biblionumber +
                            "' name='biblionumbers' value='" +
                            oObj.biblionumber +
                            "' />";
                        return s;
                    },
                },
            ],
            footerCallback: function (nRow, aaData, iStart, iEnd, aiDisplay) {
                var total_charge = 0;
                var total_fine = 0;
                var total_price = 0;
                for (var i = 0; i < aaData.length; i++) {
                    total_charge += aaData[i]["charge"] * 1;
                    total_fine += aaData[i]["fine"] * 1;
                    total_price += aaData[i]["price"] * 1;
                }
                $("#totaldue").html(total_charge.format_price());
                $("#totalfine").html(total_fine.format_price());
                $("#totalprice").html(total_price.format_price());
            },
            paging: false,
            processing: true,
            serverSide: false,
            ajax: {
                url: "/cgi-bin/koha/svc/checkouts?borrowernumber=%s".format(
                    borrowernumber
                ),
            },
            bKohaAjaxSVC: true,
            rowGroup: {
                dataSrc: "issued_today",
                startRender: function (rows, group) {
                    if (group) {
                        return __("Today's checkouts");
                    } else {
                        return __("Previous checkouts");
                    }
                },
            },
            initComplete: function (oSettings, json) {
                CheckRenewCheckinBoxes();

                // Build a summary of checkouts grouped by itemtype
                var checkoutsByItype = json.aaData.reduce(function (obj, row) {
                    obj[row.type_for_stat] = (obj[row.type_for_stat] || 0) + 1;
                    return obj;
                }, {});
                var ul = $("<ul>");
                Object.keys(checkoutsByItype)
                    .sort()
                    .forEach(function (itype) {
                        var li = $("<li>")
                            .append(
                                $("<strong>").html(itype || __("No itemtype"))
                            )
                            .append(": " + checkoutsByItype[itype]);
                        ul.append(li);
                    });
                $("<details>")
                    .addClass("checkouts-by-itemtype")
                    .append(
                        $("<summary>").html(
                            __("Number of checkouts by item type")
                        )
                    )
                    .append(ul)
                    .insertBefore(oSettings.nTableWrapper);
            },
        },
        table_settings_issues_table
    );

    if ($("#issues-table").length) {
        $("#issues-table_processing").position({
            of: $("#issues-table"),
            collision: "none",
        });
    }

    // Disable rowGroup when sorting on due date
    $("#issues-table").on("order.dt", function () {
        var order = issuesTable.api().order();
        if (order[0][0] === 3) {
            issuesTable.api().rowGroup().disable();
        } else {
            issuesTable.api().rowGroup().enable();
        }
    });
}

var loadIssuesTableDelayTimeoutId;
var barcodefield = $("#barcode");

if (AlwaysLoadCheckoutsTable) {
    if (LoadCheckoutsTableDelay) {
        setTimeout(function () {
            LoadIssuesTable();
        }, LoadCheckoutsTableDelay * 1000);
    } else {
        LoadIssuesTable();
    }
} else {
    $("#issues-table-load-immediately").change(function () {
        if (this.checked && typeof issuesTable === "undefined") {
            $("#issues-table-load-now-button").click();
        }
        barcodefield.focus();
    });
    $("#issues-table-load-now-button").click(function () {
        if (loadIssuesTableDelayTimeoutId)
            clearTimeout(loadIssuesTableDelayTimeoutId);
        LoadIssuesTable();
        barcodefield.focus();
        return false;
    });

    if (Cookies.get("issues-table-load-immediately-" + script) == "true") {
        if (LoadCheckoutsTableDelay) {
            setTimeout(function () {
                LoadIssuesTable();
            }, LoadCheckoutsTableDelay * 1000);
        } else {
            LoadIssuesTable();
        }
        $("#issues-table-load-immediately").prop("checked", true);
    } else {
        $("#issues-table-load-delay").hide();
    }
    $("#issues-table-load-immediately").on("change", function () {
        Cookies.set(
            "issues-table-load-immediately-" + script,
            $(this).is(":checked"),
            { expires: 365, sameSite: "Lax" }
        );
    });
}

$(document).ready(function () {
    var onHoldDueDateSet = false;

    var onHoldChecked = function () {
        var isChecked = false;
        $("input[data-on-reserve]").each(function () {
            if ($(this).is(":checked")) {
                isChecked = true;
            }
        });
        return isChecked;
    };

    var showHideOnHoldRenewal = function () {
        // Display the date input
        if (onHoldChecked()) {
            $("#newonholdduedate").show();
        } else {
            $("#newonholdduedate").hide();
        }
    };

    // Handle the select all/none links for checkouts table columns
    $("#CheckAllRenewals").on("click", function () {
        $("#UncheckAllCheckins").click();
        $(".renew:visible").prop("checked", true);
        CheckRenewCheckinBoxes();
        showHideOnHoldRenewal();
        return false;
    });
    $("#UncheckAllRenewals").on("click", function () {
        $(".renew:visible").prop("checked", false);
        CheckRenewCheckinBoxes();
        showHideOnHoldRenewal();
        return false;
    });

    $("#CheckAllCheckins").on("click", function () {
        $("#UncheckAllRenewals").click();
        $(".checkin:visible").prop("checked", true);
        CheckRenewCheckinBoxes();
        return false;
    });
    $("#UncheckAllCheckins").on("click", function () {
        $(".checkin:visible").prop("checked", false);
        CheckRenewCheckinBoxes();
        return false;
    });

    $("#newduedate").on("change", function () {
        if (!onHoldDueDateSet) {
            $("#newonholdduedate input").val($("#newduedate").val());
        }
    });

    $("#newonholdduedate").on("change", function () {
        onHoldDueDateSet = true;
    });

    // Don't allow both return and renew checkboxes to be checked
    $(document).on("change", ".renew", function () {
        if ($(this).is(":checked")) {
            $("#checkin_" + $(this).val()).prop("checked", false);
        }
        CheckRenewCheckinBoxes();
    });
    $(document).on("change", ".checkin", function () {
        if ($(this).is(":checked")) {
            $("#renew_" + $(this).val()).prop("checked", false);
        }
        CheckRenewCheckinBoxes();
    });

    // Display on hold due dates input when an on hold item is
    // selected
    $(document).on("change", ".renew", function () {
        showHideOnHoldRenewal();
    });

    $("#output_format > option:first-child").attr("selected", "selected");
    $("select[name='csv_profile_id']").hide();
    $(document).on("change", "#issues-table-output-format", function () {
        if ($(this).val() == "csv") {
            $("select[name='csv_profile_id']").show();
        } else {
            $("select[name='csv_profile_id']").hide();
        }
    });

    // Clicking the table cell checks the checkbox inside it
    $(document).on("click", "td", function (e) {
        if (e.target.tagName.toLowerCase() == "td") {
            $(this)
                .find("input:checkbox:visible")
                .each(function () {
                    $(this).click();
                });
        }
    });

    // Handle renewals and returns
    $("#CheckinChecked").on("click", function (e) {
        e.preventDefault();
        let refresh_table = true;
        function checkin(item_id) {
            params = {
                item_id,
                patron_id: borrowernumber,
                library_id: branchcode,
                exempt_fine: $("#exemptfine").is(":checked"),
            };

            const client = APIClient.circulation;
            return client.checkins.create(params).then(
                success => {
                    id = "#checkin_" + item_id;

                    content = "";
                    if (success.returned) {
                        content = __("Checked in");
                        $(id).parent().parent().addClass("ok");
                        $("#date_due_" + success.itemnumber).html(
                            __("Checked in")
                        );
                        if (success.patronnote != null) {
                            $(".patron_note_" + success.itemnumber).html(
                                __("Patron note") + ": " + success.patronnote
                            );
                        }
                    } else {
                        content = __("Unable to check in");
                        $(id).parent().parent().addClass("warn");
                        refresh_table = false;
                    }

                    $(id).parent().empty().append(content);
                },
                error => {
                    console.warn("Something wrong happened: %s".format(error));
                }
            );
        }

        function checkin_all(item_ids, fn) {
            let i = 0;
            function next() {
                if (i < item_ids.length) {
                    return fn(item_ids[i++]).then(function (id) {
                        return next();
                    });
                }
            }

            $(item_ids).each((i, id) => {
                $("#checkin_" + id)
                    .parent()
                    .append(
                        "<img id='checkin_" +
                            id +
                            "' src='" +
                            interface +
                            "/" +
                            theme +
                            "/img/spinner-small.gif' />"
                    );
                $("#checkin_" + id).hide();
            });

            return next();
        }

        let item_ids = $(".checkin:checked:visible").map((i, c) => c.value);

        checkin_all(item_ids, checkin).then(() => {
            // Refocus on barcode field if it exists
            if ($("#barcode").length) {
                $("#barcode").focus();
            }

            if (refresh_table) {
                RefreshIssuesTable();
            }
            $("#RenewChecked, #CheckinChecked").prop("disabled", true);
        });

        CheckRenewCheckinBoxes();
        // Prevent form submit
        return false;
    });
    $("#RenewChecked").on("click", function (e) {
        e.preventDefault();
        let refresh_table = true;
        function renew(item_id) {
            var override_limit = $("#override_limit").is(":checked") ? 1 : 0;

            $(this)
                .parent()
                .parent()
                .replaceWith(
                    "<img id='renew_" +
                        item_id +
                        "' src='" +
                        interface +
                        "/" +
                        theme +
                        "/img/spinner-small.gif' />"
                );

            var params = {
                item_id,
                patron_id: borrowernumber,
                library_id: branchcode,
                override_limit: override_limit,
            };

            if (UnseenRenewals) {
                var ren = $("#renew_as_unseen_checkbox");
                var renew_unseen = ren.length > 0 && ren.is(":checked") ? 1 : 0;
                params.seen = renew_unseen === 1 ? 0 : 1;
            }

            var dueDate = $("#newduedate").val();

            if (dueDate && dueDate.length > 0) {
                params.date_due = dueDate;
            }

            const client = APIClient.circulation;
            return client.checkouts.renew(params).then(
                success => {
                    var id = "#renew_" + success.itemnumber;

                    var content = "";
                    if (success.renew_okay) {
                        content = __("Renewed, due:") + " " + success.date_due;
                        $("#date_due_" + success.itemnumber).replaceWith(
                            success.date_due
                        );
                    } else {
                        content = __("Renew failed:") + " ";
                        if (success.error == "no_checkout") {
                            content += __("not checked out");
                        } else if (success.error == "too_many") {
                            content += __("too many renewals");
                        } else if (success.error == "too_unseen") {
                            content += __(
                                "too many consecutive renewals without being seen by the library"
                            );
                        } else if (success.error == "on_reserve") {
                            content += __("on hold");
                        } else if (success.error == "restriction") {
                            content += __("Not allowed: patron restricted");
                        } else if (success.error == "overdue") {
                            content += __("Not allowed: overdue");
                        } else if (success.error == "no_open_days") {
                            content += __("Unable to find an open day");
                        } else if (success.error) {
                            content += success.error;
                        } else {
                            content += __("reason unknown");
                        }
                        refresh_table = false;
                    }
                    $(id).parent().empty().append(content);
                },
                error => {
                    console.warn("Something wrong happened: %s".format(error));
                }
            );
        }

        function renew_all(item_ids, fn) {
            let i = 0;
            function next() {
                if (i < item_ids.length) {
                    return fn(item_ids[i++]).then(function (id) {
                        return next();
                    });
                }
            }

            $(item_ids).each((i, id) => {
                $("#renew_" + id)
                    .parent()
                    .append(
                        "<img id='renew_" +
                            id +
                            "' src='" +
                            interface +
                            "/" +
                            theme +
                            "/img/spinner-small.gif' />"
                    );
                $("#renew_" + id).hide();
            });

            return next();
        }

        let item_ids = $(".renew:checked:visible").map((_, c) => c.value);
        if (item_ids.length > 0) {
            renew_all(item_ids, renew).then(() => {
                // Refocus on barcode field if it exists
                if ($("#barcode").length) {
                    $("#barcode").focus();
                }

                if (refresh_table) {
                    RefreshIssuesTable();
                }
                $("#RenewChecked, #CheckinChecked").prop("disabled", true);
            });

            // Prevent form submit
            return false;
        } else {
            alert(__("There are no items to be renewed."));
        }
    });

    $("#RenewAll").on("click", function () {
        $("#CheckAllRenewals").click();
        $("#UncheckAllCheckins").click();
        showHideOnHoldRenewal();
        $("#RenewChecked").click();
        $("#RenewChecked").prop("disabled", true);
        // Prevent form submit
        return false;
    });

    var ymd = flatpickr.formatDate(new Date(), "Y-m-d");

    // Don't load relatives' issues table unless it is clicked on
    var relativesIssuesTable;
    $("#relatives-issues-tab").click(function () {
        if (!relativesIssuesTable) {
            relativesIssuesTable = $("#relatives-issues-table").kohaTable(
                {
                    autoWidth: false,
                    dom: '<"table_controls"B>rt',
                    order: [],
                    columns: [
                        {
                            data: "date_due",
                            visible: false,
                        },
                        {
                            orderData: 0, // Sort on hidden unformatted date due column
                            data: function (oObj) {
                                var today = new Date();
                                var due = new Date(oObj.date_due);
                                let date_due_formatted = $datetime(
                                    oObj.date_due,
                                    { as_due_date: true, no_tz_adjust: true }
                                );
                                if (today > due) {
                                    return (
                                        "<span class='overdue'>" +
                                        date_due_formatted +
                                        "</span>"
                                    );
                                } else {
                                    return date_due_formatted;
                                }
                            },
                        },
                        {
                            data: function (oObj) {
                                let title =
                                    "<span class='strong'><a href='/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
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

                                title += "</a></span>";

                                if (oObj.author) {
                                    title +=
                                        " " +
                                        __("by _AUTHOR_").replace(
                                            "_AUTHOR_",
                                            " " + oObj.author.escapeHtml()
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

                                if (oObj.itemnotes_nonpublic) {
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
                                        oObj.itemnotes_nonpublic.escapeHtml() +
                                        "</span>";
                                }

                                var onsite_checkout = "";
                                if (oObj.onsite_checkout == 1) {
                                    onsite_checkout +=
                                        " <span class='onsite_checkout'>(" +
                                        __("On-site checkout") +
                                        ")</span>";
                                }

                                title +=
                                    " " +
                                    "<a href='/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=" +
                                    oObj.biblionumber +
                                    "&itemnumber=" +
                                    oObj.itemnumber +
                                    "#" +
                                    oObj.itemnumber +
                                    "'>" +
                                    (oObj.barcode
                                        ? oObj.barcode.escapeHtml()
                                        : "") +
                                    "</a>" +
                                    onsite_checkout;

                                return title;
                            },
                            type: "anti-the",
                        },
                        {
                            data: function (oObj) {
                                return oObj.recordtype_description.escapeHtml();
                            },
                        },
                        {
                            data: function (oObj) {
                                return oObj.itemtype_description.escapeHtml();
                            },
                        },
                        {
                            data: function (oObj) {
                                return oObj.collection
                                    ? oObj.collection.escapeHtml()
                                    : "";
                            },
                        },
                        {
                            data: function (oObj) {
                                return oObj.location
                                    ? oObj.location.escapeHtml()
                                    : "";
                            },
                        },
                        {
                            data: "issuedate",
                            visible: false,
                        },
                        {
                            orderData: 7, // Sort on hidden unformatted issuedate column
                            data: function (oObj) {
                                return $datetime(oObj.issuedate, {
                                    no_tz_adjust: true,
                                });
                            },
                        },
                        {
                            data: function (oObj) {
                                return oObj.branchname
                                    ? oObj.branchname.escapeHtml()
                                    : "";
                            },
                        },
                        {
                            data: function (oObj) {
                                return oObj.itemcallnumber
                                    ? oObj.itemcallnumber.escapeHtml()
                                    : "";
                            },
                        },
                        {
                            data: function (oObj) {
                                return oObj.copynumber
                                    ? oObj.copynumber.escapeHtml()
                                    : "";
                            },
                        },
                        {
                            data: function (oObj) {
                                if (!oObj.charge) oObj.charge = 0;
                                return parseFloat(oObj.charge).toFixed(2);
                            },
                        },
                        {
                            data: function (oObj) {
                                if (!oObj.fine) oObj.fine = 0;
                                return parseFloat(oObj.fine).toFixed(2);
                            },
                        },
                        {
                            data: function (oObj) {
                                if (!oObj.price) oObj.price = 0;
                                return parseFloat(oObj.price).toFixed(2);
                            },
                        },
                        {
                            data: function (oObj) {
                                return (
                                    "<a href='/cgi-bin/koha/members/moremember.pl?borrowernumber=" +
                                    oObj.borrowernumber +
                                    "'>" +
                                    (oObj.borrower.firstname
                                        ? oObj.borrower.firstname.escapeHtml()
                                        : "") +
                                    " " +
                                    (oObj.borrower.surname
                                        ? oObj.borrower.surname.escapeHtml()
                                        : "") +
                                    " (" +
                                    (oObj.borrower.cardnumber
                                        ? oObj.borrower.cardnumber.escapeHtml()
                                        : "") +
                                    ")</a>"
                                );
                            },
                        },
                    ],
                    paging: false,
                    processing: true,
                    serverSide: false,
                    ajax: {
                        url: "/cgi-bin/koha/svc/checkouts?%s".format(
                            relatives_borrowernumbers
                                .map(b => "borrowernumber=%s".format(b))
                                .join("&")
                        ),
                    },
                    bKohaAjaxSVC: true,
                },
                table_settings_relatives_issues_table
            );
        }
    });

    if ($("#relatives-issues-table").length) {
        $("#relatives-issues-table_processing").position({
            of: $("#relatives-issues-table"),
            collision: "none",
        });
    }

    if (AllowRenewalLimitOverride || AllowRenewalOnHoldOverride) {
        $("#override_limit")
            .click(function () {
                if (this.checked) {
                    if (AllowRenewalLimitOverride) {
                        $(".renewals-allowed").show();
                        $(".renewals-disabled").hide();
                    }
                    if (AllowRenewalOnHoldOverride) {
                        $(".renewals-allowed-on_reserve").show();
                    }
                } else {
                    $(".renewals-allowed").hide();
                    $(".renewals-allowed-on_reserve").hide();
                    $(".renewals-disabled").show();
                }
            })
            .prop("checked", false);
    }

    // Refresh after return claim
    $("body").on("refreshClaimModal", function () {
        refreshReturnClaimsTable();
        issuesTable.api().ajax.reload();
    });

    // Don't load return claims table unless its tab is shown
    var returnClaimsTable;
    $("#return-claims-tab").on("shown.bs.tab", function () {
        refreshReturnClaimsTable();
    });

    function refreshReturnClaimsTable() {
        const table = $("#return-claims-table");
        if ($.fn.dataTable.isDataTable(table)) {
            table.DataTable().ajax.reload();
        } else {
            loadReturnClaimsTable();
        }
    }
    function loadReturnClaimsTable() {
        if (!returnClaimsTable) {
            returnClaimsTable = $("#return-claims-table").kohaTable({
                autoWidth: false,
                dom: "rt",
                order: [],
                columnDefs: [{ type: "anti-the", targets: ["anti-the"] }],
                columns: [
                    {
                        data: "id",
                        visible: false,
                    },
                    {
                        data: function (oObj) {
                            if (oObj.resolution) {
                                return "is_resolved";
                            } else {
                                return "is_unresolved";
                            }
                        },
                        visible: false,
                    },
                    {
                        data: function (oObj) {
                            let title =
                                '<a class="return-claim-title strong" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' +
                                oObj.biblionumber +
                                '">' +
                                oObj.title +
                                (oObj.subtitle ? " " + oObj.subtitle : "") +
                                (oObj.enumchron || "") +
                                "</a>";
                            if (oObj.author) {
                                title += " by " + oObj.author;
                            }
                            title +=
                                ' <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=' +
                                oObj.biblionumber +
                                "&itemnumber=" +
                                oObj.itemnumber +
                                '">' +
                                (oObj.barcode
                                    ? oObj.barcode.escapeHtml()
                                    : "") +
                                "</a>";

                            return title;
                        },
                    },
                    {
                        className: "return-claim-notes-td",
                        data: function (oObj) {
                            let notes =
                                '<span id="return-claim-notes-static-' +
                                oObj.id +
                                '" class="return-claim-notes" data-return-claim-id="' +
                                oObj.id +
                                '">';
                            if (oObj.notes) {
                                notes += oObj.notes;
                            }
                            notes += "</span>";
                            notes +=
                                '<i style="float:right" class="fa-solid fa-pen-to-square" title="' +
                                __("Double click to edit") +
                                '"></i>';
                            return notes;
                        },
                    },
                    {
                        data: "created_on",
                        visible: false,
                    },
                    {
                        orderData: 4,
                        data: function (oObj) {
                            if (oObj.created_on) {
                                return $date(oObj.created_on, {
                                    no_tz_adjust: true,
                                });
                            } else {
                                return "";
                            }
                        },
                    },
                    {
                        data: "updated_on",
                        visible: false,
                    },
                    {
                        orderData: 6,
                        data: function (oObj) {
                            if (oObj.updated_on) {
                                return $date(oObj.updated_on, {
                                    no_tz_adjust: true,
                                });
                            } else {
                                return "";
                            }
                        },
                    },
                    {
                        data: function (oObj) {
                            if (!oObj.resolution) return "";

                            let desc =
                                "<strong>" +
                                oObj.resolution_data.lib +
                                "</strong> <i>(";
                            if (oObj.resolved_by_data)
                                desc +=
                                    '<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=' +
                                    oObj.resolved_by_data.borrowernumber +
                                    '">' +
                                    (oObj.resolved_by_data.firstname || "") +
                                    " " +
                                    (oObj.resolved_by_data.surname || "") +
                                    "</a>";
                            desc += ", " + oObj.resolved_on + ")</i>";
                            return desc;
                        },
                    },
                    {
                        data: function (oObj) {
                            let delete_html = oObj.resolved_on
                                ? '<li><a href="#" class="return-claim-tools-delete dropdown-item" data-return-claim-id="' +
                                  oObj.id +
                                  '"><i class="fa fa-trash-can"></i> ' +
                                  __("Delete") +
                                  "</a></li>"
                                : "";
                            let resolve_html = !oObj.resolution
                                ? '<li><a href="#" class="return-claim-tools-resolve dropdown-item" data-return-claim-id="' +
                                  oObj.id +
                                  '" data-current-lost-status="' +
                                  escape_str(oObj.itemlost) +
                                  '"><i class="fa fa-check-square"></i> ' +
                                  __("Resolve") +
                                  "</a></li>"
                                : "";

                            return (
                                '<div class="btn-group">' +
                                ' <button type="button" class="btn btn-default btn-xs dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">' +
                                __("Actions") +
                                ' <span class="caret"></span>' +
                                " </button>" +
                                ' <ul class="dropdown-menu">' +
                                '  <li><a href="#" class="return-claim-tools-editnotes dropdown-item" data-return-claim-id="' +
                                oObj.id +
                                '"><i class="fa-solid fa-pencil" aria-hidden="true"></i> ' +
                                __("Edit notes") +
                                "</a></li>" +
                                resolve_html +
                                delete_html +
                                " </ul>" +
                                " </div>"
                            );
                        },
                    },
                ],
                paging: false,
                processing: true,
                serverSide: false,
                ajax: {
                    url: "/cgi-bin/koha/svc/return_claims?borrowernumber=%s".format(
                        borrowernumber
                    ),
                },
                bKohaAjaxSVC: true,
                search: { search: "is_unresolved" },
                footerCallback: function (row, data, start, end, display) {
                    var api = this.api();
                    // Total over all pages
                    var colData = api.column(1).data();
                    var is_unresolved = 0;
                    var is_resolved = 0;
                    colData.each(function (index, value) {
                        if (index == "is_unresolved") {
                            is_unresolved++;
                        }
                        if (index == "is_resolved") {
                            is_resolved++;
                        }
                    });
                    // Update footer
                    $("#return-claims-controls").html(
                        showClaimFilter(is_unresolved, is_resolved)
                    );
                },
            });
        }
    }

    function showClaimFilter(is_unresolved, is_resolved) {
        var showAll, showUnresolved;
        var total = Number(is_unresolved) + Number(is_resolved);
        if (total > 0) {
            showAll = __nx("Show 1 claim", "Show all {count} claims", total, {
                count: total,
            });
        } else {
            showAll = "";
        }
        if (is_unresolved > 0) {
            showUnresolved = __nx(
                "Show 1 unresolved claim",
                "Show {count} unresolved claims",
                is_unresolved,
                { count: is_unresolved }
            );
        } else {
            showUnresolved = "";
        }
        $("#show_all_claims").html(showAll);
        $("#show_unresolved_claims").html(showUnresolved);
    }

    $("body").on("click", ".return-claim-tools-editnotes", function (e) {
        e.preventDefault();
        let id = $(this).data("return-claim-id");
        $("#return-claim-notes-static-" + id)
            .parent()
            .dblclick();
        $("#return-claim-notes-editor-textarea-" + id).focus();
    });

    $("body").on("dblclick", ".return-claim-notes-td", function () {
        let elt = $(this).children(".return-claim-notes");
        let id = elt.data("return-claim-id");
        if ($("#return-claim-notes-editor-textarea-" + id).length == 0) {
            let note = elt.text();
            let editor =
                '  <span id="return-claim-notes-editor-' +
                id +
                '">' +
                ' <textarea id="return-claim-notes-editor-textarea-' +
                id +
                '">' +
                note +
                "</textarea>" +
                " <br/>" +
                ' <a class="btn btn-default btn-xs claim-returned-notes-editor-submit" data-return-claim-id="' +
                id +
                '"><i class="fa fa-save"></i> ' +
                __("Update") +
                "</a>" +
                ' <a class="claim-returned-notes-editor-cancel" data-return-claim-id="' +
                id +
                '" href="#">' +
                __("Cancel") +
                "</a>" +
                "</span>";
            elt.hide();
            $(editor).insertAfter(elt);
        }
    });

    $("body").on("click", ".claim-returned-notes-editor-submit", function () {
        let id = $(this).data("return-claim-id");
        let notes = $("#return-claim-notes-editor-textarea-" + id).val();

        let params = {
            notes: notes,
            updated_by: logged_in_user_borrowernumber,
        };

        $(this).parent().remove();

        $.ajax({
            url: "/api/v1/return_claims/" + id + "/notes",
            type: "PUT",
            data: JSON.stringify(params),
            success: function (data) {
                let notes = $("#return-claim-notes-static-" + id);
                notes.text(data.notes);
                notes.show();
            },
            contentType: "json",
        });
    });

    $("body").on("click", ".claim-returned-notes-editor-cancel", function (e) {
        e.preventDefault();
        let id = $(this).data("return-claim-id");
        $(this).parent().remove();
        $("#return-claim-notes-static-" + id).show();
    });

    // Hanld return claim deletion
    $("body").on("click", ".return-claim-tools-delete", function (e) {
        e.preventDefault();
        let confirmed = confirm(
            __("Are you sure you want to delete this return claim?")
        );
        if (confirmed) {
            let id = $(this).data("return-claim-id");

            $.ajax({
                url: "/api/v1/return_claims/" + id,
                type: "DELETE",
                success: function (data) {
                    refreshReturnClaimsTable();
                    issuesTable.api().ajax.reload();
                },
            });
        }
    });

    $("#show_all_claims").on("click", function (e) {
        e.preventDefault();
        $(".ctrl_link").removeClass("disabled");
        $(this).addClass("disabled");
        $("#return-claims-table").DataTable().search("").draw();
    });

    $("#show_unresolved_claims").on("click", function (e) {
        e.preventDefault();
        $(".ctrl_link").removeClass("disabled");
        $(this).addClass("disabled");
        $("#return-claims-table").DataTable().search("is_unresolved").draw();
    });

    $(".confirmation-required-form").on("submit", function (e) {
        var currentCookieValue = Cookies.get("patronSessionConfirmation") || "";
        var currentPatron = currentCookieValue.split(":")[0] || null;

        var rememberForSession = $("#patron_session_confirmation").is(
            ":checked"
        );
        var sessionConfirmations = [];
        $("input[name^=session_confirmations]").each(function () {
            sessionConfirmations.push($(this).val());
        });

        // Add cancelreserve checkbox state if it's checked
        if (rememberForSession) {
            if ($("#cancelreserve").is(":checked")) {
                sessionConfirmations.push("cancelreserve");
            }
        }
        if (currentPatron != borrowernumber && !rememberForSession) {
            Cookies.set("patronSessionConfirmation", borrowernumber + ":", {
                sameSite: "Lax",
            });
            return true;
        }

        if (currentPatron == borrowernumber && rememberForSession) {
            sessionConfirmations.forEach(function (sessionConfirmation) {
                currentCookieValue += sessionConfirmation + "|";
            });
            Cookies.set("patronSessionConfirmation", currentCookieValue, {
                sameSite: "Lax",
            });
            return true;
        }

        if (currentPatron != borrowernumber && rememberForSession) {
            var newCookieValue = borrowernumber + ":";
            sessionConfirmations.forEach(function (sessionConfirmation) {
                newCookieValue += sessionConfirmation + "|";
            });
            Cookies.set("patronSessionConfirmation", newCookieValue, {
                sameSite: "Lax",
            });
            return true;
        }
        return true;
    });
});
