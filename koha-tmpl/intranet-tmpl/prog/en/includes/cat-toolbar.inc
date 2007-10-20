<div id="toolbar">
	
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    $("#edititems").parent().remove();
	    $("#duplicatebiblio").parent().remove();
	    $("#editmenucontainer").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	    var editmenu = [
	        { text: "Edit Record", url: "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=&amp;op=" },
	        { text: "Edit Items", url: "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->" },
	        { text: "Edit as New (Duplicate)", url: "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=&amp;op=duplicate" }
	    ];

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: "Edit",
	        name: "editmenubutton",
	        menu: editmenu,
	        container: "editmenucontainer"
	    });   

	    new YAHOO.widget.Button("addbiblio");
	    new YAHOO.widget.Button("editbiblio");
	    new YAHOO.widget.Button("edititems");
	    new YAHOO.widget.Button("duplicatebiblio");
	    new YAHOO.widget.Button("deletebiblio");
	    new YAHOO.widget.Button("addtoshelf");
	    new YAHOO.widget.Button("printbiblio");
	    new YAHOO.widget.Button("placehold");		 
	}

	//]]>
	</script>
	
<ul class="toolbar">

	<li><a id="addbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New</a></li>
	<li id="editmenucontainer"><a id="editbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=">Edit Record</a></li>
	<li><a id="edititems" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Edit Items</a></li>
	<li><a id="duplicatebiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=duplicate">Duplicate Record</a></li>
	<li><a id="deletebiblio" href="javascript:confirm_deletion(<!-- TMPL_VAR NAME="count" -->)">Delete</a></li>
	<li><a id="addtoshelf" href="#" onclick="window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes'); return false;">Add to shelf</a></li>
	<li><a id="printbiblio" href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Print</a></li>
        <!-- TMPL_UNLESS name="bi_notforloan" -->
	<!-- TMPL_UNLESS NAME="norequests" --><li><a id="placehold" href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Place Hold</a></li><!-- /TMPL_UNLESS --><!-- TMPL_UNLESS -->
</ul></div>
