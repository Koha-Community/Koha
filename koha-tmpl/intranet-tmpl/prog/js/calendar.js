/* global debug sentmsg __ dateformat_pref dateformat_string bidi calendarFirstDayOfWeek */
/* exported DateTime_from_syspref */
var MSG_PLEASE_ENTER_A_VALID_DATE = ( __("Please enter a valid date (should match %s).") );
if (debug > 1) {
    alert("dateformat: " + dateformat_pref + "\ndebug is on (level " + debug + ")");
}

function is_valid_date(date) {
    // An empty string is considered as a valid date for convenient reasons.
    if (date === '') return 1;

    var dateformat = dateformat_string;
    if (dateformat == 'us') {
        if (date.search(/^\d{2}\/\d{2}\/\d{4}($|\s)/) == -1) return 0;
        dateformat = 'mm/dd/yy';
    } else if (dateformat == 'metric') {
        if (date.search(/^\d{2}\/\d{2}\/\d{4}($|\s)/) == -1) return 0;
        dateformat = 'dd/mm/yy';
    } else if (dateformat == 'iso') {
        if (date.search(/^\d{4}-\d{2}-\d{2}($|\s)/) == -1) return 0;
        dateformat = 'yy-mm-dd';
    } else if (dateformat == 'dmydot') {
        if (date.search(/^\d{2}\.\d{2}\.\d{4}($|\s)/) == -1) return 0;
        dateformat = 'dd.mm.yy';
    }
    try {
        $.datepicker.parseDate(dateformat, date);
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
        $('#' + inst.id).val('');
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

/* Instead of including multiple localization files as you would normally see with
   jQueryUI we expose the localization strings in the default configuration */
jQuery(function ($) {
    $.datepicker.regional[''] = {
        closeText: __("Done"),
        prevText: __("Prev"),
        nextText: __("Next"),
        currentText: __("Today"),
        monthNames: [__("January"), __("February"), __("March"), __("April"), __("May"), __("June"),
            __("July"), __("August"), __("September"), __("October"), __("November"), __("December")
        ],
        monthNamesShort: [__("Jan"), __("Feb"), __("Mar"), __("Apr"), __("May"), __("Jun"),
            __("Jul"), __("Aug"), __("Sep"), __("Oct"), __("Nov"), __("Dec")
        ],
        dayNames: [__("Sunday"), __("Monday"), __("Tuesday"), __("Wednesday"), __("Thursday"), __("Friday"), __("Saturday")],
        dayNamesShort: [__("Sun"), __("Mon"), __("Tue"), __("Wed"), __("Thu"), __("Fri"), __("Sat")],
        dayNamesMin: [__("Su"), __("Mo"), __("Tu"), __("We"), __("Th"), __("Fr"), __("Sa")],
        weekHeader: __("Wk"),
        dateFormat: dateformat_string,
        firstDay: calendarFirstDayOfWeek,
        isRTL: bidi,
        showMonthAfterYear: false,
        yearSuffix: ''
    };
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

$(document).ready(function () {

    $.datepicker.setDefaults({
        showOn: "both",
        buttonImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAT0lEQVQ4jWNgoAZYd/LVf3IwigGkAuwGLE4hDg9eA4il8RqADVdtLYVjZLVEuwDZAKJcgKxh+zkyXIBuI8lhgG4jOqZdLJACMAygKDNRAgBj9qOB+rWnhAAAAABJRU5ErkJggg==",
        buttonImageOnly: true,
        buttonText: __("Select date"),
        changeMonth: true,
        changeYear: true,
        showButtonPanel: true,
        showOtherMonths: true,
        selectOtherMonths: true,
        yearRange: "c-100:c+10"
    });

    $("#dateofbirth").datepicker({
        yearRange: "c-100:c"
    });

    $(".futuredate").datepicker({
        minDate: 1, // require that hold suspended until date is after today
    });

    $(".datepicker").datepicker({
        onClose: function (dateText, inst) {
            validate_date(dateText, inst);
        },
    }).on("change", function () {
        if (!is_valid_date($(this).val())) {
            $(this).val("");
        } else {
            $(this).datepicker("setDate",$(this).val());
        }
    });
    // http://jqueryui.com/demos/datepicker/#date-range
    var dates = $(".datepickerfrom, .datepickerto").datepicker({
        changeMonth: true,
        numberOfMonths: 1,
        onSelect: function (selectedDate) {
            var option = this.id == "from" ? "minDate" : "maxDate",
                instance = $(this).data("datepicker");
            var date = $.datepicker.parseDate(
                instance.settings.dateFormat ||
                $.datepicker._defaults.dateFormat,
                selectedDate, instance.settings);
            dates.not(this).datepicker("option", option, date);
        },
        onClose: function (dateText, inst) {
            validate_date(dateText, inst);
        },
    }).on("change", function () {
        if (!is_valid_date($(this).val())) {
            $(this).val("");
        }
    });
});
