[% USE Price %]
[% SET NoIssuesCharge = Koha.Preference('noissuescharge') %]
[% IF fines and fines > 0 %]
    <li>
        <span class="circ-hlt">Fees &amp; Charges:</span>
        Patron has outstanding fees &amp; charges of [% fines | $Price %].
        [% IF !Koha.Preference('AllowFineOverride') && NoIssuesCharge && fines > NoIssuesCharge %]
           <span class="circ-hlt">Checkouts are BLOCKED because fine balance is OVER THE LIMIT.</span>
        [% END %]
        <a href="/cgi-bin/koha/members/pay.pl?borrowernumber=[% borrowernumber | uri %]" class="btn btn-default btn-xs" >Make payment</a>
        <a href="/cgi-bin/koha/members/paycollect.pl?borrowernumber=[% borrowernumber | uri %]" class="btn btn-default btn-xs" >Pay all fines</a></li>
    </li>
[% END %]
