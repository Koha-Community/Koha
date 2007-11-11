        </div>

<!-- TMPL_IF NAME="languages_loop" -->
		<div id="changelanguage" class="ft">
		<ul>
		<!-- TMPL_LOOP NAME="languages_loop" -->
		<!-- TMPL_IF NAME="current" -->
		<li><!-- TMPL_IF NAME="language_native_description" --><!-- TMPL_VAR NAME="language_native_description" --><!-- TMPL_ELSE --><!-- TMPL_VAR NAME="language_code" --><!-- /TMPL_IF --></li>
		<!-- TMPL_ELSE -->
		<li><a title="<!-- TMPL_IF NAME="language_description" --><!-- TMPL_VAR NAME="language_description" --> <!-- TMPL_IF NAME="language_script_description" -->, <!-- TMPL_VAR NAME="language_script_description" --> (Script)<!-- /TMPL_IF --> <!-- TMPL_IF NAME="language_region_description" -->, <!-- TMPL_VAR NAME="language_region_description" --> (Region)<!-- /TMPL_IF --> <!-- TMPL_IF NAME="language_variant_description" -->, <!-- TMPL_VAR NAME="language_variant_description" --> (Vartiant)<!-- /TMPL_IF --><!-- TMPL_ELSE --><!-- TMPL_VAR NAME="language_code" --><!-- /TMPL_IF -->" href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="language" -->"><!-- TMPL_IF NAME="language_native_description" --><!-- TMPL_VAR NAME="language_native_description" --><!-- TMPL_ELSE --><!-- TMPL_VAR NAME="language_code" --><!-- /TMPL_IF --></a></li>
		<!-- /TMPL_IF -->
		<!-- /TMPL_LOOP -->
		</ul>
		</div>
<!-- /TMPL_IF -->

    </body>
</html>
