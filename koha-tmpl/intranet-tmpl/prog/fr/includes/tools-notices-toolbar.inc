<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	    new YAHOO.widget.Button("newnotice");
	}

	//]]>
	</script>
	<ul class="toolbar">
	<li><a id="newnotice" href="/cgi-bin/koha/tools/letter.pl?op=add_form">Ajouter notification</a></li>
</ul></div>