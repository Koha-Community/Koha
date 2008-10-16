function check_additem() {
	var	barcodes = document.getElementsByName('barcode');
	var success = true;
	for(i=0;i<barcodes.length;i++){
		for(j=0;j<barcodes.length;j++){
			if( (i > j) && (barcodes[i].value == barcodes[j].value) && barcodes[i].value !='') {
				barcodes[i].className='error';
				barcodes[j].className='error';
				success = false;
			}
		}
	}
	// TODO : Add AJAX function to test against barcodes already in the database, not just 
	// duplicates within the form.  
	return success;
}
$(document).ready(function(){
	$(".cloneItemBlock").click(function(){
		$(this).parent().parent().clone(true).insertAfter($(this).parent().parent()).find("a.deleteItemBlock").show();
		var quantityrec = parseFloat($("#quantityrec").attr("value"));
		quantityrec++;
		$("#quantityrec").attr("value",quantityrec);
		return false;
	});
	$(".deleteItemBlock").click(function(){
		$(this).parent().parent().remove();
		var quantityrec = parseFloat($("#quantityrec").attr("value"));
		quantityrec--;
		$("#quantityrec").attr("value",quantityrec);
		return false;
	});
});