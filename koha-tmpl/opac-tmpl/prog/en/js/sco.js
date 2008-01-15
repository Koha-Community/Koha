function focusOnFirst(){
	;	// FIXME: do something here?
}

function sco_init(valid_session) {
	if (valid_session == 1) {
  		setTimeout("location.href='/cgi-bin/koha/sco/sco-main.pl?op=logout';",120000);
	}
	if(document.forms['mainform']){
		document.forms['mainform'].elements[0].focus();
	}
}
    
function confirmDelete(message) {
	return (confirm(message) ? true : false);
}

function Dopop(link) {
	newin=window.open(link,'popup','width=500,height=400,toolbar=false,scrollbars=yes');
}
