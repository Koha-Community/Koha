/**
 *
 * Used in: koha-tmpl/opac-tmpl/bootstrap/en/modules/opac-messaging.tt
 *
 * This component is also used in Staff client: koha-tmpl/intranet-tmpl/prog/en/modules/memberentrygen.tt
 * For modifications, edit also Staff client version in: koha-tmpl/intranet-tmpl/prog/en/js/messaging-preference.js
 *
 * Disables and clears checkboxes from messaging preferences
 * if there is either invalid or nonexistent contact information
 * for the message transfer type.
 *
 * @param {HTMLInputElement} elem
 *  The contact field
 * @param {string} id_attr
 *  Checkboxes' id attribute so that we can recognize them
 */
// Settings for messaging-preference.js
var patron_messaging_checkbox_preferences = {
    email: {
        checked_checkboxes: null,
        is_enabled: true,
        disabled_checkboxes: null
    },
    sms: {
        checked_checkboxes: null,
        is_enabled: true,
        disabled_checkboxes: null
    },
    phone: {
        checked_checkboxes: null,
        is_enabled: true,
        disabled_checkboxes: null
    }
};

function disableCheckboxesWithInvalidPreferences(elem, id_attr) {
    if (!$(elem).length && typeof window["patron_" + id_attr] !== "undefined") {
        return;
    }
    // Get checkbox preferences for the element
    var checkbox_prefs = eval("patron_messaging_checkbox_preferences." + id_attr);
    // Check if element is empty or not valid

    if (!$(elem).length || $(elem).val().length == 0 || !$(elem).valid()) {

        if (checkbox_prefs.is_enabled) {
            // Save the state of checked checkboxes
            checkbox_prefs.checked_checkboxes = $("input[type='checkbox'][id^=" + id_attr + "][value=" + id_attr + "]:checked");

            // Save the state of automatically disabled checkboxes
            // (We don't want to enable them once the e-mail is valid!)
            checkbox_prefs.disabled_checkboxes = $("input[type='checkbox'][id^=" + id_attr + "][value=" + id_attr + "]:disabled");

            // Clear patron messaging preferences checkboxes
            $("input[type='checkbox'][id^=" + id_attr + "][value=" + id_attr + "]").removeAttr("checked");

            // Then disable checkboxes from patron messaging perferences
            $("input[type='checkbox'][id^=" + id_attr + "][value=" + id_attr + "]").attr("disabled", "disabled");

            // Color table cell's background emphasize the disabled state of the checkbox
            $("input[type='checkbox'][id^=" + id_attr + "][value=" + id_attr + "]").parent().css("background-color", "#E8F0F8");

            // Show notice about missing contact in messaging preferences box
            $("#required-" + id_attr).css("display", "block");

            checkbox_prefs.is_enabled = false;
        }
    } else {

        if (!checkbox_prefs.is_enabled) {
            // Enable patron messaging preferences checkboxes
            $("input[type='checkbox'][id^=" + id_attr + "][value=" + id_attr + "]").removeAttr("disabled");

            // Disable the checkboxes that were disabled by default
            checkbox_prefs.disabled_checkboxes.each(function() {
                $(this).attr("disabled", "disabled");
                $(this).removeAttr("checked");
            });

            // Restore the state of checkboxes
            checkbox_prefs.checked_checkboxes.each(function() {
                $(this).attr("checked", "checked");
            });

            // Remove the background color from table cell
            $("input[type='checkbox'][id^=" + id_attr + "][value=" + id_attr + "]").parent().css("background-color", "#FFF");

            // Remove notice about missing contact from messaging preferences box
            $("#required-" + id_attr).css("display", "none");

            checkbox_prefs.is_enabled = true;
        }
    }
}
