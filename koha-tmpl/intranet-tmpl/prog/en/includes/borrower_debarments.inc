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
                    <tr>
                        <td>
                            [% SWITCH d.type %]
                                [% CASE 'MANUAL' %]
                                    Manual
                                [% CASE 'OVERDUES' %]
                                    Overdues
                                [% CASE 'SUSPENSION' %]
                                    Suspension
                                [% CASE 'DISCHARGE' %]
                                    Discharge
                            [% END %]
                        </td>
                        <td>
			    [% IF d.comment.search('OVERDUES_PROCESS') %]
				Restriction added by overdues process [% d.comment.remove('OVERDUES_PROCESS ') | $raw %]
			    [% ELSE %]
                [% d.comment | $raw %]
			    [% END %]
			</td>
                        <td>[% IF d.expiration %] [% d.expiration | $KohaDates %] [% ELSE %] <i>Indefinite</i> [% END %]</td>
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
                    <li><label for="rcomment">Comment:</label> <input type="text" id="rcomment" name="comment" type="text" /></li>
                    <li><label for="rexpiration">Expiration:</label> <input name="expiration" id="rexpiration" size="10" value="" class="datepicker" type="text" />
                        <a href="#" class="clear-date" id="clear-date-rexpiration">Clear date</a></li>
                </ol>
            <fieldset class="action"><input type="submit" value="Add restriction" /> <a href="#" class="cancel" id="cancel_manual_restriction">Cancel</a></fieldset>
            </fieldset>
        </form>
    [% END %]
</div>
