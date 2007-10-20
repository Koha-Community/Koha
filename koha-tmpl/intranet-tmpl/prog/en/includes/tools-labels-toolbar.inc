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
		new YAHOO.widget.Button("newbatch");
	}

	//]]>
	</script>
	<ul class="toolbar">
	<li><a id="newlabel" href="/cgi-bin/koha/labels/label-create-layout.pl">New Layout</a></li>
	<li><a id="newtemplate" href="/cgi-bin/koha/labels/label-create-template.pl?op=blank">New Label Template</a></li>
	<li><a id="newbatch" href="/cgi-bin/koha/labels/label-manager.pl?op=add_batch">New Label Batch</a></li>
</ul></div>
