[% USE Asset %]
[% USE Koha %]
[% USE raw %]
<!-- calendar.inc -->
[% FILTER collapse %]
<script>
    var debug    = "[% debug | html %]";
    var dateformat_pref = "[% Koha.Preference('dateformat ') | html %]";
    var dateformat_string = [% IF ( dateformat == "us" ) %]"mm/dd/yy"[% ELSIF ( dateformat == "metric" ) %]"dd/mm/yy"[% ELSIF ( dateformat == "dmydot" ) %]"dd.mm.yy"[% ELSE %]"yy-mm-dd"[% END %];
    var flatpickr_dateformat_string = [% IF ( dateformat == "us" ) %]"m/d/Y"[% ELSIF ( dateformat == "metric" ) %]"d/m/Y"[% ELSIF ( dateformat == "dmydot" ) %]"d.m.Y"[% ELSE %]"Y-m-d"[% END %];
    var sentmsg = 0;
    var bidi = [% IF(bidi) %] true[% ELSE %] false[% END %];
    var calendarFirstDayOfWeek = '[% Koha.Preference('CalendarFirstDayOfWeek') | html %]';
    var flatpickr_timeformat_string = [% IF Koha.Preference('TimeFormat') == '12hr' %]"h:i K"[% ELSE %]"H:i"[% END %];
    var flatpickr_timeformat = [% IF Koha.Preference('TimeFormat') == '12hr' %]false[% ELSE %]true[% END %];
</script>
<!-- / calendar.inc -->
[% Asset.js("js/calendar.js") | $raw %]
[% Asset.js("lib/flatpickr/flatpickr.min.js") | $raw %]
<script>
    flatpickr.l10ns.default.weekdays = flatpickr_weekdays;
    flatpickr.l10ns.default.months   = flatpickr_months;
    flatpickr.setDefaults({
        allowInput: true,
        dateFormat: flatpickr_dateformat_string,
        nextArrow: '<i class="fa fa-fw fa-arrow-right"></i>',
        prevArrow: '<i class="fa fa-fw fa-arrow-left"></i>',
        time_24hr: flatpickr_timeformat,
        locale: {
            "firstDayOfWeek": calendarFirstDayOfWeek
        },
        onReady: function( selectedDates, dateStr, instance ){
            /* When flatpickr instance is created, automatically append a "clear date" link */
            $(instance.input)
                .after( $("<a/>")
                    .attr("href","#")
                    .addClass("clear_date")
                    .on("click", function(){
                        instance.clear();
                    })
                    .addClass("fa fa-fw fa-remove")
                    .attr("aria-hidden", true)
                    .attr("aria-label", _("Clear date") )
                );
        },
        onClose: function( selectedDates, dateText, instance) {
            validate_date( selectedDates, instance );
        },
    });
</script>
[% END %]
