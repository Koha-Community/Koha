<div id="bottombloc">
<!-- TMPL_IF NAME="loggedinusername" -->
	<p>
		Logged in as <b><!-- TMPL_VAR NAME="loggedinusername" --></b> <a href="/cgi-bin/koha/opac-user.pl">Members Home</a>
		|| <a href=/cgi-bin/koha/opac-main.pl?logout.x=1>Log Out</a>
	</p>
<!-- TMPL_ELSE -->
	<p>
		<a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha
	</p>
<!-- /TMPL_IF -->
</div>
</body>
</html>
