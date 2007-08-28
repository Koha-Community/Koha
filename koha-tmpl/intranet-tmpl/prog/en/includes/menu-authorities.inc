<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}

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