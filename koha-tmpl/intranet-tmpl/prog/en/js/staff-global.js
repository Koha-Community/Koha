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
 });
 

// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function verify_patron_images() {
    for (var i = 0; i < document.images.length; i++) {
        img = document.images[i];
        if ((img.src.indexOf('patronimage') >= 0)) {
			w = img.width;
            h = img.height;
     if ((w == 0) && (h == 0) || ((img.complete != null) && (!img.complete))) {
               img.src = '/intranet-tmpl/prog/img/patron-blank.png';
			}
        }
    }
}

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