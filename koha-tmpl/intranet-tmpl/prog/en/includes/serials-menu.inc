[% IF ( subscriptionid ) %]
<ul>
<li><a href="serials-collection.pl?subscriptionid=[% subscriptionid %]">Serial Collection</a></li>
	[% IF ( CAN_user_serials_routing ) %]
        [% IF ( hasRouting ) %]
             <li><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=[% subscriptionid %]">Edit Routing List</a></li>
        [% ELSE %]
			<li><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=[% subscriptionid %]&amp;op=new">Create Routing List</a></li>
		[% END %]
	[% END %]
</ul>
[% END %]

<ul>
    [% IF ( CAN_user_serials_claim_serials ) %]
	<li><a href="/cgi-bin/koha/serials/claims.pl">Claims</a></li>
    [% END %]
    [% IF ( CAN_user_serials_check_expiration ) %]
	<li><a href="/cgi-bin/koha/serials/checkexpiration.pl">Check Expiration</a></li>
    [% END %]
</ul>
