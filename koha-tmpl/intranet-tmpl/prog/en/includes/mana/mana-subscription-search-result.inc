[% USE KohaDates %]
[% USE Koha %]
[% USE AuthorisedValues %]
[% USE Branches %]
[% USE raw %]

[% IF statuscode == "200" %]
    [% INCLUDE 'mana/mana-comment-status.inc' %]
    <div id="mana_results">
        <table id="mana_results_datatable">
            <thead>
                <tr>
                    <th>ISSN</th>
                    <th class="anti-the">Title</th>
                    <th> Published by </th>
                    <th>Frequency</th>
                    <th>Numbering pattern</th>
                    <th title="Number of libraries using this pattern"># of users</th>
                    <th title="Last time a library used this pattern">Last import</th>
                    <th> Comments </th>
                    [% UNLESS search_only %]
                        <th class="no-sort no-export">Actions</th>
                    [% END %]
                </tr>
            </thead>
            <tbody>
                [% FOREACH subscription IN subscriptions %]
                    [% UNLESS subscription.cannotdisplay %]
                        [% SET tr_class = '' %]
                        [% SET tr_warning = '' %]
                        [% IF subscription.nbofcomment > highWarned %]
                            [% SET tr_class = 'high-warned-row' %]
                            [% SET tr_warning = highWarned %]
                        [% ELSIF subscription.nbofcomment > warned %]
                            [% SET tr_class = 'warned-row' %]
                            [% SET tr_warning = warned %]
                        [% ELSIF subscription.nbofcomment > lowWarned %]
                            [% SET tr_class = 'highlighted-row' %]
                            [% SET tr_warning = lowWarned %]
                        [% END %]
                        <tr
                            id="row[% subscription.id | html %]"
                            [% IF tr_class %]class="[% tr_class | html %]"[% END %]
                            [% IF tr_warning %]title="This resource has been reported more than [% tr_warning | html %] times, take care!"[% END %]
                        >
                            <input type="hidden" hidden class="rowid" value="[% subscription.id | html %]" />
                            <td>[% IF ( subscription.issn ) %][% subscription.issn | html %][% END %]</td>
                            <td>[% subscription.title | html %]</td>
                            <td>[% IF ( subscription.publishercode ) %][% subscription.publishercode | html %][% END %]</td>
                            <td>[% IF ( subscription.sfdescription ) %][% subscription.sfdescription | html %][% END %]</td>
                            <td>[% IF ( subscription.numberingmethod ) %][% subscription.numberingmethod | html %][% END %]</td>
                            <td>[% IF ( subscription.nbofusers ) %][% subscription.nbofusers | html %][% END %]</td>
                            <td data-order="[% subscription.lastimport | html %]">[% subscription.lastimport | $KohaDates %]</td>
                            <td>
                                [% FOREACH comment IN subscription.comments %]
                                    [% comment.message | html %]
                                    ([% comment.nb | html %])<br />
                                [% END %]
                            </td>
                            [% UNLESS search_only %]
                                <td class="actions">
                                    <button class="btn btn-default btn-xs mana-use" data-subscription_id="[% subscription.id | html %]" id="mana-use-[% subscription.id | html %]"><i class="fa fa-download"></i> Import</button>
                                    <div class="dropup">
                                        <button type="button" class="btn btn-default btn-xs dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false"> Report </button>
                                        <ul class="dropdown-menu dropdown-menu-end mana-actions" id="mana-actions-[% subscription.id | html %]">
                                            [% IF ( subscription.comments.size ) %]
                                                [% FOREACH comment IN subscription.comments %]
                                                    <li
                                                        ><a class="dropdown-item" data-commentid="[% comment.id | html %]" data-resourceid="[% subscription.id | html %]" href="#"
                                                            >[% comment.message | html %] ([% comment.nb | html %])</a
                                                        ></li
                                                    >
                                                [% END %]
                                                <li><hr class="dropdown-divider" /></li>
                                            [% END %]
                                            <li><a class="dropdown-item" data-commentid="other" data-resourceid="[% subscription.id | html %]" href="#">New comment</a></li>
                                        </ul>
                                    </div>
                                </td>
                            [% END %]
                        </tr>
                    [% END %]
                [% END %]
            </tbody>
        </table>
    </div>
    <div id="new_mana_comment" style="display:none">
        <h4 id="mana_submit_comment"> Please enter a new comment (max 35 characters)</h4>
        <form id="mana_comment_form" action="/cgi-bin/koha/serials/subscription-detail.pl" method="get">
            <input type="hidden" id="mana-resource" value="subscription" />
            <input type="hidden" id="mana-resource-id" value="[% mana_id | html %]" />
            <input type="text" maxlength="35" size="35" id="mana-comment" required="required" />
            <input type="hidden" id="selected_id" value="" />
            <div class="action">
                <button id="mana-send-comment">Submit</button>
                <a href="#" class="cancel" id="mana-comment-close">Cancel</a>
            </div>
        </form>
    </div>
[% ELSE %]
    <h4>Mana search fails with the code: [% statuscode | html %] </h4>
[% END %]
