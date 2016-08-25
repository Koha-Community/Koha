[% INCLUDE 'blocking_errors.inc' %]
[% IF subscriptionid and ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription || CAN_user_serials_receive_serials ) %]
    <div id="toolbar" class="btn-toolbar">
        [% IF CAN_user_serials_create_subscription %]
            [% IF biblionumber_for_new_subscription %]
                <div class="btn-group"><a id="newsubscription" class="btn btn-default btn-sm" href="/cgi-bin/koha/serials/subscription-add.pl?biblionumber_for_new_subscription=[% biblionumber_for_new_subscription | html %]"><i class="fa fa-plus"></i> New subscription</a></div>
            [% ELSE %]
                <div class="btn-group"><a id="newsubscription" class="btn btn-default btn-sm" href="/cgi-bin/koha/serials/subscription-add.pl"><i class="fa fa-plus"></i> New subscription</a></div>
            [% END %]
            [% IF Koha.Preference('Mana') %]
                [% IF one_language_enabled==0 or mana_id %]
                    <div class="btn-group"><a data-toggle="modal" data-toggle="tooltip" title="Your email address will be associated to your sharing." data-target="#mana_share_modal" class="btn btn-small"><i class="fa fa-share-alt"></i> Share</a></div>
                [% ELSE %]
                    <div class="btn-group" data-toggle="tooltip" title="Your email address will be associated to your sharing."><a class="btn btn-small" onclick="share()"><i class="fa fa-share-alt"></i> Share</a></div>
                [% END %]
            [% END %]
        [% END %]

        [% IF ( CAN_user_serials_edit_subscription || CAN_user_serials_create_subscription || CAN_user_serials_delete_subscription ) %]
            [% UNLESS ( cannotedit ) %]
                <div class="btn-group">
                    <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-pencil"></i> Edit <span class="caret"></span></button>
                        <ul class="dropdown-menu">
                            [% IF ( cannotedit ) %] <li class="disabled"> [% ELSE %]
                            <li> [% END %]
                            <a href="/cgi-bin/koha/serials/subscription-add.pl?op=modify&amp;subscriptionid=[% subscriptionid | uri %]">Edit subscription</a></li>
                            [% IF ( cannotedit ) %] <li class="disabled"> [% ELSE %]
                            <li> [% END %]
                            <a href="/cgi-bin/koha/serials/subscription-add.pl?op=dup&amp;subscriptionid=[% subscriptionid | uri %]">Edit as new (duplicate)</a></li>

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

<div id="mana_share_modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="mana_share_modal_label" style="display: none;">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="mana_share_modal_label">Share [% bibliotitle %] to Mana</h3>
            </div>
            <div class="modal-body">
                [% IF (mana_id) %]
                    <div class="alert">
                        <p>Your subscription is already linked with a Mana subscription model. Share it if you have made modifications, otherwide it will do nothing.</p>
                    </div>
                [% END %]
                [% IF ( languages_loop ) %]
                    [% UNLESS ( one_language_enabled ) %]
                        <div class="rows">
                            <p>The frequency and the numberpattern of [% bibliotitle %] are :</p>
                            <ol>
                                <li><span class="label">Frequency : </span>
                                        [% frequency.description %]
                                </li>
                                <li><span class="label">Number pattern : </span>
                                    [% numberpattern.label %]
                                </li>
                            </ol>
                        </div>
                        <div class="rows">
                            <form method="get" id="mana_share_form" action="/cgi-bin/koha/serials/subscription-detail.pl" class="validated" >
                                <fieldset>
                                    <label for="mana_language">Language of your sharing :</label>
                                    <select id="mana_language" name="mana_language">
                                        [% FOREACH languages_loo IN languages_loop %]
                                            [% IF ( languages_loo.group_enabled ) %]
                                                [% IF ( languages_loo.plural ) %]
                                                    [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                                                        [% IF ( sublanguages_loo.enabled ) %]
                                                            [% IF ( sublanguages_loo.sublanguage_current ) %]
                                                                <option value="[% languages_loo.rfc4646_subtag %]" selected>
                                                                    [% sublanguages_loo.native_description %]
                                                                    [% sublanguages_loo.script_description %]
                                                                    [% sublanguages_loo.region_description %]
                                                                    [% sublanguages_loo.variant_description %]
                                                                    ([% sublanguages_loo.rfc4646_subtag %])
                                                                </option>
                                                            [% ELSE %]
                                                                <option value="[% languages_loo.rfc4646_subtag %]">
                                                                    [% sublanguages_loo.native_description %]
                                                                    [% sublanguages_loo.script_description %]
                                                                    [% sublanguages_loo.region_description %]
                                                                    [% sublanguages_loo.variant_description %]
                                                                    ([% sublanguages_loo.rfc4646_subtag %])
                                                                </option>
                                                            [% END %]
                                                        [% END %]
                                                    [% END %]
                                                [% ELSE %]
                                                    [% IF ( languages_loo.group_enabled ) %]
                                                        [% IF ( languages_loo.current ) %]
                                                            <option value="[% languages_loo.rfc4646_subtag %]" selected>
                                                                [% IF ( languages_loo.native_description ) %]
                                                                    [% languages_loo.native_description %]
                                                                [% ELSE %]
                                                                    [% languages_loo.rfc4646_subtag %]
                                                                [% END %]
                                                            </option>
                                                        [% ELSE %]
                                                            <option value="[% languages_loo.rfc4646_subtag %]">
                                                                [% IF ( languages_loo.native_description ) %]
                                                                    [% languages_loo.native_description %]
                                                                [% ELSE %]
                                                                    [% languages_loo.rfc4646_subtag %]
                                                                [% END %]
                                                            </option>
                                                        [% END %]
                                                    [% END %]
                                                [% END %]
                                            [% END %]
                                        [% END %]
                                    </select>
                                    <input type="hidden" id="op" name="op" value="share"/>
                                    <input type="hidden" id="subscriptionid" name="subscriptionid" value="[% subscriptionid %]"/>
                                </fieldset>
                            </form>
                        </div>
                    [% END %]
                [% END %]
            </div>
            <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                [% IF one_language_enabled==0 %]
                    <button type="submit" form="mana_share_form" class="btn btn-primary">Share</button>
                [% ELSE %]
                    <div class="btn-group"><a class="btn btn-primary" onclick="share()">Share</a></div>
                [% END %]
            </div>
        </div>
    </div>
</div>
