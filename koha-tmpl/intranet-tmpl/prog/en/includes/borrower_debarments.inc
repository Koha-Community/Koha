<script type="text/javascript">
   //<![CDATA[

        function confirm_remove_restriction() {
            return confirm(_("Remove restriction?"));
        }

    //]]>
</script>

<div id="reldebarments">
    [% UNLESS debarments %]<p>Patron is currently unrestricted.</p>[% END %]

    <table>
        <thead>
            <tr>
                 <th>Type</th>
                 <th>Comment</th>
                 <th>Expiration</th>
                 [% IF ( CAN_user_borrowers ) %]
                     <th>&nbsp;</th>
                 [% END %]
            </tr>
        </thead>

        <tbody>
            [% FOREACH d IN debarments %]
                <tr>
                    <td>[% d.type %]</td>
                    <td>[% d.comment %]</td>
                    <td>[% IF d.expiration %] [% d.expiration | $KohaDates %] [% ELSE %] <i>Indefinite</i> [% END %]</td>
                    [% IF ( CAN_user_borrowers )%]
                        <td>
                            <a href="/cgi-bin/koha/members/mod_debarment.pl?borrowernumber=[% borrowernumber %]&amp;borrower_debarment_id=[% d.borrower_debarment_id %]&amp;action=del" onclick="return confirm_remove_restriction()">
                                Remove
                            </a>
                        </td>
                    [% END %]
                </tr>
            [% END %]
        </tbody>

        [% IF ( CAN_user_borrowers )%]
            <form method="post" action="/cgi-bin/koha/members/mod_debarment.pl">
                <input type="hidden" name="borrowernumber" value="[% borrowernumber %]" />
                <input type="hidden" name="action" value="add" />

                <tfoot>
                    <tr>
                        <td>MANUAL</td>
                        <td><input type="text" name="comment" /></td>
                        <td>
                            <input name="expiration" id="expiration" size="10" readonly="readonly" value="" class="datepicker" />
                            <a href='#' onclick="document.getElementById('expiration').value='';">Clear Date</a>
                        </td>
                        <td>
                            <input type="submit" value="Add restriction" />
                        </td>
                    </tr>
                </tfoot>
            </form>
        [% END %]
    </table>
</div>
