<table>
    <tr>
        [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
            <th>Priority</th>
            <th>&nbsp;</th>
        [% ELSE %]
            <th>Delete?</th>
        [% END %]
        <th>Patron</th>
        <th>Notes</th>
        <th>Date</th>
        <th>Expiration</th>
        <th>Pickup library</th>
        <th>Details</th>
        [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
            <th><img src="[% interface %]/[% theme %]/img/go-bottom.png" alt="Toggle set to lowest priority" /></th>
        [% END %]
        <th>&nbsp;</th>
        [% IF SuspendHoldsIntranet %]<th>&nbsp;</th><!-- Suspend Holds Column Header -->[% END %]
    </tr>

    [% FOREACH hold IN holds %]
        <tr>
            <td>
                <input type="hidden" name="reserve_id" value="[% hold.reserve_id %]" />
                <input type="hidden" name="borrowernumber" value="[% hold.borrowernumber %]" />
                <input type="hidden" name="biblionumber" value="[% hold.biblionumber %]" />
                <select name="rank-request">
                    [% IF ( hold.found ) %]
                        [% IF ( hold.intransit ) %]
                            <option value="T" selected="selected">In transit</option>
                        [% ELSE %]
                            <option value="W" selected="selected">Waiting</option>
                        [% END %]
                    [% END %]

                    [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                        [% IF Koha.Preference('HoldsSplitQueueNumbering') == 'actual' %]
                            [% FOREACH optionloo IN hold.optionloop %]
                                [% IF ( optionloo.selected ) %]
                                    <option value="[% optionloo.num %]" selected="selected">[% optionloo.num %]</option>
                                [% ELSE %]
                                    <option value="[% optionloo.num %]">[% optionloo.num %]</option>
                                [% END %]
                            [% END %]
                        [% ELSE %]
                            [% FOREACH h IN holds %]
                                [% IF ( h.priority == hold.priority ) %]
                                    <option value="[% h.priority %]" selected="selected">[% loop.index + 1 %]</option>
                                [% ELSE %]
                                    <option value="[% h.priority %]">[% loop.index + 1 %]</option>
                                [% END %]
                            [% END %]
                        [% END %]
                    [% ELSIF !hold.found %]
                        <option value="[% hold.priority %]" selected="selected">[% hold.priority %]</option>
                    [% END %]

                    <option value="del">del</option>
                </select>
            </td>

            [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                [% SET first_priority = holds.first.priority %]
                [% SET last_priority  = holds.last.priority %]
                [% SET prev_priority  = loop.prev.priority %]
                [% SET next_priority  = loop.next.priority %]
                [% holds.index %]

                <td style="white-space:nowrap;">
                    <a title="Move hold up" href="request.pl?action=move&amp;where=up&amp;first_priority=[% first_priority %]&amp;last_priority=[% last_priority %]&amp;prev_priority=[% prev_priority %]&amp;next_priority=[% next_priority %]&amp;borrowernumber=[% hold.borrowernumber %]&amp;biblionumber=[% hold.biblionumber %]&amp;reserve_id=[% hold.reserve_id %]&amp;date=[% hold.date %]">
                        <img src="[% interface %]/[% theme %]/img/go-up.png" alt="Go up" />
                    </a>

                    <a title="Move hold to top" href="request.pl?action=move&amp;where=top&amp;first_priority=[% first_priority %]&amp;last_priority=[% last_priority %]&amp;prev_priority=[% prev_priority %]&amp;next_priority=[% next_priority %]&amp;borrowernumber=[% hold.borrowernumber %]&amp;biblionumber=[% hold.biblionumber %]&amp;reserve_id=[% hold.reserve_id %]&amp;date=[% hold.date %]">
                        <img src="[% interface %]/[% theme %]/img/go-top.png" alt="Go top" />
                    </a>

                    <a title="Move hold to bottom" href="request.pl?action=move&amp;where=bottom&amp;first_priority=[% first_priority %]&amp;last_priority=[% last_priority %]&amp;prev_priority=[% prev_priority %]&amp;next_priority=[% next_priority %]&amp;borrowernumber=[% hold.borrowernumber %]&amp;biblionumber=[% hold.biblionumber %]&amp;reserve_id=[% hold.reserve_id %]&amp;date=[% hold.date %]">
                        <img src="[% interface %]/[% theme %]/img/go-bottom.png" alt="Go bottom" />
                    </a>

                    <a title="Move hold down" href="request.pl?action=move&amp;where=down&amp;first_priority=[% first_priority %]&amp;last_priority=[% last_priority %]&amp;prev_priority=[% prev_priority %]&amp;next_priority=[% next_priority %]&amp;borrowernumber=[% hold.borrowernumber %]&amp;biblionumber=[% hold.biblionumber %]&amp;reserve_id=[% hold.reserve_id %]&amp;date=[% hold.date %]">
                        <img src="[% interface %]/[% theme %]/img/go-down.png" alt="Go down" />
                    </a>
                </td>
            [% END %]

            <td>
                [% INCLUDE 'patron-title.inc' patron=hold.patron hide_patron_infos_if_needed=1 %]
            </td>

            <td>[% hold.notes %]</td>
            <td>[% hold.date %]</td>
            <td>[% hold.expirationdate %]</td>

            <td>
                [% IF ( hold.found ) %]
                    [% IF ( hold.atdestination ) %]
                        [% IF ( hold.found ) %]
                            Item waiting at <b> [% hold.wbrname %]</b> <input type="hidden" name="pickup" value="[% hold.wbrcode %]" /> since [% hold.waiting_date | $KohaDates %]
                        [% ELSE %]
                            Waiting to be pulled <input type="hidden" name="pickup" value="[% hold.wbrcode %]" />
                        [% END %]
                    [% ELSE %]
                        Item being transferred to <b> [% hold.wbrname %]</b> <input type="hidden" name="pickup" value="[% hold.wbrcode %]" />
                    [% END %]
                [% ELSE %]
                    [% IF Koha.Preference('IndependentBranches') && Branches.all().size == 1 %]
                        [% Branches.GetName(hold.branchcode) %] <input type="hidden" name="pickup" value="[% hold.branchcode %]" />
                    [% ELSE %]
                        <select name="pickup">
                            [% PROCESS options_for_libraries libraries => Branches.all( selected => hold.branchcode ) %]
                        </select>
                    [% END %]
                [% END %]
            </td>

            <td>
                [% IF ( hold.found ) %]
                    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% hold.biblionumber %]">
                        [% IF ( hold.barcodenumber ) %]
                            [% hold.barcodenumber %]
                            <input type="hidden" name="itemnumber" value="[% hold.itemnumber %]" />
                        [% ELSE %]
                            No barcode
                        [% END %]
                    </a>
                [% ELSE %]
                    [% IF ( hold.item_level_hold ) %]
                        <i>
                            Only item
                            <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% hold.biblionumber %]">
                                [% IF ( hold.barcodenumber ) %]
                                    [% hold.barcodenumber %]
                                    <input type="hidden" name="itemnumber" value="[% hold.itemnumber %]" />
                                [% ELSE %]
                                    No barcode
                                [% END %]
                            </a>
                        </i>
                    [% ELSE %]
                        [% IF hold.itemtype %]
                            <i>Next available [% ItemTypes.GetDescription( hold.itemtype ) %] item</i>
                        [% ELSE %]
                            <i>Next available</i>
                        [% END %]

                        <input type="hidden" name="itemnumber" value="" />
                    [% END %]
                [% END %]
            </td>

            [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                <td>
                    <a title="Toggle lowest priority" href="request.pl?action=setLowestPriority&amp;borrowernumber=[% hold.borrowernumber %]&amp;biblionumber=[% hold.biblionumber %]&amp;reserve_id=[% hold.reserve_id %]&amp;date=[% hold.date %]">
                        [% IF ( hold.lowestPriority ) %]
                            <img src="[% interface %]/[% theme %]/img/go-bottom.png" alt="Unset lowest priority" />
                        [% ELSE %]
                            <img src="[% interface %]/[% theme %]/img/go-down.png" alt="Set to lowest priority" />
                        [% END %]
                    </a>
                </td>
            [% END %]

            <td>
                <a class="cancel-hold" title="Cancel hold" href="request.pl?action=cancel&amp;borrowernumber=[% hold.borrowernumber %]&amp;biblionumber=[% hold.biblionumber %]&amp;reserve_id=[% hold.reserve_id %]&amp;date=[% hold.date %]">
                    <img src="[% interface %]/[% theme %]/img/x.png" alt="Cancel" />
                </a>
            </td>

            [% IF SuspendHoldsIntranet %]
                <td>
                    [% UNLESS ( hold.found ) %]
                        <input type="button" value="[% IF ( hold.suspend ) %]Unsuspend[% ELSE %]Suspend[% END %]" onclick="window.location.href='request.pl?action=toggleSuspend&amp;reserve_id=[% hold.reserve_id %]&amp;borrowernumber=[% hold.borrowernumber %]&amp;biblionumber=[% hold.biblionumber %]&amp;date=[% hold.date %]&amp;suspend_until=' + $('#suspend_until_[% hold.reserve_id %]').val()" />

                        [% IF AutoResumeSuspendedHolds %]
                            <label for="suspend_until_[% hold.reserve_id %]">[% IF ( hold.suspend ) %] on [% ELSE %] until [% END %]</label>
                            <input name="suspend_until" id="suspend_until_[% hold.reserve_id %]" size="10" value="[% hold.suspend_until | $KohaDates %]" class="datepicker suspend_until_datepicker" />
                            <a href='#' onclick="document.getElementById('suspend_until_[% hold.reserve_id %]').value='';">Clear date</a>
                        [% ELSE %]
                            <input type="hidden" name="suspend_until" id="suspend_until_[% hold.reserve_id %]" value=""/>
                        [% END %]

                    [% ELSE %]
                        <input type="hidden" name="suspend_until" value="" />
                    [% END %]
                </td>
            [% END # IF SuspendHoldsIntranet %]

        </tr>

    [% END %]
</table>
