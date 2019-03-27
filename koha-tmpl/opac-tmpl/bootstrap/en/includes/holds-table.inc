[% USE Branches %]
[% USE ItemTypes %]
[% USE KohaDates %]

[% IF ( HOLDS.count ) %]
    <div id="opac-user-holds">
        <table id="holdst" class="table table-bordered table-striped">
            <caption>Holds <span class="count">([% HOLDS.count | html %] total)</span></caption>
            <!-- HOLDS TABLE ROWS -->
            <thead>
                <tr>
                    <th class="anti-the">Title</th>
                    [% IF ( showpriority ) %]
                        <th class="title-string">Placed on</th>
                    [% ELSE %]
                        <th class="psort title-string">Placed on</th>
                    [% END %]
                    <th class="title-string">Expires on</th>
                    [% UNLESS( singleBranchMode) %]
                        <th>Pick up location</th>
                    [% END %]
                    [% IF ( showpriority ) %]
                        <th class="psort">Priority</th>
                    [% END %]
                    <th>Status</th>
                    [% IF SuspendHoldsOpac and ! onlyinfo %]
                            <th class="nosort" >Suspend</th>
                    [% END %]
                    [% IF ! onlyinfo %]
                        <th class="nosort">Modify</th>
                    [% END %]
                </tr>
            </thead>
            <tbody>
                [% FOREACH HOLD IN HOLDS %]
                    [% IF ( HOLD.is_waiting ) %]
                        [% IF ( HOLD.is_at_destination ) %]
                            [% IF ( HOLD.is_found ) %]
                                <tr class="reserved">
                            [% ELSE %]
                                <tr>
                            [% END %]
                        [% ELSE %]
                            <tr class="transfered">
                        [% END %]
                    [% ELSE %]
                        <tr>
                    [% END %]
                        <td class="title">
                            [% IF ! onlyinfo %]
                                <a class="title" href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% HOLD.biblionumber | html %]">
                                    [% HOLD.biblio.title | html %]
                                    [% FOREACH s IN HOLD.biblio.subtitles %]
                                        [% s | html %]
                                    [% END %]
                                    [% HOLD.item.enumchron | html %]
                                </a>
                            [% ELSE %]
                                <strong>
                                    [% HOLD.biblio.title | html %]
                                    [% FOREACH s IN HOLD.biblio.subtitles %]
                                        [% s | html %]
                                    [% END %]
                                    [% HOLD.item.enumchron | html %]
                                </strong>
                            [% END %]
                            [% HOLD.biblio.author | html %]
                        </td>
                        <td class="reservedate">
                            <span title="[% HOLD.reservedate | html %]">
                                <span class="tdlabel">Hold date:</span>
                                [% HOLD.reservedate | $KohaDates %]
                            </span>
                        </td>
                        <td class="expirationdate">
                            [% IF ! HOLD.found %]
                                [% IF ( HOLD.expirationdate ) %]
                                    <span title="[% HOLD.expirationdate | html %]">
                                        <span class="tdlabel">Expiration:</span>
                                            [% HOLD.expirationdate | $KohaDates %]
                                    </span>
                                [% ELSE %]
                                    <span title="0000-00-00">
                                        <span class="tdlabel">Expiration:</span>
                                        Never expires
                                    </span>
                                [% END %]
                            [% ELSE %]
                                <span title="0000-00-00">-</span>
                            [% END %]
                        </td>
                        [% UNLESS( singleBranchMode) %]
                            <td class="branch">
                                <span class="tdlabel">Pick up location:</span>
                                [% HOLD.branch.branchname | html %]
                            </td>
                        [% END %]
                        [% IF ( showpriority ) %]
                                <td data-order="[% HOLD.priority | html %]" class="priority">
                                <span class="tdlabel">Priority:</span>
                                [% HOLD.priority | html %]
                            </td>
                        [% END %]
                        <td class="status">
                            <span class="tdlabel">Status:</span>
                            [% IF ( HOLD.is_waiting ) %]
                                [% IF ( HOLD.is_at_destination ) %]
                                    [% IF ( HOLD.found ) %]
                                        Item waiting at <b> [% HOLD.branch.branchname | html %]</b>
                                        [% IF ( HOLD.waitingdate ) %]
                                            since [% HOLD.waitingdate | $KohaDates %]
                                            [% IF HOLD.expirationdate %]
                                                until [% HOLD.expirationdate | $KohaDates %]
                                            [% END %]
                                        [% END %]
                                        <input type="hidden" name="pickup" value="[% HOLD.branchcode | html %]" />
                                    [% ELSE %]
                                        Item waiting to be pulled from <b> [% Branches.GetName( HOLD.branchcode ) | html %]</b>
                                    [% END %]
                                [% ELSE %]
                                    Item in transit to <b> [% Branches.GetName( HOLD.branchcode ) | html %]</b> <input type="hidden" name="pickup" value="[% HOLD.branchcode | html %]" />
                                [% END %]
                            [% ELSE %]
                                [% IF ( HOLD.is_in_transit ) %]
                                    [% SET transfer = HOLD.item.get_transfer %]
                                    Item in transit from <b> [% Branches.GetName( transfer.frombranch ) | html %]</b> since
                                    [% transfer.datesent | $KohaDates %]
                                [% ELSIF ( HOLD.suspend ) %]
                                    Suspended [% IF ( HOLD.suspend_until ) %] until [% HOLD.suspend_until | html %] [% END %]
                                [% ELSE %]
                                    [% IF HOLD.itemtype %]
                                        Pending for next available item of item type '[% ItemTypes.GetDescription( HOLD.itemtype ) | html %]'
                                    [% ELSE %]
                                        Pending
                                    [% END %]
                                [% END %]
                            [% END %]
                        </td>
                        [% IF SuspendHoldsOpac and ! onlyinfo %]
                            <td>
                                [% IF ( HOLD.is_cancelable_from_opac ) %]
                                    [% IF HOLD.suspend %]
                                        <form class="form-inline" action="/cgi-bin/koha/opac-modrequest-suspend.pl" method="post">
                                            <input type="hidden" name="reserve_id" value="[% HOLD.reserve_id | html %]" />
                                            <button class="btn btn-link" type="submit" name="submit"><i class="fa fa-play"></i> Resume</button>
                                        </form>
                                    [% ELSE %]
                                        [% IF AutoResumeSuspendedHolds %]
                                            <a class="btn btn-link js-show" href="#suspendModal[% HOLD.reserve_id | html %]" role="button" data-toggle="modal"><i class="fa fa-pause"></i> Suspend</a>
                                            [% # hold suspend modal form %]
                                            <div id="suspendModal[% HOLD.reserve_id | html %]" class="modal-nojs" tabindex="-1" role="dialog" aria-labelledby="suspendModal[% HOLD.reserve_id | html %]Label" aria-hidden="true">
                                                <form class="form-inline" action="/cgi-bin/koha/opac-modrequest-suspend.pl" method="post">
                                                    <div class="modal-header">
                                                        <button type="button" class="closebtn" data-dismiss="modal" aria-hidden="true">×</button>
                                                        [% IF HOLD.suspend %]
                                                            <h3 id="suspendModal[% HOLD.reserve_id | html %]Label">Resume your hold on <i>[% HOLD.biblio.title | html %]</i></h3>
                                                        [% ELSE %]
                                                            <h3 id="suspendModal[% HOLD.reserve_id | html %]Label">Suspend your hold on <i>[% HOLD.biblio.title | html %]</i></h3>
                                                        [% END %]
                                                    </div>
                                                    <div class="modal-body">
                                                        <input type="hidden" name="reserve_id" value="[% HOLD.reserve_id | html %]" />
                                                        <label for="suspend_until_[% HOLD.reserve_id | html %]">Suspend until:</label>
                                                        <input type="text" name="suspend_until" id="suspend_until_[% HOLD.reserve_id | html %]" class="suspend-until" size="10" />
                                                        [% INCLUDE 'date-format.inc' %]
                                                        <p class="js-show"><a href="#" onclick="document.getElementById('suspend_until_[% HOLD.reserve_id | html %]').value='';return false;">Clear date to suspend indefinitely</a></p>
                                                        <button class="btn btn-mini js-hide" type="submit" name="submit">Suspend</button>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button class="btn btn-primary" type="submit" name="submit">Suspend</button>
                                                        <a href="#" data-dismiss="modal" aria-hidden="true" class="cancel">Cancel</a>
                                                    </div>
                                                </form>
                                            </div>  <!-- /#suspendModal[% HOLD.reserve_id | html %] -->
                                        [% ELSE %]
                                            <form class="form-inline" action="/cgi-bin/koha/opac-modrequest-suspend.pl" method="post">
                                                <input type="hidden" name="reserve_id" value="[% HOLD.reserve_id | html %]" />
                                                <button class="btn btn-link" type="submit" name="submit"><i class="fa fa-pause"></i> Suspend</button>
                                            </form>
                                        [% END # / IF AutoResumeSuspendedHolds %]
                                    [% END # / IF HOLD.suspend %]
                                [% END # / IF ( HOLD.is_cancelable_from_opac )%]
                            </td>
                        [% END # / IF SuspendHoldsOpac %]
                        [% IF ! onlyinfo %]
                            <td class="modify">
                                [% IF ( HOLD.is_cancelable_from_opac ) %]
                                    <form action="/cgi-bin/koha/opac-modrequest.pl" method="post">
                                    <input type="hidden" name="biblionumber" value="[% HOLD.biblionumber | html %]" />
                                    <input type="hidden" name="reserve_id" value="[% HOLD.reserve_id | html %]" />
                                    <button type="submit" name="submit" class="btn btn-mini btn-danger" onclick="return confirmDelete(MSG_CONFIRM_DELETE_HOLD);"><i class="fa fa-remove"></i> Cancel</button></form>
                                [% END %]
                            </td>
                        [% END # / IF onlyinfo %]
                    </tr>
                [% END # /FOREACH HOLDS %]
            </tbody>
        </table>

        [% IF SuspendHoldsOpac and ! onlyinfo %]
            <div>
                <form class="form-inline" action="/cgi-bin/koha/opac-modrequest-suspend.pl" method="post">
                    <button type="submit" name="submit" class="btn" onclick="return confirmDelete(MSG_CONFIRM_SUSPEND_HOLDS);"><i class="fa fa-pause"></i> Suspend all holds</button>
                    <input type="hidden" name="suspend" value="1" />

                    [% IF AutoResumeSuspendedHolds %]
                        <label for="suspend_until"> until </label>
                        <input type="text" name="suspend_until" id="suspend_until" class="suspend-until" readonly="readonly" size="10" />
                        <a href="#" style="font-size:85%;text-decoration:none;" onclick="document.getElementById('suspend_until').value='';return false;">Clear date to suspend indefinitely</a>
                    [% END %]
                </form>
            </div>
            <br/>
            <div>
                <form action="/cgi-bin/koha/opac-modrequest-suspend.pl" method="post">
                    <button type="submit" name="submit" class="btn" onclick="return confirmDelete(MSG_CONFIRM_RESUME_HOLDS);"><i class="fa fa-play"></i> Resume all suspended holds</button>
                    <input type="hidden" name="suspend" value="0" />
                </form>
            </div>
        [% END %]
    </div> <!-- / #opac-user-holds -->
[% END # / #HOLDS.count %]
