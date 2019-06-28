    <li>
    <span class="circ-hlt">Patron's age is incorrect for their category.</span>
    Ages allowed are [% age_low | html %]-[% age_high | html %].
    <a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;borrowernumber=[% patron.borrowernumber | uri %]&amp;step=3" class="btn btn-default btn-xs">Change category</a></li>
