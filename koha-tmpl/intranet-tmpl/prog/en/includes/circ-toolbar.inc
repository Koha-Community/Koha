<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

function confirm_deletion() {
    var is_confirmed = window.confirm(_("Are you sure you want to delete this patron? This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/deletemem.pl?member=[% borrowernumber %]';
    }
}

function confirm_updatechild() {
    var is_confirmed = window.confirm(_("Are you sure you want to update this child to an Adult category?  This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/update-child.pl?op=update&borrowernumber=[% borrowernumber %]&catcode=[% catcode %]&catcode_multi=[% CATCODE_MULTI %]';
    }
}

function confirm_reregistration() {
    var is_confirmed = window.confirm(_("Are you sure you want to renew this patron's registration?"));
    // var borrowernumbervalue1 = $("#borrowernumber").attr("value");
    if (is_confirmed) {
	window.location = '/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% borrowernumber %]&amp;cardnumber=[% cardnumber %]&amp;destination=circ&amp;reregistration=y';
    }
}

function update_child() {
    // var borrowernumbervalue= $("#borrowernumber").attr("value"); 
[% IF ( CATCODE_MULTI ) %]
 window.open('/cgi-bin/koha/members/update-child.pl?op=multi&borrowernumber=[% borrowernumber %]','UpdateChild','width=400,height=300,toolbar=no,scrollbars=yes,resizable=yes');
[% ELSE %]
 confirm_updatechild();
[% END %]
}

function export_barcodes() {
    window.open('/cgi-bin/koha/members/readingrec.pl?borrowernumber=[% borrowernumber %]&amp;op=export_barcodes');
}

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    $("#printslip,#patronflags,#deletepatron").parent().remove();
		$("#moremenuc,#printmenuc,#searchtoholdc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions
    var slip_re = /slip/;
	function printx_window(print_type) {
        var handler = print_type.match(slip_re) ? "printslip" : "moremember";
		window.open("/cgi-bin/koha/members/" + handler + ".pl?borrowernumber=[% borrowernumber %]&amp;print=" + print_type, "printwindow");
		return false;
	}
	function searchToHold(){
		var date = new Date();
		date.setTime(date.getTime() + (10 * 60 * 1000));
	    $.cookie("holdfor", "[% borrowernumber %]", { path: "/", expires: date });
	    location.href="/cgi-bin/koha/catalogue/search.pl";
	}
	function yuiToolbar() {
	    var printmenu = [
            [% IF ( CAN_user_borrowers ) %]
            { text: _("Print summary"), onclick: {fn: function(){printx_window("page")}} },
            [% END %]
            { text: _("Print slip"), onclick: {fn: function(){printx_window("slip")}} },
            { text: _("Print quick slip"), onclick: {fn: function(){printx_window("qslip")}} }
	    ];
	
		var moremenu = [
            { text: _("Renew patron"),  onclick: { fn: confirm_reregistration } },
            { text: _("Set permissions"), url: "/cgi-bin/koha/members/member-flags.pl?member=[% borrowernumber %]"[% UNLESS CAN_user_permissions %], disabled: true[% END %]},
            { text: _("Delete"), [% UNLESS CAN_user_borrowers %]disabled: true, [% END %] onclick: { fn: confirm_deletion } },
            { text: _("Update child to adult patron") , onclick: { fn: update_child }[% UNLESS is_child %], disabled: true[% END %]},
            { text: _("Export today's checked in barcodes"), onclick: { fn: export_barcodes }}
        ];

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("Print"),
	        name: "printmenubutton",
	        menu: printmenu,
	        container: "printmenuc"
	    });
	    new YAHOO.widget.Button({
	        id: "searchtohold",
	        type: "button",
	        label: _("Search to hold"),
	        container: "searchtoholdc",
			onclick: {fn: searchToHold }
		});
	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("More"),
	        name: "moremenubutton",
	        menu: moremenu,
	        container: "moremenuc"
	    });

	    [% IF ( adultborrower ) %]new YAHOO.widget.Button("addchild");[% END %]
	    new YAHOO.widget.Button("editpatron");
	    new YAHOO.widget.Button("addnote");
        [% IF CAN_user_borrowers %] new YAHOO.widget.Button("changepassword");  [% END %]
	    new YAHOO.widget.Button("duplicate");
	    new YAHOO.widget.Button("printslip");
		new YAHOO.widget.Button("printpage");
	}

	//]]>
	</script>
	<ul class="toolbar">
	[% IF ( CAN_user_borrowers ) %]
	[% IF ( category_type ) %]
            [% IF ( guarantor ) %]
                <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;guarantorid=[% guarantorborrowernumber %]&amp;category_type=[% category_type %]">
            [% ELSE %]
            <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;category_type=[% category_type %]">
            [% END %]Edit</a></li>
        [% ELSE %] <!-- try with categorycode if no category_type -->
            [% IF ( categorycode ) %]
            <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;categorycode=[% categorycode %]">Edit</a></li>
            [% ELSE %] <!-- if no categorycode, set category_type to A by default -->
                <li><a id="editpatron" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;category_type=A">Edit</a></li>
            [% END %]
        [% END %]
	[% END %]
	[% IF ( CAN_user_borrowers ) %]
        [% IF ( adultborrower AND activeBorrowerRelationship ) %]<li><a id="addchild" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;guarantorid=[% borrowernumber %]&amp;category_type=C">Add child</a></li>[% END %]
        [% IF ( CAN_user_borrowers ) %] <li><a id="changepassword" href="/cgi-bin/koha/members/member-password.pl?member=[% borrowernumber %]">Change password</a></li>[% END %]
    [% END %]
    <li><a id="duplicate" href="/cgi-bin/koha/members/memberentry.pl?op=duplicate&amp;borrowernumber=[% borrowernumber %]&amp;category_type=[% category_type %]">Duplicate</a></li>
    <li id="printmenuc"><a id="printpage" href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% borrowernumber %]&amp;print=page">Print summary</a></li>
    <li><a id="printslip" href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% borrowernumber %]&amp;print=slip">Print slip</a></li>
	<li id="searchtoholdc"><a id="searchtohold" href="#">Search to hold</a></li>
    <li id="moremenuc"><a id="renewpatron" href="/cgi-bin/koha/members/moremember.pl?reregistration=y&amp;borrowernumber=[% borrowernumber %]">Renew account</a></li>
    [% IF ( CAN_user_permissions ) %]
        [% IF ( StaffMember ) %]
            [% IF ( CAN_user_staffaccess ) %]
                <li><a id="patronflags" href="/cgi-bin/koha/members/member-flags.pl?member=[% borrowernumber %]">Set permissions</a></li>
            [% END %]
          [% ELSE %]
                <li><a id="patronflags" href="/cgi-bin/koha/members/member-flags.pl?member=[% borrowernumber %]">Set permissions</a></li>
        [% END %]
    [% END %]
    [% IF ( StaffMember ) %][% UNLESS ( CAN_user_staffaccess ) %]<li><a id="deletepatron" href="javascript:confirm_deletion();">Delete</a></li>[% END %]
    [% ELSE %]<li><a id="deletepatron" href="javascript:confirm_deletion();">Delete</a></li>[% END %]

</ul></div>
