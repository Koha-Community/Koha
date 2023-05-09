[% USE raw %]
[% USE Koha %]
[% PROCESS 'restriction-types.inc' %]

[% IF ( patron.restrictions.count == 0 ) %]
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
            [% FOREACH restriction IN patron.restrictions %]
                <tr>
                    <td>
                        [% PROCESS restriction_type_description restriction_type=restriction.type %]
                    </td>
                    <td>
                        [% IF restriction.comment.search('OVERDUES_PROCESS') %]
                            <span>Restriction added by overdues process [% restriction.comment.remove('OVERDUES_PROCESS ') | $raw %]</span>
                        [% ELSE %]
                            [% restriction.comment | $raw %]
                        [% END %]
                    </td>
                    <td>[% IF restriction.expiration %] [% restriction.expiration | $KohaDates %] [% ELSE %] <em>Indefinite</em> [% END %]</td>
                    <td>[% restriction.created | $KohaDates %]</td>
                    [% IF CAN_user_borrowers_edit_borrowers && CAN_user_circulate_manage_restrictions %]
                        <td>
                            <a class="remove_restriction btn btn-default btn-xs" href="/cgi-bin/koha/members/mod_debarment.pl?borrowernumber=[% patron.borrowernumber | html %]&amp;borrower_debarment_id=[% restriction.borrower_debarment_id | html %]&amp;action=del">
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
                [% IF Koha.Preference('PatronRestrictionTypes') %]
                <li>
                    <label for="debarred_type">Type:</label>
                    <select name="debarred_type">
                        [% FOREACH restriction_type IN restriction_types %]
                            [% IF !restriction_type.is_system %]
                                [% IF restriction_type.is_default %]
                                <option value="[% restriction_type.code | html %]" selected>[% PROCESS restriction_type_description %]</option>
                                [% ELSE %]
                                <option value="[% restriction_type.code | html %]">[% PROCESS restriction_type_description %]</option>
                                [% END %]
                            [% END %]
                        [% END %]
                    </select>
                </li>
                [% END %]
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

