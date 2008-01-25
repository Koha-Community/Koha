	/**
	 * this function checks all checkbox 
	 * or uncheck all if there are already checked.
	 */
	function CheckAll(){
		var checkboxes = document.getElementsByTagName('input');
		var nbCheckbox = checkboxes.length;
		var check = areAllChecked();
		for(var i=0;i<nbCheckbox;i++){
			if(checkboxes[i].getAttribute('type') == "checkbox" ){
				checkboxes[i].checked = (check) ? 0 : 1;
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
	return (confirm(message) ? true : false);
}

function Dopop(link) {
	newin=window.open(link,'popup','width=500,height=400,toolbar=false,scrollbars=yes');
}
	
/*$(document).ready(function(){
	$('#masthead').each(function(){
		$('a.button').each(function(){
			var b = $(this);
			var tt = b.text() || b.val();
			if ($(':submit,:button',this)) {
				b = $('<a>').insertAfter(this).addClass('btn').attr('id',this.id).attr('href',this.href);
				$(this).remove();
			}
			b.text('').css({cursor:'pointer'}). prepend('<i></i>').append($('<span>').
			text(tt).append('<i></i><span></span>'));
			});
		});
	});*/
