

<div id="toolbar">
<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    $("#newmenuc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {   
	
    <!-- TMPL_IF NAME="NOTMARC" -->
	    new YAHOO.widget.Button("newrecord");
	<!-- TMPL_ELSE -->
	
		var newmenu = [
			{ text: "Default Framework", url: "/cgi-bin/koha/cataloguing/addbiblio.pl?frameworkcode=" },
			<!-- TMPL_LOOP NAME="frameworkcodeloop" -->{ text: "<!-- TMPL_VAR name="frameworktext" --> Framework", url: "/cgi-bin/koha/cataloguing/addbiblio.pl?frameworkcode=<!-- TMPL_VAR name="value" -->"},
<!-- /TMPL_LOOP -->
		]

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: "New Record",
	        name: "newmenubutton",
	        menu: newmenu,
	        container: "newmenuc"
	    });  
	}

			<!-- /TMPL_IF -->
	//]]>
	</script>
	
  <span id="newmenuc">
    <!-- TMPL_IF NAME="NOTMARC" -->
		<a id="newrecord" href="/cgi-bin/koha/cataloging/addbiblio.pl">Ajouter commande</a>
	<!-- TMPL_ELSE -->
		<form name="f" action="addbiblio.pl" method="post">
		<label for="frameworkcode">Ajouter notice avec la grille :</label>
			<select name="frameworkcode" id="frameworkcode">
				<option value="">Par défaut</option>
				<!-- TMPL_LOOP NAME="frameworkcodeloop" -->
					<option value="<!-- TMPL_VAR NAME="value" -->">
						<!-- TMPL_VAR NAME="frameworktext" -->
					</option>
				<!-- /TMPL_LOOP -->
			</select>
			<input type="submit" value="Ajouter une notice sans recherche">
		</form>
  
  </span>
</div>