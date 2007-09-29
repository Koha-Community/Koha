<div id="toolbar"><ul class="toolbar">
	<li>                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=">Edit biblio</a></li>
	<li>                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=duplicate">Duplicate</a></li>
	<li>                <a href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Edit item</a></li>
	<li>                <a href="javascript:confirm_deletion(<!-- TMPL_VAR NAME="count" -->)">Delete</a></li>

	<li>                <a href="#" onclick="window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes'); return false;">Add to shelf</a></li>
	<li>                <a href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Print</a></li>
	                
	                <!-- TMPL_IF NAME="norequests" --><!-- TMPL_ELSE --><li><a href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Request</a></li><!-- /TMPL_IF -->
	
</ul>
    <br clear="all" /></div>
