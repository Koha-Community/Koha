<div id="toolbar"><script type="text/javascript">
	//<![CDATA[

    function confirm_close() {
        var is_confirmed = confirm(_("Are you sure you want to close this subscription?"));
        if (is_confirmed) {
            window.location="subscription-detail.pl?subscriptionid=[% subscriptionid %]&op=close";
        }
    }
    function confirm_reopen() {
        var is_confirmed = confirm(_("Are you sure you want to reopen this subscription?"));
        if (is_confirmed) {
            window.location="subscription-detail.pl?subscriptionid=[% subscriptionid %]&op=reopen";
        }
    }
	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    $("#editmenuc").empty();
	    $("#duplicate").parent().remove();
		$("#delete").parent().remove();
	 	$("#renewc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
	
    [% IF ( subscriptionid ) %]
	    var editmenu = [
	        [% IF ( CAN_user_serials_edit_subscription ) %]
            { text: _("Edit subscription"),  [% IF ( cannotedit ) %]disabled: true, [% END %] url: "/cgi-bin/koha/serials/subscription-add.pl?op=modify&amp;subscriptionid=[% subscriptionid %]" },
		[% END %]
	        [% IF ( CAN_user_serials_create_subscription ) %]
            { text: _("Edit as new (duplicate)"), [% IF ( cannotedit ) %]disabled: true, [% END %] url: "/cgi-bin/koha/serials/subscription-add.pl?op=dup&amp;subscriptionid=[% subscriptionid %]" },
		[% END %]
	        [% IF ( CAN_user_serials_delete_subscription ) %]
            { text: _("Delete subscription"), [% IF ( cannotedit ) %]disabled: true, [% END %] onclick: {fn: confirm_deletion }}
		[% END %]
	    ];
	 [% END %]
	    new YAHOO.widget.Button("newsubscription");
	    [% IF ( subscriptionid ) %]		
		new YAHOO.widget.Button({
              id: "renew", 
              type: "link", 
			  href: "#",
              label: _("Renew"), 
              container: "renewc",
onclick: {fn:function(){popup([% subscriptionid %])}}
          });
	[% IF ( subscriptionid ) %]	  
	new YAHOO.widget.Button({
	        type: "menu",
	        label: _("Edit"),
	        name: "editmenubutton",
	        menu: editmenu,
	        container: "editmenuc"
			
	    });
		[% END %]
	    new YAHOO.widget.Button("renew");
	    new YAHOO.widget.Button("receive");
        new YAHOO.widget.Button("close");
        new YAHOO.widget.Button("reopen");
		[% END %]
	}

	//]]>
	</script>
<ul class="toolbar">
    [% IF ( CAN_user_serials_create_subscription ) %]
        [% IF ( biblionumber_for_new_subscription ) %]
            <li><a id="newsubscription" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber_for_new_subscription %]">New subscription</a></li>
        [% ELSE %]
            <li><a id="newsubscription" href="/cgi-bin/koha/serials/subscription-add.pl">New subscription</a></li>
        [% END %]
    [% END %]

    [% IF ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription ) %]
        [% IF ( subscriptionid ) %]

            [% IF ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription ) %]
                [% UNLESS ( cannotedit ) %]
                    <li id="editmenuc"><a id="edit" href="/cgi-bin/koha/serials/subscription-add.pl?op=modify&amp;subscriptionid=[% subscriptionid %]">Edit</a></li>
                [% END %]
            [% END %]

            [% IF ( CAN_user_serials_create_subscription ) %]
                <li><a id="duplicate" href="/cgi-bin/koha/serials/subscription-add.pl?op=dup&amp;subscriptionid=[% subscriptionid %]">Duplicate </a></li>
            [% END %]

            [% UNLESS ( cannotedit ) %]
                [% UNLESS closed %]
                    [% IF ( CAN_user_serials_renew_subscription ) %]
                        <li id="renewc"><a id="renew" href="#" onclick="popup([% subscriptionid %])">Renew </a></li>
                    [% END %]
                [% END %]
                [% IF ( CAN_user_serials_receive_serials ) %]
                    [% UNLESS closed %]
                        <li><a id="receive" href="/cgi-bin/koha/serials/serials-edit.pl?subscriptionid=[% subscriptionid %]&amp;serstatus=1,3">Receive</a></li>
                    [% END %]
                [% END %]
                [% IF CAN_user_serials_edit_subscription %]
                    [% IF closed %]
                        <li><a id="reopen" href="javascript:confirm_reopen();">Reopen</a></li>
                    [% ELSE %]
                        <li><a id="close" href="javascript:confirm_close();">Close</a></li>
                    [% END %]
                [% END %]
                [% IF ( CAN_user_serials_delete_subscription ) %]
                    <li><a id="delete" href="javascript:confirm_deletion()">Delete</a></li>
                [% END %]
            [% END %]
        [% END %]
    [% END %]
</ul>
</div>
