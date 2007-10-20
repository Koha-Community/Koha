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
	
		var newmenu = [
			<!-- TMPL_LOOP name="authtypesloop" -->{ text: "New <!-- TMPL_VAR name="authtypetext" -->", url: "/cgi-bin/koha/authorities/authorities.pl?authtypecode=<!-- TMPL_VAR name="value" -->"},
<!-- /TMPL_LOOP -->
		]

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: "New Authority",
	        name: "newmenubutton",
	        menu: newmenu,
	        container: "newmenuc"
	    });  
	}

	//]]>
	</script>
	
  <span id="newmenuc"><form name="f2" method="post" action="authorities.pl">
	<label for="add_authtypecode">New: </label>
        <select id="add_authtypecode" name="authtypecode">
<!-- TMPL_LOOP name="authtypesloop" -->
  <!-- TMPL_IF name="selected" -->
        <option value="<!-- TMPL_VAR name="value" -->" selected="selected"><!-- TMPL_VAR name="authtypetext" --></option>
  <!-- TMPL_ELSE -->
        <option value="<!-- TMPL_VAR name="value" -->"><!-- TMPL_VAR name="authtypetext" --></option>
  <!-- /TMPL_IF -->
<!-- /TMPL_LOOP -->
        </select>
      <input type="submit" value="Add" class="button" />
  </form></span>
</div>