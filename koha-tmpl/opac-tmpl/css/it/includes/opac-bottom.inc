<div id="bottombloc">
<!-- TMPL_IF NAME="loggedinusername" -->
	<p>
		Logged in come <b><!-- TMPL_VAR NAME="loggedinusername" --></b> <a href="/cgi-bin/koha/opac-user.pl">Pagina utente</a>
		|| <a href="/cgi-bin/koha/opac-main.pl?logout.x=1">Logout</a>
	</p>
<!-- TMPL_ELSE -->
	<p>
		<a href="/cgi-bin/koha/opac-user.pl">Entra</a> in Koha
	</p>
<!-- /TMPL_IF -->
</div>
</body>
</html>
