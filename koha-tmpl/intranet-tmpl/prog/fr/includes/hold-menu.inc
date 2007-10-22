<!-- TMPL_IF NAME="borrowernumber" -->
<div class="patroninfo"><h5><!-- TMPL_VAR name="borrowerfirstname" --> <!-- TMPL_VAR name="borrowersurname" --></h5>
<ul>
	        <li><!-- TMPL_IF NAME="borrowerstreetaddress"-->
            <!-- TMPL_VAR NAME="borrowerstreetaddress" -->,
        <!-- TMPL_ELSE -->
            <span class="problem">Pas d'adresse enregistrée pour cet adhérent.</span>
        <!-- /TMPL_IF --></li>
       <li> <!-- TMPL_IF NAME="borrowercity" -->
            <!-- TMPL_VAR NAME="borrowercity" -->
        <!-- TMPL_ELSE -->
            Pas de commune enregistrée
        <!-- /TMPL_IF --></li>
   <li> <!--TMPL_IF NAME="borrowerphone" -->
        <!-- TMPL_VAR NAME="borrowerphone" -->
    <!-- TMPL_ELSE -->
        <span class="problem">Pas de téléphone enregistré.</span>    
    <!-- /TMPL_IF --></li>
	<li><!-- TMPL_VAR NAME="borrowerphonepro" --></li>
	<li><!-- TMPL_VAR NAME="borrowermobile" --></li>
	    <!-- TMPL_IF NAME="borroweremail" -->
   <li> <a href="mailto:<!-- TMPL_VAR NAME="email" -->"><!-- TMPL_VAR NAME="borroweremail" --></a></li>
    <!-- /TMPL_IF -->
		    <!-- TMPL_IF NAME="borroweremailpro" -->
   <li> <a href="mailto:<!-- TMPL_VAR NAME="emailpro" -->"><!-- TMPL_VAR NAME="borroweremailpro" --></a></li>
    <!-- /TMPL_IF -->
    <li>Catégorie : <!-- TMPL_VAR name="borrowercategorycode" --></li>
</ul></div>
<div class="patronviews">
<ul><li><a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Détails</a></li>
	<li><a href="/cgi-bin/koha/members/boraccount.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Amendes</a></li>
	<!-- TMPL_IF NAME="intranetreadinghistory" --><li><a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Liste des lecturespour %s %s</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_parameters"--><li><a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;module=MEMBERS&amp;action=MODIFY&amp;object=<!-- TMPL_VAR NAME="borrowernumber" -->">Log des modifications</a></li><!-- /TMPL_IF --></ul>
</div>
<!-- /TMPL_IF -->
