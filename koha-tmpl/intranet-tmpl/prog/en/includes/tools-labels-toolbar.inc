<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	    new YAHOO.widget.Button("newlabel");
	    new YAHOO.widget.Button("newtemplate");
	    new YAHOO.widget.Button("newprofile");
	    new YAHOO.widget.Button("newlabelbatch");
	    new YAHOO.widget.Button("newpatroncardbatch");
	}

	//]]>
	</script>
	<ul class="toolbar">
	<li><a id="newlabel" href="/cgi-bin/koha/labels/label-edit-layout.pl">New Layout</a></li>
	<li><a id="newtemplate" href="/cgi-bin/koha/labels/label-create-template.pl?op=blank">New Label Template</a></li>
	<li><a id="newprofile" href="/cgi-bin/koha/labels/label-create-profile.pl?op=blank">New Printer Profile</a></li>
	<li><a id="newlabelbatch" href="/cgi-bin/koha/labels/label-manager.pl?op=add_batch&amp;type=labels">New Label Batch</a></li>
	<li><a id="newpatroncardbatch" href="/cgi-bin/koha/labels/label-manager.pl?op=add_batch&amp;type=patroncards">New Patron Card Batch</a></li>
</ul></div>
