[% USE Koha %]
<script type="text/javascript">
//<![CDATA[

var debug    = "[% debug | html %]";
var dformat  = "[% dateformat | html %]";
var sentmsg = 0;
if (debug > 1) {alert("dateformat: " + dformat + "\ndebug is on (level " + debug + ")");}
var MSG_PLEASE_ENTER_A_VALID_DATE = (_("Please enter a valid date (should match %s)."));

function is_valid_date(date) {
    // An empty string is considered as a valid date for convenient reasons.
    if ( date === '' ) return 1;

    var dateformat = dateformat_str = '[% Koha.Preference('dateformat') | html %]';
    if ( dateformat == 'us' ) {
        if ( date.search(/^\d{2}\/\d{2}\/\d{4}($|\s)/) == -1 ) return 0;
        dateformat = 'mm/dd/yy';
    } else if ( dateformat == 'metric' ) {
        if ( date.search(/^\d{2}\/\d{2}\/\d{4}($|\s)/) == -1 ) return 0;
        dateformat = 'dd/mm/yy';
    } else if (dateformat == 'iso' ) {
        if ( date.search(/^\d{4}-\d{2}-\d{2}($|\s)/) == -1 ) return 0;
        dateformat = 'yy-mm-dd';
    } else if ( dateformat == 'dmydot' ) {
        if ( date.search(/^\d{2}\.\d{2}\.\d{4}($|\s)/) == -1 ) return 0;
        dateformat = 'dd.mm.yy';
    }
    try {
        $.datepicker.parseDate(dateformat, date);
    } catch (e) {
        return 0;
    };
    return 1;
}

function get_dateformat_str(dateformat) {
    var dateformat_str;
    if ( dateformat == 'us' ) {
        dateformat_str = 'mm/dd/yyyy';
    } else if ( dateformat == 'metric' ) {
        dateformat_str = 'dd/mm/yyyy';
    } else if (dateformat == 'iso' ) {
        dateformat_str = 'yyyy-mm-dd';
    } else if ( dateformat == 'dmydot' ) {
        dateformat_str = 'dd.mm.yyyy';
    }
    return dateformat_str;
}

function validate_date (dateText, inst) {
    if ( !is_valid_date(dateText) ) {
        var dateformat_str = get_dateformat_str( '[% Koha.Preference('dateformat') | html %]' );
        alert(MSG_PLEASE_ENTER_A_VALID_DATE.format(dateformat_str));
        $('#'+inst.id).val('');
    }
}

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

function DateTime_from_syspref(date_time) {
        var parts = date_time.split(" ");
        var date = parts[0];
        var time = parts[1];
        parts = time.split(":");
        var hour = parts[0];
        var minute = parts[1];

        if ( hour < 0 || hour > 23 ) {
            return 0;
        }
        if ( minute < 0 || minute > 59 ) {
            return 0;
        }

        var datetime = Date_from_syspref( date );

        if ( isNaN( datetime.getTime() ) ) {
            return 0;
        }

        datetime.setHours( hour );
        datetime.setMinutes( minute );

        return datetime;
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
        dateFormat: "[% IF ( dateformat == "us" ) %]mm/dd/yy[% ELSIF ( dateformat == "metric" ) %]dd/mm/yy[% ELSIF ( dateformat == "dmydot" ) %]dd.mm.yy[% ELSE %]yy-mm-dd[% END %]",
        firstDay: [% Koha.Preference('CalendarFirstDayOfWeek') | html %],
        isRTL: [% IF ( bidi ) %]true[% ELSE %]false[% END %],
        showMonthAfterYear: false,
        yearSuffix: ''};
    $.datepicker.setDefaults($.datepicker.regional['']);
});

/*  jQuery Validator plugin custom method
    This allows you to check that a given date falls after another.
    It is required that a message be defined.

   Syntax:
       $("#form_id").validate({
        rules: {
            input_name_of_later_date_field: {
                is_date_after: "#input_id_of_earlier_date_field"
            },
        },
        messages: {
            input_name_of_later_date_field: {
                is_date_after: _("Validation error to be shown, i.e. End date must come after start date")
            }
        }
    });
*/

jQuery.validator.addMethod("is_date_after",
function(value, element, params) {
    var from = Date_from_syspref( $(params).val() );
    var to = Date_from_syspref(value);
    return to > from;
});

jQuery.validator.addMethod("date_on_or_after",
function(value, element, params) {
    var from = Date_from_syspref( $(params).val() );
    var to = Date_from_syspref(value);
    return to >= from;
});

$(document).ready(function(){

$.datepicker.setDefaults({
        showOn: "both",
        changeMonth: true,
        changeYear: true,
        buttonImage: '[% interface | html %]/[% theme | html %]/img/famfamfam/silk/calendar.png',
        buttonImageOnly: true,
        showButtonPanel: true,
        showOtherMonths: true,
        selectOtherMonths: true,
        yearRange: "c-100:c+10"
    });

$("#dateofbirth").datepicker({
        yearRange: "c-100:c"
    });

    $( ".datepicker" ).datepicker({
        onClose: function(dateText, inst) {
            validate_date(dateText, inst);
        },
    }).on("change", function(e, value) {
        if ( ! is_valid_date( $(this).val() ) ) {$(this).val("");}
    });
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
        },
        onClose: function(dateText, inst) {
            validate_date(dateText, inst);
        },
    }).on("change", function(e, value) {
        if ( ! is_valid_date( $(this).val() ) ) {$(this).val("");}
    });
});
//]]>
</script>
