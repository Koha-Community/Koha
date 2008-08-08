function countItemBlocks() {
    var outeritemblock = document.getElementById('outeritemblock');
    var quantityrec = document.getElementById('quantityrec');
    var origquantityrec = document.getElementById('origquantityrec');
    var itemblockcount = outeritemblock.getElementsByTagName('div');
    var num = parseFloat(origquantityrec.value) + itemblockcount.length;
    quantityrec.setAttribute('value',num);
}
function deleteItemBlock(index) {
    var aDiv = document.getElementById(index);
    aDiv.parentNode.removeChild(aDiv);
    countItemBlocks();
}
function cloneItemBlock(index) {    
    var original = document.getElementById(index); //original <div>
    var clone = original.cloneNode(true);
    // set the attribute for the new 'div' subfields
    clone.setAttribute('id',index + index);//set another id.
    var NumTabIndex;
    NumTabIndex = parseInt(original.getAttribute('tabindex'));
    if(isNaN(NumTabIndex)) NumTabIndex = 0;
    clone.setAttribute('tabindex',NumTabIndex+1);
    var CloneButtonPlus;
    var CloneButtonMinus;
  //  try{
        CloneButtonPlus = clone.getElementsByTagName('a')[0];
        CloneButtonPlus.setAttribute('onclick',"cloneItemBlock('" + index + index + "')");
    CloneButtonMinus = clone.getElementsByTagName('a')[1];
    CloneButtonMinus.setAttribute('onclick',"deleteItemBlock('" + index + index + "')");
    CloneButtonMinus.setAttribute('style',"display:inline");
   // }
    //catch(e){        // do nothig if ButtonPlus & CloneButtonPlus don't exist.
    //}
    // insert this line on the page    
    original.parentNode.insertBefore(clone,original.nextSibling);
    countItemBlocks();
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
