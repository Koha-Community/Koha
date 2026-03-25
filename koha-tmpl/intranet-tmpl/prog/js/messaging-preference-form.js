$(document).ready(function () {
    var message_prefs_dirty = false;
    $("#memberentry_messaging_prefs > *").change(function () {
        message_prefs_dirty = true;
    });

    if (window.location.href.indexOf("op=add") === -1) {
        message_prefs_dirty = true;
    }

    if ($("#messaging_prefs_loading").length) {
        $("#categorycode_entry").change(function () {
            var categorycode = $(this).val();

            // Show the combined modal and reset checkboxes to checked
            $("#categoryChangeUpdateMessaging").prop("checked", true);
            $("#categoryChangeUpdateExpiry").prop("checked", true);
            $("#categoryChangeModal").modal("show");

            // Remove any previously bound confirm handler to avoid stacking
            $("#categoryChangeConfirmBtn")
                .off("click")
                .on("click", function () {
                    $("#categoryChangeModal").modal("hide");

                    // --- Update messaging preferences ---
                    if (
                        $("#categoryChangeUpdateMessaging").prop("checked") &&
                        message_prefs_dirty
                    ) {
                        var messaging_prefs_loading = $(
                            "#messaging_prefs_loading"
                        );
                        messaging_prefs_loading.show();

                        $.getJSON(
                            "/cgi-bin/koha/members/default_messageprefs.pl?categorycode=" +
                                categorycode,
                            function (data) {
                                $.each(
                                    data.messaging_preferences,
                                    function (i, item) {
                                        var attrid = item.message_attribute_id;
                                        var transports = [
                                            "email",
                                            "rss",
                                            "sms",
                                        ];
                                        $.each(
                                            transports,
                                            function (j, transport) {
                                                var checked =
                                                    item[
                                                        "transports_" +
                                                            transport
                                                    ] == 1;
                                                $(
                                                    "#" + transport + attrid
                                                ).prop("checked", checked);
                                                toggle_digest(attrid);
                                            }
                                        );
                                        if (item.digest && item.digest != " ") {
                                            $("#digest" + attrid).prop(
                                                "checked",
                                                true
                                            );
                                        } else {
                                            $("#digest" + attrid).prop(
                                                "checked",
                                                false
                                            );
                                        }
                                        if (item.takes_days == "1") {
                                            $("[name=" + attrid + "-DAYS]").val(
                                                "" + item.days_in_advance
                                            );
                                        }
                                    }
                                );
                                message_prefs_dirty = false;
                            }
                        ).always(function () {
                            messaging_prefs_loading.hide();
                        });
                    }

                    // --- Update expiry date ---
                    if ($("#categoryChangeUpdateExpiry").prop("checked")) {
                        var fp = $("#to").flatpickr();
                        var expiryDate = $(
                            "select" + category_selector + " option:selected"
                        ).data("expiryDate");
                        if (expiryDate) {
                            var formattedDate = expiryDate.split("T")[0];
                            fp.setDate(formattedDate);
                        }
                    }
                });
        });
    }

    function toggle_digest(id) {
        let phone_checked = TalkingTechItivaPhoneNotification
            ? false
            : PhoneNotification
              ? $("#phone" + id).prop("checked")
              : false;
        if (
            $("#email" + id).prop("checked") ||
            $("#sms" + id).prop("checked") ||
            phone_checked
        ) {
            $("#digest" + id)
                .attr("disabled", false)
                .tooltip("disable");
        } else {
            $("#digest" + id)
                .attr("disabled", true)
                .prop("checked", false)
                .tooltip("enable");
        }
    }

    $(".pmp_email").each(function () {
        toggle_digest(Number($(this).attr("id").replace("email", "")));
    });

    $(".pmp_email").click(function () {
        toggle_digest(Number($(this).attr("id").replace("email", "")));
    });
    $(".pmp_sms").click(function () {
        toggle_digest(Number($(this).attr("id").replace("sms", "")));
    });
    $(".pmp_phone").click(function () {
        toggle_digest(Number($(this).attr("id").replace("phone", "")));
    });
});
