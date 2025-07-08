<!-- patron-detail-tabs.inc -->
[% USE raw %]
[% PROCESS 'html_helpers.inc' %]
[% PROCESS 'modals/holds_table_modals.inc' %]
[% WRAPPER tabs id= "finesholdsissues" %]
    [% WRAPPER tabs_nav %]
        [% WRAPPER tab_item tabname= "checkouts" bt_active= 1 %]
            <span>Checkouts</span>
            [% IF ( issuecount ) %]
                <span class="checkout_count badge text-bg-info">[% issuecount || 0 | html %]</span>
            [% END %]
        [% END %]

        [% IF relatives_issues_count %]
            [% WRAPPER tab_item tabname= "relatives-issues" %]
                <span>Relatives' checkouts</span>
                [% IF ( relatives_issues_count ) %]
                    <span class="badge text-bg-info">[% relatives_issues_count | html %]</span>
                [% END %]
            [% END %]
        [% END %]

        [% IF ( guarantees_fines ) %]
            [% WRAPPER tab_item tabname= "guarantees_finesandcharges" %]
                <span>Guarantees' charges</span>
                [% IF ( guarantees_fines ) %]
                    <span class="badge text-bg-info">[% guarantees_fines | $Price %]</span>
                [% END %]
            [% END %]
        [% END %]

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% WRAPPER tab_item tabname= "holds" %]
                <span>Holds</span>
                [% IF ( holds_count ) %]
                    <span class="badge text-bg-info">[% holds_count | html %]</span>
                [% END %]
            [% END %]
            [% IF Koha.Preference('EnableBooking') %]
                [% WRAPPER tab_item tabname="bookings" %]
                    [% SET bookings_count = patron.bookings.filter_by_active.count %]
                    [% SET expired_bookings_count = patron.bookings.count - bookings_count %]
                    <span>Bookings</span>
                    [% IF ( bookings_count ) %]
                        <span class="badge text-bg-info">[% bookings_count || 0 | html %]</span>
                    [% END %]
                [% END %]
            [% END %]
        [% END %]

        [% IF Koha.Preference('UseRecalls') %]
            [% WRAPPER tab_item tabname= "recalls" %]
                <span>Recalls</span>
                [% IF ( recalls.count ) %]
                    <span class="badge text-bg-info">[% recalls.count | html %]</span>
                [% END %]
            [% END %]
        [% END %]

        [% IF Koha.Preference('ArticleRequests') %]
            [% SET article_requests = patron.article_requests.filter_by_current %]
            [% WRAPPER tab_item tabname= "article-requests" %]
                <span>Article requests</span>
                [% IF ( article_requests.count ) %]
                    <span class="badge text-bg-info">[% article_requests.count | html %]</span>
                [% END %]
            [% END %]
        [% END %]

        [% IF Koha.Preference('ClaimReturnedLostValue') || Koha.Preference('BundleLostValue') %]
            [% WRAPPER tab_item tabname= "return-claims" %]
                <span>Claims</span>
                [% SET warning_threshold = Koha.Preference('ClaimReturnedWarningThreshold') %]
                [% IF warning_threshold != '' && ( patron.return_claims.count > warning_threshold ) %]
                    <span id="return-claims-count" title="Unresolved claims / Resolved claims" class="badge text-bg-warning">
                        <span id="return-claims-count-unresolved" class="count-active" data-warning="[% warning_threshold | html %]">[% patron.return_claims.unresolved.count | html %]</span>
                        <span id="return-claims-count-resolved" class="count-inactive">[% patron.return_claims.resolved.count | html %]</span>
                    </span>
                [% ELSE %]
                    <span id="return-claims-count" title="Unresolved claims" class="badge text-bg-info">
                        <span id="return-claims-count-unresolved" class="count-active" data-warning="[% warning_threshold | html %]">[% patron.return_claims.unresolved.count || "" | html %]</span>
                        <span id="return-claims-count-resolved" class="count-inactive">[% patron.return_claims.resolved.count || "" | html %]</span>
                    </span>
                [% END %]
            [% END # /WRAPPER tab_item return-claims %]
        [% END %]

        [% WRAPPER tab_item tabname= "reldebarments" %]
            <span>Restrictions</span>
            [% IF ( patron.restrictions.count ) %]
                <span class="badge text-bg-danger">[% patron.restrictions.count | html %]</span>
            [% END %]
        [% END %]

        [% SET enrollments = patron.get_club_enrollments %]
        [% SET enrollable  = patron.get_enrollable_clubs(0) %]
        <!-- 0 => not OPAC -->
        [% IF CAN_user_clubs && ( enrollable.count || enrollments.count ) %]
            [% WRAPPER tab_item tabname= "clubs" %]
                <span>Clubs</span>
                <span id="clubs-count" title="Club enrollments" class="badge text-bg-info">
                    <span id="clubs-count-enrolled" class="count-active">[% enrollments.count || "" | html %]</span>
                </span>
            [% END %]
        [% END %]

        [% IF CAN_user_tools_manage_patron_lists || patron_lists_count %]
            [% WRAPPER tab_item tabname="pat_lists" %]
                <span>Patron lists</span>
                <span id="patron-lists" title="Lists containing this patron" class="badge text-bg-info">
                    <span id="patron-lists-count">[%~ patron_lists_count || "" | html ~%]</span>
                </span>
            [% END %]
        [% END %]
    [% END # /WRAPPER tabs_nav %]

    [% WRAPPER tab_panels %]
        [% WRAPPER tab_panel tabname="checkouts" bt_active= 1 %]
            [% INCLUDE "checkouts-table.inc" %]
        [% END # /tab_panel# %]

        [% IF relatives_issues_count %]
            [% WRAPPER tab_panel tabname="relatives-issues" %]
                [% INCLUDE "relatives-issues-table.inc" %]
            [% END # /tab_panel# %]
        [% END %]

        [% IF ( guarantees_fines ) %]
            [% WRAPPER tab_panel tabname="guarantees_finesandcharges" %]
                <table id="tguaranteesfines">
                    <thead>
                        <tr>
                            <th>Guarantee</th>
                            <th>Amount outstanding</th>
                        </tr>
                    </thead>
                    [% FOREACH guarantee IN guarantees %]
                        <tr>
                            <td>[% INCLUDE 'patron-title.inc' patron=guarantee hide_patron_infos_if_needed=1 %]</td>
                            [% IF logged_in_user.can_see_patron_infos( guarantee ) %]
                                <td>[% guarantee.account.balance | $Price %]</td>
                            [% ELSE %]
                                <td>-</td>
                            [% END %]
                        </tr>
                    [% END %]
                    <tfoot>
                        <td>Total due</td>
                        <td>[% guarantees_fines | $Price %]</td>
                    </tfoot>
                </table>
            [% END # /tab_panel# %]
        [% END # /tab_panel# %]

        [% IF CAN_user_clubs && ( enrollments.count || enrollable.count ) %]
            [% WRAPPER tab_panel tabname="clubs" %]
                Loading...
            [% END # /tab_panel# %]
        [% END %]

        [% IF CAN_user_tools_manage_patron_lists || patron_lists_count %]
            [% WRAPPER tab_panel tabname="pat_lists" %]
                Loading...
            [% END # /tab_panel# %]
        [% END %]

        [% WRAPPER tab_panel tabname="reldebarments" %]
            [% INCLUDE 'patron-restrictions-tab.inc' %]
        [% END # /tab_panel# %]

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            [% WRAPPER tab_panel tabname="holds" %]
                [% IF ( holds_count ) %]
                    <table id="holds-table" class="holds_table" style="width: 100% !Important;">
                        <thead>
                            <tr>
                                <th id="checkbox" data-colname="checkbox"><input type="checkbox" class="select_hold_all" /></th>
                                <th>Hold date</th>
                                [% IF Koha.Preference('DisplayAddHoldGroups') %]
                                    <th>Hold group</th>
                                [% END %]
                                <th class="anti-the">Title</th>
                                <th>Call number</th>
                                <th>Item type</th>
                                <th>Barcode</th>
                                <th>Pickup at</th>
                                <th>Expiration</th>
                                <th>Priority</th>
                                <th>Notes</th>
                                <th>Delete?</th>
                                <th>Suspend?</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                    </table>

                    [% PROCESS 'cancel-hold-modal' form_action = '/cgi-bin/koha/reserve/modrequest.pl' from_param = patronpage %]
                    [% PROCESS 'suspend-hold-modal' %]
                    [% PROCESS 'group-hold-modal' %]
                    <fieldset class="action">
                        <span class="me-2"><span class="badge text-bg-info selected_holds_count"></span> holds selected</span>
                        <button class="btn btn-default cancel_selected_holds" data-bulk="true"><i class="fa fa-trash"></i> Cancel selected</button>
                        [% IF Koha.Preference('SuspendHoldsIntranet') %]
                            <button class="btn btn-default suspend_selected_holds" data-bulk="true"><i class="fa fa-pause"></i> Suspend selected</button>
                        [% END # IF SuspendHoldsIntranet %]
                        [% IF Koha.Preference('DisplayAddHoldGroups') %]
                            <button class="btn btn-default group_selected_holds" data-bulk="true"><i class="fa fa-layer-group"></i> Group selected</button>
                        [% END # IF DisplayAddHoldGroups %]
                    </fieldset>
                    [% IF Koha.Preference('SuspendHoldsIntranet') %]
                        <fieldset class="action">
                            <form action="/cgi-bin/koha/reserve/modrequest_suspendall.pl" method="post">
                                [% INCLUDE 'csrf-token.inc' %]
                                <input type="hidden" name="op" value="cud-unsuspendall" />
                                <input type="hidden" name="from" value="borrower" />
                                <input type="hidden" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
                                <input type="hidden" name="suspend" value="0" />
                                <button type="submit" class="btn btn-default"><i class="fa fa-play"></i> Resume all suspended holds</button>
                            </form>
                        </fieldset>
                    [% END # IF SuspendHoldsIntranet %]
                [% ELSE %]
                    <p>Patron has nothing on hold.</p>
                [% END %]
            [% END # /tab_panel#holds %]

            [% IF Koha.Preference('EnableBooking') %]
                [% WRAPPER tab_panel tabname="bookings" %]
                    [% IF ( bookings_count ) %]
                        <fieldset class="action filters" style="cursor:pointer;">
                            <a id="expired_filter" class="filtered"><i class="fa fa-bars"></i> Show expired</a>
                        </fieldset>
                        <table id="bookings_table" style="width: 100% !Important;"></table>
                    [% ELSIF ( expired_bookings_count ) %]
                        <fieldset class="action filters" style="cursor:pointer;">
                            <a id="expired_filter"><i class="fa fa-filter"></i> Hide expired</a>
                        </fieldset>
                        <table id="bookings_table" style="width: 100% !Important;"></table>
                    [% ELSE %]
                        <p>Patron has nothing booked.</p>
                    [% END %]
                [% END %]
            [% END %]
        [% END %]

        [% IF Koha.Preference('UseRecalls') %]
            [% WRAPPER tab_panel tabname="recalls" %]
                [% INCLUDE 'recalls.inc' %]
            [% END # /tab_panel# %]
        [% END %]

        [% IF Koha.Preference('ClaimReturnedLostValue') || Koha.Preference('BundleLostValue') %]
            [% WRAPPER tab_panel tabname="return-claims" %]
                [% INCLUDE 'patron-return-claims.inc' %]
            [% END # /tab_panel# %]
        [% END %]

        [% IF Koha.Preference('ArticleRequests') %]
            [% WRAPPER tab_panel tabname="article-requests" %]
                [% INCLUDE 'patron-article-requests.inc' %]
            [% END %]
        [% END # /tab_panel# %]
    [% END # /WRAPPER tab_panels %]
[% END # /WRAPPER tabs %]
<!-- /patron-detail-tabs.inc -->
