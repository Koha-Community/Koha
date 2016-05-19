<script type="text/javascript">
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

	 $(document).ready(function() {
        $("#deletesub").click(function(){
            confirm_deletion();
            return false;
        });
        $("#reopen").click(function(){
            confirm_reopen();
            return false;
        });
        $("#close").click(function(){
            confirm_close();
            return false;
        });
        $("#renew").click(function(){
            popup([% subscriptionid %]);
            return false;
        })
	 });
	//]]>
	</script>

[% IF subscriptionid and ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription || CAN_user_serials_receive_serials ) %]
    <div id="toolbar" class="btn-toolbar">
        [% IF CAN_user_serials_create_subscription %]
            [% IF biblionumber_for_new_subscription %]
                <div class="btn-group"><a id="newsubscription" class="btn btn-small" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber_for_new_subscription %]"><i class="fa fa-plus"></i> New subscription</a></div>
            [% ELSE %]
                <div class="btn-group"><a id="newsubscription" class="btn btn-small" href="/cgi-bin/koha/serials/subscription-add.pl"><i class="fa fa-plus"></i> New subscription</a></div>
            [% END %]
        [% END %]

        [% IF ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription ) %]
            [% UNLESS ( cannotedit ) %]
                <div class="btn-group">
                    <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="fa fa-pencil"></i> Edit <span class="caret"></span></button>
                        <ul class="dropdown-menu">
                            [% IF ( cannotedit ) %] <li class="disabled"> [% ELSE %]
                            <li> [% END %]
                            <a href="/cgi-bin/koha/serials/subscription-add.pl?op=modify&amp;subscriptionid=[% subscriptionid %]">Edit subscription</a></li>
                            [% IF ( cannotedit ) %] <li class="disabled"> [% ELSE %]
                            <li> [% END %]
                            <a href="/cgi-bin/koha/serials/subscription-add.pl?op=dup&amp;subscriptionid=[% subscriptionid %]">Edit as new (duplicate)</a></li>
                            [% IF ( CAN_user_serials_delete_subscription ) %]
                            [% IF ( cannotedit ) %] <li class="disabled"> [% ELSE %]
                            <li> [% END %]
                            <a href="#" id="deletesub">Delete subscription</a></li>[% END %]
                        </ul>
                </div>
            [% END %]
        [% END %]

        [% IF not cannotedit or CAN_user_serials_receive_serials %]
            [% IF CAN_user_serials_renew_subscription and not closed %]
                <div class="btn-group"><a id="renew" class="btn btn-small" href="#"><i class="fa fa-refresh"></i> Renew</a></div>
            [% END %]
            [% IF CAN_user_serials_receive_serials and not closed %]
                <div class="btn-group"><a id="receive" class="btn btn-small" href="/cgi-bin/koha/serials/serials-edit.pl?subscriptionid=[% subscriptionid %]&amp;serstatus=1,3"><i class="fa fa-inbox"></i> Receive</a></div>
            [% END %]
            [% UNLESS cannotedit %]
                [% IF closed %]
                    <div class="btn-group"><a id="reopen" class="btn btn-small" href="#"><i class="fa fa-repeat"></i> Reopen</a></div>
                [% ELSE %]
                    <div class="btn-group"><a id="close" class="btn btn-small" href="#"><i class="fa fa-times-circle"></i> Close</a></div>
                [% END %]
            [% END %]
        [% END %]
    </div>
[% ELSIF CAN_user_serials_create_subscription %]
    <div id="toolbar" class="btn-toolbar">
        [% IF ( biblionumber_for_new_subscription ) %]
            <div class="btn-group"><a id="newsubscription" class="btn btn-small" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber_for_new_subscription %]"><i class="fa fa-plus"></i> New subscription</a></div>
        [% ELSE %]
            <div class="btn-group"><a id="newsubscription" class="btn btn-small" href="/cgi-bin/koha/serials/subscription-add.pl"><i class="fa fa-plus"></i> New subscription</a></div>
        [% END %]
    </div>
[% END %]
