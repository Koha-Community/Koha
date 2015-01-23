[% INCLUDE 'blocking_errors.inc' %]
[% IF subscriptionid and ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription || CAN_user_serials_receive_serials ) %]
    <div id="toolbar" class="btn-toolbar">
        [% IF CAN_user_serials_create_subscription %]
            [% IF biblionumber_for_new_subscription %]
                <div class="btn-group"><a id="newsubscription" class="btn btn-default btn-sm" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber_for_new_subscription | html %]"><i class="fa fa-plus"></i> New subscription</a></div>
            [% ELSE %]
                <div class="btn-group"><a id="newsubscription" class="btn btn-default btn-sm" href="/cgi-bin/koha/serials/subscription-add.pl"><i class="fa fa-plus"></i> New subscription</a></div>
            [% END %]
        [% END %]

        [% IF ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription ) %]
            [% UNLESS ( cannotedit ) %]
                <div class="btn-group">
                    <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-pencil"></i> Edit <span class="caret"></span></button>
                        <ul class="dropdown-menu">
                            [% IF ( cannotedit ) %] <li class="disabled"> [% ELSE %]
                            <li> [% END %]
                            <a href="/cgi-bin/koha/serials/subscription-add.pl?op=modify&amp;subscriptionid=[% subscriptionid | html %]">Edit subscription</a></li>
                            [% IF ( cannotedit ) %] <li class="disabled"> [% ELSE %]
                            <li> [% END %]
                            <a href="/cgi-bin/koha/serials/subscription-add.pl?op=dup&amp;subscriptionid=[% subscriptionid | html %]">Edit as new (duplicate)</a></li>

                            [% IF CAN_user_editcatalogue_edit_catalogue %]
                                <li><a id="editbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=[% biblionumber | html %]">Edit record</a></li>
                            [% END %]

                            [% IF serialsadditems && CAN_user_editcatalogue_edit_items %]
                                <li><a id="edititems" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=[% biblionumber | html %]">Edit items</a></li>
                            [% END %]

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
                <div class="btn-group"><a id="renew" class="btn btn-default btn-sm" href="#"><i class="fa fa-refresh"></i> Renew</a></div>
            [% END %]
            [% IF CAN_user_serials_receive_serials and not closed %]
                <div class="btn-group"><a id="receive" class="btn btn-default btn-sm" href="/cgi-bin/koha/serials/serials-edit.pl?subscriptionid=[% subscriptionid | html %]&amp;serstatus=1,3"><i class="fa fa-inbox"></i> Receive</a></div>
            [% END %]
            [% UNLESS cannotedit %]
                [% IF closed %]
                    <div class="btn-group"><a id="reopen" class="btn btn-default btn-sm" href="#"><i class="fa fa-repeat"></i> Reopen</a></div>
                [% ELSE %]
                    <div class="btn-group"><a id="close" class="btn btn-default btn-sm" href="#"><i class="fa fa-times-circle"></i> Close</a></div>
                [% END %]
            [% END %]
        [% END %]
    </div>
[% ELSIF CAN_user_serials_create_subscription %]
    <div id="toolbar" class="btn-toolbar">
        [% IF ( biblionumber_for_new_subscription ) %]
            <div class="btn-group"><a id="newsubscription" class="btn btn-default btn-sm" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber_for_new_subscription | html %]"><i class="fa fa-plus"></i> New subscription</a></div>
        [% ELSE %]
            <div class="btn-group"><a id="newsubscription" class="btn btn-default btn-sm" href="/cgi-bin/koha/serials/subscription-add.pl"><i class="fa fa-plus"></i> New subscription</a></div>
        [% END %]
    </div>
[% END %]
