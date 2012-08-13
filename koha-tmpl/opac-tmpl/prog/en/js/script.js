function _(s) { return s } // dummy function for gettext
function confirmDelete(message) {
	return (confirm(message) ? true : false);
}

function Dopop(link) {
	newin=window.open(link,'popup','width=500,height=400,toolbar=false,scrollbars=yes,resizeable=yes');
}

$.datepicker.setDefaults({
        showOn: "both",
        changeMonth: true,
        changeYear: true,
        buttonImage: '/opac-tmpl/lib/famfamfam/silk/calendar.png',
        buttonImageOnly: true,
        showButtonPanel: true
    });

$(document).ready(function(){
	$(".close").click(function(){
		window.close();
	});
	$(".focus").focus();
    $( ".datepicker" ).datepicker();
    // http://jqueryui.com/demos/datepicker/#date-range
    var dates = $( ".datepickerfrom, .datepickerto" ).datepicker({
        changeMonth: true,
        numberOfMonths: 1,
        onSelect: function( selectedDate ) {
            var option = this.id == "from" ? "minDate" : "maxDate",
                instance = $( this ).data( "datepicker" );
                date = $.datepicker.parseDate(
                    instance.settings.dateFormat ||
                    $.datepicker._defaults.dateFormat,
                    selectedDate, instance.settings );
            dates.not( this ).datepicker( "option", option, date );
        }
    });
	// clear the basket when user logs out
	$("#logout").click(function(){
		var nameCookie = "bib_list";
	    var valCookie = readCookie(nameCookie);
		if (valCookie) { // basket has contents
			updateBasket(0,null);
			delCookie(nameCookie);
			return true;
		} else {
			return true;
		}
	});
});

// build Change Language menus
YAHOO.util.Event.onContentReady("changelanguage", function () {
	$(".sublangs").each(function(){
		var menuid = $(this).attr("id");
		var menuid = menuid.replace("show","");

		var oMenu = new YAHOO.widget.Menu("sub"+menuid, { zindex: 2 });
		function positionoMenu() {
			oMenu.align("bl", "tl");
		}
		oMenu.subscribe("beforeShow", function () {
		if (this.getRoot() == this) {
			positionoMenu();
		}
		});
		oMenu.render();
		oMenu.cfg.setProperty("context", ["show"+menuid, "bl", "tl"]);
		function onYahooClick(p_oEvent) {
			// Position and display the menu        
			positionoMenu();
			oMenu.show();
			// Stop propagation and prevent the default "click" behavior
			YAHOO.util.Event.stopEvent(p_oEvent);
		}
		YAHOO.util.Event.addListener("show"+menuid, "click", onYahooClick);
		YAHOO.widget.Overlay.windowResizeEvent.subscribe(positionoMenu);
		
	});
});
			
// Build lists menu
YAHOO.util.Event.onContentReady("listsmenu", function () {
	YAHOO.widget.Menu.prototype.onRender = function () { };
    $("#listsmenu").css("display","block").css("visibility","hidden");
	$("#listsmenulink").attr("href","#");
	var listMenu = new YAHOO.widget.Menu("listsmenu");
		listMenu.render();
		listMenu.cfg.setProperty("context", ["listsmenulink", "tr", "br"]);
		listMenu.cfg.setProperty("effect",{effect:YAHOO.widget.ContainerEffect.FADE,duration:0.05});
		listMenu.subscribe("beforeShow",positionlistMenu);
		listMenu.subscribe("show", listMenu.focus);
        function positionlistMenu() {
                    listMenu.align("tr", "br");
		}
		YAHOO.util.Event.addListener("listsmenulink", "click", listMenu.show, null, listMenu);
		YAHOO.widget.Overlay.windowResizeEvent.subscribe(positionlistMenu);
 });

jQuery.fn.preventDoubleFormSubmit = function() {
    jQuery(this).submit(function() {
        if (this.beenSubmitted)
            return false;
        else
            this.beenSubmitted = true;
    });
};
