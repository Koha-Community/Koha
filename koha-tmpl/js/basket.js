//////////////////////////////////////////////////////////////////////////////
// BASIC FUNCTIONS FOR COOKIE MANGEMENT //
//////////////////////////////////////////////////////////////////////////////

var CGIBIN = "/cgi-bin/koha/";

function writeCookie(name, val, wd) {
	if (wd) {
		parent.opener.document.cookie = name + "=" + val;
	}
	else {
		parent.document.cookie = name + "=" + val;
	}
}

function readCookieValue (str, val_beg) {
	var val_end = str.indexOf(";", val_end);
	if (val_end == -1)
		val_end = str.length;
	return str.substring(val_beg, val_end);
}

function readCookie(name, wd) {
	var str_name = name + "=";
	var str_len = str_name.length;
	var str_cookie = "";
	if (wd) {
		str_cookie = parent.opener.document.cookie;
	}
	else {
		str_cookie = parent.document.cookie;
	}
	var coo_len = str_cookie.length;
	var i = 0;

	while (i < coo_len) {
		var j = i + str_len;
		if (str_cookie.substring(i, j) == str_name)
			return readCookieValue(str_cookie, j);
		i = str_cookie.indexOf(" ", i) + 1;
		if (i == 0)
			break;
	}

	return null;
}

function delCookie(name) {
	var exp = new Date();
	exp.setTime(exp.getTime()-1);
	parent.opener.document.cookie = name + "=null; expires=" + exp.toGMTString();
}


///////////////////////////////////////////////////////////////////
// SPECIFIC FUNCTIONS USING COOKIES //
///////////////////////////////////////////////////////////////////

function openBasket() {
	var strCookie = "";

	var nameCookie = "bib_list";
	var valCookie = readCookie(nameCookie);
	if (valCookie) {
		strCookie = nameCookie + "=" + valCookie;
	}

	if (strCookie) {
//		alert(strCookie);
//		return;

//		var Wmax = screen.width;
//		var Hmax = screen.height;

		var iW = 650;
		var iH = 600;

		var optWin = "dependant=yes,status=yes,scrollbars=yes,resizable=no,height="+iH+",width="+iW;
		var loc = CGIBIN + "opac-basket.pl?" + strCookie;
		var basket = open(loc, "basket", optWin);
	}
	else {
		alert(MSG_BASKET_EMPTY);
		//alert("Il n'y a aucune notice !");
	}
}


function addRecord(val, selection) {
	var nameCookie = "bib_list";
	var valCookie = readCookie(nameCookie);

	var write = 0;

	if ( ! valCookie ) { // empty basket
		valCookie = val + '/';
		write = 1;
	}
	else {
		// is this record already in the basket ?
		var found = false;
		var arrayRecords = valCookie.split("/");
		
		for (var i = 0; i < valCookie.length - 1; i++) {
			if (val == arrayRecords[i]) {
				found = true;
				break;
			}
		}

		if ( found ) {
			if (selection) {
				return 0;
			}
			alert(MSG_RECORD_IN_BASKET);
		}
		else {
			valCookie += val + '/';
			write = 1;
		}
	}

	if (write) {
		writeCookie(nameCookie, valCookie);
		if (selection) { // ajout à partir d'une sélection de notices
			return 1;
		}
		alert(MSG_RECORD_ADDED);
	}
}


function addSelRecords(valSel) { // fonction permettant d'ajouter une sélection de notices
									// (à partir d'une page de résultats) au panier
	var arrayRecords = valSel.split("/");
	var i = 0;
	var nbAdd = 0;
	for (i=0;i<arrayRecords.length;i++) {
		if (arrayRecords[i]) {
			nbAdd += addRecord(arrayRecords[i], 1);
		}
		else {
			break;
		}
	}

	var msg = "";
	if (nbAdd) {
		if (i > nbAdd) {
			msg = nbAdd+" "+MSG_NRECORDS_ADDED+", "+(i-nbAj)+" "+MSG_NRECORDS_IN_BASKET;
		}
		else {
			msg = nbAdd+" "+MSG_NRECORDS_ADDED;
		}
	}
	else {
		if (i < 1) {
			msg = MSG_NO_RECORD_SELECTED;	
		}
		else {
			msg = MSG_NO_RECORD_ADDED+" ("+MSG_NRECORDS_IN_BASKET+") !";
		}
	}
	alert(msg);
}


function selRecord(num, status) {
	var str = document.myform.records.value
	if (status){
		str += num+"/";
	}
	else {
		str = delRecord(num, str);
	}

	document.myform.records.value = str;
}


function delSelRecords() {
	var recordsSel = 0;
	var end = 0;
	var nameCookie = "bib_list";
	var valCookie = readCookie(nameCookie, 1);

	if (valCookie) {
		var str = document.myform.records.value;
		if (str.length > 0){
			recordsSel = 1;
			var str2 = valCookie;
			while (!end){
				s = str.indexOf("/");
				if (s>0){
					num = str.substring(0, s)
					str = delRecord(num,str);
					str2 = delRecord(num,str2);
				}
				else {
					end = 1;
				}
			}

			if (str2.length == 0) { // equivalent to emptying the basket
				var rep = false;
				rep = confirm(MSG_CONFIRM_DEL_BASKET);
				if (rep) { 
					delCookie(nameCookie);
					document.location = "about:blank";
					window.close();
				}
				else {
					return;
				}
			}
			else {
				writeCookie(nameCookie, str2, 1);
			}
		}
	}

	if (recordsSel) {
		var strCookie = "";
		var nameCookie = "bib_list";
		var valCookie = readCookie(nameCookie, 1);
		strCookie = nameCookie + "=" + valCookie;
		document.location = CGIBIN + "opac-basket.pl?" + strCookie;
	}
	else {
		alert(MSG_NO_RECORD_SELECTED);
	}
}


function delRecord (n, s) {
	var re = /\d/;
	var aux = s;
	var found = 0;
	var pos = -1;

	while (!found) {
		pos = aux.indexOf(n, pos+1);
		var charAfter = aux.charAt(pos+n.length); // character right after the researched string
		if (charAfter.match(re)) { // record number inside another one
			continue;
		}
		else { // good record number
			aux = s.substring(0, pos)+ s.substring(pos+n.length+1, s.length);
			s = aux;
			found = 1;
		}
	}

	return s;
}


function delBasket() {
	var nameCookie = "bib_list";

	var rep = false;
	rep = confirm(MSG_CONFIRM_DEL_BASKET);
	if (rep) {
		delCookie(nameCookie);
		document.location = "about:blank";
		window.close();
	}
}


function quit() {
	if (document.myform.records.value) {
		var rep = false;
		rep = confirm(MSG_CONFIRM_DEL_RECORDS);
		if (rep) {
			delSelRecords();
		}
	}
	window.close();
}


function sendBasket() {
	var nameCookie = "bib_list";
	var valCookie = readCookie(nameCookie);
	var strCookie = nameCookie + "=" + valCookie;

	var loc = CGIBIN + "opac-sendbasket.pl?" + strCookie;

	var optWin="dependant=yes,scrollbars=no,resizable=no,height=300,width=400,top=50,left=100";
	var win_form = open(loc,"win_form",optWin);
}


function printBasket() {
	var loc = document.location + "&print=1";
	document.location = loc;
}
