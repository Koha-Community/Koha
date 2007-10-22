<div id="toolbar">
<ul class="toolbar">

	<li><a id="addbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">Nouveau</a></li>
	<li id="editmenucontainer"><a id="editbiblio" class="menubutton" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=">Editer notice</a></li>
	<li><a id="edititems" class="menubutton" href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Modifier exemplaire</a></li>
	<li><a id="duplicatebiblio" class="menubutton" href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=duplicate">Dupliquer notice</a></li>
	<li><a id="deletebiblio" href="javascript:confirm_deletion(<!-- TMPL_VAR NAME="count" -->)">Supprimer</a></li>
	<li><a id="addtoshelf" href="#" onclick="window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes'); return false;">Ajouter à une étagère</a></li>
	<li><a id="printbiblio" href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Imprimer</a></li>
        <!-- TMPL_UNLESS name="bi_notforloan" -->
	<!-- TMPL_UNLESS NAME="norequests" --><li><a id="placehold" href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Réserver</a></li><!-- /TMPL_UNLESS --><!-- TMPL_UNLESS -->
</ul></div>
