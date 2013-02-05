<div id="toolbar">
	
	<script type="text/javascript">
	//<![CDATA[
	[% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
	/* this function open a popup to search on z3950 server.  */
	function PopupZ3950() {
		var strQuery = GetZ3950Terms();
		if(strQuery){
			window.open("/cgi-bin/koha/cataloguing/z3950_search.pl?biblionumber=[% biblionumber %]"+strQuery,"z3950search",'width=740,height=450,location=yes,toolbar=no,scrollbars=yes,resize=yes');
		} 
	}
    function PopupZ3950Confirmed() {
        if (confirm(_("Please note that this Z39.50 search could replace the current record."))){
            PopupZ3950();
        }
    }

	/* provide Z3950 search points */
	function GetZ3950Terms(){
		var strQuery="&frameworkcode=";
		[% FOREACH z3950_search_param IN z3950_search_params %]
			strQuery += "&" + "[% z3950_search_param.name |html %]" + "=" + "[% z3950_search_param.encvalue |html %]";
		[% END %]
		return strQuery;
	}
	[% END %]
	function addToCart() { addRecord('[% biblionumber %]'); }
	function addToShelf() {	window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=[% biblionumber %]','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes');
	}
    function printBiblio() {window.print(); }
[% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
    function confirm_deletion() {
        var count = [% count %];
        var holdcount = [% holdcount %];

        var is_confirmed;
	if (count > 0){
            is_confirmed = alert( count + " " +_("item(s) are attached to this record.\nYou must delete all items before deleting this record.") );
        } else if ( holdcount > 0 ) {
            is_confirmed = confirm( holdcount + " " + _("holds(s) for this record \n Are you sure you want to delete this record?."));
        } else {
            is_confirmed = confirm(_("Are you sure you want to delete this record?"));
        }

        if (is_confirmed) {
            if ( count > 0 || holdcount > 0 ){
                return false;
            } else {
                window.location="/cgi-bin/koha/cataloguing/addbiblio.pl?op=delete&amp;biblionumber=[% biblionumber %]";
            }
	} else {
            return false;
	}
    }
[% END %]

[% IF ( CAN_user_editcatalogue_edit_items ) %]
    function confirm_items_deletion() {
        var count = [% count %];
        var holdcount = [% holdcount %];

        if ( holdcount > 0 ) {
            alert( holdcount + " " + _("holds(s) for this record \n You must delete all holds before deleting all items.") );
        } else if ( count > 0 ) {
            if( confirm( _("Are you sure you want to delete the") + " " + count + " " + _("attached items?") ) ) {
                window.location="/cgi-bin/koha/cataloguing/additem.pl?op=delallitems&amp;biblionumber=[% biblionumber %]";
            } else {
                return false;
            }
        } else {
            alert(_("This record has no items."));
            return false;
        }
    }
[% END %]
	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    [% IF ( CAN_user_editcatalogue_edit_items ) %]$("#edititems").parent().remove();
		$("#newitem").parent().remove();[% END %]
	    [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]$("#duplicatebiblio").parent().remove();
		$("#deletebiblio").parent().remove();
		$("#z3950searchc").empty();[% END %]
		[% IF ( CAN_user_serials_create_subscription ) %]$("#newsub").parent().remove();[% END %]
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
			[% IF CAN_user_editcatalogue_edit_catalogue %]
            {text: _("New record"), url: "/cgi-bin/koha/cataloguing/addbiblio.pl" },
            [% END %]
			[% IF ( CAN_user_editcatalogue_edit_items ) %]
            {text: _("New item"), url: "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber %]#additema" },
            [% END %]
            [% IF ( CAN_user_serials_create_subscription ) %]
                {text: _("New subscription"), url: "/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber %]"},
            [% END %]
            [% IF ( EasyAnalyticalRecords && CAN_user_editcatalogue_edit_catalogue ) %]
                {text: _("Analyze items"), url: "/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblionumber %]&analyze=1" },
            [% END %]
            [% IF CAN_user_editcatalogue_edit_catalogue %]
                {text: _("New child record"), url: "/cgi-bin/koha/cataloguing/addbiblio.pl?parentbiblionumber=[% biblionumber %]" },
            [% END %]
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
            [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]{ text: _("Edit record"), url: "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber %]&amp;frameworkcode=&amp;op=" },[% END %]
            [% IF ( CAN_user_editcatalogue_edit_items ) %]{ text: _("Edit items"), url: "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber %]" },[% END %]
            [% IF ( CAN_user_tools_items_batchmod ) %]{ text: _("Edit items in batch"), url: "/cgi-bin/koha/tools/batchMod.pl?op=show&biblionumber=[% biblionumber %]&src=CATALOGUING" },[% END %]
            [% IF ( CAN_user_tools_items_batchdel ) %]{ text: _("Delete items in batch"), url: "/cgi-bin/koha/tools/batchMod.pl?del=1&op=show&biblionumber=[% biblionumber %]&src=CATALOGUING" },[% END %]
            [% IF ( CAN_user_editcatalogue_edit_items ) %]{ text: _("Attach item"), url: "/cgi-bin/koha/cataloguing/moveitem.pl?biblionumber=[% biblionumber %]" },[% END %]
            [% IF ( EasyAnalyticalRecords ) %][% IF ( CAN_user_editcatalogue_edit_items ) %]{ text: _("Link to host item"), url: "/cgi-bin/koha/cataloguing/linkitem.pl?biblionumber=[% biblionumber %]" },[% END %][% END %]
            [% IF ( LocalCoverImages || OPACLocalCoverImages) %][% IF ( CAN_user_tools_upload_local_cover_images ) %]{ text: _("Upload image"), url: "/cgi-bin/koha/tools/upload-cover-image.pl?biblionumber=[% biblionumber %]&filetype=image" },[% END %][% END %]
            [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]{ text: _("Edit as new (duplicate)"), url: "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber %]&amp;frameworkcode=&amp;op=duplicate" },[% END %]
            [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]{ text: _("Replace record via Z39.50"), onclick: {fn: PopupZ3950 } },[% END %]
            [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]{ text: _("Delete record"), onclick: {fn: confirm_deletion }[% IF ( count || holdcount ) %],id:'disabled'[% END %] },[% END %]
            [% IF ( CAN_user_editcatalogue_edit_items ) %]{ text: _("Delete all items"), onclick: {fn: confirm_items_deletion }[% IF ( count < 1 || holdcount ) %],id:'disabled2'[% END %] },[% END %]
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
			{ text: _("MODS (XML)"), url: "/cgi-bin/koha/catalogue/export.pl?format=mods&op=export&bib=[% biblionumber %]" },
			{ text: _("Dublin Core (XML)"), url: "/cgi-bin/koha/catalogue/export.pl?format=dc&op=export&bib=[% biblionumber %]" },
			{ text: _("MARCXML"), url: "/cgi-bin/koha/catalogue/export.pl?format=marcxml&op=export&bib=[% biblionumber %]" },
			{ text: _("MARC (non-Unicode/MARC-8)"), url: "/cgi-bin/koha/catalogue/export.pl?format=marc8&op=export&bib=[% biblionumber %]" },
            { text: _("MARC (Unicode/UTF-8)"), url: "/cgi-bin/koha/catalogue/export.pl?format=utf8&op=export&bib=[% biblionumber %]" },
            { text: _("MARC (Unicode/UTF-8, Standard)"), url: "/cgi-bin/koha/catalogue/export.pl?format=marcstd&op=export&bib=[% biblionumber %]" }
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
		[% IF ( CAN_user_reserveforothers ) %][% UNLESS ( norequests ) %]
		[% IF ( holdfor ) %]
		//	Create an array of YAHOO.widget.MenuItem configuration properties
		var onButtonClick = function () { 
			location.href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber %]";
		}
		var HoldForButtonMenu = [
			{ text: _("Place hold"), url: "/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber %]" },
			{ text: _("Place hold for")+ " [% holdfor_firstname %] [% holdfor_surname %] ([% holdfor_cardnumber %])", url: "/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber %]&findborrower=[% holdfor_cardnumber %]" }
		];

		//	Instantiate a Split Button using the array of YAHOO.widget.MenuItem 
		//	configuration properties as the value for the "menu" 
		//	configuration attribute.

		var HoldForButton = new YAHOO.widget.Button({
				id: "holdfor",
				type: "split",
				label: _("Place hold"),
				name: "holdfor",
				menu: HoldForButtonMenu,
				container: this,
				onclick: { fn: onButtonClick }
		});
	    [% ELSE %]
	    new YAHOO.widget.Button({
			id: "placehold",
			type: "link",
			label: _("Place hold"),
			container: this,
			href: "/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber %]"
	     });
	    [% END %]
	    [% END %][% END %]

	});
	//]]>
	</script>
	
