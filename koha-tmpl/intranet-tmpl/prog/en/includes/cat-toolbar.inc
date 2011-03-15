<div id="toolbar">
	
	<script type="text/javascript">
	//<![CDATA[
	<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->
	/* this function open a popup to search on z3950 server.  */
	function PopupZ3950() {
		var strQuery = GetZ3950Terms();
		if(strQuery){
			window.open("/cgi-bin/koha/cataloguing/z3950_search.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->"+strQuery,"z3950search",'width=740,height=450,location=yes,toolbar=no,scrollbars=yes,resize=yes');
		} 
	}

	/* provide Z3950 search points */
	function GetZ3950Terms(){
		var strQuery="&frameworkcode=";
		<!-- TMPL_LOOP NAME='z3950_search_params' -->
			strQuery += "&" + "<!-- TMPL_VAR NAME="name" -->" + "=" + "<!-- TMPL_VAR NAME="encvalue" -->";
		<!-- /TMPL_LOOP -->
		return strQuery;
	}
	<!-- /TMPL_IF -->
	function addToCart() { addRecord('<!-- TMPL_VAR NAME="biblionumber" -->'); }
	function addToShelf() {	window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes');
	}
	function printBiblio() {window.open('/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Print_Biblio','width=700,height=500,toolbar=false,scrollbars=yes');
	}
<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->
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
		return false;
	}
}
<!-- /TMPL_IF -->
<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_items" -->
function confirm_items_deletion() {
        var count = <!-- TMPL_VAR NAME="count" -->;
        if(count > 0){
            if(confirm(_('Are you sure you want to delete the ' + count + ' attached items? '))){
                window.location="/cgi-bin/koha/cataloguing/additem.pl?op=delallitems&amp;biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->";
            }else{
                return false;
            }
		}
}
<!-- /TMPL_IF -->
	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    <!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_items" -->$("#edititems").parent().remove();
		$("#newitem").parent().remove();<!-- /TMPL_IF -->
	    <!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->$("#duplicatebiblio").parent().remove();
		$("#deletebiblio").parent().remove();
		$("#z3950searchc").empty();<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="CAN_user_serials_create_subscription" -->$("#newsub").parent().remove();<!-- /TMPL_IF -->
	    $("#newbiblio").parent().remove();
		$("#editbiblio").parent().remove();
		$("#addtoshelf").parent().remove();
		$("#printbiblio").parent().remove();
		$("#placehold").parent().remove();
		$("#export").remove();
	 });

	YAHOO.util.Event.onContentReady("cattoolbar", function () {
		//	Menu for new record, new item, new subscription
		var newmenu = [
			<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->{text: _("New Record"), url: "/cgi-bin/koha/cataloguing/addbiblio.pl" },<!-- /TMPL_IF -->
			<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_items" -->{text: _("New Item"), url: "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->#additema" },<!-- /TMPL_IF -->
			<!-- TMPL_IF NAME="CAN_user_serials_create_subscription" -->
			{text: _("New Subscription"), url: "/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=<!-- TMPL_VAR NAME="biblionumber" -->"},<!-- /TMPL_IF -->
		];
		if(newmenu.length){
			new YAHOO.widget.Button({
				type: "menu",
				label: _("New"),
				id: "newmenuc",
				name: "newmenubutton",
				menu: newmenu,
				container: this
			 });
		 }
	    var editmenu = [
	        <!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->{ text: _("Edit Record"), url: "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=&amp;op=" },<!-- /TMPL_IF -->
	        <!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_items" -->{ text: _("Edit Items"), url: "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->" },<!-- /TMPL_IF -->
	        <!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_items" -->{ text: _("Attach Item"), url: "/cgi-bin/koha/cataloguing/moveitem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->" },<!-- /TMPL_IF -->
	        <!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->{ text: _("Edit as New (Duplicate)"), url: "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=&amp;op=duplicate" },<!-- /TMPL_IF -->
			<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->{ text: _("Delete Record"), onclick: {fn: confirm_deletion }<!-- TMPL_IF NAME="count" -->,id:'disabled'<!-- /TMPL_IF --> },<!-- /TMPL_IF -->
	        <!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_items" -->{ text: _("Delete all Items"), onclick: {fn: confirm_items_deletion } }<!-- /TMPL_IF -->
	    ];
		if(editmenu.length){
			new YAHOO.widget.Button({
				type: "menu",
				label: _("Edit"),
				id: "editmenuc",
				name: "editmenubutton",
				menu: editmenu,
				container: this
			 });
		}
		var savemenu = [
			{ text: _("MODS (XML)"), url: "/cgi-bin/koha/catalogue/export.pl?format=mods&op=export&bib=<!-- TMPL_VAR NAME="biblionumber" -->" },
			{ text: _("Dublin Core (XML)"), url: "/cgi-bin/koha/catalogue/export.pl?format=dc&op=export&bib=<!-- TMPL_VAR NAME="biblionumber" -->" },
			{ text: _("MARCXML"), url: "/cgi-bin/koha/catalogue/export.pl?format=marcxml&op=export&bib=<!-- TMPL_VAR NAME="biblionumber" -->" },
			{ text: _("MARC (non-Unicode/MARC-8)"), url: "/cgi-bin/koha/catalogue/export.pl?format=marc8&op=export&bib=<!-- TMPL_VAR NAME="biblionumber" -->" },
			{ text: _("MARC (Unicode/UTF-8)"), url: "/cgi-bin/koha/catalogue/export.pl?format=utf8&op=export&bib=<!-- TMPL_VAR NAME="biblionumber" -->" }
		];

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("Save"),
	        id: "savemenuc",
	        name: "savemenubutton",
	        menu: savemenu,
	        container: this
	    });

	    var addtomenu = [
			{ text: _("Cart"), onclick: { fn: addToCart } },
			{ text: _("List"),  onclick: { fn: addToShelf } }
		];

		new YAHOO.widget.Button({
	        type: "menu",
	        label: _("Add to"),
	        name: "addtomenubutton",
	        menu: addtomenu,
	        container: this
	    });

		new YAHOO.widget.Button({
	        id: "printbiblio",
	        type: "button",
	        label: _("Print"),
	        container: this,
			onclick: {fn: printBiblio }
		});
		<!-- TMPL_IF NAME="CAN_user_reserveforothers" --><!-- TMPL_UNLESS NAME="norequests" -->
		<!-- TMPL_IF NAME="holdfor" -->
		//	Create an array of YAHOO.widget.MenuItem configuration properties
		var onButtonClick = function () { 
			location.href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->";
		}
		var HoldForButtonMenu = [
			{ text: "Place hold", url: "/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->" },
			{ text: "Place hold for <!-- TMPL_VAR NAME="holdfor_firstname" --> <!-- TMPL_VAR NAME="holdfor_surname" --> (<!-- TMPL_VAR NAME="holdfor_cardnumber" -->)", url: "/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&findborrower=<!-- TMPL_VAR NAME="holdfor_cardnumber" -->" }
		];

		//	Instantiate a Split Button using the array of YAHOO.widget.MenuItem 
		//	configuration properties as the value for the "menu" 
		//	configuration attribute.

		var HoldForButton = new YAHOO.widget.Button({
				id: "holdfor",
				type: "split",
				label: "Place hold",
				name: "holdfor",
				menu: HoldForButtonMenu,
				container: this,
				onclick: { fn: onButtonClick }
		});
	    <!-- TMPL_ELSE -->
	    new YAHOO.widget.Button({
			id: "placehold",
			type: "link",
			label: _("Place hold"),
			container: this,
			href: "/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->"
	     });
	    <!-- /TMPL_IF -->
	    <!-- /TMPL_IF --><!-- /TMPL_IF -->
	    <!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->
		new YAHOO.widget.Button({
			id: "z3950search",
			type: "button", 
			label: _("Z39.50 Search"),
			container: this,
			onclick: {fn:function(){PopupZ3950()}}
		});
		<!-- /TMPL_IF -->
	});
	//]]>
	</script>
	
