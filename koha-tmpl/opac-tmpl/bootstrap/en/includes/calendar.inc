[% USE Asset %]
[% USE Koha %]
[% USE raw %]
<script>
    var flatpickr_weekdays = {
        shorthand: [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
        longhand: [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]
    };

    var flatpickr_months = {
        shorthand: [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        longhand: [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    };
    var debug    = "[% debug | html %]";
    var dateformat_pref = "[% Koha.Preference('dateformat ') | html %]";
    var sentmsg = 0;
    if (debug > 1) {alert("dateformat: " + dateformat_pref + "\ndebug is on (level " + debug + ")");}
    var calendarFirstDayOfWeek = '[% Koha.Preference('CalendarFirstDayOfWeek') | html %]';
    var flatpickr_timeformat_string = [% IF Koha.Preference('TimeFormat') == '12hr' %]"G:i K"[% ELSE %]"H:i"[% END %];
    var flatpickr_timeformat = [% IF Koha.Preference('TimeFormat') == '12hr' %]false[% ELSE %]true[% END %];
    var flatpickr_dateformat_string = "";
    switch ( dateformat_pref ){
        case "us":
            flatpickr_dateformat_string = "m/d/Y";
            break;
        case "metric":
            flatpickr_dateformat_string = "d/m/Y";
            break;
        case "dmydot":
            flatpickr_dateformat_string = "d.m.Y";
            break;
        default:
            flatpickr_dateformat_string = "Y-m-d";
    }
</script>
[% Asset.js("lib/flatpickr/flatpickr.min.js") | $raw %]
<script>
    flatpickr.l10ns.default.weekdays = flatpickr_weekdays;
    flatpickr.l10ns.default.months   = flatpickr_months;
    flatpickr.setDefaults({
        allowInput: true,
        dateFormat: flatpickr_dateformat_string,
        nextArrow: '<i class="fa fa-fw fa-arrow-right" aria-hidden="true"></i>',
        prevArrow: '<i class="fa fa-fw fa-arrow-left" aria-hidden="true"></i>',
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
            validate_date( dateText, instance );
            var thisInput = instance.input;
            if ( thisInput.hasAttribute('data-start_for') ) {
                var endPicker = document.querySelector("#"+thisInput.dataset.start_for)._flatpickr;
                endPicker.set('minDate', selectedDates[0]);
            }
        },
    });

    var MSG_PLEASE_ENTER_A_VALID_DATE = ( __("Please enter a valid date (should match %s).") );

    function is_valid_date(date) {
        // An empty string is considered as a valid date for convenient reasons.
        if (date === '') return 1;
        var dateformat = flatpickr_dateformat_string;
        switch ( dateformat_pref ){
            case "us":
                flatpickr_dateformat_string = "m/d/Y";
                break;
            case "metric":
                flatpickr_dateformat_string = "d/m/Y";
                break;
            case "dmydot":
                flatpickr_dateformat_string = "d.m.Y";
                break;
            default:
                flatpickr_dateformat_string = "Y-m-d";
        }
        try {
            flatpickr.parseDate(date, dateformat);
        } catch (e) {
            return 0;
        }
        return 1;
    }

    function validate_date(dateText, inst) {
        if (!is_valid_date(dateText)) {
            var dateformat_str = get_dateformat_str( dateformat_pref );
            alert(MSG_PLEASE_ENTER_A_VALID_DATE.format(dateformat_str));
            inst.clear();
        }
    }

        $(document).ready(function(){
            $(".flatpickr").flatpickr();

            $(".clear-flatpickr").on("click", function(e){
                e.preventDefault();
                var element = $(this).data("fp");
                if( element ){
                    document.querySelector("#" + element )._flatpickr.clear();
                }
            });
        });

</script>
