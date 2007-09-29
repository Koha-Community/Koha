<!-- TMPL_IF NAME="subscriptionid" -->
<ul>
<li><a href="serials-collection.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Serial Collection</a></li>
	<!-- TMPL_IF NAME="routing" --><li><a href="routing.pl?subscriptionid=<!-- TMPL_VAR NAME="subscriptionid" -->">Edit Routing List</a></li><!-- TMPL_ELSE -->
	<li><a href="routing.pl?subscriptionid=<!-- TMPL_VAR NAME="subscriptionid" -->&amp;op=new">Create Routing List</a></li><!-- /TMPL_IF -->
</ul>
<!-- TMPL_ELSE -->
	<!-- TMPL_IF NAME="subscriptions" -->
	<ul>
	<li>Manage Subscriptions
		<!-- TMPL_LOOP NAME="subscriptions" -->
			<li>#<!-- TMPL_VAR name="subscriptionid" --> <a href="serials-collection.pl?subscriptionid=<!-- TMPL_VAR name="subscriptionid" -->">Serial Collection</a></li>
			<!-- TMPL_IF NAME="routing" --><li><a href="routing.pl?subscriptionid=<!-- TMPL_VAR NAME="subscriptionid" -->">#<!-- TMPL_VAR name="subscriptionid" --> Edit Routing List</a></li><!-- TMPL_ELSE -->
	<li><a href="routing.pl?subscriptionid=<!-- TMPL_VAR NAME="subscriptionid" -->&amp;op=new">#<!-- TMPL_VAR name="subscriptionid" --> Create Routing List</a></li><!-- /TMPL_IF -->
		<!-- /TMPL_LOOP -->
	</li></ul>
	<!-- /TMPL_IF -->
<!-- /TMPL_IF -->

<ul>
	<li>        <a href="/cgi-bin/koha/serials/claims.pl">Claims</a></li>
	<li>        <a href="/cgi-bin/koha/serials/checkexpiration.pl">Check Expiration</a></li>
</ul>