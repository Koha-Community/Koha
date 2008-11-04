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
		var clonedRow = $(this).parent().parent().clone(true);
		clonedRow.insertAfter($(this).parent().parent()).find("a.deleteItemBlock").show();
		// find ID of cloned row so we can increment it for the clone
		var count = $("input[id^=volinf]",clonedRow).attr("id");
		var current = Number(count.replace("volinf",""));
		var increment = current + 1;
		// loop over inputs
		var inputs = ["volinf","barcode"];
		jQuery.each(inputs,function() {
			// increment IDs of labels and inputs in the clone
			$("label[for="+this+current+"]",clonedRow).attr("for",this+increment);
			$("input[name="+this+"]",clonedRow).attr("id",this+increment);
		});
		// loop over selects
		var selects = ["homebranch","location","itemtype","ccode"];
		jQuery.each(selects,function() {
			// increment IDs of labels and selects in the clone
			$("label[for="+this+current+"]",clonedRow).attr("for",this+increment);
			$("input[name="+this+"]",clonedRow).attr("id",this+increment);
			$("select[name="+this+"]",clonedRow).attr("id",this+increment);
			// find the selected option and select it in the clone
			var selectedVal = $("select#"+this+current).find("option:selected").attr("value");
			$("select[name="+this+"] option[value="+selectedVal+"]",clonedRow).attr("selected","selected");
		});
		
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