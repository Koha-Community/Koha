</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-system.css">

<!-- Estos scripts permiten manejar calendario de fechas. -->
<script type="text/javascript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/calendar/calendar.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/calendar/calendar-en.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/calendar/calendar-setup.js"></script>
<!-- **************************************************** -->

<script language="JavaScript" type="text/javascript">
	// Captura el evento onmousemove para cualquier navegador
	if (document.layers) { // Netscape
		document.captureEvents(Event.MOUSEMOVE);
	    document.onmousemove = captureMousePosition;
	} else if (document.all) { // Internet Explorer
	    document.onmousemove = captureMousePosition;
	} else if (document.getElementById) { // Netcsape 6
	    document.onmousemove = captureMousePosition;
	}

	var mouseXMax = 0;
	var mouseYMax = 0;
	var mouseX = 0;
	var mouseY = 0;

	function captureMousePosition(e) {
	    if (document.layers) {
		    mouseX = e.pageX;
			mouseY = e.pageY;
	        mouseXMax = window.innerWidth + window.pageXOffset;
		    mouseYMax = window.innerHeight + window.pageYOffset;
	    } else if (document.all) {
		    mouseX = window.event.x + document.body.scrollLeft;
	        mouseY = window.event.y + document.body.scrollTop;
	        mouseXMax = document.body.clientWidth + document.body.scrollLeft;
	        mouseYMax = document.body.clientHeight + document.body.scrollTop;
	    } else if (document.getElementById) {
	        mouseX = e.pageX;
		    mouseY = e.pageY;
	        mouseXMax = window.innerWidth + window.pageXOffset;
	        mouseYMax = window.innerHeight + window.pageYOffset;
	    }
	}

	function holidayOperation(formObject, opType) {
		var op = document.getElementsByName('operation');
		op[0].value = opType;
		formObject.submit();
	}

	// This function shows the "Show Holiday" panel //
	function showHoliday (exceptionPosibility, dayName, day, month, year, weekDay, title, description) {
		
		var panel = document.getElementById('showHoliday');
		panel.style.display = 'inline';
		document.getElementById('newHoliday').style.display = 'none';
		panel.style.top = mouseYMax/2;
		panel.style.left = (mouseXMax/2) - 250;
		document.getElementById('showDayname').value = dayName;
		document.getElementById('showBranchName').value = document.getElementById('branch').value;
		document.getElementById('showDay').value = day;
		document.getElementById('showMonth').value = month;
		document.getElementById('showYear').value = year;
		document.getElementById('showDescription').value = description;
		document.getElementsByName('showWeekday')[0].value = weekDay;
		document.getElementById('showTitle').value = title;
		
		if (exceptionPosibility == 1) {
			document.getElementById('exceptionPosibility').style.display = 'inline';
		} else {
			document.getElementById('exceptionPosibility').style.display = 'none';
		}
	}

	// This function shows the "Add Holiday" panel //
	function newHoliday (dayName, day, month, year, weekDay) {
		var panel = document.getElementById('newHoliday');
		panel.style.display = 'inline';
		document.getElementById('showHoliday').style.display = 'none';
		panel.style.top = mouseYMax/2;
		panel.style.left = (mouseXMax/2)  - 250;
		document.getElementById('newDayname').value = dayName;
		document.getElementById('newBranchName').value = document.getElementById('branch').value;
		document.getElementById('newDay').value = day;
		document.getElementById('newMonth').value = month;
		document.getElementById('newYear').value = year;
		document.getElementsByName('newWeekday')[0].value = weekDay;
	}

	function hidePanel(aPanelName) {
		document.getElementById(aPanelName).style.display = 'none';
	}

	function changeBranch () {
		var branch = document.getElementById('branch').options[document.getElementById('branch').selectedIndex].value;
		location.href='/cgi-bin/koha/tools/holidays.pl?branch=' + branch;
	}

	function additionalInformation (anExplanation) {
		var panel = document.getElementById('information');
		var paragraph = document.getElementById('explanation');
		panel.style.display = 'inline'
		panel.style.top = mouseY;
		panel.style.left = mouseX;
		var info = document.createTextNode(anExplanation);
		if (paragraph.hasChildNodes()) {
			paragraph.removeChild(paragraph.lastChild);
		}
		paragraph.appendChild(info);
	}

	function Help() {
		newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
	}
</script>

<style type="text/css">
.normalday { 
	background-color: #EDEDED;
	color: Black; 
	border:1px solid #000000;
}

.exception {
	background-color: #EDEDED;
	color: Black; 		
	border:1px solid #000000;
}

.holiday { 
	background-color: red;
	color: Black; 
	border:1px solid #000000;
}

.repeatableday { 
	background-color: yellow;
	color: Black; 
	border:1px solid #000000;
}

.information {
	z-index:1;
	background-color: #DCD2F1;
	width:300px;
	display:none;
	border:1px solid #000000;
	color: #000000;
	font-size: 8pt;
	font-weight: bold;
    background-color: #FFD700;
	cursor: pointer;
	padding:2px;
}

.panel {
	z-index:1;
	width:500px;
	display:none;
	border:1px solid #000000;
	padding:0px;
}

</style>


