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
<div id="toolbar" class="btn-toolbar">

    [% IF ( CAN_user_serials_create_subscription ) %]
        [% IF ( biblionumber_for_new_subscription ) %]
            <div class="btn-group"><a id="newsubscription" class="btn btn-small" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber_for_new_subscription %]"><i class="icon-plus"></i> New subscription</a></div>
        [% ELSE %]
            <div class="btn-group"><a id="newsubscription" class="btn btn-small" href="/cgi-bin/koha/serials/subscription-add.pl"><i class="icon-plus"></i> New subscription</a></div>
        [% END %]
    [% END %]

    [% IF ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription ) %]
        [% IF ( subscriptionid ) %]

            [% IF ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription ) %]
                [% UNLESS ( cannotedit ) %]
                    <div class="btn-group">
                        <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-pencil"></i> Edit <span class="caret"></span></button>
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

            [% UNLESS ( cannotedit ) %]
                [% UNLESS closed %]
                    [% IF ( CAN_user_serials_renew_subscription ) %]
                        <div class="btn-group"><a id="renew" class="btn btn-small" href="#" onclick="popup([% subscriptionid %])"><i class="icon-refresh"></i> Renew</a></div>
                    [% END %]
                [% END %]
                [% IF ( CAN_user_serials_receive_serials ) %]
                    [% UNLESS closed %]
                        <div class="btn-group"><a id="receive" class="btn btn-small" href="/cgi-bin/koha/serials/serials-edit.pl?subscriptionid=[% subscriptionid %]&amp;serstatus=1,3"><i class="icon-inbox"></i> Receive</a></div>
                    [% END %]
                [% END %]
                [% IF CAN_user_serials_edit_subscription %]
                    [% IF closed %]
                        <div class="btn-group"><a id="reopen" class="btn btn-small" href="#">Reopen</a></div>
                    [% ELSE %]
                        <div class="btn-group"><a id="close" class="btn btn-small" href="#"><i class="icon-remove-circle"></i> Close</a></div>
                    [% END %]
                [% END %]
            [% END %]
        [% END %]
    [% END %]
</div>
