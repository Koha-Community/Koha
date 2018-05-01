[% USE Koha %]
<script>
    //<![CDATA[
        var debug    = "[% debug %]";
        var dformat  = "[% dateformat %]";
        var sentmsg = 0;
        if (debug > 1) {alert("dateformat: " + dformat + "\ndebug is on (level " + debug + ")");}

        function Date_from_syspref(dstring) {
                var dateX = dstring.split(/[-/.]/);
                if (debug > 1 && sentmsg < 1) {sentmsg++; alert("Date_from_syspref(" + dstring + ") splits to:\n" + dateX.join("\n"));}
                if (dformat === "iso") {
                        return new Date(dateX[0], (dateX[1] - 1), dateX[2]);  // YYYY-MM-DD to (YYYY,m(0-11),d)
                } else if (dformat === "us") {
                        return new Date(dateX[2], (dateX[0] - 1), dateX[1]);  // MM/DD/YYYY to (YYYY,m(0-11),d)
                } else if (dformat === "metric") {
                        return new Date(dateX[2], (dateX[1] - 1), dateX[0]);  // DD/MM/YYYY to (YYYY,m(0-11),d)
                } else if (dformat === "dmydot") {
                        return new Date(dateX[2], (dateX[1] - 1), dateX[0]);  // DD.MM.YYYY to (YYYY,m(0-11),d)
                } else {
                        if (debug > 0) {alert("KOHA ERROR - Unrecognized date format: " +dformat);}
                        return 0;
                }
        }

        /* Instead of including multiple localization files as you would normally see with
           jQueryUI we expose the localization strings in the default configuration */
        jQuery(function($){
            $.datepicker.regional[''] = {
                closeText: _("Done"),
                prevText: _("Prev"),
                nextText: _("Next"),
                currentText: _("Today"),
                monthNames: [_("January"),_("February"),_("March"),_("April"),_("May"),_("June"),
                _("July"),_("August"),_("September"),_("October"),_("November"),_("December")],
                monthNamesShort: [_("Jan"), _("Feb"), _("Mar"), _("Apr"), _("May"), _("Jun"),
                _("Jul"), _("Aug"), _("Sep"), _("Oct"), _("Nov"), _("Dec")],
                dayNames: [_("Sunday"), _("Monday"), _("Tuesday"), _("Wednesday"), _("Thursday"), _("Friday"), _("Saturday")],
                dayNamesShort: [_("Sun"), _("Mon"), _("Tue"), _("Wed"), _("Thu"), _("Fri"), _("Sat")],
                dayNamesMin: [_("Su"),_("Mo"),_("Tu"),_("We"),_("Th"),_("Fr"),_("Sa")],
                weekHeader: _("Wk"),
                dateFormat: '[% IF ( dateformat == "us" ) %]mm/dd/yy[% ELSIF ( dateformat == "metric" ) %]dd/mm/yy[% ELSIF ( dateformat == "dmydot" ) %]dd.mm.yy[% ELSE %]yy-mm-dd[% END %]',
                firstDay: [% Koha.Preference('CalendarFirstDayOfWeek') %],
                isRTL: [% IF ( bidi ) %]true[% ELSE %]false[% END %],
                showMonthAfterYear: false,
                yearSuffix: ''};
            $.datepicker.setDefaults($.datepicker.regional['']);
        });

        $(document).ready(function(){

        $.datepicker.setDefaults({
                showOn: "both",
                changeMonth: true,
                changeYear: true,
                buttonImage: '[% interface %]/lib/famfamfam/silk/calendar.png',
                buttonImageOnly: true,
                showButtonPanel: true,
                showOtherMonths: true,
                yearRange: "c-100:c+10"
            });

        $("#borrower_dateofbirth").datepicker({
                yearRange: "c-100:c"
            });

            $( ".datepicker" ).datepicker();
            // http://jqueryui.com/demos/datepicker/#date-range
            var dates = $( ".datepickerfrom, .datepickerto" ).datepicker({
                changeMonth: true,
                numberOfMonths: 1,
                onSelect: function( selectedDate ) {
                    var option = this.id == "from" ? "minDate" : "maxDate",
                        instance = $( this ).data( "datepicker" );
                        date = $.datepicker.parseDate(
                            instance.settings.dateFormat ||
                            $.datepicker._defaults.dateFormat,
                            selectedDate, instance.settings );
                    dates.not( this ).datepicker( "option", option, date );
                }
            });
        });
    //]]>
</script>
