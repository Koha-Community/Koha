<script language="JavaScript" type="text/javascript">
//
function isNotNull(f,noalert) {
	if (f.value.length ==0) {
		return false;
	}
	return true;
}
//
function toUC(f) {
	var x=f.value.toUpperCase();
	f.value=x;
	return true;
}
//
function isNum(v,maybenull) {
var n = new Number(v.value);
if (isNaN(n)) {
	return false;
	}
if (maybenull==0 && v.value=='') {
	return false;
}
return true;
}
//
function isDate(f) {
	var t = Date.parse(f.value);
	if (isNaN(t)) {
		return false;
	}
}
//
function Check(f) {
	var ok=1;
	var _alertString="";
	var alertString2;
	if (f.itemtype.value.length==0) {
		_alertString += "- itemtype missing\n";
	}
	if (!(isNotNull(window.document.Aform.description,1))) {
		_alertString += "- description missing\n";
	}
	if ((!isNum(f.loanlength,0)) && f.loanlength.value.length > 0) {
		_alertString += "- loan length is not a number\n";
	}
	if ((!isNum(f.rentalcharge,0)) && f.rentalcharge.value.length > 0) {
		_alertString += "- rental charge is not a number\n";
	}
	if (_alertString.length==0) {
		document.Aform.submit();
	} else {
		alertString2 = "Form not submitted because of the following problem(s)\n";
		alertString2 += "------------------------------------------------------------------------------------\n\n";
		alertString2 += _alertString;
		alert(alertString2);
	}
}
</script>