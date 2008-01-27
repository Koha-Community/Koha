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

$(document).ready(function(){
	if(basketcount){ updateBasket(basketcount,document) }	
});
	
YAHOO.util.Event.onContentReady("changelanguage", function () {
                var oMenu = new YAHOO.widget.Menu("sublangs", { zindex: 2 });
	            function positionoMenu() {
                    oMenu.align("bl", "tl");
                }
                oMenu.subscribe("beforeShow", function () {
                    if (this.getRoot() == this) {
						positionoMenu();
                    }
                });
                oMenu.render();
				oMenu.cfg.setProperty("context", ["showlang", "bl", "tl"]);
				function onYahooClick(p_oEvent) {
                    // Position and display the menu        
                    positionoMenu();
                    oMenu.show();
                    // Stop propagation and prevent the default "click" behavior
                    YAHOO.util.Event.stopEvent(p_oEvent);
                }
				YAHOO.util.Event.addListener("showlang", "click", onYahooClick);
				YAHOO.widget.Overlay.windowResizeEvent.subscribe(positionoMenu);
            });