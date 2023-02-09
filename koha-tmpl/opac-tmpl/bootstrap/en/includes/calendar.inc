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
    var dateformat_pref = "[% Koha.Preference('dateformat') | html %]";
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

    function get_dateformat_str(dateformat) {
        var dateformat_str;
        if (dateformat == 'us') {
            dateformat_str = 'mm/dd/yyyy';
        } else if (dateformat == 'metric') {
            dateformat_str = 'dd/mm/yyyy';
        } else if (dateformat == 'iso') {
            dateformat_str = 'yyyy-mm-dd';
        } else if (dateformat == 'dmydot') {
            dateformat_str = 'dd.mm.yyyy';
        }
        return dateformat_str;
    }
</script>
[% Asset.js("lib/flatpickr/flatpickr.min.js") | $raw %]
<script>
    flatpickr.l10ns.default.weekdays = flatpickr_weekdays;
    flatpickr.l10ns.default.months   = flatpickr_months;
    flatpickr.setDefaults({
        dateFormat: "Y-m-d",
        altInput: true,
        allowInput: true,
        altFormat: flatpickr_dateformat_string,
        altInputClass: 'flatpickr-input',
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
            $(instance.input).find('~input.flatpickr:first')
                /* Add a wrapper element so that we can prevent the clear button from wrapping */
                .wrap("<span class='flatpickr_wrapper'></span>")
                .after( $("<a/>")
                    .attr("href","#")
                    .addClass("clear_date")
                    .on("click", function(e){
                        e.preventDefault();
                        instance.clear();
                    })
                    .addClass("fa fa-fw fa-times")
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
            $(".flatpickr").each(function(){
                let options = {};
                let refresh_max_date = 0;
                let disable_buttons = [];

                if( $(this).data("flatpickr-futureinclusive") === true
                 || $(this).data("flatpickr-futuredate") === true ) {
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
                        if( $(this).data("flatpickr-futureinclusive") === true ) {
                            options['minDate'] = new Date().setHours(00, 00, 00, 00);
                        } else {
                            options['minDate'] = new Date().fp_incr(1);
                        }
                    }

                    disable_buttons.push(0); /* Yesterday */

                    if ( $(this).data("flatpickr-futuredate") === true ) {
                        disable_buttons.push(1); /* Today */
                    }
                }
                if( $(this).data("flatpickr-pastinclusive") === true ) {
                    options['maxDate'] = new Date(); /* Not today or hh:mm will be 00:00 */
                    refresh_max_date = 1;
                    disable_buttons.push(2); /* Tomorrow */
                }
                if( $(this).data("flatpickr-pastdate") === true ) {
                    options['maxDate'] = new Date().fp_incr(-1).setHours(23, 59, 00, 00);
                    disable_buttons.push(1); /* Today */
                    disable_buttons.push(2); /* Tomorrow */
                }
                if ( $(this).data('flatpickr-enable-time') === true ) {
                    options['enableTime'] = true;
                    options['dateFormat'] = flatpickr_dateformat_string + " " + flatpickr_timeformat_string;
                }

                let fp = $(this).flatpickr(options);

                $(disable_buttons).each(function(index, value){
                    $(fp.calendarContainer).find(".shortcut-buttons-flatpickr-button[data-index='"+value+"']").prop("disabled", "disabled");
                });

                if ( refresh_max_date ) {
                    /* Refresh the maxDate every 30 secondes to make sure the user will not
                       be stuck with the minute passed.
                       Adding 1 minute to not introduce a gap.
                       Example: last update at 40s, a new minute passed at 00.
                       Between 00 and 10s the user won't be able click 'Today'.
                    */
                    setInterval(() => {
                        let now = new Date();
                        fp.set("maxDate", now.setMinutes(now.getMinutes() + 1));
                    }, 30000);
                }
            });
        });

</script>
