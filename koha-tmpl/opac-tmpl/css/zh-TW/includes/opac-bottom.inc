<div id="bottombloc">
<!-- TMPL_IF NAME="loggedinusername" -->
	<p>
		目前身份：<b><!-- TMPL_VAR NAME="loggedinusername" --></b> 【<a href="/cgi-bin/koha/opac-user.pl">個人主頁</a>】
		|| <a href="/cgi-bin/koha/opac-main.pl?logout.x=1">登出</a>
	</p>
<!-- TMPL_ELSE -->
	<p>
		<a href="/cgi-bin/koha/opac-user.pl">登入</a> Koha
	</p>
<!-- /TMPL_IF -->
</div>
</body>
</html>
