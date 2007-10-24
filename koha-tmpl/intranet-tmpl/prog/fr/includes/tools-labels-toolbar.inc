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
	<li><a id="newlabel" href="/cgi-bin/koha/labels/label-create-layout.pl">Ajouter format</a></li>
	<li><a id="newtemplate" href="/cgi-bin/koha/labels/label-create-template.pl?op=blank">Nouveau modèle d'étiquette</a></li>
	<li><a id="newbatch" href="/cgi-bin/koha/labels/label-manager.pl?op=add_batch">Tâches d'impression d'étiquettes</a></li>
</ul></div>
