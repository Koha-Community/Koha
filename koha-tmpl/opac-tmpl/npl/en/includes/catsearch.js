function hideSearchsTypes() {
	  document.getElementById('simple').style.display = 'none';
            document.getElementById('advanced').style.display = 'none';
            document.getElementById('power').style.display = 'none';
            document.getElementById('proximity').style.display = 'none';
		}

		function resetButtonsColors() {
			document.getElementById('simple_formButton').className = 'off';
			document.getElementById('advanced_formButton').className = 'off';
			document.getElementById('power_formButton').className = 'off';
			document.getElementById('proximity_formButton').className = 'off';
		}

		function changeSearch(divid) {
			resetButtonsColors();
			var navlink = divid+"_formButton";
		    document.getElementById(navlink).className = 'on';
		    hideSearchsTypes();
		  //  document.getElementById('keyword_form').reset();
		    document.getElementById(divid).style.display = 'block';
		}

		function checkKeywordSearch() {
		if (document.keyword_form.keyword.value == '' && document.keyword_form.callno.value == '') {
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
