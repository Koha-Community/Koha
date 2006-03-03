</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME='themelang' -->/includes/favicon.ico" type="image/x-icon" />
<style type="text/css"> 
	<!-- TMPL_IF NAME="intranetstylesheet" -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/<!-- TMPL_VAR NAME="intranetstylesheet" -->);<!-- TMPL_ELSE -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/intranet.css);<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="intranetcolorstylesheet" -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/<!-- TMPL_VAR NAME="intranetcolorstylesheet" -->);<!-- /TMPL_IF -->
</style>
<style type="text/css">
.panel { 
	position:relative;
}

.countryPanel {
	background-color : #D8DEB8;
	z-index : 1;
	width : 300px;
	display : none;
	border-top : 2px outset #FFFFCC;
	border-left : 2px outset #FFFFCC;
	border-right : 2px outset #000000;
	border-bottom : 2px outset #000000;
	padding : 0;
	position : absolute;
	font-size : 80%;
}

.countryPanel h4 {
	background-color : #EFF1D8;
	color : #000066;
	margin : 0;
	padding : 3px;
	text-align : center;
}

.countryPanel p {
	text-align : center;
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
		panel.style.top = mouseY+'px';
		panel.style.left = mouseX+'px';
	}
</script>
</head>
<body onload="changeRange(document.getElementById('rangeType'))">
