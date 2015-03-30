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
        if (confirm(_("Please note that this external search could replace the current record."))){
            PopupZ3950();
        }
    }

	/* provide Z3950 search points */
	function GetZ3950Terms(){
		var strQuery="&frameworkcode=";
		[% FOREACH z3950_search_param IN z3950_search_params %]
            strQuery += "&" + "[% z3950_search_param.name |uri %]" + "=" + "[% z3950_search_param.value |uri %]";
		[% END %]
		return strQuery;
	}
	[% END %]
	function addToCart() { addRecord('[% biblionumber %]'); }
	function addToShelf() {	window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=[% biblionumber %]','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes');
	}
    function printBiblio() {window.print(); }
[% IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
    function confirm_deletion() {
        var count = [% count %];
        var holdcount = [% holdcount %];
        var countorders = [% countorders %];
        var countdeletedorders = [% countdeletedorders %];
        var is_confirmed;
	if (count > 0){
            is_confirmed = alert( _("%s item(s) are attached to this record. You must delete all items before deleting this record.").format(count) );
         }
        else if (countorders > 0){
            [% IF ( CAN_user_acquisition_order_manage ) %]
                is_confirmed = confirm( _("Warning: This record is used in %s order(s). Deleting it could cause serious issues on acquisition module. Are you sure you want to delete this record?").format(countorders) );
            [% ELSE %]
                is_confirmed = alert( _("%s order(s) are using this record. You need order managing permissions to delete this record.").format(countorders) );
            [% END %]
        }
        else if (countdeletedorders > 0){
             [% IF ( CAN_user_acquisition_order_manage ) %]
                 is_confirmed = confirm( _("%s deleted order(s) are using this record. Are you sure you want to delete this record?").format(countdeletedorders) );
             [% ELSE %]
                 is_confirmed = alert( _("%s deleted order(s) are using this record. You need order managing permissions to delete this record.").format(countdeletedorders) );
             [% END %]
        }
        else if ( holdcount > 0 ) {
            is_confirmed = confirm( _("%s holds(s) for this record. Are you sure you want to delete this record?").format(holdcount) );
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

[% IF CAN_user_editcatalogue_edit_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
    function confirm_items_deletion() {
        var count = [% count %];
        var holdcount = [% holdcount %];

        if ( holdcount > 0 ) {
            alert( _("%s hold(s) on this record. You must delete all holds before deleting all items.").format(holdcount) );
        } else if ( count > 0 ) {
            if( confirm( _("Are you sure you want to delete the %s attached items?").format(count) ) ) {
                window.location="/cgi-bin/koha/cataloguing/additem.pl?op=delallitems&amp;biblionumber=[% biblionumber %]";
            } else {
                return false;
            }
        } else {
            alertNoItems();
            return false;
        }
    }
    function alertNoItems(){
        alert(_("This record has no items."));
    }
[% END %]
	 $(document).ready(function() {
        $("#z3950copy").click(function(){
            PopupZ3950();
            return false;
        });
        $("#deletebiblio").click(function(){
            confirm_deletion();
            return false;
        });
        $("#deleteallitems").click(function(){
            confirm_items_deletion();
            return false;
        });
        $("#printbiblio").click(function(){
            printBiblio();
            return false;
        });
        $("#addtocart").click(function(){
            addToCart();
            $(".btn-group").removeClass("open");
            return false;
        });
        $("#addtoshelf").click(function(){
            addToShelf();
            $(".btn-group").removeClass("open");
            return false;
        });
        $("#export").remove(); // Hide embedded export form if JS menus available
        $("#deletebiblio").tooltip();
        $("#batchedit-disabled,#batchdelete-disabled,#deleteallitems-disabled")
            .on("click",function(e){
                e.preventDefault();
                alertNoItems();
            })
            .tooltip();
	 });
	//]]>
	</script>

<div id="toolbar" class="btn-toolbar">

<form method="post" name="f" id="f" action="/cgi-bin/koha/cataloguing/addbiblio.pl" onsubmit="return Check();">

[% IF ( CAN_user_editcatalogue_edit_catalogue || CAN_user_editcatalogue_edit_items ||
CAN_user_serials_create_subscription ) %]
    <div class="btn-group">
    <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-plus"></i> New <span class="caret"></span></button>
        <ul class="dropdown-menu">
            [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
             <li><a id="newbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New record</a></li>
            [% END %]

            [% IF ( CAN_user_editcatalogue_edit_items ) %]
             <li><a id="newitem" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber %]#additema">New item</a></li>
            [% END %]
            [% IF ( CAN_user_serials_create_subscription ) %]
             <li><a id="newsub" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber %]">New subscription</a></li>
            [% END %]

            [% IF ( EasyAnalyticalRecords && CAN_user_editcatalogue_edit_catalogue ) %]
                <li><a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblionumber %]&amp;analyze=1">Analyze items</a></li>
            [% END %]
            [% IF CAN_user_editcatalogue_edit_catalogue && ! EasyAnalyticalRecords %]
                <li><a href="/cgi-bin/koha/cataloguing/addbiblio.pl?parentbiblionumber=[% biblionumber %]">New child record</a></li>
            [% END %]
    </ul>
    </div>
[% END %]

[% IF ( CAN_user_editcatalogue_edit_catalogue || CAN_user_editcatalogue_edit_items || CAN_user_tools_items_batchmod || CAN_user_tools_items_batchdel ) or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
    <div class="btn-group">
    <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-pencil"></i> Edit <span class="caret"></span></button>
        <ul class="dropdown-menu">
            [% IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
            <li><a id="editbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber %]&amp;frameworkcode=[% current_framework %]&amp;op=">Edit record</a></li>
            [% END %]

            [% IF CAN_user_editcatalogue_edit_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
            <li><a id="edititems" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber %]">Edit items</a></li>
            [% END %]

            [% IF ( CAN_user_tools_items_batchmod ) %]
                [% IF ( count ) %]
                    <li><a id="batchedit" href="/cgi-bin/koha/tools/batchMod.pl?op=show&amp;biblionumber=[% biblionumber %]&amp;src=CATALOGUING">Edit items in batch</a></li>
                [% ELSE %]
                    <li class="disabled"><a id="batchedit-disabled" href="#" data-toggle="tooltip" data-placement="left" title="This record has no items">Edit items in batch</a></li>
                [% END %]
            [% END %]

            [% IF ( CAN_user_tools_items_batchdel ) %]
                [% IF ( count ) %]
                    <li><a id="batchdelete" href="/cgi-bin/koha/tools/batchMod.pl?del=1&amp;op=show&amp;biblionumber=[% biblionumber %]&amp;src=CATALOGUING">Delete items in a batch</a></li>
                [% ELSE %]
                    <li class="disabled"><a id="batchdelete-disabled" href="#" data-toggle="tooltip" data-placement="left" title="This record has no items">Delete items in a batch</a></li>
                [% END %]
            [% END %]

            [% IF ( CAN_user_editcatalogue_edit_items ) %]<li><a href="/cgi-bin/koha/cataloguing/moveitem.pl?biblionumber=[% biblionumber %]">Attach item</a></li>[% END %]

            [% IF ( EasyAnalyticalRecords ) %][% IF ( CAN_user_editcatalogue_edit_items ) %]<li><a href="/cgi-bin/koha/cataloguing/linkitem.pl?biblionumber=[% biblionumber %]">Link to host item</a>[% END %][% END %]
            [% IF ( LocalCoverImages || OPACLocalCoverImages) %][% IF ( CAN_user_tools_upload_local_cover_images ) %]<li><a href="/cgi-bin/koha/tools/upload-cover-image.pl?biblionumber=[% biblionumber %]&amp;filetype=image">Upload image</a>[% END %][% END %]

            [% IF ( CAN_user_editcatalogue_edit_catalogue ) %]
                <li><a id="duplicatebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber %]&amp;frameworkcode=[% current_framework %]&amp;op=duplicate">Edit as new (duplicate)</a></li>
                <li><a href="#" id="z3950copy">Replace record via Z39.50/SRU</a></li>
            [% END %]

            [% IF CAN_user_editcatalogue_edit_catalogue or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
                [% IF ( count ) %]
                    <li class="disabled"><a id="deletebiblio" data-toggle="tooltip" data-placement="left" title="[% count %] item(s) are attached to this record. You must delete all items before deleting this record." href="#">Delete record</a></li>
                [% ELSE %]
                    <li><a id="deletebiblio" href="#">Delete record</a></li>
                [% END %]
            [% END %]

            [% IF CAN_user_editcatalogue_delete_all_items or ( frameworkcode == 'FA' and CAN_user_editcatalogue_fast_cataloging ) %]
                [% IF ( count ) %]
                    <li><a href="#" id="deleteallitems">Delete all items</a></li>
                [% ELSE %]
                    <li class="disabled"><a href="#" id="deleteallitems-disabled" data-toggle="tooltip" data-placement="left" title="This record has no items">Delete all items</a></li>
                [% END %]
            [% END %]

    </ul>
    </div>
[% END %]

    <div class="btn-group">
    <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-download-alt"></i> Save <span class="caret"></span></button>
    <ul class="dropdown-menu">
        <li><a href="/cgi-bin/koha/catalogue/export.pl?format=bibtex&amp;op=export&amp;bib=[% biblionumber %]">BIBTEX</a></li>
        <li><a href="/cgi-bin/koha/catalogue/export.pl?format=dc&amp;op=export&amp;bib=[% biblionumber %]">Dublin Core (XML)</a></li>
        <li><a href="/cgi-bin/koha/catalogue/export.pl?format=marcxml&amp;op=export&amp;bib=[% biblionumber %]">MARCXML</a></li>
        <li><a href="/cgi-bin/koha/catalogue/export.pl?format=marc8&amp;op=export&amp;bib=[% biblionumber %]">MARC (non-Unicode/MARC-8)</a></li>
        <li><a href="/cgi-bin/koha/catalogue/export.pl?format=utf8&amp;op=export&amp;bib=[% biblionumber %]">MARC (Unicode/UTF-8)</a></li>
        <li><a href="/cgi-bin/koha/catalogue/export.pl?format=marcstd&amp;op=export&amp;bib=[% biblionumber %]">MARC (Unicode/UTF-8, Standard)</a></li>
        <li><a href="/cgi-bin/koha/catalogue/export.pl?format=mods&amp;op=export&amp;bib=[% biblionumber %]">MODS (XML)</a></li>
        <li><a href="/cgi-bin/koha/catalogue/export.pl?format=ris&amp;op=export&amp;bib=[% biblionumber %]">RIS</a></li>
    </ul>
    </div>

[% IF ( virtualshelves && intranetbookbag ) %]
    <div class="btn-group">
    <button class="btn btn-small dropdown-toggle" data-toggle="dropdown">Add to <span class="caret"></span></button>
    <ul class="dropdown-menu">
        <li><a href="#" id="addtocart">Cart</a></li>
        <li><a href="#" id="addtoshelf">List</a></li>
    </ul>
    </div>
[% ELSIF ( virtualshelves ) %]
    <div class="btn-group"><a id="addtoshelf" class="btn btn-small"><i class="icon-list"></i> Add to list</a> </div>
[% ELSIF ( intranetbookbag ) %]
    <div class="btn-group"><a id="addtocart" class="btn btn-small"><i class="icon-shopping-cart"></i> Add to cart</a> </div>
[% END %]

    <div class="btn-group"><a id="printbiblio" class="btn btn-small"><i class="icon-print"></i> Print</a></div>

[% IF ( CAN_user_reserveforothers ) %]
    [% UNLESS ( norequests ) %]
        [% IF ( holdfor ) %]
            <div class="btn-group">
                <button class="btn btn-small dropdown-toggle" data-toggle="dropdown">
                    <i class="icon-hold"></i>
                    Place hold
                    <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <li><a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber %]">Place hold</a></li>
                    <li><a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber %]&amp;findborrower=[% holdfor_cardnumber %]">Place hold for [% holdfor_firstname %] [% holdfor_surname %] ([% holdfor_cardnumber %])</a></li>
                </ul>
            </div>
        [% ELSE %]
            <div class="btn-group"><a id="placehold" class="btn btn-small" href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblionumber %]"><i class="icon-hold"></i> Place hold</a></div>
        [% END %]
    [% END %]
[% END %]

</form>
</div>

