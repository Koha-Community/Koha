<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	 	$("#editlistc").empty();
		$("#deletelistc").remove();
		$("#sendlistc").empty();
		$("#downloadlistc").empty();
		$("#printlistc").empty();
		$("#sendlistc").before("<li id=\"downloadmenuc\"><\/li>");
	    yuiToolbar();
	 });
	 
	<!-- TMPL_IF NAME="viewshelf" --> function sendList(){
		open(CGIBIN+'virtualshelves/sendshelf.pl?shelfid=<!-- TMPL_VAR NAME="shelfnumber" -->','win_form','dependant=yes,scrollbars=no,resizable=no,height=300,width=450,top=50,left=100');
	 }
	 
	 function downloadList(){
		open(CGIBIN+'virtualshelves/downloadshelf.pl?shelfid=<!-- TMPL_VAR NAME="shelfnumber" -->','win_form','dependant=yes,scrollbars=no,resizable=no,height=300,width=450,top=50,left=100');
	 }<!-- /TMPL_IF -->

	// YUI Toolbar Functions

	function yuiToolbar() {
	   	    newshelfButton = new YAHOO.widget.Button("newshelf");
	   	    <!-- TMPL_IF NAME="viewshelf" --><!-- TMPL_IF name="manageshelf" -->editshelfButton = new YAHOO.widget.Button("editshelf");
			
	    var editmenu = [
	        { text: _("Edit list"), url: "/cgi-bin/koha/virtualshelves/shelves.pl?shelfnumber=<!-- TMPL_VAR NAME="shelfnumber" -->&amp;op=modif" },
			{ text: _("Delete list"), onclick: {fn:function(){confirmDelete(_("Are you sure you want to delete this list?"))}}}
	    ];
		
		var downloadmenu = [
		{ text: _("iso2709"), url: "/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=iso2709&shelfid=<!-- TMPL_VAR NAME="shelfnumber" -->" },
		{ text: _("RIS"), url: "/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=ris&shelfid=<!-- TMPL_VAR NAME="shelfnumber" -->" },
		{ text: _("BibTex"), url: "/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=bibtex&shelfid=<!-- TMPL_VAR NAME="shelfnumber" -->" },
<!-- TMPL_LOOP NAME="csv_profiles" -->
		{ text: _("CSV - <!-- TMPL_VAR NAME="profile" -->"), url: "/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=<!-- TMPL_VAR NAME="export_format_id" -->&shelfid=<!-- TMPL_VAR NAME="shelfnumber" -->" },
<!-- /TMPL_LOOP -->
		];

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("Download list"),
	        name: "downloadmenubutton",
	        menu: downloadmenu,
	        container: "downloadmenuc"
	    });

		new YAHOO.widget.Button({
	        type: "menu",
	        label: _("Edit"),
	        name: "editmenubutton",
	        menu: editmenu,
	        container: "editlistc"
	    });

<!-- /TMPL_IF -->
			downloadlistButton = new YAHOO.widget.Button({
                                            id: "downloadlist", 
                                            type: "button", 
                                            label: _("Download list"), 
                                            container: "downloadlistc",
											onclick: {fn:downloadList}
                                        });
			sendlistButton = new YAHOO.widget.Button({
                                            id: "sendlist", 
                                            type: "button", 
                                            label: _("Send list"), 
                                            container: "sendlistc",
											onclick: {fn:sendList}
                                        });
			printlistButton = new YAHOO.widget.Button({
                                            id: "printbiblio", 
                                            type: "button", 
                                            label: _("Print list"), 
                                            container: "printlistc",
											onclick: {fn:function(){print();}}
                                        });<!-- /TMPL_IF -->
	}

	//]]>
	</script>
	
<ul class="toolbar">
	<li><a id="newshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1">New list</a></li>
	<!-- TMPL_IF NAME="viewshelf" --><!-- TMPL_IF name="manageshelf" -->
	<li id="editlistc"><a id="editshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelfnumber=<!-- TMPL_VAR NAME="shelfnumber" -->&amp;op=modif">Edit list</a></li>
	<li id="deletelistc"><!-- TMPL_IF NAME="showprivateshelves" --><a id="deleteshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?display=privateshelves&amp;shelves=1&amp;DEL-<!-- TMPL_VAR NAME="shelfnumber" -->=1">Delete list</a><!-- TMPL_ELSE --><a id="deleteshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1&amp;DEL-<!-- TMPL_VAR NAME="shelfnumber" -->=1">Delete list</a><!-- /TMPL_IF --></li>
	<!-- /TMPL_IF -->
	<li id="sendlistc"><a href="#" id="sendlist">Send list</a></li>
	<li id="printlistc"><a id="printbiblio" href="#">Print list</a></li>
	<!-- /TMPL_IF -->
</ul>
</div>
 