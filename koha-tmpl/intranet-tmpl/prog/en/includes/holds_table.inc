[% USE Koha %]
[% SET hold_cancellation = AuthorisedValues.GetAuthValueDropbox('HOLD_CANCELLATION') %]
[% USE AuthorisedValues %]

<table id="patron_holds_table" class="holds_table">
    <thead>
        <tr>
            <th id="checkbox" data-colname="checkbox"><input type="checkbox" class="select_hold_all" /></th>
            <th id="priority" data-colname="priority">Priority</th>
            [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                <th id="change_priority" data-colname="change_priority">Change priority</th>
            [% END %]
            <th id="patron" data-colname="patron">Patron</th>
            <th id="notes" data-colname="notes">Notes</th>
            <th id="date" data-colname="date">Date</th>
            <th id="expiration" data-colname="expiration">Expiration</th>
            <th id="pickup_library" data-colname="pickup_library">Pickup library</th>
            <th id="details" data-colname="details">Details</th>
            [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                <th id="set_lowest_priority" data-colname="set_lowest_priority"><span style="display:none;">Set lowest priority</span><i class="fa fa-lg fa-rotate-90 fa-fast-forward" title="Toggle set to lowest priority"></i></th>
            [% END %]
            <th id="delete" data-colname="delete">Delete</th>
            <th id="suspend" data-colname="suspend">Suspend</th>
            <th id="print_slip" data-colname="print_slip">Print hold/transfer slip</th>
        </tr>
    </thead>
    [%- SET first_priority = 0 -%]
    [%- SET found_holds = 0 -%]
    [%- SET last_priority  = holds.last.priority -%]

    [% SET all_priorities = [] %]
    [% FOREACH hold IN holds %]
        [% all_priorities.push( hold.priority ) %]
    [% END %]

    <tbody>
        [% FOREACH hold IN holds %]
            [%- IF !hold.found && first_priority == 0 -%]
                [%- first_priority = hold.priority -%]
                [%- found_holds = loop.index() -%]
            [%- END -%]
            [%- IF Koha.Preference('HoldsSplitQueueNumbering') == 'actual' -%]
                [%- this_priority = hold.priority -%]
            [%- ELSE -%]
                [%- this_priority = loop.count() - found_holds -%]
            [%- END -%]
            [% SET tr_class = hold.suspend ? 'suspend' : '' %]
            <tr class="[% tr_class | html %]">
                <td><input type="checkbox" class="select_hold" data-id="[% hold.reserve_id | html %]" /></td>
                <td>
                    <input type="hidden" name="reserve_id" value="[% hold.reserve_id | html %]" />
                    <input type="hidden" name="borrowernumber" value="[% hold.borrowernumber | html %]" />
                    <input type="hidden" name="biblionumber" value="[% hold.biblionumber | html %]" />
                    [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                        [% IF Koha.Preference('HoldsSplitQueue') == "nothing" && !hold.found %]
                            <select name="rank-request" class="rank-request" data-hold-id="[% hold.reserve_id | html %]">
                                [% IF ( CAN_user_reserveforothers_modify_holds_priority ) %]
                                    [% FOREACH priority IN all_priorities %]
                                        [% IF priority == this_priority %]
                                            <option value="[% priority | html %]" selected="selected">[% priority | html %]</option>
                                        [% ELSIF priority > 0 %]
                                            <option value="[% priority | html %]">[% priority | html %]</option>
                                        [% END %]
                                    [% END %]
                                [% ELSE %]
                                    <option value="[% hold.priority | html %]" selected="selected">[% this_priority | html %]</option>
                                [% END %]
                                <option value="del">del</option>
                            </select>
                        [% ELSE %]
                            <input type="hidden" name="rank-request" class="rank-request" value="[% hold.priority | html %]" data-hold-id="[% hold.reserve_id | html %]" />
                            <select name="rank-request" class="rank-request" disabled="disabled" data-hold-id="[% hold.reserve_id | html %]">
                                [% IF ( hold.found ) %]
                                    [% IF ( hold.intransit ) %]
                                        <option value="T" selected="selected">In transit</option>
                                    [% ELSIF (hold.inprocessing) %]
                                        <option value="P" selected="selected">In processing</option>
                                    [% ELSE %]
                                        <option value="W" selected="selected">Waiting</option>
                                    [% END %]
                                [% ELSE %]
                                    <option value="[% hold.priority | html %]" selected="selected">[% this_priority | html %]</option>
                                [% END %]
                            </select>
                        [% END %]
                    [% ELSE %]
                        <input type="hidden" name="rank-request" class="rank-request" value="[% hold.priority | html %]" data-hold-id="[% hold.reserve_id | html %]" />
                        [% hold.priority | html %]
                    [% END %]
                </td>
                [%- IF ( CAN_user_reserveforothers_modify_holds_priority ) -%]
                    [%- UNLESS hold.found -%]
                        [%- SET prev_priority  = loop.prev.priority -%]
                        [%- SET next_priority  = loop.next.priority -%]
                        <td style="white-space:nowrap;">
                            <a
                                class="hold-arrow"
                                title="Move hold up"
                                data-op="cud-move"
                                data-where="up"
                                data-first_priority="[% first_priority | html %]"
                                data-last_priority="[% last_priority | html %]"
                                data-prev_priority="[% prev_priority | html %]"
                                data-next_priority="[% next_priority | html %]"
                                data-borrowernumber="[% hold.borrowernumber | html %]"
                                data-biblionumber="[% hold.biblionumber | html %]"
                                data-reserve_id="[% hold.reserve_id | html %]"
                                data-date="[% hold.date | html %]"
                            >
                                <i class="fa fa-lg icon-move-hold-up" aria-hidden="true"></i>
                            </a>

                            <a
                                class="hold-arrow"
                                title="Move hold to top"
                                data-op="cud-move"
                                data-where="top"
                                data-first_priority="[% first_priority | html %]"
                                data-last_priority="[% last_priority | html %]"
                                data-prev_priority="[% prev_priority | html %]"
                                data-next_priority="[% next_priority | html %]"
                                data-borrowernumber="[% hold.borrowernumber | html %]"
                                data-biblionumber="[% hold.biblionumber | html %]"
                                data-reserve_id="[% hold.reserve_id | html %]"
                                data-date="[% hold.date | html %]"
                            >
                                <i class="fa fa-lg icon-move-hold-top" aria-hidden="true"></i>
                            </a>

                            <a
                                class="hold-arrow"
                                title="Move hold to bottom"
                                data-op="cud-move"
                                data-where="bottom"
                                data-first_priority="[% first_priority | html %]"
                                data-last_priority="[% last_priority | html %]"
                                data-prev_priority="[% prev_priority | html %]"
                                data-next_priority="[% next_priority | html %]"
                                data-borrowernumber="[% hold.borrowernumber | html %]"
                                data-biblionumber="[% hold.biblionumber | html %]"
                                data-reserve_id="[% hold.reserve_id | html %]"
                                data-date="[% hold.date | html %]"
                            >
                                <i class="fa fa-lg icon-move-hold-bottom" aria-hidden="true"></i>
                            </a>

                            <a
                                class="hold-arrow"
                                title="Move hold down"
                                data-op="cud-move"
                                data-where="down"
                                data-first_priority="[% first_priority | html %]"
                                data-last_priority="[% last_priority | html %]"
                                data-prev_priority="[% prev_priority | html %]"
                                data-next_priority="[% next_priority | html %]"
                                data-borrowernumber="[% hold.borrowernumber | html %]"
                                data-biblionumber="[% hold.biblionumber | html %]"
                                data-reserve_id="[% hold.reserve_id | html %]"
                                data-date="[% hold.date | html %]"
                            >
                                <i class="fa fa-lg icon-move-hold-down" aria-hidden="true"></i>
                            </a>
                        </td>
                    [%- ELSE -%]
                        <td></td>
                    [%- END -%]
                [%- END -%]
                <td> [% INCLUDE 'patron-title.inc' patron=hold.patron hide_patron_infos_if_needed=1 %] </td>
                <td>[% hold.notes | html | html_line_break %]</td>
                <td data-order="[% hold.date| html %]">
                    [% IF Koha.Preference('AllowHoldDateInFuture') %]
                        <input type="text" class="flatpickr" value="[% hold.date | html %]" required="required" size="10" name="reservedate" />
                    [% ELSE %]
                        [% hold.date | $KohaDates %]
                    [% END %]
                </td>
                <td>
                    <input type="text" class="flatpickr" data-flatpickr-futuredate="true" value="[% hold.expirationdate | html %]" size="10" name="expirationdate" />
                </td>
                <td>
                    [%- IF ( hold.found ) -%]
                        <input type="hidden" name="pickup" value="[% hold.wbrcode | html %]" />
                        [%- IF ( hold.atdestination ) -%]
                            Item waiting at <strong> [% hold.wbrname | html %]</strong>[% IF hold.desk_name %], [% hold.desk_name | html %],[% END %] since [% hold.waiting_date | $KohaDates %]
                        [%- ELSIF (hold.intransit) -%]
                            Item being transferred to <strong> [% hold.wbrname | html %]</strong>
                        [%- ELSIF (hold.inprocessing) -%]
                            Item being processed at <strong> [% hold.wbrname | html %]</strong>
                        [%- ELSE -%]
                            Hold expected at <strong>[% hold.wbrname | html %]</strong>, please checkin to verify status
                        [%- END -%]
                    [%- ELSE -%]
                        [%- IF Koha.Preference('IndependentBranches') && Branches.all().size == 1 -%]
                            [% Branches.GetName(hold.branchcode) | html %] <input type="hidden" name="pickup" value="[% hold.branchcode | html %]" />
                        [%- ELSE -%]
                            <select class="pickup_location_dropdown" data-selected="[% hold.branchcode | html %]" data-hold-id="[% hold.reserve_id | html %]" data-pickup-location-source="hold" name="pickup">
                                <option selected="selected" value="[% hold.branchcode | html %]">[% Branches.GetName(hold.branchcode) | html %]</option>
                                <option value="" disabled="disabled" class="loading">Loading...</option>
                            </select>
                            <img class="loading_[% hold.reserve_id | html %]" src="[% interface | html %]/[% theme | html %]/img/spinner-small.gif" alt="" style="display:none;" />
                        [%- END -%]
                    [%- END -%]
                </td>
                <td>
                    [%- IF ( hold.found ) -%]
                        <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% hold.biblionumber | uri %]&amp;itemnumber=[% hold.itemnumber | uri %]#item[% hold.itemnumber | uri %]">
                            [%- IF ( hold.barcodenumber ) -%]
                                [%- hold.barcodenumber | html -%]
                            [%- ELSE -%]
                                <span>No barcode</span>
                            [%- END -%]
                            <input type="hidden" name="itemnumber" value="[% hold.itemnumber | html %]" />
                        </a>
                    [%- ELSE -%]
                        [%- IF ( hold.item_level_hold ) -%]
                            <em>
                                [%- IF ! hold.change_hold_type_allowed -%]
                                    <span>Only item</span>
                                    <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% hold.biblionumber | uri %]&amp;itemnumber=[% hold.itemnumber | uri %]#item[% hold.itemnumber | uri %]">
                                        [%- IF ( hold.barcodenumber ) -%]
                                            [%- hold.barcodenumber | html -%]
                                        [%- ELSE -%]
                                            <span>No barcode</span>
                                        [%- END -%]
                                        <input type="hidden" name="itemnumber" value="[% hold.itemnumber | html %]" />
                                    </a>
                                [%- ELSE -%]
                                    <select name="change_hold_type_[% hold.reserve_id | html %]">
                                        <option selected="selected" value="">
                                            [%- IF ( hold.barcodenumber ) -%]
                                                [% tx("Only item {barcode}", {barcode = hold.barcodenumber}) | html %]
                                            [%- ELSE -%]
                                                [% t("Only item [No barcode]") | html %]
                                            [%- END -%]
                                        </option>
                                        <option value="1">Next available</option>
                                    </select>
                                    [%- IF ( hold.itemnumber ) -%]
                                        <input type="hidden" name="itemnumber" value="[% hold.itemnumber | html %]" />
                                    [%- END -%]
                                    [%- IF hold.itemtype -%]
                                        <span style="display:none">Next available [% ItemTypes.GetDescription( hold.itemtype ) | html %] item</span>
                                    [%- ELSE -%]
                                        <span style="display:none">Next available</span>
                                    [%- END -%]
                                [%- END -%]
                            </em>
                        [%- ELSE -%]
                            [%- IF hold.itemtype -%]
                                <em>Next available [% ItemTypes.GetDescription( hold.itemtype ) | html %] item</em>
                            [%- ELSIF hold.object.item_group -%]
                                <em>Next available item from group <strong>[% hold.object.item_group.description | html %]</strong></em>
                            [%- ELSE -%]
                                <em>Next available</em>
                            [%- END -%]

                            <input type="hidden" name="itemnumber" value="" />
                        [%- END -%]
                    [%- END -%]
                    [%- IF hold.non_priority -%]
                        <br /><i>Non priority hold</i>
                    [%- END -%]
                </td>
                [%- IF ( CAN_user_reserveforothers_modify_holds_priority ) -%]
                    [%- UNLESS hold.found -%]
                        <td>
                            [% IF ( hold.lowestPriority ) %]
                                <a
                                    class="hold-arrow"
                                    title="Remove lowest priority"
                                    data-op="cud-setLowestPriority"
                                    data-borrowernumber="[% hold.borrowernumber | html %]"
                                    data-biblionumber="[% hold.biblionumber | html %]"
                                    data-reserve_id="[% hold.reserve_id | html %]"
                                    data-date="[% hold.date | html %]"
                                >
                                    <i class="fa fa-lg fa-rotate-90 icon-unset-lowest" aria-hidden="true"></i>
                                </a>
                            [% ELSE %]
                                <a
                                    class="hold-arrow"
                                    title="Set lowest priority"
                                    data-op="cud-setLowestPriority"
                                    data-borrowernumber="[% hold.borrowernumber | html %]"
                                    data-biblionumber="[% hold.biblionumber | html %]"
                                    data-reserve_id="[% hold.reserve_id | html %]"
                                    data-date="[% hold.date | html %]"
                                >
                                    <i class="fa fa-lg fa-rotate-90 icon-set-lowest" aria-hidden="true"></i>
                                </a>
                            [% END %]
                        </td>
                    [%- ELSE -%]
                        <td></td>
                    [%- END -%]
                [%- END -%]
                <td>
                    <a class="cancel-hold" title="Cancel hold" data-borrowernumber="[% hold.borrowernumber | html %]" data-biblionumber="[% hold.biblionumber | html %]" data-id="[% hold.reserve_id | html %]" href="#">
                        <i class="fa fa-trash" aria-label="Cancel hold"></i>
                    </a>
                </td>
                <td>
                    [% IF Koha.Preference('SuspendHoldsIntranet') %]
                        [% UNLESS ( hold.found ) %]
                            [% IF ( hold.suspend ) %]
                                <button class="btn btn-default btn-xs unsuspend-hold" data-reserve-id="[% hold.reserve_id | html %]" data-biblionumber="[% hold.biblionumber | html %]">
                                    <i class="fa fa-play" aria-hidden="true"></i> Unsuspend
                                </button>
                            [% ELSE %]
                                <button class="btn btn-default btn-xs suspend-hold" data-reserve-id="[% hold.reserve_id | html %]" data-biblionumber="[% hold.biblionumber | html %]">
                                    <i class="fa fa-pause" aria-hidden="true"></i> Suspend
                                </button>
                            [% END %]

                            [% IF Koha.Preference('AutoResumeSuspendedHolds') %]
                                <label for="suspend_until_[% hold.reserve_id | html %]">[% IF ( hold.suspend ) %]on[% ELSE %]until[% END %]</label>
                                <input
                                    type="text"
                                    name="suspend_until_[% hold.reserve_id | html %]"
                                    id="suspend_until_[% hold.reserve_id | html %]"
                                    size="10"
                                    value="[% hold.suspend_until | html %]"
                                    class="flatpickr"
                                    data-flatpickr-futuredate="true"
                                />
                            [%- ELSE -%]
                                <input type="hidden" name="suspend_until_[% hold.reserve_id | html %]" id="suspend_until_[% hold.reserve_id | html %]" value="" />
                            [%- END -%]
                        [%- END -%]
                    [%- END # IF SuspendHoldsIntranet -%]
                    [%- IF ( hold.found ) -%]
                        <a
                            class="btn btn-default  submit-form-link"
                            href="#"
                            id="revert_hold_[% hold.reserve_id | html %]"
                            data-op="cud-move"
                            data-where="down"
                            data-first_priority="[% first_priority | html %]"
                            data-last_priority="[% last_priority | html %]"
                            data-prev_priority="0"
                            data-next_priority="1"
                            data-borrowernumber="[% hold.borrowernumber | html %]"
                            data-biblionumber="[% hold.biblionumber | html %]"
                            data-itemnumber="[% hold.itemnumber | html %]"
                            data-reserve_id="[% hold.reserve_id | html %]"
                            data-date="[% hold.date | html %]"
                            data-action="request.pl"
                            data-method="post"
                            >[% IF hold.intransit %]Revert transit status[% ELSE %]Revert waiting status[% END %]</a
                        >
                    [%- END -%]
                </td>
                [% IF ( hold.intransit || hold.atdestination ) %]
                    <td><input class="printholdslip" type="button" name="printholdslip" value="Print slip" data-reserve_id="[% hold.reserve_id | html %]" /></td>
                [% ELSE %]
                    <td></td>
                [% END %]
            </tr>
        [% END %]
    </tbody>
</table>
