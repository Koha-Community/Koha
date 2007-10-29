        </div>

<!-- TMPL_IF NAME="languages_loop" -->
		<div id="changelanguage">
		<ul>
		<!-- TMPL_LOOP NAME="languages_loop" -->
		<li><a href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="language_code" -->"><!-- TMPL_VAR NAME="language_name" --></a></li>
		<!-- /TMPL_LOOP -->
		</ul>
		</div>
<!-- /TMPL_IF -->

    </body>
</html>
