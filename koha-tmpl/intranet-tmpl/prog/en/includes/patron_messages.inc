[% USE raw %]
[% USE Branches %]
[% SET ClaimReturnedWarningThreshold = Koha.Preference('ClaimReturnedWarningThreshold') %]
[% SET return_claims = patron.return_claims %]
[% SET logged_in_branchcode = Branches.GetLoggedInBranchcode() %]

[% IF ( has_modifications || warndeparture || returnbeforeexpiry || expired || patron.gonenoaddress || patron.lost || userdebarred || odues || ( return_claims.count > ClaimReturnedWarningThreshold ) || age_limitations || charges || charges_guarantors_guarantees || charges_guarantees || credits ) %]
    <h3>Attention</h3>
    <ul>
        [% IF ( has_modifications ) %]
            <li class="has_modifications">
                <span class="circ-hlt">Pending modifications:</span>
                [% IF CAN_user_borrowers_edit_borrowers && ( !Koha.Preference('IndependentBranchesPatronModifications') || borrower.branch == branch ) %]
                    <a href="/cgi-bin/koha/members/members-update.pl?active=[% patron.borrowernumber | uri %]">Review pending modifications</a>
                [% ELSE %]
                    <span>Patron has pending modifications</span>
                [% END %]
            </li>
        [% END %]

        [% IF ( warndeparture ) %]
            <li class="warndeparture">
                <span class="circ-hlt">Expiration:</span>
                <span>Patron's card will expire soon.</span>
                <span>Patron's card expires on [% expiry | $KohaDates %]</span>
                <a href="/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% patron.borrowernumber | uri %]&amp;destination=circ&amp;reregistration=y">Renew</a> or <a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% patron.borrowernumber | html %]">Edit details</a>
            </li>
        [% END %]

        [% IF ( returnbeforeexpiry ) %]
            <li class="returnbeforeexpiry">
                <span class="circ-hlt">Set due date to expiry:</span> You have the ReturnBeforeExpiry system preference enabled this means if the expiry date is before the date due, the date due will be set to the expiry date
            </li>
        [% END %]

        [% IF ( expired ) %]
            <li class="expired">
                <span class="circ-hlt">Expiration:</span>
                <span>Patron's card has expired.</span>
                [% IF ( expiry ) %]
                    <span>Patron's card expired on [% expiry | $KohaDates %]</span>
                [% END %]
                <a href="/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% patron.borrowernumber | uri %]&amp;destination=circ&amp;reregistration=y">Renew</a> or <a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% patron.borrowernumber | html %]">Edit details</a>
            </li>
        [% END %]

        [% IF ( patron.gonenoaddress ) %]
            <li class="gonenoaddress blocker">
                <span title="gonenoaddress flag is set in patron record"><span class="circ-hlt">Address:</span> Patron's address flagged as in doubt</span>
            </li>
        [% END %]

        [% IF ( patron.lost ) %]
            <li class="lost blocker">
                <span title="lost flag is set in patron record"><span class="circ-hlt">Lost: </span> Patron's card is flagged as lost</span>
            </li>
        [% END %]

        [% IF ( userdebarred ) %]
            <li class="userdebarred blocker">
                <span class="circ-hlt"> Restricted since [% debarredsince | $KohaDates %]:</span> Patron's account is restricted

                [% IF ( userdebarreddate ) %]
                    until [% userdebarreddate | $KohaDates %]
                [% END %]

                [% IF ( debarredcomment ) %]
                    with the explanation: <br/>
                    <em>
                        [% IF debarredcomment.search('OVERDUES_PROCESS') %]
                            Restriction added by overdues process [% debarredcomment.remove('OVERDUES_PROCESS ') | $raw | html_line_break %]
                        [% ELSE %]
                            [% debarredcomment | $raw | html_line_break %]
                        [% END %]
                    </em><br/>
                [% END %]
                <a class="btn btn-xs btn-default" href="#reldebarments" onclick="$('#reldebarments-tab').click()"><i class="fa fa-ban"></i> View restrictions</a>

                [% IF (noissues && CAN_user_circulate_force_checkout) %]
                    <span class="override_debarment">
                        <a href="/cgi-bin/koha/circ/circulation.pl?forceallow=1&amp;borrowernumber=[% patron.borrowernumber | uri %]" class="btn btn-xs btn-default">Override restriction temporarily</a>
                    </span>
                [% END %]
            </li> <!-- /.blocker -->
        [% END # /IF userdebarred %]

        [% IF ( odues ) %]
            <li class="odues blocker">
                <span class="circ-hlt">Overdues:</span>  Patron has ITEMS OVERDUE <a href="#checkouts">See highlighted items below</a>
            </li>
        [% END %]

        [% IF return_claims.count > ClaimReturnedWarningThreshold %]
            <li class="return_claims blocker">
                <span class="circ-hlt return-claims">Return claims:</span> Patron has [% return_claims.count | html %] RETURN CLAIMS
            </li>
        [% END %]

        [% IF age_limitations %]
            [% INCLUDE 'category-out-of-age-limit.inc' %]
        [% END %]

        [% IF ( charges ) %]
            [% INCLUDE 'blocked-fines.inc' fines = chargesamount %]
        [% END %]

        [% IF ( charges_guarantors_guarantees ) %]
            <li class="charges_guarantors_guarantees">
                <span class="circ-hlt">Charges:</span> Patron's guarantors and their other guarantees collectively owe [% charges_guarantors_guarantees | $Price %].
                [% IF noissues %]
                    <span class="circ-hlt">Checkouts are BLOCKED because fine balance is OVER THE LIMIT.</span>
                [% END %]
            </li>
        [% END %]

        [% IF ( charges_guarantees ) %]
            <li class="charges_guarantees">
                <span class="circ-hlt">Charges:</span> Patron's guarantees collectively owe [% chargesamount_guarantees | $Price %].
                    [% IF noissues %]
                        <span class="circ-hlt">Checkouts are BLOCKED because fine balance is OVER THE LIMIT.</span>
                    [% END %]
            </li>
        [% END %]

        [% IF ( credits ) %]
            <li class="credits">
                <span class="circ-hlt">Credits:</span> Patron has a credit[% IF ( creditsamount ) %] of <span class="credit"><strong>[% creditsamount | $Price %]</strong></span>[% END %]
            </li>
        [% END %]

    </ul>

[% END # /F ( has_modifications || warndeparture... %]

[% IF waiting_recalls.count %]
    <div id="recallswaiting" class="circmessage">
        [% SET waiting_here = 0 %]
        [% SET waiting_elsewhere = 0 %]
        [% FOREACH w IN waiting_recalls %]
            [% IF ( w.pickup_library_id == logged_in_branchcode  ) %]
                [% waiting_here = waiting_here + 1 %]
            [% ELSE %]
                [% waiting_elsewhere = waiting_elsewhere + 1 %]
            [% END %]
        [% END %]

        [% IF ( waiting_here > 0 ) %]
            <h4>Recalls waiting here ([% waiting_here | html %])</h4>
            <ul>
                [% FOREACH w IN waiting_recalls %]
                    [% IF ( w.pickup_library_id == logged_in_branchcode  ) %]
                        <li>
                            <a href="/cgi-bin/koha/recalls/request.pl?biblionumber=[% w.biblio_id | uri %]">[% w.biblio.title | html %]</a>
                            ([% ItemTypes.GetDescription( w.item.effective_itemtype ) | html %]),
                            [% IF ( w.biblio.author ) %] by [% w.biblio.author | html %] [% END %]
                            [% IF ( w.item.itemcallnumber ) %] [[% w.item.itemcallnumber | html %]] [% END %]
                            <span>Recall placed on [% w.created_date | $KohaDates %].</span>
                            <br />
                            <strong class="waitinghere">
                                [% SET expires_on = w.expiration_date %]
                                Waiting here [% IF expires_on %] until [% expires_on | $KohaDates %] [% END %]
                            </strong>
                        </li>
                    [% END %]
                [% END %]
            </ul>
        [% END %]

        [% IF ( waiting_elsewhere > 0 ) %]
            <h4>Recalls waiting at other libraries ([% waiting_elsewhere | html %])</h4>
            <ul>
                [% FOREACH w IN waiting_recalls %]
                    [% IF ( w.pickup_library_id != logged_in_branchcode  ) %]
                        <li>
                            <a href="/cgi-bin/koha/recalls/request.pl?biblionumber=[% w.biblio_id | uri %]">[% w.biblio.title | html %]</a>
                            ([% ItemTypes.GetDescription( w.item.effective_itemtype ) | html %]),
                            [% IF ( w.biblio.author ) %] by [% w.biblio.author | html %] [% END %]
                            [% IF ( w.item.itemcallnumber ) %] [[% w.item.itemcallnumber | html %]] [% END %]
                            <span>Recall placed on [% w.created_date | $KohaDates %].</span>
                            <br />
                            <strong>
                                [% SET expires_on = w.expiration_date %]
                                Waiting at [% Branches.GetName( w.pickup_library_id ) | html %] [% IF expires_on %] until [% expires_on | $KohaDates %] [% END %]
                            </strong>
                        </li>
                    [% END %]
                [% END %]
            </ul>
        [% END %]
    </div>
[% END # /IF waiting_recalls.count %]

[% IF WaitingHolds.count %]
    <div id="holdswaiting" class="circmessage">
        [% SET waiting_here = 0 %]
        [% SET waiting_elsewhere = 0 %]
        [% FOREACH w IN WaitingHolds %]
            [% IF ( w.branch.branchcode == logged_in_branchcode  ) %]
                [% waiting_here = waiting_here + 1 %]
            [% ELSE %]
                [% waiting_elsewhere = waiting_elsewhere + 1 %]
            [% END %]
        [% END %]

        [% IF ( waiting_here > 0 ) %]
            <h4>Holds waiting here ([% waiting_here | html %])</h4>
            <ul>
                [% FOREACH w IN WaitingHolds %]
                    [% IF ( w.branch.branchcode == logged_in_branchcode  ) %]
                        <li>
                            <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% w.biblio.biblionumber | uri %]">[% w.biblio.title | html %]</a>
                            ([% ItemTypes.GetDescription( w.item.effective_itemtype ) | html %]),
                            [% IF ( w.biblio.author ) %] by [% w.biblio.author | html %] [% END %]
                            [% IF ( w.item.itemcallnumber ) %] [[% w.item.itemcallnumber | html %]] [% END %]
                            <span>Hold placed on [% w.reservedate | $KohaDates %].</span>
                            <br />
                            <strong class="waitinghere">
                                [% SET expires_on = w.expirationdate %]
                                Waiting here [% IF expires_on %] until [% expires_on | $KohaDates %] [% END %]
                            </strong>
                        </li>
                    [% END %]
                [% END %]
            </ul>
        [% END %]

        [% IF ( waiting_elsewhere > 0 ) %]
            <h4>Holds waiting at other libraries ([% waiting_elsewhere | html %])</h4>
            <ul>
                [% FOREACH w IN WaitingHolds %]
                    [% IF ( w.branch.branchcode != logged_in_branchcode  ) %]
                        <li>
                            <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% w.biblio.biblionumber | uri %]">[% w.biblio.title | html %]</a>
                            ([% ItemTypes.GetDescription( w.item.effective_itemtype ) | html %]),
                            [% IF ( w.biblio.author ) %] by [% w.biblio.author | html %] [% END %]
                            [% IF ( w.item.itemcallnumber ) %] [[% w.item.itemcallnumber | html %]] [% END %]
                            <span>Hold placed on [% w.reservedate | $KohaDates %].</span>
                            <br />
                            <strong>
                                [% SET expires_on = w.expirationdate %]
                                Waiting at [% w.branch.branchname | html %] [% IF expires_on %] until [% expires_on | $KohaDates %] [% END %]
                            </strong>
                        </li>
                    [% END %]
                [% END %]
            </ul>
        [% END %]
    </div>
[% END # /IF WaitingHolds.count %]

[% IF Koha.Preference("CurbsidePickup") %]
    [% SET curbside_pickups = patron.curbside_pickups.search( branchcode => Branches.GetLoggedInBranchcode ) %]
    [% IF curbside_pickups.count %]
        <div id="curbside_pickups" class="circmessage">
            <h4>Curbside pickups scheduled here</h4>
            <ul>
            [% FOR cp IN curbside_pickups %]
                <li>On [% cp.scheduled_pickup_datetime | $KohaDates %]:
                    [% SWITCH cp.status %]
                    [% CASE 'to-be-staged' %]
                        <a href="/cgi-bin/koha/circ/curbside_pickups.pl?tab=to-be-staged">
                        To be staged</a>
                    [% CASE 'staged-and-ready' %]
                        <a href="/cgi-bin/koha/circ/curbside_pickups.pl?tab=staged-and-ready">
                        Staged and ready</a>
                    [% CASE 'patron-is-outside' %]
                        <a href="/cgi-bin/koha/circ/curbside_pickups.pl?tab=patron-is-outside">
                        Patron is outside!</a>
                    [% CASE 'delivered' %]
                        <a href="/cgi-bin/koha/circ/curbside_pickups.pl?tab=delivered-today">
                        Delivered</a>
                    [% CASE %]<span>Unknown status "[% cp.status | html %]"</span>
                    [% END %]
                </li>
            [% END %]
            </ul>
        </div>
    [% END %]
[% END %]

[% IF ( patron.borrowernotes ) %]
    <div id="circnotes" class="circmessage">
        <h4>Notes</h4>
        <ul>
            <li>
                <span class="circ-hlt">
                    [% patron.borrowernotes | $raw | html_line_break %]
                </span>
            </li>
        </ul>
    </div> <!-- /#circnotes -->
[% END # /IF patron.borrowernotes %]

[% IF ( patron_messages ) %]
    <div id="messages" class="circmessage">
        <h4>Messages</h4>
        <ul>
            [% FOREACH patron_message IN patron_messages %]
                <li>
                    [% IF(patron_message.message_type == "L") %]
                        <span class="circ-hlt">
                    [% ELSE %]
                        <span>
                    [% END %]
                        [% patron_message.message_date | $KohaDates %]
                        [% Branches.GetName( patron_message.branchcode ) | html %]
                        [% IF patron_message.manager_id %]
                            ( <a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% patron_message.manager_id | uri %]">[% patron_message.get_column('manager_firstname') | html %] [% patron_message.get_column('manager_surname') | html %]</a> )
                        [% END %]
                        <em>"[% patron_message.message | html %]"</em>
                        [% IF patron_message.patron_read_date %]
                            Read: <em>[% patron_message.patron_read_date | $KohaDates %]</em>
                        [% END %]
                    </span>
                    [% IF patron_message.branchcode == Branches.GetLoggedInBranchcode OR Koha.Preference('AllowAllMessageDeletion') %]
                        [% IF moremember %]
                            <a id="#edit_message_form_[% patron_message.message_id | html %]" class="btn btn-link edit_message" href="#edit_message_form_[% patron_message.message_id | uri %]" data-target="#edit_message_form_[% patron_message.message_id | html %]" data-toggle="modal" class="btn btn-default"><i class="fa fa-edit"></i> Edit</a>
                            <a class="btn btn-link delete_message" href="/cgi-bin/koha/circ/del_message.pl?message_id=[% patron_message.message_id | html %]&amp;borrowernumber=[% patron_message.borrowernumber | html %]&amp;from=moremember"><i class="fa fa-trash"></i> Delete</a>
                        [% ELSE %]
                            <a id="#edit_message_form_[% patron_message.message_id | html %]" class="btn btn-link edit_message" href="#edit_message_form_[% patron_message.message_id | uri %]" data-target="#edit_message_form_[% patron_message.message_id | html %]" data-toggle="modal" class="btn btn-default"><i class="fa fa-edit"></i> Edit</a>
                            <a class="btn btn-link delete_message" href="/cgi-bin/koha/circ/del_message.pl?message_id=[% patron_message.message_id | html %]&amp;borrowernumber=[% patron_message.borrowernumber | html %]"><i class="fa fa-trash"></i> Delete</a>
                        [% END %]
                    [% END %]
                </li>
            [% END %]
        </ul>
        <a id="addnewmessageLabel" href="#add_message_form" class="btn btn-link" data-toggle="modal"><i class="fa fa-plus"></i> Add a new message</a>
    </div> <!-- /#messages -->

    [% FOREACH pm IN patron_messages %]
        <div id="edit_message_form_[% pm.message_id | html %]" class="modal" tabindex="-1" role="dialog" aria-labelledby="#edit_message_form_[% patron_message.message_id | html %]" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form method="post" action="/cgi-bin/koha/circ/add_message.pl" id="message_form" name="message_f">
                        <input type="hidden" name="message_id" value="[% pm.message_id | html %]"/>
                        <div class="modal-header">
                            <h3>Edit message</h3>
                        </div>
                        <div class="modal-body">
                            <div class="form-group">
                                <label for="message_type">Message is for:</label>
                                <select name="message_type" id="message_type" disabled>
                                    [% IF pm.message_type == "L" %]
                                        <option value="L" selected="selected">Staff - Internal note</option>
                                    [% ELSE %]
                                        <option value="L">Staff - Internal note</option>
                                    [% END %]

                                    [% IF pm.message_type == "B" %]
                                        <option value="B" selected="selected">OPAC - [% patron.firstname | html %] [% patron.surname | html %]</option>
                                    [% ELSE %]
                                        <option value="B">OPAC - [% patron.firstname | html %] [% patron.surname | html %]</option>
                                    [% END %]
                                </select>
                            </div>
                            <div class="form-group">
                                <textarea rows="3" class="modal-textarea" name="borrower_message" id="borrower_message" >[% pm.message | html %]</textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button class="btn btn-default approve" type="submit"><i class="fa fa-check"></i> Save</button>
                            <button class="btn btn-default deny cancel" href="#" data-dismiss="modal" aria-hidden="true"><i class="fa fa-times"></i> Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    [% END %]

[% END # /IF patron_messages %]
