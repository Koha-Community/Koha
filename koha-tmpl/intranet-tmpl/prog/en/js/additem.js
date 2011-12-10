function deleteItemBlock(index) {
    var aDiv = document.getElementById(index);
    aDiv.parentNode.removeChild(aDiv);
    var quantity = document.getElementById('quantity');
    quantity.setAttribute('value',parseFloat(quantity.getAttribute('value'))-1);
}
function cloneItemBlock(index) {    
    var original = document.getElementById(index); //original <div>
    var clone = clone_with_selected(original)
    var random = Math.floor(Math.random()*100000); // get a random itemid.
    // set the attribute for the new 'div' subfields
    clone.setAttribute('id',index + random);//set another id.
    var NumTabIndex;
    NumTabIndex = parseInt(original.getAttribute('tabindex'));
    if(isNaN(NumTabIndex)) NumTabIndex = 0;
    clone.setAttribute('tabindex',NumTabIndex+1);
    var CloneButtonPlus;
    var CloneButtonMinus;
  //  try{
        CloneButtonPlus = clone.getElementsByTagName('a')[0];
        CloneButtonPlus.setAttribute('onclick',"cloneItemBlock('" + index + random + "')");
    CloneButtonMinus = clone.getElementsByTagName('a')[1];
    CloneButtonMinus.setAttribute('onclick',"deleteItemBlock('" + index + random + "')");
    CloneButtonMinus.setAttribute('style',"display:inline");
    // change itemids of the clone
    var elems = clone.getElementsByTagName('input');
    for( i = 0 ; elems[i] ; i++ )
    {
        if(elems[i].name.match(/^itemid/)) {
            elems[i].value = random;
        }
    }    
   // }
    //catch(e){        // do nothig if ButtonPlus & CloneButtonPlus don't exist.
    //}
    // insert this line on the page    
    original.parentNode.insertBefore(clone,original.nextSibling);
    var quantity = document.getElementById('quantity');
    quantity.setAttribute('value',parseFloat(quantity.getAttribute('value'))+1);
}
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

function clone_with_selected (node) {
	   var origin = node.getElementsByTagName("select");
	   var tmp = node.cloneNode(true)
	   var selectelem = tmp.getElementsByTagName("select");
	   for (var i=0; i<origin.length; i++) {
	       selectelem[i].selectedIndex = origin[i].selectedIndex;
	   }
	   origin = null;
	   selectelem = null;
	   return tmp;
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