<form method="post" name="f" id="f" action="/cgi-bin/koha/cataloguing/addbiblio.pl" onsubmit="return Check();">

<ul class="toolbar" id="cattoolbar">

	[% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
    <li><a id="newbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New record</a></li>
	[% END %]
	[% IF ( CAN_user_editcatalogue_edit_items ) %]
    <li><a id="newitem" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber %]">New item</a></li>
	[% END %]
	[% IF ( CAN_user_serials_create_subscription ) %]
    <li><a id="newsub" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber %]">New subscription</a></li>
	[% END %]

	[% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
    <li><a id="editbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber %]&amp;frameworkcode=[% current_framework %]&amp;op=">Edit record</a></li>
	[% END %]
	[% IF ( CAN_user_editcatalogue_edit_items ) %]
    <li><a id="edititems" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber %]">Edit items</a></li>
	[% END %]
	[% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
    <li><a id="duplicatebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber %]&amp;frameworkcode=[% current_framework %]&amp;op=duplicate">Duplicate record</a></li>
	[% END %]
	[% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
	<li><a id="deletebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?op=delete&amp;biblionumber=[% biblionumber %]">Delete</a></li>
	[% END %]	

	<li><a id="addtoshelf" href="/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=[% biblionumber %]">Add to shelf</a></li>
    <li><span id="printbiblio"></span></li>
	[% IF ( CAN_user_reserveforothers ) %]
    [% UNLESS ( norequests ) %]<li><a id="placehold" href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber %]">Place hold</a></li>[% END %]
	[% END %]
	[% IF ( CAN_user_editcatalogue_edit_catalogue ) %]<li id="z3950searchc"><input type="button" id="z3950search" value="Z39.50 Search" onclick="PopupZ3950Confirmed(); return false;" /></li>[% END %]
    </ul>
</form>
</div>

