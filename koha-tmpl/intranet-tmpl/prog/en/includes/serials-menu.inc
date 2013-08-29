[% IF ( subscriptionid ) %]
<ul>
<li><a href="serials-collection.pl?subscriptionid=[% subscriptionid %]">Serial collection</a></li>
  [% UNLESS closed %]
    [% IF ( routing && CAN_user_serials_routing ) %]
        [% IF ( hasRouting ) %]
             <li><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=[% subscriptionid %]">Edit routing list</a></li>
        [% ELSE %]
            <li><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=[% subscriptionid %]&amp;op=new">Create routing list</a></li>
        [% END %]
    [% END %]
  [% END %]
</ul>
[% END %]

<ul>
    [% IF ( CAN_user_serials_claim_serials ) %]
	<li><a href="/cgi-bin/koha/serials/claims.pl">Claims</a></li>
    [% END %]
    [% IF ( CAN_user_serials_check_expiration ) %]
	<li><a href="/cgi-bin/koha/serials/checkexpiration.pl">Check expiration</a></li>
    [% END %]
    <li>
        <a href="/cgi-bin/koha/serials/subscription-frequencies.pl">
            Manage frequencies
        </a>
    </li>
    <li>
        <a href="/cgi-bin/koha/serials/subscription-numberpatterns.pl">
            Manage numbering patterns
        </a>
    </li>
    <li><a href="/cgi-bin/koha/serials/add_fields.pl">Add subscription fields</a></li>
</ul>
