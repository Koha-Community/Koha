<div id="menu">
<ul>
	<li class="active">                <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Normal</a></li>
<li>                <a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">MARC</a></li>
	<li>                <a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">ISBD</a></li>
	<li><a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Items</a></li>
	<li><a href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Holds</a></li>
<!-- TMPL_IF name="subscriptionsnumber" --><li><a href="/cgi-bin/koha/serials/serials-home.pl?searched=1&amp;title_filter=<!-- TMPL_VAR NAME="subscriptiontitle" -->">Subscription(s)</a></li><!-- /TMPL_IF -->
</ul>
<ul>
<li>                <a href="/cgi-bin/koha/catalogue/issuehistory.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;title=<!-- TMPL_VAR NAME="title"-->&amp;author=<!-- TMPL_VAR NAME="author"-->" >Circulation history</a></li>
	                  <!-- TMPL_IF NAME="CAN_user_parameters"--><li><a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;module=CATALOGUING&amp;action=MODIFY&amp;object=<!-- TMPL_VAR NAME="biblionumber"-->">Modification log</a> </li><!-- /TMPL_IF -->
</ul>
</div>