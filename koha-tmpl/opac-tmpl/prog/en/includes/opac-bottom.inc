
<!-- TMPL_IF NAME="opaccredits" -->
	<div class="ft">
        <!-- TMPL_VAR NAME="opaccredits" -->
    </div>
<!-- /TMPL_IF -->
</div>
<!-- TMPL_IF NAME="opaclanguagesdisplay" -->
<!-- TMPL_IF NAME="languages_loop" -->
        <div id="changelanguage" class="ft"><strong>Languages: </strong>
        <!-- TMPL_LOOP NAME="languages_loop" -->
            <!-- TMPL_IF NAME="group_enabled" -->
            <!-- TMPL_IF NAME="plural" -->
            <a id="show<!-- TMPL_VAR NAME="rfc4646_subtag" -->" class="sublangs more" href="#"><!-- TMPL_IF NAME="native_description" --><!-- TMPL_VAR NAME="native_description" --><!-- TMPL_ELSE --><!-- TMPL_VAR NAME="rfc4646_subtag" --><!-- /TMPL_IF --></a>
			<div id="sub<!-- TMPL_VAR NAME="rfc4646_subtag" -->">
            <div class="bd"><ul>
            <!-- TMPL_LOOP NAME="sublanguages_loop" -->
		<!-- TMPL_IF NAME="enabled" -->
                <!-- TMPL_IF NAME="sublanguage_current" -->
                    <li> <!-- TMPL_VAR NAME="native_description" --> <!-- TMPL_VAR NAME="script_description" --> <!-- TMPL_VAR NAME="region_description" --> <!-- TMPL_VAR NAME="variant_description" --> (<!-- TMPL_VAR NAME="rfc4646_subtag" -->)</li>
                <!-- TMPL_ELSE -->
                <li><a href="/cgi-bin/koha/opac-changelanguage.pl?language=<!-- TMPL_VAR NAME="rfc4646_subtag" -->"> <!-- TMPL_VAR NAME="native_description" --> <!-- TMPL_VAR NAME="script_description" --> <!-- TMPL_VAR NAME="region_description" --> <!-- TMPL_VAR NAME="variant_description" --> (<!-- TMPL_VAR NAME="rfc4646_subtag" -->)</a></li>
                <!-- /TMPL_IF -->
		<!-- /TMPL_IF -->
            <!-- /TMPL_LOOP -->
            </ul>
			</div>
			</div>

            <!-- TMPL_ELSE -->
            <!-- TMPL_UNLESS NAME="one_language_enabled" -->
	    	<!-- TMPL_IF NAME="group_enabled" -->
                <!-- TMPL_IF NAME="current" -->
                    <!-- TMPL_IF NAME="native_description" --><!-- TMPL_VAR NAME="native_description" --><!-- TMPL_ELSE --><!-- TMPL_VAR NAME="rfc4646_subtag" --><!-- /TMPL_IF -->
                <!-- TMPL_ELSE -->
                    <a href="/cgi-bin/koha/opac-changelanguage.pl?language=<!-- TMPL_VAR NAME="rfc4646_subtag" -->"><!-- TMPL_IF NAME="native_description" --><!-- TMPL_VAR NAME="native_description" --><!-- TMPL_ELSE --><!-- TMPL_VAR NAME="rfc4646_subtag" --><!-- /TMPL_IF --></a>
                <!-- /TMPL_IF -->
		<!-- /TMPL_IF -->
            <!-- /TMPL_IF -->
            <!-- /TMPL_UNLESS -->
            <!-- /TMPL_IF --><!-- TMPL_UNLESS NAME="__last__" --> | <!-- /TMPL_UNLESS -->
        <!-- /TMPL_LOOP -->
        </div>
<!-- /TMPL_IF -->
<!-- /TMPL_IF -->

<!-- TMPL_IF NAME="Babeltheque" -->
<script type="text/javascript" src="http://www.babeltheque.com/bw_30.js"></script>
<!-- /TMPL_IF -->

</body>
</html>
