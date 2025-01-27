$(document).ready(function () {
    var message_prefs_dirty = false;
    $("#memberentry_messaging_prefs > *").change(function () {
        message_prefs_dirty = true;
    });

    if (window.location.href.indexOf("op=add") === -1) {
        message_prefs_dirty = true; // unless op=add consider the message prefs dirty
    }

    if ($("#messaging_prefs_loading").length) {
        // This element only appears in the template if op=add
        $("#categorycode_entry").change(function () {
            var messaging_prefs_loading = $("#messaging_prefs_loading");
            // Upon selecting a new patron category, show "Loading" message for messaging defaults
            messaging_prefs_loading.show();
            var categorycode = $(this).val();
            if (message_prefs_dirty) {
                if (
                    !confirm(
                        __(
                            "Change messaging preferences to default for this category?"
                        )
                    )
                ) {
                    // Not loading messaging defaults. Hide loading indicator
                    messaging_prefs_loading.hide();
                    return;
                }
            }
            var jqxhr = $.getJSON(
                "/cgi-bin/koha/members/default_messageprefs.pl?categorycode=" +
                    categorycode,
                function (data) {
                    $.each(data.messaging_preferences, function (i, item) {
                        var attrid = item.message_attribute_id;
                        var transports = ["email", "rss", "sms"];
                        $.each(transports, function (j, transport) {
                            if (item["transports_" + transport] == 1) {
                                $("#" + transport + attrid).prop(
                                    "checked",
                                    true
                                );
                                toggle_digest(attrid);
                            } else {
                                $("#" + transport + attrid).prop(
                                    "checked",
                                    false
                                );
                                toggle_digest(attrid);
                            }
                        });
                        if (item.digest && item.digest != " ") {
                            $("#digest" + attrid).prop("checked", true);
                        } else {
                            $("#digest" + attrid).prop("checked", false);
                        }
                        if (item.takes_days == "1") {
                            $("[name=" + attrid + "-DAYS]").val(
                                "" + item.days_in_advance
                            );
                        }
                    });
                    message_prefs_dirty = false;
                }
            ).always(function () {
                // Loaded messaging defaults. Hide loading indicator
                messaging_prefs_loading.hide();
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
    // At load time, we want digest disabled if no digest using transport is enabled
    $(".pmp_email").each(function () {
        toggle_digest(Number($(this).attr("id").replace("email", "")));
    });

    // If user clears all digest using transports for a notice, disable digest checkbox
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
