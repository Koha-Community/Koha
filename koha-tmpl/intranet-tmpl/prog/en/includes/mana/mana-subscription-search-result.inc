[% USE KohaDates %]
[% USE Koha %]
[% USE AuthorisedValues %]
[% USE Branches %]
[% INCLUDE 'mana.inc' %]
<script type="text/javascript">
//<![CDATA[
$(document).ready(function() {
    $(document).on('click', 'button.mana-use', function() {
        id = $(this).attr('id');
        mana_use(id.substr(9));
    });
});
//]]>
</script>

[% IF statuscode == "200" %]
    <table id="mana_results_datatable" width=100%>
        <thead>
            <tr>
                <th>ISSN</th>
                <th class="anti-the" width=50%>Title</th>
                <th> Published by </th>
                <th>Frequency</th>
                <th>Numbering pattern</th>
                <th title="number of libraries using this pattern"># of users</th>
                <th class="title-string" title="last time a library used this pattern">Last import</th>
                <th> Comments </th>
                [% UNLESS search_only %]
                  <th class="NoSort">Actions</th>
                [% END %]
            </tr>
        </thead>
        <tbody>
            [% FOREACH subscription IN subscriptions %]
                [% UNLESS subscription.cannotdisplay %]
                    [% IF subscription.nbofcomment > highWarned  %]
                    <tr id="row[% subscription.subscriptionid %]" class = "high-warned-row" title="this resource has been reported more than [% highWarned %] times, take care!">
                    [% ELSIF subscription.nbofcomment > warned  %]
                    <tr id="row[% subscription.subscriptionid %]" class = "warned-row" title="this resource has been reported more than [% warned %] times, take care!">
                    [% ELSIF subscription.nbofcomment > lowWarned  %]
                    <tr id="row[% subscription.subscriptionid %]" class = "highlighted-row" title="this resource has been reported more than [% lowWarned %] times, take care!">
                    [% END %]
                    <input hidden class="rowid" value="[% subscription.id %]">
                        <td>[% IF ( subscription.issn ) %][% subscription.issn %][% END %]</td>
                        <td>[% subscription.title %]</a></td>
                        <td>[% IF ( subscription.publishercode ) %][% subscription.publishercode %][% END %]</td>
                        <td>[% IF ( subscription.sfdescription ) %][% subscription.sfdescription %][% END %]</td>
                        <td>[% IF ( subscription.numberingmethod ) %][% subscription.numberingmethod %][% END %]</td>
                        <td>[% IF ( subscription.nbofusers ) %][% subscription.nbofusers %][% END %]</td>
                        <td><span title="[% subscription.lastimport %]">[% subscription.lastimport | $KohaDates %]</span></td>
                        <td>[% FOREACH comment IN subscription.comments %][% comment.message %] ([% comment.nb %]) <br>[% END %]</td>

                        [% UNLESS search_only %]
                            <td>
                                <button class="mana-use" id="mana-use-[% subscription.id %]"><i class="fa fa-inbox"></i> Use</button>
                                <select class="mana-actions" id="mana-actions-[% subscription.id %]">
                                    <option selected disabled>Report mistake</option>
                                    [% FOREACH comment IN subscription.comments %]
                                        <option value="[% comment.id %]"> [% comment.message %] ([% comment.nb %])</option>
                                    [% END %]
                                        <option>other</option>
                                </select>
                                <button hidden class="actionreport2" hidden> Cancel</button>
                            </td>
                        [% END %]
                    </tr>
                [% END %]
            [% END %]
        </tbody>
    </table>
[% ELSE %]
    <h4>Mana search fails with the code: [% statuscode %] </h4>
[% END %]

<div id="comment_box" class="modal" tabindex="-1" role="dialog" aria-labelledby="mana_search_result_label" style="display: none;">
    <div class="modal-dialog modal-lg" style="width: 30%">
        <div class="modal-content" style="">
            <div class="modal-header">
                <button type="button" id="commentCloseButton" class="closebtn" aria-hidden="true">×</button>
                <h3 id="mana_submit_comment"> Please enter a new commment (max 35 caracters)</h3>
            </div>
            <div class="modal-body">
                <form>
                    <input hidden id="selected_id" value="">
                    <input type="text" id="manamsg"> Comment:
                </form>
                <button id="CommentButton"> Comment </button>
            </div>
        </div>
    </div>
</div>
