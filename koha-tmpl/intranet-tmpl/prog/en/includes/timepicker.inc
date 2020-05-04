<!-- timepicker.inc -->
<script>
    /* Localization of the timepicker plugin */
    jQuery(function($){
        $.timepicker.regional[''] = {
            timeFormat: "[% IF Koha.Preference('TimeFormat') == '12hr' %]hh:mm TT[% ELSE %]HH:mm[% END %]",
            currentText: _("Now"),
            closeText: _("Done"),
            amNames: [_("AM"), _("A")],
            pmNames: [_("PM"), _("P")],
            timeSuffix: "",
            timeOnlyTitle: _("Choose time"),
            timeText: _("Time"),
            hourText: _("Hour"),
            minuteText: _("Minute"),
            secondText: _("Second"),
            millisecText: _("Millisecond"),
            microsecText: _("Microsecond"),
            timezoneText: _("Time zone"),
            [% IF ( bidi ) %] isRTL: true [% ELSE %] isRTL: false [% END %]
        };
        $.timepicker.setDefaults($.timepicker.regional['']);
    });
</script>
<!-- / timepicker.inc -->
