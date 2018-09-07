[% USE Koha %]
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
            <th><img src="[% interface | html %]/[% theme | html %]/img/go-bottom.png" alt="Toggle set to lowest priority" /></th>
        [% END %]
        <th>&nbsp;</th>
        [% IF SuspendHoldsIntranet %]<th>&nbsp;</th><!-- Suspend Holds Column Header -->[% END %]
    </tr>

    [% FOREACH hold IN holds %]
        <tr>
            <td>
                <input type="hidden" name="reserve_id" value="[% hold.reserve_id | html %]" />
                <input type="hidden" name="borrowernumber" value="[% hold.borrowernumber | html %]" />
                <input type="hidden" name="biblionumber" value="[% hold.biblionumber | html %]" />
                [% IF Koha.Preference('HoldsSplitQueue') == "nothing" %]
                    <select name="rank-request">
                [% ELSE %]
                    <select name="rank-request" disabled>
                [% END %]
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
                                    <option value="[% optionloo.num | html %]" selected="selected">[% optionloo.num | html %]</option>
                                [% ELSE %]
                                    <option value="[% optionloo.num | html %]">[% optionloo.num | html %]</option>
                                [% END %]
                            [% END %]
                        [% ELSE %]
                            [% FOREACH h IN holds %]
                                [% IF ( h.priority == hold.priority ) %]
                                    <option value="[% h.priority | html %]" selected="selected">[% loop.index + 1 | html %]</option>
                                [% ELSE %]
                                    <option value="[% h.priority | html %]">[% loop.index + 1 | html %]</option>
                                [% END %]
                            [% END %]
                        [% END %]
                    [% ELSIF !hold.found %]
                        <option value="[% hold.priority | html %]" selected="selected">[% hold.priority | html %]</option>
                    [% END %]

                    <option value="del">del</option>
                </select>
            </td>

            [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                [% SET first_priority = holds.first.priority %]
                [% SET last_priority  = holds.last.priority %]
                [% SET prev_priority  = loop.prev.priority %]
                [% SET next_priority  = loop.next.priority %]
                [% holds.index | html %]

                <td style="white-space:nowrap;">
                    <a title="Move hold up" href="request.pl?action=move&amp;where=up&amp;first_priority=[% first_priority | html %]&amp;last_priority=[% last_priority | html %]&amp;prev_priority=[% prev_priority | html %]&amp;next_priority=[% next_priority | html %]&amp;borrowernumber=[% hold.borrowernumber | html %]&amp;biblionumber=[% hold.biblionumber | html %]&amp;reserve_id=[% hold.reserve_id | html %]&amp;date=[% hold.date | html %]">
                        <img src="[% interface | html %]/[% theme | html %]/img/go-up.png" alt="Go up" />
                    </a>

                    <a title="Move hold to top" href="request.pl?action=move&amp;where=top&amp;first_priority=[% first_priority | html %]&amp;last_priority=[% last_priority | html %]&amp;prev_priority=[% prev_priority | html %]&amp;next_priority=[% next_priority | html %]&amp;borrowernumber=[% hold.borrowernumber | html %]&amp;biblionumber=[% hold.biblionumber | html %]&amp;reserve_id=[% hold.reserve_id | html %]&amp;date=[% hold.date | html %]">
                        <img src="[% interface | html %]/[% theme | html %]/img/go-top.png" alt="Go top" />
                    </a>

                    <a title="Move hold to bottom" href="request.pl?action=move&amp;where=bottom&amp;first_priority=[% first_priority | html %]&amp;last_priority=[% last_priority | html %]&amp;prev_priority=[% prev_priority | html %]&amp;next_priority=[% next_priority | html %]&amp;borrowernumber=[% hold.borrowernumber | html %]&amp;biblionumber=[% hold.biblionumber | html %]&amp;reserve_id=[% hold.reserve_id | html %]&amp;date=[% hold.date | html %]">
                        <img src="[% interface | html %]/[% theme | html %]/img/go-bottom.png" alt="Go bottom" />
                    </a>

                    <a title="Move hold down" href="request.pl?action=move&amp;where=down&amp;first_priority=[% first_priority | html %]&amp;last_priority=[% last_priority | html %]&amp;prev_priority=[% prev_priority | html %]&amp;next_priority=[% next_priority | html %]&amp;borrowernumber=[% hold.borrowernumber | html %]&amp;biblionumber=[% hold.biblionumber | html %]&amp;reserve_id=[% hold.reserve_id | html %]&amp;date=[% hold.date | html %]">
                        <img src="[% interface | html %]/[% theme | html %]/img/go-down.png" alt="Go down" />
                    </a>
                </td>
            [% END %]

            <td>
                [% INCLUDE 'patron-title.inc' patron=hold.patron hide_patron_infos_if_needed=1 %]
            </td>

            <td>[% hold.notes | html %]</td>
            <td>[% hold.date | html %]</td>
            <td>[% hold.expirationdate | html %]</td>

            <td>
                [% IF ( hold.found ) %]
                    [% IF ( hold.atdestination ) %]
                        [% IF ( hold.found ) %]
                            Item waiting at <b> [% hold.wbrname | html %]</b> <input type="hidden" name="pickup" value="[% hold.wbrcode | html %]" /> since [% hold.waiting_date | $KohaDates %]
                        [% ELSE %]
                            Waiting to be pulled <input type="hidden" name="pickup" value="[% hold.wbrcode | html %]" />
                        [% END %]
                    [% ELSE %]
                        Item being transferred to <b> [% hold.wbrname | html %]</b> <input type="hidden" name="pickup" value="[% hold.wbrcode | html %]" />
                    [% END %]
                [% ELSE %]
                    [% IF Koha.Preference('IndependentBranches') && Branches.all().size == 1 %]
                        [% Branches.GetName(hold.branchcode) | html %] <input type="hidden" name="pickup" value="[% hold.branchcode | html %]" />
                    [% ELSE %]
                        <select name="pickup">
                            [% PROCESS options_for_libraries libraries => Branches.all( selected => hold.branchcode ) %]
                        </select>
                    [% END %]
                [% END %]
            </td>

            <td>
                [% IF ( hold.found ) %]
                    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% hold.biblionumber | html %]">
                        [% IF ( hold.barcodenumber ) %]
                            [% hold.barcodenumber | html %]
                            <input type="hidden" name="itemnumber" value="[% hold.itemnumber | html %]" />
                        [% ELSE %]
                            No barcode
                        [% END %]
                    </a>
                [% ELSE %]
                    [% IF ( hold.item_level_hold ) %]
                        <i>
                            Only item
                            <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% hold.biblionumber | html %]">
                                [% IF ( hold.barcodenumber ) %]
                                    [% hold.barcodenumber | html %]
                                    <input type="hidden" name="itemnumber" value="[% hold.itemnumber | html %]" />
                                [% ELSE %]
                                    No barcode
                                [% END %]
                            </a>
                        </i>
                    [% ELSE %]
                        [% IF hold.itemtype %]
                            <i>Next available [% ItemTypes.GetDescription( hold.itemtype ) | html %] item</i>
                        [% ELSE %]
                            <i>Next available</i>
                        [% END %]

                        <input type="hidden" name="itemnumber" value="" />
                    [% END %]
                [% END %]
            </td>

            [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                <td>
                    <a title="Toggle lowest priority" href="request.pl?action=setLowestPriority&amp;borrowernumber=[% hold.borrowernumber | html %]&amp;biblionumber=[% hold.biblionumber | html %]&amp;reserve_id=[% hold.reserve_id | html %]&amp;date=[% hold.date | html %]">
                        [% IF ( hold.lowestPriority ) %]
                            <img src="[% interface | html %]/[% theme | html %]/img/go-bottom.png" alt="Unset lowest priority" />
                        [% ELSE %]
                            <img src="[% interface | html %]/[% theme | html %]/img/go-down.png" alt="Set to lowest priority" />
                        [% END %]
                    </a>
                </td>
            [% END %]

            <td>
                <a class="cancel-hold" title="Cancel hold" href="request.pl?action=cancel&amp;borrowernumber=[% hold.borrowernumber | html %]&amp;biblionumber=[% hold.biblionumber | html %]&amp;reserve_id=[% hold.reserve_id | html %]&amp;date=[% hold.date | html %]">
                    <img src="[% interface | html %]/[% theme | html %]/img/x.png" alt="Cancel" />
                </a>
            </td>

            [% IF SuspendHoldsIntranet %]
                <td>
                    [% UNLESS ( hold.found ) %]
                        <input type="button" value="[% IF ( hold.suspend ) %]Unsuspend[% ELSE %]Suspend[% END %]" onclick="window.location.href='request.pl?action=toggleSuspend&amp;reserve_id=[% hold.reserve_id | html %]&amp;borrowernumber=[% hold.borrowernumber | html %]&amp;biblionumber=[% hold.biblionumber | html %]&amp;date=[% hold.date | html %]&amp;suspend_until=' + $('#suspend_until_[% hold.reserve_id | html %]').val()" />

                        [% IF AutoResumeSuspendedHolds %]
                            <label for="suspend_until_[% hold.reserve_id | html %]">[% IF ( hold.suspend ) %] on [% ELSE %] until [% END %]</label>
                            <input name="suspend_until" id="suspend_until_[% hold.reserve_id | html %]" size="10" value="[% hold.suspend_until | $KohaDates %]" class="datepicker suspend_until_datepicker" />
                            <a href='#' onclick="document.getElementById('suspend_until_[% hold.reserve_id | html %]').value='';">Clear date</a>
                        [% ELSE %]
                            <input type="hidden" name="suspend_until" id="suspend_until_[% hold.reserve_id | html %]" value=""/>
                        [% END %]

                    [% ELSE %]
                        <input type="hidden" name="suspend_until" value="" />
                    [% END %]
                </td>
            [% END # IF SuspendHoldsIntranet %]

        </tr>

    [% END %]
</table>
