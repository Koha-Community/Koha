<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	    new YAHOO.widget.Button("newfund");
	}

	//]]>
	</script>
	<ul class="toolbar">
	<li><a id="newfund" href="/cgi-bin/koha/admin/aqbookfund.pl?op=add_form">New Fund</a></li>
</ul></div>
