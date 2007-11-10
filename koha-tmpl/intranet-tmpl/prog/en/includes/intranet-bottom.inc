        </div>

<!-- TMPL_IF NAME="languages_loop" -->
		<div id="changelanguage" class="ft">
		<ul>
		<!-- TMPL_LOOP NAME="languages_loop" -->
		<!-- TMPL_IF NAME="current" -->
		<li><!-- TMPL_VAR NAME="language_name" --></li>
		<!-- TMPL_ELSE -->
		<li><a href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="language_code" -->"><!-- TMPL_VAR NAME="language_name" --></a></li>
		<!-- /TMPL_IF -->
		<!-- /TMPL_LOOP -->
		</ul>
		</div>
<!-- /TMPL_IF -->

    </body>
</html>
