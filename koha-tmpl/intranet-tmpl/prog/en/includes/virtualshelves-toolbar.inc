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
	 
	[% IF ( viewshelf ) %] function sendList(){
        open(CGIBIN+'virtualshelves/sendshelf.pl?shelfid=[% shelfnumber %]','win_form','scrollbars=no,resizable=no,height=300,width=450,top=50,left=100');
	 }
	 
	 function downloadList(){
        open(CGIBIN+'virtualshelves/downloadshelf.pl?shelfid=[% shelfnumber %]','win_form','scrollbars=no,resizable=no,height=300,width=450,top=50,left=100');
	 }[% END %]

	// YUI Toolbar Functions

	function yuiToolbar() {
	   	    newshelfButton = new YAHOO.widget.Button("newshelf");
	   	    [% IF ( viewshelf ) %][% IF ( manageshelf ) %]editshelfButton = new YAHOO.widget.Button("editshelf");
			
	    var editmenu = [
	        { text: _("Edit list"), url: "/cgi-bin/koha/virtualshelves/shelves.pl?shelfnumber=[% shelfnumber %]&amp;op=modif" },
			{ text: _("Delete list"), onclick: {fn:function(){confirmDelete(_("Are you sure you want to delete this list?"))}}}
	    ];
		
		var downloadmenu = [
		{ text: _("iso2709"), url: "/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=iso2709&shelfid=[% shelfnumber %]" },
		{ text: _("RIS"), url: "/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=ris&shelfid=[% shelfnumber %]" },
		{ text: _("BibTex"), url: "/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=bibtex&shelfid=[% shelfnumber %]" },
[% FOREACH csv_profile IN csv_profiles %]
		{ text: _("CSV - [% csv_profile.profile %]"), url: "/cgi-bin/koha/virtualshelves/downloadshelf.pl?format=[% csv_profile.export_format_id %]&shelfid=[% shelfnumber %]" },
[% END %]
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

[% END %]
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
                                        });[% END %]
	}

	//]]>
	</script>
	
<ul class="toolbar">
	<li><a id="newshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1">New list</a></li>
	[% IF ( viewshelf ) %][% IF ( manageshelf ) %]
	<li id="editlistc"><a id="editshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelfnumber=[% shelfnumber %]&amp;op=modif">Edit list</a></li>
	<li id="deletelistc">[% IF ( showprivateshelves ) %]<a id="deleteshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?display=privateshelves&amp;shelves=1&amp;DEL-[% shelfnumber %]=1">Delete list</a>[% ELSE %]<a id="deleteshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1&amp;DEL-[% shelfnumber %]=1">Delete list</a>[% END %]</li>
	[% END %]
	<li id="sendlistc"><a href="#" id="sendlist">Send list</a></li>
	<li id="printlistc"><a id="printbiblio" href="#">Print list</a></li>
	[% END %]
</ul>
</div>
