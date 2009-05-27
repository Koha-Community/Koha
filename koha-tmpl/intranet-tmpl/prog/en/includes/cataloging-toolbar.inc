

<div id="toolbar">
<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    $("#newmenuc").empty();
	    yuiToolbar();
        yuiZ3950button();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	
    <!-- TMPL_IF NAME="NOTMARC" -->
	    new YAHOO.widget.Button("newrecord");
	<!-- TMPL_ELSE -->
	
		var newmenu = [
			{ text: _("Default Framework"), url: "/cgi-bin/koha/cataloguing/addbiblio.pl?frameworkcode=" },
			<!-- TMPL_LOOP NAME="frameworkcodeloop" -->{ text: "<!-- TMPL_VAR name="frameworktext" -->", url: "/cgi-bin/koha/cataloguing/addbiblio.pl?frameworkcode=<!-- TMPL_VAR name="value" -->"},
<!-- /TMPL_LOOP -->
		]

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("New Record"),
	        name: "newmenubutton",
	        menu: newmenu,
	        container: "newmenuc"
	    });  
	}

    /* this function open a popup to search on z3950 server.  */
    function PopupZ3950() {
        var strQuery = GetZ3950Terms();
        if(strQuery){
            window.open("/cgi-bin/koha/cataloguing/z3950_search.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->"+strQuery,"z3950search",'width=740,height=450,location=yes,toolbar=no,scrollbars=yes,resize=yes');
        }
    }
    /* provide Z3950 search points */
    function GetZ3950Terms(){
        var strQuery="&frameworkcode=";
        <!-- TMPL_LOOP NAME='z3950_search_params' -->
            strQuery += "&" + "<!-- TMPL_VAR NAME="name" -->" + "=" + "<!-- TMPL_VAR NAME="encvalue" -->";
        <!-- /TMPL_LOOP -->
        return strQuery;
    }
    /* prepare DOM for Z39.50 Search Button */
    function yuiZ3950button() {
        new YAHOO.widget.Button({
                id: "z3950search",
                type: "button",
                label: _("z39.50 Search"),
                container: "newmenuc",
                onclick: {fn:function(){PopupZ3950()}}
        });
    }
	//]]>
	</script>
	
  <div id="newmenuc">
    <!-- TMPL_IF NAME="NOTMARC" -->
		<a id="newrecord" href="/cgi-bin/koha/cataloging/addbiblio.pl">New Record</a>
	<!-- TMPL_ELSE -->
		<form name="f" action="addbiblio.pl" method="post">
		<label for="frameworkcode">New Record with framework:</label>
			<select name="frameworkcode" id="frameworkcode">
				<option value="">Default</option>
				<!-- TMPL_LOOP NAME="frameworkcodeloop" -->
					<option value="<!-- TMPL_VAR NAME="value" -->">
						<!-- TMPL_VAR NAME="frameworktext" -->
					</option>
				<!-- /TMPL_LOOP -->
			</select>
			<input type="submit" value="Add Record Without Search" />
		</form>
        <a id="z3950search" onclick="PopupZ3950(); return false;">z39.50 Search</a>
    <!-- /TMPL_IF -->  

  </div>
</div>
