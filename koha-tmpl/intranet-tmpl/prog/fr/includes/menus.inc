<div id="kohalogo">
    <img src="/intranet-tmpl/prog/images/koha-logo.png" height="60px"/>
    <h3><a href="/cgi-bin/koha/mainpage.pl">Client Koha bibliothécaire</a></h3>
</div>
<div id="onlinehelp">
    <a href="#" onclick="javascript:window.open('/cgi-bin/koha/help.pl','Koha_Help','width=600,height=600,toolbar=false,scrollbars=yes');">[?]</a>
</div>
<div id="mainmenu">

    <!-- TMPL_IF NAME="CAN_user_circulate" -->
    <a href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
    <ul>
       <li>
       <form method="post" action="/cgi-bin/koha/circ/circulation.pl">
        <label for="navfindborrower">Préter à</label>
            <input id="navfindborrower" name="findborrower" type="text" size="10" />
            <input type="hidden" name="branch" value="<!-- TMPL_VAR name="branch" -->" />
            <input type="hidden" name="printer" value="<!-- TMPL_VAR name="printer" -->" />
            <input type="submit" class="submit" value="OK" />
       </form>
       </li>
       <li>
        <a accesskey="r" href="/cgi-bin/koha/circ/returns.pl">Retours</a>
       </li>
        <li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Transferts</a></li>
     </ul>
     <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_borrowers" -->
    <a href="/cgi-bin/koha/members/members-home.pl">Adhérents</a>
    <ul>
        <li><form action="/cgi-bin/koha/members/member.pl" method="post">
           <label for="navmember">Chercher</label>
           <input id="navmember" type="text" size="10" name="member" />
           <input type="submit" value="OK" class="submit" />
            </form>
        </li>
    </ul>
    <!-- /TMPL_IF -->
                <!-- TMPL_IF NAME="CAN_user_catalogue" -->
                <a href="/cgi-bin/koha/catalogue/search.pl">Catalogue</a>
                <ul>
                    <li>
                        <form name="searchform" method="get" action="/cgi-bin/koha/catalogue/search.pl" id="searchform">
                        <input type="hidden" name="idx" value="" />
                        <label for="navkeyword">
                            Chercher
                        </label><input type="text" id="navkeyword" name="q" size="10" accesskey="s" />
                        <input type="submit" value=" OK " class="submit" />
                        </form>
                     </li>
                    <li><a href="/cgi-bin/koha/bookshelves/shelves.pl">Étagères virtuelles</a></li>
                </ul>
                <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_editcatalogue" -->
    <a href="/cgi-bin/koha/cataloguing/addbooks.pl">Catalogage</a>
    <ul>
        <li><a href="/cgi-bin/koha/cataloguing/addbiblio.pl">Ajout notice</a></li>
        <li><a href="/cgi-bin/koha/authorities/authorities-home.pl">Autorités</a></li>
        <li><a href="/cgi-bin/koha/serials/serials-home.pl">Périodiques</a></li>
    </ul>
    <a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions</a>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_reports" -->
        <a href="/cgi-bin/koha/reports/reports-home.pl">Bilans et statistiques</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_parameters" -->
    <a href="/cgi-bin/koha/admin/admin-home.pl">Administration Koha</a>
        <ul>
            <li><a href="/cgi-bin/koha/admin/systempreferences.pl">Préférences système</a></li>
        </ul>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools" -->
    <a href="/cgi-bin/koha/tools/tools-home.pl">Outils</a>
    <!-- /TMPL_IF -->
    <a href="/cgi-bin/koha/about.pl">A propos de Koha</a>
    <div id="login">
        <!-- TMPL_IF NAME="loggedinusername" -->
        <ul>
        <li>
            <b> Information de connexion</b>
        </li>
        <li>Connecté en tant que : <b> <!-- TMPL_VAR NAME="loggedinusername" --> </b> à <b><!-- TMPL_VAR NAME="LoginBranchname" --></b></li>
            <!-- TMPL_IF NAME="AutoLocation" -->
                <li>autolocalisation activée</li>
        <!-- TMPL_ELSE -->
            <li><a href="/cgi-bin/koha/circ/selectbranchprinter.pl">Changer réglages</a></li>
        <!-- /TMPL_IF -->
        </ul>
        <ul>
            <li><a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Se déconnecter</a></li>
        </ul>
        <!-- /TMPL_IF -->
    </div>
    <!-- TMPL_IF NAME="IntranetNav" -->
        <!-- TMPL_VAR NAME="IntranetNav" -->
    <!-- /TMPL_IF -->
</div>
