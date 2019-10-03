[% USE raw %]
<div id="reldebarments">
    [% IF ( not debarments.defined || debarments.size < 1 ) %]
        <p>Patron is currently unrestricted.</p>
    [% ELSE %]
        <table>
            <thead>
                <tr>
                     <th>Type</th>
                     <th>Comment</th>
                     <th>Expiration</th>
                     <th>Created</th>
                     [% IF CAN_user_borrowers_edit_borrowers && CAN_user_circulate_manage_restrictions %]
                         <th>&nbsp;</th>
                     [% END %]
                </tr>
            </thead>
            <tbody>
                [% FOREACH d IN debarments %]
                    [% dtype = d.type %]
                    <tr>
                        <td>
                            [% restriction_types.$dtype.display_text | html %]
                        </td>
                        <td>
                            [% IF d.comment.search('OVERDUES_PROCESS') %]
                                <span>Restriction added by overdues process [% d.comment.remove('OVERDUES_PROCESS ') | $raw %]</span>
                            [% ELSE %]
                                [% d.comment | $raw %]
                            [% END %]
                        </td>
                        <td>[% IF d.expiration %] [% d.expiration | $KohaDates %] [% ELSE %] <em>Indefinite</em> [% END %]</td>
                        <td>[% d.created | $KohaDates %]</td>
                        [% IF CAN_user_borrowers_edit_borrowers && CAN_user_circulate_manage_restrictions %]
                            <td>
                                <a class="remove_restriction btn btn-default btn-xs" href="/cgi-bin/koha/members/mod_debarment.pl?borrowernumber=[% patron.borrowernumber | html %]&amp;borrower_debarment_id=[% d.borrower_debarment_id | html %]&amp;action=del">
                                    <i class="fa fa-trash"></i> Remove
                                </a>
                            </td>
                        [% END %]
                    </tr>
                [% END %]
            </tbody>
        </table>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers && CAN_user_circulate_manage_restrictions %]
        <p><a href="#" id="add_manual_restriction"><i class="fa fa-plus"></i> Add manual restriction</a></p>
        <form method="post" action="/cgi-bin/koha/members/mod_debarment.pl" class="clearfix">
            <input type="hidden" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
            <input type="hidden" name="action" value="add" />
            <fieldset class="rows" id="manual_restriction_form">
                <legend>Add manual restriction</legend>
                <ol>
                    <li><label for="rcomment">Comment:</label> <input type="text" id="rcomment" name="comment" /></li>
                    <li>
                        <label for="rexpiration">Expiration:</label>
                        <input name="expiration" id="rexpiration" size="20" value="" class="flatpickr" data-flatpickr-futuredate="true" type="text" />
                    </li>
                </ol>
            <fieldset class="action"><input type="submit" value="Add restriction" /> <a href="#" class="cancel" id="cancel_manual_restriction">Cancel</a></fieldset>
            </fieldset>
        </form>
    [% END %]
</div>
