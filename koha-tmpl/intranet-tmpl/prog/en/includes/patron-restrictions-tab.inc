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
                <tr [% IF restriction.is_expired %]class="expired"[% END %]>
                    <td> [% PROCESS restriction_type_description restriction_type=restriction.type %] </td>
                    <td>
                        [% IF restriction.comment.search('OVERDUES_PROCESS') %]
                            <span>Restriction added by overdues process [% restriction.comment.remove('OVERDUES_PROCESS ') | $raw %]</span>
                        [% ELSE %]
                            [% restriction.comment | $raw %]
                        [% END %]
                    </td>
                    <td>
                        [% IF restriction.expiration %]
                            [% restriction.expiration | $KohaDates %]
                            [% IF restriction.is_expired %](<span>expired</span>)[% END %]
                        [% ELSE %]
                            <em>Indefinite</em>
                        [% END %]
                    </td>
                    <td>[% restriction.created | $KohaDates %]</td>
                    [% IF CAN_user_borrowers_edit_borrowers && CAN_user_circulate_manage_restrictions %]
                        <td>
                            <form method="post" action="/cgi-bin/koha/members/mod_debarment.pl">
                                [% INCLUDE 'csrf-token.inc' %]
                                <input type="hidden" name="op" value="cud-del" />
                                <input type="hidden" name="borrowernumber" value="[% patron.borrowernumber | uri %]" />
                                <input type="hidden" name="borrower_debarment_id" value="[% restriction.borrower_debarment_id | uri %]" />
                                <button type="submit" class="remove_restriction btn btn-default btn-xs"><i class="fa fa-trash-can"></i> Remove</button>
                            </form>
                        </td>
                    [% END %]
                </tr>
            [% END %]
        </tbody>
    </table>
[% END %]
[% IF CAN_user_borrowers_edit_borrowers && CAN_user_circulate_manage_restrictions %]
    <p
        ><a href="#" id="add_manual_restriction"><i class="fa fa-plus"></i> Add manual restriction</a></p
    >
    <form method="post" action="/cgi-bin/koha/members/mod_debarment.pl" class="clearfix">
        [% INCLUDE 'csrf-token.inc' %]
        <input type="hidden" name="borrowernumber" value="[% patron.borrowernumber | html %]" />
        <input type="hidden" name="op" value="cud-add" />
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
