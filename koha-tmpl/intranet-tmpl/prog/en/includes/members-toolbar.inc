[% USE Koha %]
[% USE Branches %]
[% USE Categories %]
[% USE Notices %]
[% USE AuthorisedValues %]
[% USE NoticeTemplates %]
[% USE scalar %]
<div id="toolbar" class="btn-toolbar">
    [% IF CAN_user_borrowers_edit_borrowers %]
        <a id="editpatron" class="btn btn-default" href="/cgi-bin/koha/members/memberentry.pl?op=edit_form&amp;destination=circ&amp;borrowernumber=[% patron.borrowernumber | html %]"
            ><i class="fa-solid fa-pencil" aria-hidden="true"></i> Edit</a
        >
    [% END %]
    [% SET guarantee_categories = Categories.limited( can_be_guarantee => 1 ).unblessed %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF patron.is_adult AND Koha.Preference("borrowerRelationship") %]
            [% IF guarantee_categories.size > 1 %]
                <div id="addchild" class="btn-group">
                    <button class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="fa fa-plus"></i> Add guarantee</button>
                    <ul class="dropdown-menu">
                        [% FOREACH cat IN guarantee_categories %]
                            <li
                                ><a class="dropdown-item" href="/cgi-bin/koha/members/memberentry.pl?op=add_form&amp;guarantor_id=[% patron.borrowernumber | html %]&categorycode=[% cat.categorycode | html %]"
                                    >[% cat.description | html %]</a
                                ></li
                            >
                        [% END %]
                    </ul>
                </div>
            [% ELSE %]
                <a id="addchild" class="btn btn-default" href="/cgi-bin/koha/members/memberentry.pl?op=add_form&amp;guarantor_id=[% patron.borrowernumber | html %]"><i class="fa fa-plus"></i> Add guarantee</a>
            [% END %]
        [% END %]
        <a id="changepassword" class="btn btn-default" href="/cgi-bin/koha/members/member-password.pl?member=[% patron.borrowernumber | html %]"><i class="fa fa-lock"></i> Change password</a>
        <a id="duplicate" class="btn btn-default" href="/cgi-bin/koha/members/memberentry.pl?op=duplicate&amp;borrowernumber=[% patron.borrowernumber | html %]"><i class="fa fa-copy"></i> Duplicate</a>
    [% END %]

    [% IF CAN_user_circulate_circulate_remaining_permissions %]
        <div class="btn-group">
            <button class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="fa fa-print"></i> Print</button>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item printslip" data-code="printsummary" href="#">Print summary</a></li>
                <li><a class="dropdown-item printslip" data-code="issueslip" href="#">Print slip</a></li>
                <li><a class="dropdown-item printslip" data-code="issueqslip" href="#">Print quick slip</a></li>
                [% IF patron.account_balance != 0 %]
                    <li><a class="dropdown-item" id="printfineslip" target="_blank" href="/cgi-bin/koha/members/printnotice.pl?notice=ACCOUNTS_SUMMARY&borrowernumber=[% patron.borrowernumber | uri %]">Print account balance</a></li>
                [% END %]
                [% IF patron.has_overdues %]
                    <li><a class="dropdown-item" id="print_overdues" href="#">Print overdues</a></li>
                [% END %]
                [% IF patron.privacy < 2 %]
                    [%# 2 is the privacy rule "Never" (Delete my history immediately) %]
                    <li><a class="dropdown-item printslip" data-code="checkinslip" href="#">Print checkin slip</a></li>
                [% END %]
                [% FOREACH notice IN Notices.GetTemplates( 'patron_slip' ) %]
                    <li><a class="dropdown-item printslip" data-code="[% notice.code | html %]" href="#">Print [% notice.name | html %]</a></li>
                [% END %]
            </ul>
        </div>
    [% END %]

    [% IF ( CAN_user_reserveforothers ) %]
        <a id="searchtohold" class="btn btn-default" href="#"><i class="fa fa-search"></i> Search to hold</a>
    [% END %]

    [% IF CAN_user_borrowers_edit_borrowers %]
        <a id="toolbar_addnewmessageLabel" href="#add_message_form" data-bs-toggle="modal" class="btn btn-default"><i class="fa-solid fa-comment"></i> Add message</a>
    [% END %]

    [% IF Koha.Preference('CurbsidePickup') %]
        <a id="curbsidePickupLabel" href="/cgi-bin/koha/circ/curbside_pickups.pl?op=find-patron&borrowernumber=[% patron.borrowernumber | html %]" class="btn btn-default"><i class="fa-solid fa-rotate"></i> Schedule pickup</a>
    [% END %]

    [% IF CAN_user_borrowers_edit_borrowers %]
        <div class="btn-group">
            <button class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown">[% tp("More menu options", "More") | html %] <span class="caret"></span></button>
            <ul class="dropdown-menu dropdown-menu-end">
                [% IF CAN_user_borrowers_edit_borrowers %]
                    <li>
                        <a class="dropdown-item" id="renewpatron" href="/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% patron.borrowernumber | html %]&amp;destination=[% destination | html %]&amp;reregistration=y">Renew patron</a>
                    </li>
                [% ELSE %]
                    <li data-bs-toggle="tooltip" data-bs-placement="left" title="You are not authorized to renew patrons">
                        <a class="dropdown-item disabled" aria-disabled="true" id="renewpatron" href="#">Renew patron</a>
                    </li>
                [% END %]
                [% IF ( CAN_user_permissions ) %]
                    <li>
                        <a class="dropdown-item" id="patronflags" href="/cgi-bin/koha/members/member-flags.pl?member=[% patron.borrowernumber | html %]">Set permissions</a>
                    </li>
                [% ELSE %]
                    <li data-bs-toggle="tooltip" data-bs-placement="left" title="You are not authorized to set permissions">
                        <a class="dropdown-item disabled" aria-disabled="true" id="patronflags" href="#">Set permissions</a>
                    </li>
                [% END %]
                [% IF ( Koha.Preference('TwoFactorAuthentication') == 'enforced' || Koha.Preference('TwoFactorAuthentication') == 'enabled' ) && ( logged_in_user.borrowernumber == patron.borrowernumber || logged_in_user.is_superlibrarian ) %]
                    <li><a class="dropdown-item" id="twofa" href="/cgi-bin/koha/members/two_factor_auth.pl?borrowernumber=[% patron.borrowernumber | uri %]">Manage two-factor authentication</a></li>
                [% END %]

                [% IF CAN_user_borrowers_edit_borrowers && useDischarge %]
                    <li><a class="dropdown-item" href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% patron.borrowernumber | uri %]">Discharge</a></li>
                [% END %]

                [% IF Koha.Preference('RESTOAuth2ClientCredentials') %]
                    [% IF CAN_user_superlibrarian OR loggedinusernumber == patron.borrowernumber %]
                        <li>
                            <a class="dropdown-item" id="apikeys" href="/cgi-bin/koha/members/apikeys.pl?patron_id=[% patron.borrowernumber | html %]">Manage API keys</a>
                        </li>
                    [% ELSE %]
                        <li data-bs-toggle="tooltip" data-bs-placement="left" title="You are not authorized to manage API keys">
                            <a class="dropdown-item disabled" aria-disabled="true" id="apikeys" href="#">Manage API keys</a>
                        </li>
                    [% END %]
                [% END %]

                [% IF CAN_user_borrowers_edit_borrowers %]
                    <li>
                        <a class="dropdown-item" id="sendwelcome" href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% patron.borrowernumber | uri %]&op=send_welcome">Send welcome notice</a>
                    </li>
                [% END %]

                [% IF CAN_user_borrowers_edit_borrowers && patron.category.effective_reset_password %]
                    <li><a class="dropdown-item" id="resetpassword" href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% patron.borrowernumber | uri %]&op=send_password_reset">Send password reset</a></li>
                [% END %]

                [% IF CAN_user_borrowers_delete_borrowers %]
                    [% IF ( patron.protected == 1 ) %]
                        <li data-bs-toggle="tooltip" data-bs-placement="left" title="Patron is protected">
                            <a class="dropdown-item disabled" aria-disabled="true" id="deletepatron" href="#">Delete</a>
                        </li>
                    [% ELSE %]
                        <li>
                            <a class="dropdown-item" id="deletepatron" href="#">Delete</a>
                        </li>
                    [% END %]
                [% ELSE %]
                    <li aria-disabled="true" data-bs-toggle="tooltip" data-bs-placement="left" title="You are not authorized to delete patrons">
                        <a class="dropdown-item disabled" id="deletepatron" href="#">Delete</a>
                    </li>
                [% END %]

                [% SET adult_categories = Categories.scalar.all(category_type => 'A') %]
                [% IF adult_categories.count > 0 %]
                    [% IF patron.is_child %]
                        <li>
                            <a class="dropdown-item" id="updatechild" href="#">Update child to adult patron</a>
                        </li>
                    [% ELSE %]
                        <li data-bs-toggle="tooltip" data-bs-placement="left" title="Patron is an adult">
                            <a href="#" class="dropdown-item disabled" aria-disabled="true" id="updatechild">Update child to adult patron</a>
                        </li>
                    [% END %]
                [% END %]
                [% IF CAN_user_borrowers_view_checkout_history && Koha.Preference('intranetreadinghistory') %]
                    [% IF ( patron.privacy == 2 ) %]
                        <li data-bs-toggle="tooltip" data-bs-placement="left" title="Not allowed by patron's privacy settings">
                            <a class="dropdown-item disabled" aria-disabled="true" id="exportbarcodes" href="#">Export today's checked in barcodes</a>
                        </li>
                    [% ELSE %]
                        <li>
                            <a class="dropdown-item" id="exportcheckins" href="#">Export today's checked in barcodes</a>
                        </li>
                    [% END %]
                [% END %]
            </ul>
        </div>
    [% END %]
