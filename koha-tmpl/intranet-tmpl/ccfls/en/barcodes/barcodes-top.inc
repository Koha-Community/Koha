<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: Parameters</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<style>
.parameters {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
a.parameters:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
.ranges {
	border:0;
}

.myTable TD{
  border-width: 0px;
  border-color: navy;
  border-style: solid;
}

.panel { 
	position:relative;
}

.countryPanel {
	z-index:1;
	width:300px;
	display:none;
	border:1px solid #000000;
	padding:0px;
}
</style>


<script type="text/javascript">
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

/* Devuelve true si el explorador es Internet Explorer */
var IE = document.all?true:false;

function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}

function correctRange (from, to) {
	if (from <= to) {
		return true;
	} else {
		return false;
	}
}

function emptyField (field) {
	if ((field == null) || (field == "")) {
		return true;
	} else {
		return false;
	}
}

function checkFields (aForm) {
  var option = document.getElementById('rangeType').value;
  if (option == 'continuous' || option == 'continuous2') {
	if (emptyField(aForm.from.value) || emptyField(aForm.to.value)) {
		alert("Please, complete all fields");
	    return false;
	} else {
		if (correctRange(aForm.from.value, aForm.to.value)) {
			return true;			
		} else {
			alert("The selected range is not correct");
			return false;
		}
	}
  } else {
	var codeCount = document.getElementById('inventaryList').options.length;
	if (codeCount == 0) {
		alert("Please, complete all fields"); 
	    return false;
	} else {
		var inventaryList = document.getElementById('inventaryList');
		var allCodes = '';
	  	for (i = 0; i <= inventaryList.options.length - 1; i++) {
			allCodes = allCodes + "'" + inventaryList.options[i].text + "',";
	  	}
  		allCodes = '(' + allCodes.substr(0, allCodes.length - 1) + ')';
	  	document.getElementById('individualCodes').value = allCodes;
	    return true;
	}
  }
}

function changeRange(selectBox) {
	var option = selectBox.value;
	var panel = document.getElementById(option);
	panel.style.display = 'inline';
	if (option == 'continuous') {
		document.getElementById('inventaryList').options.length = 0;
		document.getElementById('individuals').style.display = 'none';
		document.getElementById('individualCodes').value = "";
	} else {
		document.getElementById('from').value = "";
		document.getElementById('to').value = "";
		document.getElementById('continuous').style.display = 'none';
	}
}

function itemExists(code, list) {
  var ok = false;
  var listLength = list.length - 1;
  var count = 0;
  while (!(ok) && (count <= listLength)) {
	if (code == list[count].value) {
	  ok = true;
	}
	count = count + 1;
  }
  return ok;	
}

function addItem() {
  var codeObject = document.getElementById('inventaryCode');
  var inventaryCode = document.getElementById('inventaryCode').value;
  var inventaryList = document.getElementById('inventaryList');
  if (inventaryCode == "") {
    alert('You can´t add an empty code.');
  } else {
    if (itemExists(inventaryCode, inventaryList.options)) {
	  codeObject.value = "";
  	  alert("The code is already included."); 
    } else {  	
	  var optionObject = new Option(inventaryCode, inventaryCode);
  	   if (!IE) {
	     inventaryList.add(optionObject, inventaryList.options[inventaryList.options.length]); 
      } else {
	    inventaryList.add(optionObject, inventaryList.options.length);
	  }
      codeObject.value = "";
    }
  }	
}

function removeItem() {
  var inventaryList = document.getElementById('inventaryList');
  if (inventaryList.selectedIndex == -1) {
  	alert('You have to select a code first.');
  } else {
  	inventaryList.options[inventaryList.selectedIndex] = null;
  }
}

	function addCountryCode() {
		var panel = document.getElementById('addCountryCode');
		panel.style.display = 'inline';
		panel.style.top = mouseY;
		panel.style.left = mouseX;
	}
</script>
</head>
<body onload="javascript: changeRange(document.getElementById('rangeType'))">
<!-- MENUS -->
<div id="menubar">
	<span class="koha">KOHA</span>
	<a class="home" href="/cgi-bin/koha/mainpage.pl">Home</a>
	<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet">Catalogue</a>
	<a class="members" href="/cgi-bin/koha/members/members-home.pl">Members</a>
	<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a>
	<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
	<a class="authority" href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a>
	<a class="reports" href="/cgi-bin/koha/reports-home.pl">Reports</a>
	<a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parameters</a>
	<a class="about" href="/cgi-bin/koha/about.pl">About</a>
	<a class="catalogue" href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">Help</a>
</div>
<div id="submenu">
	<span class="koha">options &gt;&gt;&nbsp;&nbsp;</span>
	<a href="/cgi-bin/koha/admin/aqbookfund.pl" class="submenu">Funds</a>
	<a href="/cgi-bin/koha/admin/authorised_values.pl" class="submenu2">Auth value</a>
	<a href="/cgi-bin/koha/admin/thesaurus.pl" class="submenu">Thesaurus</a>
	<a href="/cgi-bin/koha/admin/currency.pl" class="submenu2">Currencies</a>
	<a href="/cgi-bin/koha/admin/printers.pl" class="submenu">Printers</a>
</div>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha</p>
<!-- /TMPL_IF -->
