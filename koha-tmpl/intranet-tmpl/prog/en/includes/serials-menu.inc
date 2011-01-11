<!-- TMPL_IF NAME="subscriptionid" -->
<ul>
<li><a href="serials-collection.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Serial Collection</a></li>
	<!-- TMPL_IF NAME="CAN_user_serials_routing" -->
        <!--TMPL_IF Name="hasRouting"-->
             <li><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Edit Routing List</a></li>
        <!-- TMPL_ELSE -->
			<li><a href="/cgi-bin/koha/serials/routing.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->&amp;op=new">Create Routing List</a></li>
		<!--/TMPL_IF-->
	<!-- /TMPL_IF -->
</ul>
<!-- /TMPL_IF -->

<ul>
    <!-- TMPL_IF NAME="CAN_user_serials_claim_serials" -->
	<li><a href="/cgi-bin/koha/serials/claims.pl">Claims</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_serials_check_expiration" -->
	<li><a href="/cgi-bin/koha/serials/checkexpiration.pl">Check Expiration</a></li>
    <!-- /TMPL_IF -->
</ul>
