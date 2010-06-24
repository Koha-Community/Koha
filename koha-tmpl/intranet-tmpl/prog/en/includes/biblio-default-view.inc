<!-- TMPL_IF name="BiblioDefaultViewmarc" -->
	<a class="title" href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" ESCAPE="URL" -->">
<!-- TMPL_ELSIF NAME="BiblioDefaultViewlabeled_marc" -->
	<a class="title" href="/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" ESCAPE="URL" -->">
<!-- TMPL_ELSIF NAME="BiblioDefaultViewisbd" -->
	<a class="title" href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" ESCAPE="URL" -->">
<!-- TMPL_ELSE -->
	<a class="title" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" ESCAPE="URL" -->">
<!-- /TMPL_IF -->