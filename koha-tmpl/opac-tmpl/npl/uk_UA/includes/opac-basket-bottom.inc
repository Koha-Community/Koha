<div id="bottombloc">
<!-- TMPL_IF NAME="loggedinusername" -->
	<p>
		Зареєстровано як <b><!-- TMPL_VAR NAME="loggedinusername" --></b> <a href="/cgi-bin/koha/opac-user.pl">Домівка відвідувачів</a>
		|| <a href="/cgi-bin/koha/opac-main.pl?logout.x=1">Вийти</a>
	</p>
<!-- TMPL_ELSE -->
	<p>
		<a href="/cgi-bin/koha/opac-user.pl">Вхід</a> у Коха
	</p>
<!-- /TMPL_IF -->
</div>
</body>
</html>