<form method="post" name="f" id="f" action="/cgi-bin/koha/cataloguing/addbiblio.pl" onsubmit="return Check();">

<ul class="toolbar" id="cattoolbar">

	<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->
	<li><a id="newbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New Record</a></li>
	<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_items" -->
	<li><a id="newitem" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">New Item</a></li>
	<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_serials_create_subscription" -->
	<li><a id="newsub" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=<!-- TMPL_VAR NAME="biblionumber" -->">New Subscription</a></li>
	<!-- /TMPL_IF -->

	<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->
	<li><a id="editbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=">Edit Record</a></li>
	<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_items" -->
	<li><a id="edititems" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Edit Items</a></li>
	<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->
	<li><a id="duplicatebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=duplicate">Duplicate Record</a></li>
	<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" -->
	<li><a id="deletebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?op=delete&amp;biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Delete</a></li>
	<!-- /TMPL_IF -->	

	<li><a id="addtoshelf" href="/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Add to shelf</a></li>
	<li><a id="printbiblio" href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Print</a></li>
	<!-- TMPL_IF NAME="CAN_user_reserveforothers" -->
	<!-- TMPL_UNLESS NAME="norequests" --><li><a id="placehold" href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Place Hold</a></li><!-- /TMPL_UNLESS -->
	<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_editcatalogue_edit_catalogue" --><li id="z3950searchc"><input type="button" id="z3950search" value="Z39.50 Search" onclick="PopupZ3950(); return false;" /></li><!-- /TMPL_IF -->
    </ul>
</form>
</div>

