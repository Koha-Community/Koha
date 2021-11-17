[% USE Asset %]
[% USE Koha %]
[% USE raw %]
<!-- calendar.inc -->
[% FILTER collapse %]
<script>
    var debug    = "[% debug | html %]";
    var dateformat_pref = "[% Koha.Preference('dateformat ') | html %]";
    var dateformat_string = "";
    var flatpickr_dateformat_string = "";
    switch ( dateformat_pref ){
        case "us":
            dateformat_string = "mm/dd/yy";
            flatpickr_dateformat_string = "m/d/Y";
            break;
        case "metric":
            dateformat_string = "dd/mm/yy";
            flatpickr_dateformat_string = "d/m/Y";
            break;
        case "dmydot":
            dateformat_string = "dd.mm.yy";
            flatpickr_dateformat_string = "d.m.Y";
            break;
        default:
            dateformat_string = "yy-mm-dd";
            flatpickr_dateformat_string = "Y-m-d";
    }
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
        defaultHour: 23,
        defaultMinute: 59,
        locale: {
            "firstDayOfWeek": calendarFirstDayOfWeek
        },
        onReady: function( selectedDates, dateStr, instance ){
            /* When flatpickr instance is created, automatically append a "clear date" link */
            $(instance.input)
                /* Add a wrapper element so that we can prevent the clear button from wrapping */
                .wrap("<span class='flatpickr_wrapper'></span>")
                .attr("autocomplete", "off")
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
            validate_date( dateText, instance );
            var thisInput = instance.input;
            if ( thisInput.hasAttribute('data-date_to') ) {
                var endPicker = document.querySelector("#"+thisInput.dataset.date_to)._flatpickr;
                endPicker.set('minDate', selectedDates[0]);
            }

            let = on_close_focus = $(thisInput).data('flatpickr-on-close-focus');
            if ( on_close_focus ) {
                $(on_close_focus).focus();
            }
        },
    });
    $(document).ready(function(){
        $(".flatpickr").each(function(){
            let options = {};

            if( $(this).data("flatpickr-futuredate") === true ) {
                let original_date = $(this).val();
                if ( original_date ) {
                    original_date = Date_from_syspref( original_date ).getTime();
                    let tomorrow = new Date().fp_incr(1).getTime();

                    options['enable'] = [function(date){
                        date = date.getTime();
                        if ( date == original_date ) return true;
                        if ( date >= tomorrow)       return true;
                    }];
                }
                else {
                    options['minDate'] = new Date().fp_incr(1);
                }
            }
            if( $(this).data("flatpickr-pastinclusive") === true ) {
                options['maxDate'] = "today";
            }
            if( $(this).data("flatpickr-pastdate") === true ) {
                options['maxDate'] = new Date().fp_incr(-1);
            }
            if ( $(this).data('flatpickr-enable-time') === true ) {
                options['enableTime'] = true;
                options['dateFormat'] = flatpickr_dateformat_string + " " + flatpickr_timeformat_string;
            }

            $(this).flatpickr(options);
        });
    });
</script>
[% END %]
