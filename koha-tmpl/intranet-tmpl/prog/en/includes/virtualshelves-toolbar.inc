<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
		// $("#deleteshelfc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	   	    newshelfButton = new YAHOO.widget.Button("newshelf");
	   	    editshelfButton = new YAHOO.widget.Button("editshelf");
			deleteshelfButton = new YAHOO.widget.Button("deleteshelf", { value: "deleteshelfvalue" });
       		YAHOO.util.Event.on("deleteshelf_f", "submit", confirmDelete);
	}
        function confirmDelete(p_oEvent) {
            var bSubmit = window.confirm("Are you sure you want to delete this shelf?");
            if(!bSubmit) {
                YAHOO.util.Event.preventDefault(p_oEvent);
            }
        }

	//]]>
	</script>
	
<ul class="toolbar">

	<li><a id="newshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?shelves=1">New Shelf</a></li>
	<!-- TMPL_IF NAME="viewshelf" --><!-- TMPL_IF name="manageshelf" --><li><a id="editshelf" href="/cgi-bin/koha/virtualshelves/shelves.pl?op=modif&amp;shelf=<!-- TMPL_VAR NAME="shelfnumber" -->">Edit Shelf</a></li><li id="deleteshelfc"><form action="/cgi-bin/koha/virtualshelves/shelves.pl" method="post" id="deleteshelf_f">
<input type="hidden" name="DEL-<!-- TMPL_VAR NAME="shelfnumber" -->" />
<input type="hidden" name="shelves" value="1" />
<input type="submit" id="deleteshelf" value="Delete Shelf" onclick="return confirmDelete('Are you sure you want to delete this shelf?')" /></form>
</li>

<!-- /TMPL_IF --><!-- /TMPL_IF -->
</ul></div>
