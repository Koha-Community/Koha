// staff-global.js

function _(s) { return s } // dummy function for gettext

 $(document).ready(function() {
 	$(".focus").focus();
	$('#header_search').tabs({
		onShow: function() {
	        $('#header_search').find('div.residentsearch').not('.tabs-hide').find('input').eq(0).focus();
	    }	
	});
	$(".close").click(function(){
		window.close();
	});
	if($("#header_search #checkin_search")){ $.hotkeys.add('Alt+r',function (){$("#header_search").triggerTab(2); }); }
	if($("#header_search #circ_search")){ $.hotkeys.add('Alt+u',function (){ $("#header_search").triggerTab("#circ_search"); }); }
	if($("#header_search #catalog_search")){ $.hotkeys.add('Alt+q',function (){ $("#header_search").triggerTab(3); }); }
 });
 

            YAHOO.util.Event.onContentReady("header", function () {
				var oMoremenu = new YAHOO.widget.Menu("moremenu", { zindex: 2 });

				function positionoMoremenu() {
					oMoremenu.align("tl", "bl");
				}

                oMoremenu.subscribe("beforeShow", function () {
                    if (this.getRoot() == this) {
						positionoMoremenu();
                    }
                });

				oMoremenu.render();

                oMoremenu.cfg.setProperty("context", ["showmore", "tl", "bl"]);

				function onShowMoreClick(p_oEvent) {
                    // Position and display the menu        
                    positionoMoremenu();
                    oMoremenu.show();
                    // Stop propagation and prevent the default "click" behavior
                    YAHOO.util.Event.stopEvent(p_oEvent);	
				}

				YAHOO.util.Event.addListener("showmore", "click", onShowMoreClick);

                YAHOO.widget.Overlay.windowResizeEvent.subscribe(positionoMoremenu);
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