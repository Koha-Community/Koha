<div id="toolbar"><script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	
	    new YAHOO.widget.Button("newsubscription");
	    <!-- TMPL_IF NAME="subscriptionid" -->
		new YAHOO.widget.Button("edit");
		new YAHOO.widget.Button("duplicate");
	    new YAHOO.widget.Button("renew");
	    new YAHOO.widget.Button("receive");
	    new YAHOO.widget.Button("delete");
		<!-- /TMPL_IF -->
	}

	//]]>
	</script>
<ul class="toolbar">
	<li><a id="newsubscription" href="/cgi-bin/koha/serials/subscription-add.pl">Ajouter abonnement</a></li>
	<!-- TMPL_IF NAME="subscriptionid" --><li><a id="edit" href="subscription-add.pl?op=mod&amp;subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Modifier</a></li>
	<li><a id="duplicate" href="subscription-add.pl?op=dup&amp;subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Dupliquer </a></li>
	<li><a id="renew" href="#" onclick="popup(<!--TMPL_VAR Name="subscriptionid"-->)">Renouvellement </a></li>
	<li><a id="receive" href="serials-edit.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->&amp;serstatus=1,3">RecevoirReçu</a></li>
	<li><a id="delete" href="javascript:confirm_deletion()">Supprimer</a></li>
		<!-- /TMPL_IF -->
</ul>
</div>