</div>

<!-- Modal -->
<div id="add_message_form" class="modal" tabindex="-1" role="dialog" aria-labelledby="addnewmessageLabel toolbar_addnewmessageLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content modal-lg">
            <form method="post" action="/cgi-bin/koha/circ/add_message.pl" id="message_form" name="message_f">
                [% INCLUDE 'csrf-token.inc' %]
                <input type="hidden" name="op" value="cud-add_message" />
                <div class="modal-header">
                    <h1 class="modal-title">Leave a message</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <fieldset id="message_fieldset">
                        <ol>
                            <li class="form-group form-row">
                                <label for="message_type" class="col-form-label">Add a message for:</label>
                                <select name="message_type" id="message_type" class="form-select">
                                    <option value="L">Staff - Internal note</option>
                                    <option value="B">OPAC - [% patron.firstname | html %] [% patron.surname | html %]</option>
                                    [% IF CAN_user_borrowers_send_messages_to_borrowers %]
                                        <option value="E">Email - email addresses of patron</option>
                                        [% IF Koha.Preference("SMSSendDriver") %]
                                            <option value="SMS">SMS - sms number of patron</option>
                                        [% END %]
                                    [% END %]
                                </select>
                            </li>

                            [% bor_notes = AuthorisedValues.Get( 'BOR_NOTES' ) %]
                            [% IF bor_notes %]
                                <li class="form-group form-row">
                                    <label for="select_patron_messages" class="col-form-label">Predefined notes: </label>
                                    <select name="type" id="select_patron_messages" class="form-select">
                                        <option value="">Select note</option>
                                        [% FOREACH bor_note IN bor_notes %]
                                            <option value="[% bor_note.lib | html %]">[% bor_note.lib | html %]</option>
                                        [% END %]
                                    </select>
                                </li>
                            [% END %]

                            [% patron_letters = NoticeTemplates.GetByModule( 'add_message' ) %]
                            [% IF patron_letters %]
                                <li class="form-group form-row">
                                    <label for="select_patron_notice" class="col-form-lable" style="display:none;">Patron notice: </label>
                                    <select name="select_patron_notice" id="select_patron_notice" class="form-select" style="display:none;">
                                        <option value="">Select notice</option>
                                        [% FOREACH letter IN patron_letters %]
                                            <option value="[% letter.code | html %]">[% letter.name | html %]</option>
                                        [% END %]
                                    </select>
                                </li>
                            [% END %]

                            <li class="form-group form-row" id="subject_form" style="display: none;">
                                <label for="borrower_subject" class="col-form-label">Subject:</label>
                                <input type="text" size="60" name="borrower_subject" class="form-control" id="borrower_subject" />
                            </li>
                            <li class="form-group form-row">
                                <label for="borrower_message" class="col-form-label" style="display: none;">Body:</label>
                                <textarea cols="65" rows="5" name="borrower_message" class="form-control" id="borrower_message"></textarea>
                            </li>
                        </ol>
                    </fieldset>
                    <input type="hidden" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
                    <input type="hidden" name="batch" value="[% batch | html %]" />
                    <input type="hidden" name="branchcode" value="[% Branches.GetLoggedInBranchcode | html %]" />
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default approve" type="submit"><i class="fa fa-check"></i> Save</button>
                    <button class="btn btn-default deny cancel" type="button" data-bs-dismiss="modal"><i class="fa fa-times"></i> Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>
