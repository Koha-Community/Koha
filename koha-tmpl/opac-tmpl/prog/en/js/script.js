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
	$(".close").click(function(){
		window.close();
	});
	$("#logout").click(function(){
		var nameCookie = "bib_list";
	    var valCookie = readCookie(nameCookie);
		if (valCookie) { // basket has contents
			alert("Deleting cart contents!!!");
			updateBasket(0,document);
			delCookie(nameCookie);
			return true;
		} else {
			return true;
		}
	});
});

// build Change Language menus
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
			
// Build lists menu
YAHOO.util.Event.onContentReady("listsmenu", function () {
    $("#listsmenu").css("display","block").css("visibility","hidden");
	$("#listsmenulink").attr("href","#").find("span:eq(0)").append("<img src=\"/opac-tmpl/prog/images/list.gif\" width=\"5\" height=\"6\" alt=\"\" border=\"0\" />");
	var listMenu = new YAHOO.widget.Menu("listsmenu", { lazyload: true });
		listMenu.render();
		listMenu.cfg.setProperty("context", ["listsmenulink", "tr", "br"]);
		listMenu.cfg.setProperty("effect",{effect:YAHOO.widget.ContainerEffect.FADE,duration:0.05});
		listMenu.subscribe("show", listMenu.focus);
        function positionlistMenu() {
                    listMenu.align("tr", "br");
		}
		YAHOO.util.Event.addListener("listsmenulink", "click", listMenu.show, null, listMenu);
		YAHOO.widget.Overlay.windowResizeEvent.subscribe(positionlistMenu);
 });

