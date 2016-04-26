[% USE Price %]
[% SET NoIssuesCharge = Koha.Preference('noissuescharge') %]

[% IF NoIssuesCharge && fines > NoIssuesCharge %]
    <li>
        <span class="circ-hlt">Fees &amp; Charges:</span>
        Patron has <a href="/cgi-bin/koha/members/boraccount.pl?borrowernumber=[% borrowernumber %]">
            Outstanding fees &amp; charges
            [% IF ( fines ) %]
                of [% fines | $Price %]
            [% END %]
        </a>.

        [% IF !Koha.Preference('AllowFineOverride') %]
            <span class="circ-hlt">Checkouts are BLOCKED because fine balance is OVER THE LIMIT.</span>
        [% END %]

        <a href="/cgi-bin/koha/members/pay.pl?borrowernumber=[% borrowernumber %]">Make payment</a>
        or
        <a href="/cgi-bin/koha/members/paycollect.pl?borrowernumber=[% borrowernumber %]">Pay all fines</a></li>
    </li>
[% END %]
