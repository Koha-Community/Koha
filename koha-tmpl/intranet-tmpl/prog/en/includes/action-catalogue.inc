    <div id="action">
            
            <div class="edit">
<ul>
	<li>                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=">Edit biblio</a></li>
	<li>                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;frameworkcode=<!--TMPL_VAR Name="current_framework" -->&amp;op=duplicate">Duplicate</a></li>
	<li>                <a href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Edit item</a></li>
	<li>                <a href="javascript:confirm_deletion(<!-- TMPL_VAR NAME="count" -->)">Delete</a></li>
</ul>
            </div>
            
            <div class="view">
<ul>
	<li>                <a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Complete</a></li>
	<li>                <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Normal</a></li>
	<li>                <a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">ISBD</a></li>
</ul>
            </div>
            
            <div class="others">
<ul>
	<li>                <a href="#" onclick="window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes'); return false;">Add to shelf</a></li>
	<li>                <a href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Print</a></li>
	                <!-- TMPL_IF name="subscriptionsnumber" --><li><a href="/cgi-bin/koha/serials/serials-home.pl?searched=1&amp;title_filter=<!-- TMPL_VAR NAME="subscriptiontitle" -->">Subscription(s)</a></li><!-- /TMPL_IF -->
	                <!-- TMPL_IF NAME="norequests" --><!-- TMPL_ELSE --><li><a href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Request</a></li><!-- /TMPL_IF -->
	<li>                <a href="/cgi-bin/koha/catalogue/issuehistory.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&amp;title=<!-- TMPL_VAR NAME="title"-->&amp;author=<!-- TMPL_VAR NAME="author"-->" >Circulation history</a></li>
	                  <!-- TMPL_IF NAME="CAN_user_parameters"--><li><a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;module=CATALOGUING&amp;action=MODIFY&amp;object=<!-- TMPL_VAR NAME="biblionumber"-->">Modification log</a> </li><!-- /TMPL_IF -->
</ul>
            </div>
    </div>
