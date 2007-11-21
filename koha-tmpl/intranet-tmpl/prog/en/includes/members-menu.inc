<!-- TMPL_IF NAME="borrowernumber" -->
<h5>Patron Details</h5>
<ul>
	<li><a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Details</a></li>
	<li><a href="/cgi-bin/koha/members/boraccount.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Fines</a></li>
	<!-- TMPL_IF NAME="intranetreadinghistory" --><li><a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=<!-- TMPL_VAR NAME="borrowernumber" -->">Reading Record</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="CAN_user_parameters"--><li><a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;module=MEMBERS&amp;action=MODIFY&amp;object=<!-- TMPL_VAR NAME="borrowernumber" -->">Modification Log</a></li><!-- /TMPL_IF -->
</ul>
<!-- /TMPL_IF -->