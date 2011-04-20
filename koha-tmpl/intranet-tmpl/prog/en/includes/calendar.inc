<link rel="stylesheet" type="text/css" href="[% themelang %]/lib/calendar/calendar-system.css"/>
<script type="text/javascript" src="[% themelang %]/lib/calendar/calendar.js"></script>
<script type="text/javascript">
// full day names
Calendar._DN = new Array(_("Sunday"),_("Monday"),_("Tuesday"),_("Wednesday"),_("Thursday"),_("Friday"),_("Saturday"),_("Sunday"));
// short day names
Calendar._SDN = new Array(_("Sun"),_("Mon"),_("Tue"),_("Wed"),_("Thu"),_("Fri"),_("Sat"),_("Sun"));
// First day of the week. "0" means display Sunday first, "1" means display
// Monday first, etc.
Calendar._FD = 1;
// full month names
Calendar._MN = new Array(_("January"),_("February"),_("March"),_("April"),_("May"),_("June"),_("July"),_("August"),_("September"),_("October"),_("November"),_("December"));
// short month names
Calendar._SMN = new Array(_("Jan"),_("Feb"),_("Mar"),_("Apr"),_("May"),_("Jun"),_("Jul"),_("Aug"),_("Sep"),_("Oct"),_("Nov"),_("Dec"));
// tooltips
Calendar._TT = {};
Calendar._TT["INFO"] = _("About the calendar");

Calendar._TT["ABOUT"] =
_("Dhtml Date/Time Selector")+"\n" +
"(c) dynarch.com 2002-2003\n" + // don't translate this this ;-)
_("For latest version visit: http://dynarch.com/mishoo/calendar.epl")+"\n" +
_("Distributed under GNU LGPL.  See http://gnu.org/licenses/lgpl.html for details.") +
"\n\n" +
_("Date selection:")+"\n" +
_("- Use the \xab, \xbb buttons to select year")+"\n" +
_("- Use the " + String.fromCharCode(0x2039) + ", " + String.fromCharCode(0x203a) + " buttons to select month")+"\n" +
_("- Hold mouse button on any of the above buttons for faster selection.");
Calendar._TT["ABOUT_TIME"] = "\n\n" +
_("Time selection:")+"\n" +
_("- Click on any of the time parts to increase it")+"\n" +
_("- or Shift-click to decrease it")+"\n" +
_("- or click and drag for faster selection.");

Calendar._TT["PREV_YEAR"] = _("Prev. year (hold for menu)");
Calendar._TT["PREV_MONTH"] = _("Prev. month (hold for menu)");
Calendar._TT["GO_TODAY"] = _("Go to Today");
Calendar._TT["NEXT_MONTH"] = _("Next month (hold for menu)");
Calendar._TT["NEXT_YEAR"] = _("Next year (hold for menu)");
Calendar._TT["SEL_DATE"] = _("Select date");
Calendar._TT["DRAG_TO_MOVE"] = _("Drag to move");
Calendar._TT["PART_TODAY"] = _(" (today)");

// the following is to inform that "%s" is to be the first day of week
// %s will be replaced with the day name.
Calendar._TT["DAY_FIRST"] = _("Display %s first");

// This may be locale-dependent.  It specifies the week-end days, as an array
// of comma-separated numbers.  The numbers are from 0 to 6: 0 means Sunday, 1
// means Monday, etc.
Calendar._TT["WEEKEND"] = "0,6";

Calendar._TT["CLOSE"] = _("Close");
Calendar._TT["TODAY"] = _("Today");
Calendar._TT["TIME_PART"] = _("(Shift-)Click or drag to change value");

// date formats
Calendar._TT["DEF_DATE_FORMAT"] = "%Y-%m-%d";
Calendar._TT["TT_DATE_FORMAT"] = "%a, %b %e";

Calendar._TT["WK"] = _("wk");
Calendar._TT["TIME"] = _("Time:");
</script>
<script type="text/javascript" src="[% themelang %]/lib/calendar/calendar-setup.js"></script>
<script type="text/javascript">
//<![CDATA[
var debug    = "[% debug %]";
var dformat  = "[% dateformat %]";
var sentmsg = 0;
if (debug > 1) {alert("dateformat: " + dformat + "\ndebug is on (level " + debug + ")");}

function Date_from_syspref(dstring) {
	var dateX = dstring.split(/[-/]/);
	if (debug > 1 && sentmsg < 1) {sentmsg++; alert("Date_from_syspref(" + dstring + ") splits to:\n" + dateX.join("\n"));}
	if (dformat === "iso") {
		return new Date(dateX[0], (dateX[1] - 1), dateX[2]);  // YYYY-MM-DD to (YYYY,m(0-11),d)
	} else if (dformat === "us") {
		return new Date(dateX[2], (dateX[0] - 1), dateX[1]);  // MM/DD/YYYY to (YYYY,m(0-11),d)
	} else if (dformat === "metric") {
		return new Date(dateX[2], (dateX[1] - 1), dateX[0]);  // DD/MM/YYYY to (YYYY,m(0-11),d)
	} else {
		if (debug > 0) {alert("KOHA ERROR - Unrecognized date format: " +dformat);}
		return 0;
	}
}

function get_Calendar_limit (date,did) {
	// this function could be moved to a static calendar-extras.js file
	var dvalue = document.getElementById(did).value;
	if (dvalue == "") { return false; }
	var limitDate = Date_from_syspref(dvalue);
	if (debug && debug > 5) {
		var month = date.getMonth() + 1;
		var dateString = date.getFullYear() + '-' + month + '-' + date.getDate();
		alert("Comparing incoming (" + dateString + ") vs "
			+ "'" + did + "' limit\n"
			+ "\n thisdate: " + date
			+ "\nlimitdate: " + limitDate
			+ "\nlimit > thisdate : " + (limitDate > date) 
			+ "\nlimit < thisdate : " + (limitDate < date) 
		);
	}
	return limitDate;
}
//]]>
</script>
