/**
	 * this function checks all checkbox 
	 * or uncheck all if there are already checked.
	 */
	function CheckAll(){
		var checkboxes = document.getElementsByTagName('input');
		var nbCheckbox = checkboxes.length;
		var check = areAllChecked();
		check = !check;
		for(var i=0;i<nbCheckbox;i++){
			if(checkboxes[i].getAttribute('type') == "checkbox" ){
				checkboxes[i].checked = check;
			}
		}
	}
	/**
	 * this function return true if all checkbox are checked
	 */
	function areAllChecked(){
		var checkboxes = document.getElementsByTagName('input');
		var nbCheckbox = checkboxes.length;
		for(var i=0;i<nbCheckbox;i++){
			if(checkboxes[i].getAttribute('type') == "checkbox" ){
				if(checkboxes[i].checked == 0){
					return false;
				}
			}
		}
		return true;
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