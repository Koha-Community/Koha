<div id="bottombloc">
<!-- TMPL_IF NAME="loggedinusername" -->
	<p>
		Connecté en tant que <b><!-- TMPL_VAR NAME="loggedinusername" --></b> <a href="/cgi-bin/koha/opac-user.pl">Accueil Membre</a>
		|| <a href="/cgi-bin/koha/opac-main.pl?logout.x=1">Déconnection</a>
	</p>
<!-- TMPL_ELSE -->
	<p>
		<a href="/cgi-bin/koha/opac-user.pl">Se connecter</a> à  Koha
	</p>
<!-- /TMPL_IF -->
</div>
</body>
</html>
