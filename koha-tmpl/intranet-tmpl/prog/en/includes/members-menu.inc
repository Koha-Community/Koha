<!-- TMPL_IF NAME="borrowernumber" -->
<div id="menu">
<ul>	<!-- TMPL_IF NAME="circview" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Check Out</a></li>
	<!-- TMPL_IF NAME="detailview" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Details</a></li>
	<!-- TMPL_IF NAME="finesview" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><li><a href="/cgi-bin/koha/members/boraccount.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Fines</a></li>
	<!-- TMPL_IF NAME="intranetreadinghistory" --><li><a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Reading Record</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_parameters"--><li><a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;module=MEMBERS&amp;action=MODIFY&amp;object=<!-- TMPL_VAR NAME="borrowernumber" -->">Modification Log</a></li><!-- /TMPL_IF -->
</ul>
</div>
<!-- /TMPL_IF -->