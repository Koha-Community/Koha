$(document).ready(function(){
    $("#info_digests").tooltip();

    var message_prefs_dirty = false;
    $('#memberentry_messaging_prefs > *').change(function() {
        message_prefs_dirty = true;
    });

    if( $("#messaging_prefs_loading").length ){ // This element only appears in the template if op=add
        $('#categorycode_entry').change(function() {
            var messaging_prefs_loading = $("#messaging_prefs_loading");
            // Upon selecting a new patron category, show "Loading" message for messaging defaults
            messaging_prefs_loading.show();
            var categorycode = $(this).val();
            if (message_prefs_dirty) {
                if (!confirm( MSG_MESSAGING_DFEAULTS )) {
                    // Not loading messaging defaults. Hide loading indicator
                    messaging_prefs_loading.hide();
                    return;
                }
            }
            var jqxhr = $.getJSON('/cgi-bin/koha/members/default_messageprefs.pl?categorycode=' + categorycode, function(data) {
                $.each(data.messaging_preferences, function(i, item) {
                    var attrid = item.message_attribute_id;
                    var transports = ['email', 'rss', 'sms'];
                    $.each(transports, function(j, transport) {
                        if (item['transports_' + transport] == 1) {
                            $('#' + transport + attrid).prop('checked', true);
                        } else {
                            $('#' + transport + attrid).prop('checked', false);
                        }
                    });
                    if (item.digest && item.digest != ' ') {
                        $('#digest' + attrid).prop('checked', true);
                    } else {
                        $('#digest' + attrid).prop('checked', false);
                    }
                    if (item.takes_days == '1') {
                        $('[name=' + attrid + '-DAYS]').val('' + item.days_in_advance);
                    }
                });
                message_prefs_dirty = false;
            })
                .always(function() {
                    // Loaded messaging defaults. Hide loading indicator
                    messaging_prefs_loading.hide();
                });
        });
    }
});
