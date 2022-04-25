/* global debug sentmsg __ dateformat_pref flatpickr_dateformat_string bidi calendarFirstDayOfWeek */
/* exported DateTime_from_syspref flatpickr_weekdays flatpickr_months */
var MSG_PLEASE_ENTER_A_VALID_DATE = ( __("Please enter a valid date (should match %s).") );
if (debug > 1) {
    alert("dateformat: " + dateformat_pref + "\ndebug is on (level " + debug + ")");
}

function is_valid_date(date) {
    // An empty string is considered as a valid date for convenient reasons.
    if (date === '') return 1;
    var dateformat = flatpickr_dateformat_string;
    if (dateformat == 'us') {
        if (date.search(/^\d{2}\/\d{2}\/\d{4}($|\s)/) == -1) return 0;
        dateformat = 'm/d/Y';
    } else if (dateformat == 'metric') {
        if (date.search(/^\d{2}\/\d{2}\/\d{4}($|\s)/) == -1) return 0;
        dateformat = 'd/m/Y';
    } else if (dateformat == 'iso') {
        if (date.search(/^\d{4}-\d{2}-\d{2}($|\s)/) == -1) return 0;
        dateformat = 'Y-m-d';
    } else if (dateformat == 'dmydot') {
        if (date.search(/^\d{2}\.\d{2}\.\d{4}($|\s)/) == -1) return 0;
        dateformat = 'd.m.Y';
    }
    try {
        flatpickr.parseDate(date, dateformat);
    } catch (e) {
        return 0;
    }
    return 1;
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

function validate_date(dateText, inst) {
    if (!is_valid_date(dateText)) {
        var dateformat_str = get_dateformat_str( dateformat_pref );
        alert(MSG_PLEASE_ENTER_A_VALID_DATE.format(dateformat_str));
        inst.clear();
    }
}

function Date_from_syspref(dstring) {
    var dateX = dstring.split(/[-/.]/);
    if (debug > 1 && sentmsg < 1) {
        sentmsg++;
        alert("Date_from_syspref(" + dstring + ") splits to:\n" + dateX.join("\n"));
    }
    if (dateformat_pref === "iso") {
        return new Date(dateX[0], (dateX[1] - 1), dateX[2]); // YYYY-MM-DD to (YYYY,m(0-11),d)
    } else if (dateformat_pref === "us") {
        return new Date(dateX[2], (dateX[0] - 1), dateX[1]); // MM/DD/YYYY to (YYYY,m(0-11),d)
    } else if (dateformat_pref === "metric") {
        return new Date(dateX[2], (dateX[1] - 1), dateX[0]); // DD/MM/YYYY to (YYYY,m(0-11),d)
    } else if (dateformat_pref === "dmydot") {
        return new Date(dateX[2], (dateX[1] - 1), dateX[0]); // DD.MM.YYYY to (YYYY,m(0-11),d)
    } else {
        if (debug > 0) {
            alert("KOHA ERROR - Unrecognized date format: " + dateformat_pref);
        }
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

    if (hour < 0 || hour > 23) {
        return 0;
    }
    if (minute < 0 || minute > 59) {
        return 0;
    }

    var datetime = Date_from_syspref(date);

    if (isNaN(datetime.getTime())) {
        return 0;
    }

    datetime.setHours(hour);
    datetime.setMinutes(minute);

    return datetime;
}

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
                is_date_after: __("Validation error to be shown, i.e. End date must come after start date")
            }
        }
    });
*/

jQuery.validator.addMethod("is_date_after",
    function (value, element, params) {
        var from = Date_from_syspref($(params).val());
        var to = Date_from_syspref(value);
        return to > from;
    });

jQuery.validator.addMethod("date_on_or_after",
    function (value, element, params) {
        var from = Date_from_syspref($(params).val());
        var to = Date_from_syspref(value);
        return to >= from;
    });

var flatpickr_weekdays = {
    shorthand: [ __("Sun"), __("Mon"), __("Tue"), __("Wed"), __("Thu"), __("Fri"), __("Sat")],
    longhand: [ __("Sunday"), __("Monday"), __("Tuesday"), __("Wednesday"), __("Thursday"), __("Friday"), __("Saturday") ]
};

var flatpickr_months = {
    shorthand: [ __("Jan"), __("Feb"), __("Mar"), __("Apr"), __("May"), __("Jun"), __("Jul"), __("Aug"), __("Sep"), __("Oct"), __("Nov"), __("Dec")],
    longhand: [ __("January"), __("February"), __("March"), __("April"), __("May"), __("June"), __("July"), __("August"), __("September"), __("October"), __("November"), __("December")]
};
