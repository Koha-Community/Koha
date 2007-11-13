<div id="toolbar">
	
	<script type="text/javascript">
	
	function addToShelf() {	window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes');
	}
	function printBiblio() {window.open('/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Print_Biblio','width=700,height=500,toolbar=false,scrollbars=yes');
	}
function confirm_deletion() {
	
		var count = <!-- TMPL_VAR NAME="count" -->;
        var is_confirmed;
	if (count>0){
		    is_confirmed= alert(_('There are [ '+ count +' ] item(s) attached to this record \n You must delete all items before deleting this record.'));
		    } else{
		    is_confirmed= confirm(_('Are you sure you want to delete this record? '));
	}
   
     if (is_confirmed) {
        if (count>0){
	// 	window.location="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->";
		} else {
			window.location="/cgi-bin/koha/cataloguing/addbiblio.pl?op=delete&amp;biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->";
		}
	} else {
// FIXME -- THIS doesn't work.  addbiblio is still the target url after this fcn call !	
	 	window.location="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->";
		return false;
	}
}
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    $("#viewmarc").parent().remove();
	    $("#viewisbd").parent().remove();
	    $("#viewitems").parent().remove();
		$("#viewmenuc").empty();
	    $("#edititems").parent().remove();
	    $("#duplicatebiblio").parent().remove();
		$("#deletebiblio").parent().remove();
	    $("#editmenuc").empty();
		$("#addtoshelfc").empty();
		$("#printbiblioc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	    var editmenu = [
	        { text: "Edit Record", url: "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=&amp;op=" },
	        { text: "Edit Items", url: "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->" },
	        { text: "Edit as New (Duplicate)", url: "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=&amp;op=duplicate" },
			{ text: "Delete Record", url: "/cgi-bin/koha/cataloguing/addbiblio.pl?op=delete&amp;biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->",<!-- TMPL_IF NAME="count" -->disabled: true, <!-- /TMPL_IF --> onclick: {fn: confirm_deletion }}
	    ];

		var viewmenu = [
	        { text: "Normal Display", url: "/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->", selected: true },
	        { text: "MARC Display", url: "/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->" },
	        { text: "ISBD Display", url: "/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->" },
	        { text: "Items Display", url: "/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->" }
	    ];

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: "View",
	        name: "viewmenubutton",
	        menu: viewmenu,
	        container: "viewmenuc"
	    });
	    
		new YAHOO.widget.Button({
	        type: "menu",
	        label: "Edit",
	        name: "editmenubutton",
	        menu: editmenu,
	        container: "editmenuc",
			
	    });
		
		var addtoshelfButton = new YAHOO.widget.Button({
                                            id: "addtoshelf", 
                                            type: "button", 
                                            label: "Add to Shelf", 
                                            container: "addtoshelfc",
											onclick: {fn: addToShelf }
                                        });
										
		var printbiblioButton = new YAHOO.widget.Button({
                                            id: "printbiblio", 
                                            type: "button", 
                                            label: "Print", 
                                            container: "printbiblioc",
											onclick: {fn: printBiblio }
                                        });

	    var addbiblioButton = new YAHOO.widget.Button("addbiblio");
	    var placeholdButton = new YAHOO.widget.Button("placehold");
		
	}

	//]]>
	</script>
	
<ul class="toolbar">

	<li><a id="addbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New</a></li>
	
	<li id="editmenuc"><a id="editbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=">Edit Record</a></li>
	<li><a id="edititems" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Edit Items</a></li>
	<li><a id="duplicatebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=duplicate">Duplicate Record</a></li>
	<li><a id="deletebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?op=delete&amp;biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Delete</a></li>
	
	<li id="viewmenuc"><a id="viewnormal" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Normal View</a></li>
	<li><a id="viewmarc" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">MARC View</a></li>
	<li><a id="viewisbd" href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">ISBD View</a></li>
	<li><a id="viewitems" href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Items View</a></li>

	<li id="addtoshelfc"><a id="addtoshelf" href="/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Add to shelf</a></li>
	<li id="printbiblioc"><a id="printbiblio" href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Print</a></li>
        <!-- TMPL_UNLESS name="bi_notforloan" -->
	<!-- TMPL_UNLESS NAME="norequests" --><li><a id="placehold" href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Place Hold</a></li><!-- /TMPL_UNLESS --><!-- TMPL_UNLESS -->
</ul></div>
