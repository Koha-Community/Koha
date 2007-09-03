    <div id="action">
            
            <div class="edit">
                <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&frameworkcode=<!--TMPL_VAR Name="current_framework" -->&op="> Modifier notice </a> <a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&frameworkcode=<!--TMPL_VAR Name="current_framework" -->&op=duplicate"> Dupliquer </a> <a href="/cgi-bin/koha/cataloguing/additem.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->"> Modifier exemplaires </a> <a href="javascript:confirm_deletion(<!-- TMPL_VAR NAME="count" -->)"> Supprimer </a>
            </div>
            
            <div class="view">
                <a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Complète</a> <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Normale</a> <a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">ISBD</a>
            </div>
            
            <div class="others">
                <a href="#" onclick="JavaScript:window.open('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->','Add_to_virtualshelf','width=500,height=400,toolbar=false,scrollbars=yes'); return false;"> Ajouter à l'étagère</a> <a href="/cgi-bin/koha/catalogue/detailprint.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">Imprimer</a>
                <!-- TMPL_IF name="subscriptionsnumber" -->
                <a href="/cgi-bin/koha/serials/serials-home.pl?searched=1&title_filter=<!-- TMPL_VAR NAME="subscriptiontitle" -->">
                    Abonnement(s)
                </a>
                <!-- /TMPL_IF -->
                <!-- TMPL_IF NAME="norequests" -->
                <!-- TMPL_ELSE -->
                    <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->">
                        Réservation
                    </a>
                <!-- /TMPL_IF -->
                
                <a href="/cgi-bin/koha/catalogue/issuehistory.pl?biblionumber=<!-- TMPL_VAR NAME="biblionumber" -->&title=<!-- TMPL_VAR NAME="title"-->&author=<!-- TMPL_VAR NAME="author"-->" >
                    Historique de circulation
                </a>
  
                <!-- TMPL_IF NAME="CAN_user_parameters"-->
               <a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&module=CATALOGUING&action=MODIFY&object=<!-- TMPL_VAR NAME="biblionumber"-->">Log des modifications</a>
                <!-- /TMPL_IF --> 
            </div>
    </div>
