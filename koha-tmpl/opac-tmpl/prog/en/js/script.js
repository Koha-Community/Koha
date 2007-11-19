function CheckAll()
{
count = document.mainform.elements.length;
    for (i=0; i < count; i++) 
	{
	    if(document.mainform.elements[i].checked == 1){
			document.mainform.elements[i].checked = 0;
		} else {
			document.mainform.elements[i].checked = 1;
		}
	}
}

function confirmDelete(message) {
	var agree = confirm(message);
	if(agree) {
		return true;
	} else {
		return false;
	}
}

function Dopop(link) {
	newin=window.open(link,'popup','width=500,height=400,toolbar=false,scrollbars=yes');
	}