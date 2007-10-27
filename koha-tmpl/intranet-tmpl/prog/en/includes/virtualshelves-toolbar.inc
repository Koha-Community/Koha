<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
		$("#deleteshelfc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	   	    newshelfButton = new YAHOO.widget.Button("newshelf");
	   	    editshelfButton = new YAHOO.widget.Button("editshelf");
			deleteshelfButton = new YAHOO.widget.Button({
                                            id: "deleteshelf", 
                                            type: "button", 
                                            label: "Delete Shelf", 
                                            container: "deleteshelfc",
											onclick: {fn:function(){confirmDelete("Are you sure you want to delete this shelf?")}}
                                        });
	}

	//]]>
	</script>
	
<ul class="toolbar">

	<li><a id="newshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1">New Shelf</a></li>
	<!-- TMPL_IF NAME="viewshelf" --><!-- TMPL_IF name="manageshelf" --><li><a id="editshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?op=modif&amp;shelf=<!-- TMPL_VAR NAME="shelfnumber" -->">Edit Shelf</a></li><li id="deleteshelfc"><a id="deleteshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1&amp;DEL-<!-- TMPL_VAR NAME="shelfnumber" -->=1">Delete Shelf</a></li><!-- /TMPL_IF --><!-- /TMPL_IF -->
</ul></div>
