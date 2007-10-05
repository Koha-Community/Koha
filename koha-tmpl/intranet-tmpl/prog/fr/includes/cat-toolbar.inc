<div id="toolbar">
				<a id="addbiblio" href="/cgi-bin/koha/cataloguing/addbiblio.pl">Nouveau</a>
			<input type="submit" id="editbutton" name="editbutton_button" value="Modifier">
            <select id="editbuttonselect" name="editbuttonselect">
                <option value="0">Notice bibliographique</option>
                <option value="1">Exemplaires</option>
                <option value="2">Comme une nouvelle notire (Dupliquer)</option>                
            </select>
	                <a id="deletebiblio" href="javascript:confirm_deletion(<!-- TMPL_VAR NAME="count" -->)">Supprimer</a> <a id="addtoshelf" href="#" onclick="window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes'); return false;">Ajouter à l'étagère</a> <a id="printbiblio" href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Imprimer</a>
	                
	                <!-- TMPL_IF NAME="norequests" --><!-- TMPL_ELSE --><a id="placehold" href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Réserver</a><!-- /TMPL_IF -->
	

    <br clear="all" /></div>
