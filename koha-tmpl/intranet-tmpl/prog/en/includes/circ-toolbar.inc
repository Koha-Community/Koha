<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    $("#printslip").parent().remove();
		$("#patronflags").parent().remove();
		$("#deletepatron").parent().remove();
		$("#moremenuc").empty();
	    $("#printmenuc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	    var printmenu = [
	        { text: "Print Page", url: "#" },
	        { text: "Print Slip", url: "#" }
	    ];
	
		var moremenu = [
			{ text: "Renew Patron", url: "javascript:confirm_reregistration();"},
			{ text: "Set Permissions", url: "/cgi-bin/koha/members/member-flags.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->"},
			{ text: "Delete", url: "javascript:confirm_deletion();"},
		]

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: "Print",
	        name: "printmenubutton",
	        menu: printmenu,
	        container: "printmenuc"
	    });   
	
	    new YAHOO.widget.Button({
	        type: "menu",
	        label: "More",
	        name: "moremenubutton",
	        menu: moremenu,
	        container: "moremenuc"
	    });
	
	    new YAHOO.widget.Button("checkout");
	    new YAHOO.widget.Button("addchild");
	    new YAHOO.widget.Button("editpatron");
	    new YAHOO.widget.Button("addnote");
	    new YAHOO.widget.Button("changepassword");
	    new YAHOO.widget.Button("printslilp");
		new YAHOO.widget.Button("printpage");
	    new YAHOO.widget.Button("renewpatron");		 
		new YAHOO.widget.Button("patronflags");
		new YAHOO.widget.Button("deletepatron");
	}

	//]]>
	</script>
	<ul class="toolbar">
	<li><a id="checkout" href="/cgi-bin/koha/circ/circulation.pl?findborrower=<!-- TMPL_VAR NAME="cardnumber" -->">Check Out</a></li>
	<!-- TMPL_IF name="adultborrower" --><li><a id="addchild" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;guarantorid=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=C">Add child</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="category_type" -->
            <!--TMPL_IF NAME="guarantor"-->
                <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;guarantorid=<!-- TMPL_VAR NAME="guarantorborrowernumber" -->&amp;category_type=<!-- TMPL_VAR NAME="category_type"-->">
            <!--TMPL_ELSE-->
            <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=<!-- TMPL_VAR NAME="category_type"-->">
            <!--/TMPL_IF-->Edit</a></li>
        <!-- TMPL_ELSE --> <!-- try with categorycode if no category_type -->
            <!-- TMPL_IF NAME="categorycode" -->
            <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;categorycode=<!-- TMPL_VAR NAME="categorycode"-->">Edit</a></li>
            <!-- TMPL_ELSE --> <!-- if no categorycode, set category_type to A by default -->
                <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=A">Edit</a></li>
            <!-- /TMPL_IF -->
        <!-- /TMPL_IF -->
	<li><a id="addnote" href="Someone please write this">Add Note</a></li>
	<li><a id="changepassword" href="/cgi-bin/koha/members/member-password.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->">Change Password</a></li>
	<li id="printmenuc"><a id="printpage" href="#">Print Page</a></li>
	<li><a id="printslip" href="#">Print Slip</a></li>
	<li id="moremenuc"><a id="renewpatron" href="javascript:confirm_reregistration();">Renew Account</a></li><!-- TMPL_IF NAME="CAN_user_permission" --><li><a id="patronflags" href="/cgi-bin/koha/members/member-flags.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->">Set Permissions</a></li><!-- /TMPL_IF --><li><a id="deletepatron" href="javascript:confirm_deletion();">Delete</a></li>
</ul></div>
