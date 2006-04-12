<script language="JavaScript" type="text/javascript">
function addauthority() {
	X = document.forms[0].authtype.value;
	window.location="/cgi-bin/koha/authorities/authorities.pl?authtypecode="+X;
}
function searchauthority() {
	X = document.forms[0].authtype2.value;
	Y = document.forms[0].value.value;
	window.location="/cgi-bin/koha/authorities/authorities-home.pl?op=do_search&type=intranet&authtypecode="+X+"&value="+Y+"&marclist=&and_or=and&excluding=&operator=contains";
}
</script>

<div id="topmenu">
	<form><select name="authtype2" id="authtype2"><!-- TMPL_LOOP name="authtypesloop" --><option value="<!-- TMPL_VAR name="value" -->"<!-- TMPL_IF name="selected" --> selected="selected"<!-- /TMPL_IF -->><!-- TMPL_VAR name="authtypetext" --></option><!-- /TMPL_LOOP --></select>
	<input type="text" size="10" maxlength="100" name="value" /><input type="button" class="submit" value="Search" onclick="searchauthority(); return false;" /> <select name="authtype" id="authtype"><!-- TMPL_LOOP name="authtypesloop" --><option value="<!-- TMPL_VAR name="value" -->"<!-- TMPL_IF name="selected" --> selected="selected"<!-- /TMPL_IF -->><!-- TMPL_VAR name="authtypetext" --></option><!-- /TMPL_LOOP --></select>
	<input type="button" class="submit" value="Add Authority" onclick="addauthority(); return false;" /></form></div>
