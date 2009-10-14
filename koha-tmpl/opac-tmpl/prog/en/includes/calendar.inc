<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/lib/calendar/calendar-system.css"/>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/calendar/calendar.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/calendar/calendar-en.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/calendar/calendar-setup.js"></script>
<script type="text/javascript">
//<![CDATA[
var debug    = "<!-- TMPL_VAR Name="debug" -->";
var dformat  = "<!-- TMPL_VAR Name="dateformat" -->";
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
