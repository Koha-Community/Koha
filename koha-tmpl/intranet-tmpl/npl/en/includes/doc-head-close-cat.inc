</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME='themelang' -->/includes/favicon.ico" type="image/x-icon" />
<style type="text/css"> 
	@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/intranet.css);
</style>
<script language="JavaScript" type="text/javascript">
<!-- Hide from old browsers
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}

function openWindow(targeturl, windowname) {
	newwin =
	window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
 
 	var newwin;
	
	// Open the popup window if it doesn't already exist and give it focus.
	function PopWin(targeturl, windowname) {
	
		if (!newwin || newwin.closed) newwin = window.open(targeturl,windowname, "height=300,width=400,scrollbars=yes,resizable=yes");
	  newwin.focus();
	}
	
  // Set the value of the form field to the passed value and optionally shift
	// focus and close the popup.
	function FillForm(val,formname,formfield) {
	
		document.forms[formname].elements[formfield].value = val;

		// Uncomment below to shift focus after clicking link in popup.
		document.forms[formname].elements[formfield].focus();
		
		// Uncomment below to close popup after clicking link.
		newwin.close();
	}
 
function hideSearchsTypes() {
            document.getElementById('precise_form').style.display = 'none';
            document.getElementById('loose_form').style.display = 'none';
            document.getElementById('keyword_form').style.display = 'none';
		}

		function resetButtonsColors() {
			document.getElementById('searchType1').style.backgroundColor = 'orange';
			document.getElementById('searchType2').style.backgroundColor = 'orange';
			document.getElementById('searchType3').style.backgroundColor = 'orange';
		}

		function changeSearch1() {
		    resetButtonsColors();
		    document.getElementById('searchType1').style.backgroundColor = 'yellow';
		    hideSearchsTypes();
		  //  document.getElementById('keyword_form').reset();
		    document.getElementById('keyword_form').style.display = 'inline';
		}

        function changeSearch2() {
            resetButtonsColors();
		    document.getElementById('searchType2').style.backgroundColor = 'yellow';
		    hideSearchsTypes();
		    //document.getElementById('precise_form').reset;
		    document.getElementById('precise_form').style.display = 'inline';
		}

		function changeSearch3() {
		    resetButtonsColors();
		    document.getElementById('searchType3').style.backgroundColor = 'yellow';
		    hideSearchsTypes();
		   // document.getElementById('loose_form').reset();
		    document.getElementById('loose_form').style.display = 'inline';
		}
		
		function checkKeywordSearch() {
		if (document.keyword_form.keyword.value == '') {
			alert("Enter a word to start searching.");
			return false;
		} else {
		    return true;
		}
	}

	function checkLooseSearch() {
		if ( document.loose_form.field_value1.value == '' ) {
			alert("Enter at least the first search to start searching.");
			document.loose_form.field_value1.focus();
			return false;
		    } else {
		        return true;
		    }
	}

	function checkPreciseSearch() {
		if ( (document.precise_form.itemnumber.value == '') &&
			(document.precise_form.isbn.value == '') && (document.precise_form.biblionumber.value == '') ) {
			alert("Enter a barcode or ISBN or Biblionumber to start searching.");
			return false;
		} else {
		    return true;
		}
	}


	function openDictionary(dict, search, target) {
	    if ((dict == 'all') || (dict == 'publicationyear')) {
	        alert("The selected field is not correct to search on dictionary.");
		} else {
	    	var dict_window = window.open('/cgi-bin/koha/dictionary.pl?dictionary=' + dict + '&search=' + search + '&target=' + target,'_blanck','height=325,width=550,status=no,toolbar=no,menubar=no,location=no,resizable=no,top=100,left=100');
        	dict_window.focus();
		}
	}


		
	</script>

<style type="text/css">
.catalogue {
	background-color: #ad11ad;
	color:#FFFFFF;
	background-image:none;
	text-decoration: normal;
}
.catalogueReservesLabel {
	background-color:#5e11ac;
	color:#FFFFFF;
	background-image:none;
	text-decoration: normal;	
}
.emptyCell {
	background-color: transparent;
	color:#FFFFFF;
	background-image: none;
	border: 0px solid;
}

a.catalogue:hover {
	background-color: #ad11ad;
	color: #FFFFFF;
	text-decoration: none;
	}

.searchtype {
    height: 20px;
    font-size: 9px;
	text-align: center;
	padding: 3px, 8px, 3px, 8px;
	border:0px solid black;
	text-decoration: none;
	color: black;
	border-radius: 6px;
	-moz-border-radius: 6px;
	background-color: orange;
	margin : 3px;
	vertical-align: middle;
	}

.searchtypeselected {
    height: 20px;
    font-size: 9px;
	text-align: center;
	padding: 3px, 8px, 3px, 8px;
	border:0px solid black;
	text-decoration: none;
	color: black;
	border-radius: 6px;
	-moz-border-radius: 6px;
	background-color: yellow;
	margin : 3px;
	vertical-align: middle;
}
.catalogue_button {
	border-width: 1px;
	border-color: black;
	text-decoration: none;
	border-radius: 6px;
	cursor:pointer;
	vertical-align:middle;
	-moz-border-radius: 6px;
	background-color: #ad11ad;
	color:#FFFFFF;
}
</style>

</head>

<body>