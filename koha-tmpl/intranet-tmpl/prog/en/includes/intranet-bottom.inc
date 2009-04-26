        </div>

<!-- TMPL_IF NAME="languages_loop" -->
    <!-- TMPL_UNLESS NAME="one_language_enabled" -->
        <div id="changelanguage" class="ft">
        <ul id="i18nMenu" class="footermenu">
        <!-- TMPL_LOOP NAME="languages_loop" -->
            <!-- TMPL_IF NAME="group_enabled" -->
            <!-- TMPL_IF NAME="plural" -->
            <li class="more"><a id="showlang" href="#"><!-- TMPL_VAR NAME="native_description" --> (<!-- TMPL_VAR NAME="rfc4646_subtag" -->)</a><div id="sublangs">
            <div class="bd"><ul>
            <!-- TMPL_LOOP NAME="sublanguages_loop" -->
		<!-- TMPL_IF NAME="enabled" -->
                <!-- TMPL_IF NAME="sublanguage_current" -->
                    <li> <a href="#"><!-- TMPL_VAR NAME="native_description" --> <!-- TMPL_VAR NAME="script_description" --> <!-- TMPL_VAR NAME="region_description" --> <!-- TMPL_VAR NAME="variant_description" --> (<!-- TMPL_VAR NAME="rfc4646_subtag" -->)</a></li>
                <!-- TMPL_ELSE -->
                <li><a href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="rfc4646_subtag" -->"> <!-- TMPL_VAR NAME="native_description" --> <!-- TMPL_VAR NAME="script_description" --> <!-- TMPL_VAR NAME="region_description" --> <!-- TMPL_VAR NAME="variant_description" --> (<!-- TMPL_VAR NAME="rfc4646_subtag" -->)</a></li>
		<!-- /TMPL_IF -->
                <!-- /TMPL_IF -->

            <!-- /TMPL_LOOP -->
            </ul></div></div></li>

            <!-- TMPL_ELSE -->
	    	<!-- TMPL_IF NAME="group_enabled" -->
                <!-- TMPL_IF NAME="current" -->
                    <li><!-- TMPL_IF NAME="native_description" --><!-- TMPL_VAR NAME="native_description" --><!-- TMPL_ELSE --><!-- TMPL_VAR NAME="rfc4646_subtag" --><!-- /TMPL_IF --></li>
                <!-- TMPL_ELSE -->
                    <li><a href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="rfc4646_subtag" -->"><!-- TMPL_IF NAME="native_description" --><!-- TMPL_VAR NAME="native_description" --><!-- TMPL_ELSE --><!-- TMPL_VAR NAME="rfc4646_subtag" --><!-- /TMPL_IF --></a></li>
                <!-- /TMPL_IF -->
		<!-- /TMPL_IF -->
            <!-- /TMPL_IF -->
            <!-- /TMPL_IF -->
        <!-- /TMPL_LOOP -->
        </ul>
        </div>
    <!-- /TMPL_UNLESS -->
<!-- /TMPL_IF -->
    </body>
</html>
