<li class="userdebarred blocker">
    <strong>Your account has been frozen</strong>
    <ul>
        [% FOREACH restriction IN logged_in_user.restrictions %]
            <li class="[% restriction.type.code | lower | html %]_restriction">
                <span class="restriction_expiration">
                    [% IF restriction.expiration %]
                        <strong>Restriction expiring [% restriction.expiration | $KohaDates %]</strong>
                    [% ELSE %]
                        <strong>Indefinite restriction</strong>
                    [% END %]
                </span>
                [% IF restriction.comment.search('OVERDUES_PROCESS') %]
                    <span class="restriction_detail">Restriction added by overdues process [% restriction.comment.remove('OVERDUES_PROCESS ') | $raw | html_line_break %]</span>
                [% ELSE %]
                    [% IF restriction.comment %]
                        <span class="restriction_detail">[%- restriction.comment | html_line_break -%]</span>
                    [% END %]
                [% END %]
            </li>
        [% END %]
        <li>
            <span>Usually the reason for freezing an account is old overdues or damage fees. If it appears that your account is clear, please contact the library.</span>
            <a href="/cgi-bin/koha/opac-account.pl">Check your charges page.</a> <a href="/cgi-bin/koha/opac-user.pl?opac-user-overdues=1">Check your overdues.</a>
        </li>
    </ul>
</li>
