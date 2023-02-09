[% INCLUDE 'blocking_errors.inc' %]
[% USE Koha %]
[% USE Branches %]
[% USE Categories %]
[% USE AuthorisedValues %]
[% USE scalar %]
<div id="toolbar" class="btn-toolbar">
    [% IF CAN_user_borrowers_edit_borrowers %]
        <a id="editpatron" class="btn btn-default" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% patron.borrowernumber | html %]"><i class="fa fa-pencil-alt"></i> Edit</a>
    [% END %]

    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF patron.is_adult AND Koha.Preference("borrowerRelationship") %]
            <a id="addchild" class="btn btn-default" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;guarantor_id=[% patron.borrowernumber | html %]"><i class="fa fa-plus"></i> Add guarantee</a>
        [% END %]
        <a id="changepassword" class="btn btn-default" href="/cgi-bin/koha/members/member-password.pl?member=[% patron.borrowernumber | html %]"><i class="fa fa-lock"></i> Change password</a>
        <a id="duplicate" class="btn btn-default" href="/cgi-bin/koha/members/memberentry.pl?op=duplicate&amp;borrowernumber=[% patron.borrowernumber | html %]"><i class="fa fa-copy"></i> Duplicate</a>
    [% END %]

    [% IF CAN_user_circulate_circulate_remaining_permissions %]
    <div class="btn-group">
        <button class="btn btn-default dropdown-toggle" data-toggle="dropdown"><i class="fa fa-print"></i> Print <span class="caret"></span></button>
            <ul class="dropdown-menu">
                <li><a id="printsummary" href="#">Print summary</a></li>
                <li><a id="printslip" href="#">Print slip</a></li>
                <li><a id="printquickslip" href="#">Print quick slip</a></li>
                [% IF patron.account_balance != 0 %]
                <li><a id="printfineslip" target="_blank" href="/cgi-bin/koha/members/printnotice.pl?notice=ACCOUNTS_SUMMARY&borrowernumber=[% patron.borrowernumber | uri %]">Print account balance</a></li>
                [% END %]
                [% IF patron.has_overdues %]
                    <li><a id="print_overdues" href="#">Print overdues</a></li>
                [% END %]
                <li><a id="printcheckinslip" href="#">Print checkin slip</a></li>
            </ul>
    </div>
    [% END %]

    [% IF ( CAN_user_reserveforothers ) %]
        <a id="searchtohold" class="btn btn-default" href="#"><i class="fa fa-search"></i> Search to hold</a>
    [% END %]

    <a id="addnewmessageLabel" href="#add_message_form" data-toggle="modal" class="btn btn-default"><i class="fa-solid fa-comment"></i> Add message</a>

    [% IF Koha.Preference('CurbsidePickup') %]
        <a id="curbsidePickupLabel" href="/cgi-bin/koha/circ/curbside_pickups.pl?op=find-patron&borrowernumber=[% patron.borrowernumber | html %]" class="btn btn-default"><i class="fa-solid fa-rotate"></i> Schedule pickup</a>
    [% END %]

         <div class="btn-group">
        <button class="btn btn-default dropdown-toggle" data-toggle="dropdown">More <span class="caret"></span></button>
            <ul class="dropdown-menu dropdown-menu-right">
                [% IF CAN_user_borrowers_edit_borrowers %]
                    <li><a id="renewpatron" href="/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% patron.borrowernumber | html %]&amp;destination=[% destination | html %]&amp;reregistration=y">Renew patron</a></li>
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to renew patrons" id="renewpatron" href="#">Renew patron</a></li>
                [% END %]
                [% IF ( CAN_user_permissions ) %]
                    <li><a id="patronflags" href="/cgi-bin/koha/members/member-flags.pl?member=[% patron.borrowernumber | html %]">Set permissions</a></li>
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to set permissions" id="patronflags" href="#">Set permissions</a></li>
                [% END %]

                [% IF ( Koha.Preference('TwoFactorAuthentication') == 'enforced' || Koha.Preference('TwoFactorAuthentication') == 'enabled' ) && logged_in_user.borrowernumber == patron.borrowernumber %]
                    <li><a id="twofa" href="/cgi-bin/koha/members/two_factor_auth.pl">Manage two-factor authentication</a></li>
                [% END %]

                [% IF CAN_user_borrowers_edit_borrowers && useDischarge %]
                    <li><a href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% patron.borrowernumber | uri %]">Discharge</a></li>
                [% END %]

                [% IF Koha.Preference('RESTOAuth2ClientCredentials') %]
                    [% IF CAN_user_superlibrarian OR loggedinusernumber == patron.borrowernumber %]
                        <li><a id="apikeys" href="/cgi-bin/koha/members/apikeys.pl?patron_id=[% patron.borrowernumber | html %]">Manage API keys</a></li>
                    [% ELSE %]
                        <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to manage API keys" id="apikeys" href="#">Manage API keys</a></li>
                    [% END %]
                [% END %]

                [% IF CAN_user_borrowers_edit_borrowers %]
                    <li><a id="sendwelcome" href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% patron.borrowernumber | uri %]&op=send_welcome">Send welcome email</a></li>
                [% END %]

                [% IF CAN_user_borrowers_edit_borrowers && patron.category.effective_reset_password %]
                    <li><a id="resetpassword" href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% patron.borrowernumber | uri %]&op=send_password_reset">Send password reset</a></li>
                [% END %]

                [% IF CAN_user_borrowers_delete_borrowers %]
                    <li><a id="deletepatron" href="#">Delete</a></li>
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to delete patrons" id="deletepatron" href="#">Delete</a></li>
                [% END %]
                [% SET adult_categories = Categories.scalar.all(category_type => 'A') %]
                [% IF adult_categories.count > 0 %]
                    [% IF patron.is_child %]
                        <li><a id="updatechild" href="#">Update child to adult patron</a></li>
                    [% ELSE %]
                        <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="Patron is an adult" id="updatechild" href="#">Update child to adult patron</a></li>
                    [% END %]
                [% END %]
                [% IF Koha.Preference('intranetreadinghistory') %]
                    [%IF ( privacy == 2 ) %]
                        <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="Not allowed by patron's privacy settings" id="exportbarcodes" href="#">Export today's checked in barcodes</a></li>
                    [% ELSE %]
                        <li><a id="exportcheckins" href="#">Export today's checked in barcodes</a></li>
                    [% END %]
                [% END %]
            </ul>
    </div>
