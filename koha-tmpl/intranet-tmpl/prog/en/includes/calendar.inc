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
    var flatpickr_timeformat_string = [% IF Koha.Preference('TimeFormat') == '12hr' %]"G:i K"[% ELSE %]"H:i"[% END %];
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
            if( $(instance.input).hasClass("futuredate") ){
                instance.set("minDate", new Date().fp_incr(1));
            }
            if( $(instance.input).hasClass("pastdate") ){
                instance.set("maxDate", new Date().fp_incr(-1));
            }
            $(instance.input)
                /* Add a wrapper element so that we can prevent the clear button from wrapping */
                .wrap("<span class='flatpickr_wrapper'></span>")
                .after( $("<a/>")
                    .attr("href","#")
                    .addClass("clear_date")
                    .on("click", function(e){
                        e.preventDefault();
                        instance.clear();
                    })
                    .addClass("fa fa-fw fa-remove")
                    .attr("aria-hidden", true)
                    .attr("aria-label", _("Clear date") )
                ).keydown(function(e) {
                    var key = (event.keyCode ? event.keyCode : event.which);
                    if ( key == 40 ) {
                        instance.set('allowInput',false);
                    }
                });
        },
        onClose: function( selectedDates, dateText, instance) {
            validate_date( selectedDates, instance );
        },
    });
    $(document).ready(function(){
        $(".flatpickr").flatpickr();
        var startPicker = $(".flatpickrfrom").flatpickr({
            onClose: function( selectedDates, dateText, instance) {
                validate_date( selectedDates, instance );
                endPicker.set('minDate', selectedDates[0]);
            }
        });
        var endPicker = $(".flatpickrto").flatpickr({
            onClose: function( selectedDates, dateText, instance) {
                validate_date( selectedDates, instance );
            },
        });

    });
</script>
[% END %]
