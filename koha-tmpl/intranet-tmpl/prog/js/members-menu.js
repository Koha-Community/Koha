/* global borrowernumber advsearch dateformat __ CAN_user_borrowers_delete_borrowers CAN_user_borrowers_edit_borrowers number_of_adult_categories destination Cookies*/

$(document).ready(function () {
    searchfield_date_tooltip("");
    searchfield_date_tooltip("_filter");
    $("#searchfieldstype").change(function () {
        searchfield_date_tooltip("");
    });
    $("#searchfieldstype_filter").change(function () {
        searchfield_date_tooltip("_filter");
    });

    if (CAN_user_borrowers_delete_borrowers) {
        $("#deletepatron").click(function () {
            if ($(this).data("toggle") == "tooltip") {
                // Disabled menu option has tooltip attribute
                e.preventDefault();
            } else {
                window.location =
                    "/cgi-bin/koha/members/deletemem.pl?member=" +
                    borrowernumber;
            }
        });
    }
    if (CAN_user_borrowers_edit_borrowers) {
        $("#renewpatron").click(function (e) {
            e.preventDefault();
            confirm_reregistration();
        });

        $("#updatechild").click(function (e) {
            e.preventDefault();
            if ($(this).data("toggle") == "tooltip") {
                // Disabled menu option has tooltip attribute
            } else {
                update_child();
            }
        });
    }

    $(".delete_message").click(function () {
        return window.confirm(
            __(
                "Are you sure you want to delete this message? This cannot be undone."
            )
        );
    });

    $("#exportcheckins").click(function (e) {
        e.preventDefault();
        export_barcodes();
    });
    $("#print_overdues").click(function (e) {
        e.preventDefault();
        window.open(
            "/cgi-bin/koha/members/print_overdues.pl?borrowernumber=" +
                borrowernumber,
            "printwindow"
        );
    });
    $(".printslip").click(function (e) {
        e.preventDefault();
        let slip_code = $(this).data("code");
        let clear_screen = $(this).data("clear");
        if (slip_code == "printsummary") {
            window.open(
                "/cgi-bin/koha/members/summary-print.pl?borrowernumber=" +
                    borrowernumber,
                "printwindow"
            );
        } else {
            window.open(
                "/cgi-bin/koha/members/printslip.pl?borrowernumber=" +
                    borrowernumber +
                    "&amp;print=" +
                    slip_code,
                "printwindow"
            );
        }
        if (clear_screen) {
            window.location.replace("/cgi-bin/koha/circ/circulation.pl");
        }
    });
    $("#searchtohold").click(function () {
        searchToHold();
        return false;
    });
    $("#select_patron_messages").on("change", function () {
        $("#borrower_message").val($(this).val());
    });

    $("#patronImageEdit").on("shown.bs.modal", function () {
        startup();
    });

    $("#message_type").on("change", function () {
        if ($(this).val() == "E" || $(this).val() == "SMS") {
            $("label[for='borrower_message']").show();
            $("#subject_form").show();
            $("label[for='select_patron_notice']").show();
            $("#select_patron_notice").show();
            $("label[for='select_patron_messages']").hide();
            $("#select_patron_messages").hide();
            $("#borrower_message").val("");
            $("#select_patron_notice").val("");
        } else {
            $("#subject_form").hide();
            $("label[for='borrower_message']").hide();
            $("label[for='select_patron_notice']").hide();
            $("#select_patron_notice").hide();
            $("label[for='select_patron_messages']").show();
            $("#select_patron_messages").show();
            $("#borrower_subject").prop("disabled", false);
            $("#borrower_message").prop("disabled", false);
            $("#select_patron_messages").val("");
        }
        if ($(this).val() == "SMS") {
            $("#borrower_subject").val(__("SMS added by a librarian"));
            $("#subject_form").hide();
        } else {
            if (
                $("#borrower_subject").val() == __("SMS added by a librarian")
            ) {
                $("#borrower_subject").val("");
            }
        }
    });

    $("#select_patron_notice").on("change", function () {
        if ($(this).val()) {
            $("#borrower_subject").prop("disabled", true);
            $("#borrower_message").prop("disabled", true);
        } else {
            $("#borrower_subject").prop("disabled", false);
            $("#borrower_message").prop("disabled", false);
        }
    });

    $(".edit-patronimage").on("click", function (e) {
        e.preventDefault();
        var borrowernumber = $(this).data("borrowernumber");
        var cardnumber = $(this).data("cardnumber");
        var modalTitle = $(this).attr("title");
        $("#patronImageEdit .modal-title").text(modalTitle);
        $("#patronImageEdit").modal("show");
        $("#patronImageEdit").on("hidden.bs.modal", function () {
            /* Stop using the user's camera when modal is closed */
            let viewfinder = document.getElementById("viewfinder");
            if (viewfinder && viewfinder.srcObject) {
                viewfinder.srcObject.getTracks().forEach(track => {
                    if (track.readyState == "live" && track.kind === "video") {
                        track.stop();
                    }
                });
            }
        });
    });
});

function searchfield_date_tooltip(filter) {
    var field = "#searchmember" + filter;
    var type = "#searchfieldstype" + filter;
    if ($(type).val() == "dateofbirth") {
        var MSG_DATE_FORMAT = "";
        if (dateformat == "us") {
            MSG_DATE_FORMAT = __(
                "Dates of birth should be entered in the format 'MM/DD/YYYY'"
            );
        } else if (dateformat == "iso") {
            MSG_DATE_FORMAT = __(
                "Dates of birth should be entered in the format 'YYYY-MM-DD'"
            );
        } else if (dateformat == "metric") {
            MSG_DATE_FORMAT = __(
                "Dates of birth should be entered in the format 'DD/MM/YYYY'"
            );
        } else if (dateformat == "dmydot") {
            MSG_DATE_FORMAT = __(
                "Dates of birth should be entered in the format 'DD.MM.YYYY'"
            );
        }
        $(field).attr("title", MSG_DATE_FORMAT).tooltip("show");
    } else {
        $(field).tooltip("dispose");
    }
}

function confirm_updatechild() {
    var is_confirmed = window.confirm(
        __(
            "Are you sure you want to update this child to an Adult category? This cannot be undone."
        )
    );
    if (is_confirmed) {
        window.location =
            "/cgi-bin/koha/members/update-child.pl?op=update&borrowernumber=" +
            borrowernumber;
    }
}

function update_child() {
    if (number_of_adult_categories > 1) {
        openWindow(
            "/cgi-bin/koha/members/update-child.pl?op=multi&borrowernumber=" +
                borrowernumber,
            "UpdateChild"
        );
    } else {
        confirm_updatechild();
    }
}

function confirm_reregistration() {
    var is_confirmed = window.confirm(
        __("Are you sure you want to renew this patron's registration?")
    );
    if (is_confirmed) {
        window.location =
            "/cgi-bin/koha/members/setstatus.pl?borrowernumber=" +
            borrowernumber +
            "&destination=" +
            destination +
            "&reregistration=y";
    }
}
function export_barcodes() {
    window.open(
        "/cgi-bin/koha/members/readingrec.pl?borrowernumber=" +
            borrowernumber +
            "&op=export_barcodes"
    );
}

function searchToHold() {
    var date = new Date();
    date.setTime(date.getTime() + 10 * 60 * 1000);
    Cookies.set("holdfor", borrowernumber, {
        path: "/",
        expires: date,
        sameSite: "Lax",
    });
    location.href = "/cgi-bin/koha/catalogue/search.pl";
}