</div>

<!-- Modal -->
<div id="add_message_form" class="modal" tabindex="-1" role="dialog" aria-labelledby="addnewmessageLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="/cgi-bin/koha/circ/add_message.pl" id="message_form" name="message_f">
                <div class="modal-header">
                    <h3>Leave a message</h3>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="message_type">Add a message for:</label>
                        <select name="message_type" id="message_type">
                            <option value="L">Staff - Internal note</option>
                            <option value="B">OPAC - [% patron.firstname | html %] [% patron.surname | html %]</option>
                        </select>
                    </div>
                    [% bor_notes = AuthorisedValues.Get( 'BOR_NOTES' ) %]
                    [% IF bor_notes %]
                        <div class="form-group">
                            <label for="select_patron_messages">Predefined notes: </label>
                            <select name="type" id="select_patron_messages">
                                <option value="">Select note</option>
                                [% FOREACH bor_note IN bor_notes %]
                                    <option value="[% bor_note.lib | html %]">[% bor_note.lib | html %]</option>
                                [% END %]
                            </select>
                        </div>
                    [% END %]
                    <div class="form-group">
                        <textarea rows="3" class="modal-textarea" name="borrower_message" id="borrower_message" ></textarea>
                    </div>
                    <input type="hidden" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
                    <input type="hidden" name="batch" value="[% batch | html %]" />
                    <input type="hidden" name="branchcode" value="[% Branches.GetLoggedInBranchcode | html %]" />
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default approve" type="submit"><i class="fa fa-check"></i> Save</button>
                    <button class="btn btn-default deny cancel" href="#" data-dismiss="modal" aria-hidden="true"><i class="fa fa-times"></i> Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>
