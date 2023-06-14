[% USE Branches %]
<div id="recalls">
[% IF recalls.count %]
    <table id="recalls-table">
        <thead>
            <tr>
                [% IF checkboxes %]<th class="recall-checkbox nosort">&nbsp;</th>[% END %]
                <th class="recall-title anti-the">Title</th>
                [% UNLESS specific_patron %]<th class="recall-patron">Requested by</th>[% END %]
                <th class="recall-date">Placed on</th>
                <th class="recall-expiry">Expires on</th>
                <th class="recall-branch">Pickup location</th>
                <th class="recall-status">Status</th>
                [% UNLESS viewing_old %]<th class="recall-duedate">Due date</th>[% END %]
                [% UNLESS viewing_old %]<th class="recall-actions nosort">&nbsp;</th>[% END %]
            </tr>
        </thead>

        <tbody>
            [% FOREACH recall IN recalls %]
                [% IF recall.completed %]<tr class="old">[% ELSE %]<tr>[% END %]

                    [% IF checkboxes %]
                        <td class="recall-checkbox">
                            [% IF recall.completed %]
                                &nbsp;
                            [% ELSE %]
                                <input type="checkbox" value="[% recall.id | html %]" name="recall_ids">
                            [% END %]
                        </td>
                    [% END %]

                    <td class="recall-title">
                        [% INCLUDE 'biblio-title.inc' biblio=recall.biblio link=1 %]
                        [% IF recall.biblio.author %] by [% recall.biblio.author | html %][% END %]
                        [% recall.item.enumchron | html %]
                        [% IF ( recall.item ) %]<br><em>Barcode: [% recall.item.barcode | html %]</em>[% END %]
                    </td>

                    [% UNLESS specific_patron %]
                        <td class="recall-patron">
                            [% INCLUDE 'patron-title.inc' patron=recall.patron hide_patron_infos_if_needed=1 link_to="circulation_recalls" %]
                        </td>
                    [% END %]

                    <td class="recall-date">
                        [% recall.created_date | $KohaDates %]
                    </td>

                    <td class="recall-expiry">
                        [% IF ( recall.expiration_date ) %]
                            [% recall.expiration_date | $KohaDates %]
                        [% ELSIF ( !recall.completed ) %]
                            <span>Never expires</span>
                        [% ELSE %]
                            -
                        [% END %]
                    </td>

                    <td class="recall-branch">
                        [% recall.library.branchname | html %]
                    </td>

                    <td class="recall-status">
                        [% IF ( recall.in_transit ) %]
                            <span>In transit to [% recall.library.branchname | html %]</span>
                        [% ELSIF ( recall.waiting ) %]
                            <span>Ready for pickup</span>
                        [% ELSIF ( recall.expired ) %]
                            <span>Expired on [% recall.expiration_date | $KohaDates %]</span>
                        [% ELSIF ( recall.cancelled ) %]
                            <span>Cancelled on [% recall.completed_date | $KohaDates %]</span>
                        [% ELSIF ( recall.overdue ) %]
                            <span>Overdue to be returned</span>
                        [% ELSIF ( recall.fulfilled ) %]
                            <span>Fulfilled</span>
                        [% ELSE %]
                            <span>Requested</span>
                        [% END %]
                    </td>

                    [% UNLESS viewing_old %]
                    <td class="recall-duedate">
                        [% IF recall.requested and recall.checkout %]
                            <span>Due to be returned by [% recall.checkout.date_due | $KohaDates %]</span>
                        [% ELSIF recall.waiting and RECALL.expiration_date %]
                            <span>Pick up by [% RECALL.expiration_date | $KohaDates %]</span>
                        [% ELSE %]
                            -
                        [% END %]
                    </td>
                    [% END %]

                    [% UNLESS viewing_old %]
                    <td class="recall-cancel actions">
                        [% IF recall.completed %]
                            &nbsp;
                        [% ELSE %]
                            <div class="btn-group">
                                <button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    Actions <span class="caret"></span>
                                </button>
                                <ul class="dropdown-menu pull-right">
                                    [% IF ( recall.requested or recall.overdue ) %]
                                        <li><a class="cancel_recall" data-id="[% recall.id | html %]" data-action="cancel"><i class="fa fa-times"></i> Cancel</a></li>
                                        [% IF ( recall.should_be_overdue ) %]
                                            <li><a class="overdue_recall" data-id="[% recall.id | html %]" data-action="overdue"><i class="fa fa-hourglass-end"></i> Mark as overdue</a></li>
                                        [% END %]
                                    [% ELSIF ( recall.waiting ) %]
                                        <li><a class="revert_recall" data-id="[% recall.id | html %]" data-action="revert"><i class="fa fa-undo"></i> Revert waiting</a></li>
                                        <li><a class="expire_recall" data-id="[% recall.id | html %]" data-action="expire"><i class="fa fa-times"></i> Expire</a></li>
                                    [% ELSIF ( recall.in_transit ) %]
                                        <li><a class="transit_recall" data-id="[% recall.id | html %]" data-action="transit"><i class="fa fa-times"></i> Cancel recall and return to: [% Branches.GetName(recall.item.homebranch) | html %]</a></li>
                                    [% END %]
                                </ul>
                            </div>
                        [% END %]
                    </td>
                    [% END %]

                </tr>
            [% END %]
        </tbody>
    </table>
    [% ELSE %]
        [% IF patron.borrowernumber %]
            <div class="dialog message">Patron has no recalls.</div>
        [% ELSE %]
            <div class="dialog message">There are no recalls to show.</div>
        [% END %]
    [% END %]
</div>
