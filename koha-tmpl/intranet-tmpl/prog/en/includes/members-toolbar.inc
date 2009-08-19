<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

function confirm_deletion() {
    var is_confirmed = window.confirm('Are you sure you want to delete this patron? This cannot be undone.');
    if (is_confirmed) {
            window.location='/cgi-bin/koha/members/deletemem.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->';
    }
}
function confirm_updatechild() {
    var is_confirmed = window.confirm('Are you sure you want to update this child to an Adult category?  This cannot be undone.');
   
    if (is_confirmed) {
            window.location='/cgi-bin/koha/members/update-child.pl?op=update&borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&catcode=<!-- TMPL_VAR NAME="catcode" -->&catcode_multi=<!-- TMPL_VAR NAME="CATCODE_MULTI" -->';
    }
}

function confirm_reregistration() {
    var is_confirmed = window.confirm('Are you sure you want to renew this patron\'s registration?');
    if (is_confirmed) {
    window.location='/cgi-bin/koha/members/moremember.pl?reregistration=y&borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->';
    }
}

function update_child() {
<!-- TMPL_IF NAME="CATCODE_MULTI" -->
 window.open('update-child.pl?op=multi&borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->','UpdateChild','width=400,height=300,toolbar=no,scrollbars=no,resizable=yes');
<!-- TMPL_ELSE -->
 confirm_updatechild();
<!-- /TMPL_IF -->
}

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
	function printx_window(print_type) {
		window.open("/cgi-bin/koha/members/moremember.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;print=" + print_type, "printwindow");
		return false;
	}

	function yuiToolbar() {
	    var printmenu = [
	        { text: _("Print Page"), onclick: {fn: function(){printx_window("page")}} },
	        { text: _("Print Slip"), onclick: {fn: function(){printx_window("slip")}} },
	        { text: _("Quick Slip"), onclick: {fn: function(){printx_window("qslip")}} }
	    ];
	
		var moremenu = [
			{ text: _("Renew Patron"),  onclick: { fn: confirm_reregistration } },
			{ text: _("Set Permissions"), url: "/cgi-bin/koha/members/member-flags.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->"<!-- TMPL_UNLESS NAME="CAN_user_permissions" -->, disabled: true<!-- /TMPL_UNLESS -->},
			{ text: _("Delete"), onclick: { fn: confirm_deletion}<!-- TMPL_UNLESS NAME="samebranch" -->, disabled: true<!-- /TMPL_IF --> },
			{ text: _("Update Child to Adult Patron") , onclick: { fn: update_child }<!-- TMPL_UNLESS NAME="is_child" -->, disabled: true<!-- /TMPL_UNLESS -->}
		];

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("Print"),
	        name: "printmenubutton",
	        menu: printmenu,
	        container: "printmenuc"
	    });   
	
	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("More"),
	        name: "moremenubutton",
	        menu: moremenu,
	        container: "moremenuc"
	    });

	    <!-- TMPL_IF name="adultborrower" -->new YAHOO.widget.Button("addchild");<!-- /TMPL_IF -->
	    new YAHOO.widget.Button("editpatron");
	    new YAHOO.widget.Button("addnote");
	    new YAHOO.widget.Button("changepassword");
	    new YAHOO.widget.Button("printslip");
		new YAHOO.widget.Button("printpage");
	    new YAHOO.widget.Button("renewpatron");		 
		new YAHOO.widget.Button("patronflags");
		new YAHOO.widget.Button("deletepatron");
		new YAHOO.widget.Button("updatechild");
	}

	//]]>

	</script>
	<ul class="toolbar">
	<!-- TMPL_IF NAME="category_type" -->
            <!--TMPL_IF NAME="guarantor"-->
                <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;guarantorid=<!-- TMPL_VAR NAME="guarantorborrowernumber" -->&amp;category_type=<!-- TMPL_VAR NAME="category_type"-->">
            <!--TMPL_ELSE-->
            <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=<!-- TMPL_VAR NAME="category_type"-->">
            <!--/TMPL_IF-->Edit</a></li>
        <!-- TMPL_ELSE --> <!-- try with categorycode if no category_type -->
            <!-- TMPL_IF NAME="categorycode" -->
            <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;categorycode=<!-- TMPL_VAR NAME="categorycode"-->">Edit</a></li>
            <!-- TMPL_ELSE --> <!-- if no categorycode, set category_type to A by default -->
                <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=A">Edit</a></li>
            <!-- /TMPL_IF -->
        <!-- /TMPL_IF -->
	<!-- TMPL_IF name="adultborrower" --><li><a id="addchild" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;guarantorid=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;category_type=C">Add child</a></li><!-- /TMPL_IF -->
<!--	<li><a id="addnote" href="/cgi-bin/koha/members/addnotes.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Add Note</a></li> -->
	<li><a id="changepassword" href="/cgi-bin/koha/members/member-password.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->">Change Password</a></li>
	<li id="printmenuc"><a id="printpage" href="/cgi-bin/koha/members/moremember.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;print=page">Print Page</a></li>
	<li><a id="printslip" href="/cgi-bin/koha/members/moremember.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->&amp;print=slip">Print Slip</a></li>
	<li id="moremenuc"><a id="renewpatron" href="/cgi-bin/koha/members/moremember.pl?reregistration=y&amp;borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Renew Account</a></li><!-- TMPL_IF NAME="CAN_user_permissions" --><li><a id="patronflags" href="/cgi-bin/koha/members/member-flags.pl?member=<!-- TMPL_VAR NAME="borrowernumber" -->">Set Permissions</a></li><!-- /TMPL_IF --><li><a id="deletepatron" href="javascript:confirm_deletion();">Delete</a></li>
</ul></div>
