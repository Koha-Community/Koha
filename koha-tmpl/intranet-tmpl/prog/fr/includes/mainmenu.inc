	<div class="yui-b">

    <ul id="navigation">
    <!-- TMPL_IF NAME="CAN_user_circulate" -->
   <li> <a href="/cgi-bin/koha/circ/circulation.pl">Circulation</a><ul>
       <li>
       <form method="post" action="/cgi-bin/koha/circ/circulation.pl">
        <label for="navfindborrower">Préter à :</label>
            <input id="navfindborrower" name="findborrower" type="text" size="10" />
            <input type="hidden" name="branch" value="<!-- TMPL_VAR name="branch" -->" />
            <input type="hidden" name="printer" value="<!-- TMPL_VAR name="printer" -->" />
            <input type="submit" class="submit" value="OK" />
       </form>
       </li>
       <li><a accesskey="r" href="/cgi-bin/koha/circ/returns.pl">Retours</a></li>
        <li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Transferts</a></li>
     </ul></li>
     <!-- /TMPL_IF -->

    <!-- TMPL_IF NAME="CAN_user_borrowers" -->
    <li><a href="/cgi-bin/koha/members/members-home.pl">Adhérents</a><ul>
        <li><form action="/cgi-bin/koha/members/member.pl" method="post">
           <label for="navmember">Chercher</label>
           <input id="navmember" type="text" size="10" name="member" />
           <input type="submit" value="OK" class="submit" />
            </form>
        </li>
    </ul></li>
    
    <!-- /TMPL_IF -->
                <!-- TMPL_IF NAME="CAN_user_catalogue" -->
                <li><a href="/cgi-bin/koha/catalogue/search.pl">Catalogue</a><ul>
                    <li>
                        <form name="searchform" method="get" action="/cgi-bin/koha/catalogue/search.pl" id="searchform">
                        <input type="hidden" name="idx" value="" />
                        <label for="navkeyword">
                            Chercher
                        </label><input type="text" id="navkeyword" name="q" size="10" accesskey="s" />
                        <input type="submit" value=" OK " class="submit" />
                        </form>
                     </li>
                    <li><a href="/cgi-bin/koha/virtualshelves/shelves.pl">Étagères virtuelles</a></li>
                </ul></li>
                
                <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_editcatalogue" -->
    <li><a href="/cgi-bin/koha/cataloguing/addbooks.pl">Catalogage</a><ul>
        <li><a href="/cgi-bin/koha/cataloguing/addbiblio.pl">Ajout notice</a></li>
        <li><a href="/cgi-bin/koha/authorities/authorities-home.pl">Autorités</a></li>
        <li><a href="/cgi-bin/koha/serials/serials-home.pl">Périodiques</a></li>
    </ul></li>
    
    <li><a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_reports" -->
          <li><a href="/cgi-bin/koha/reports/reports-home.pl">Bilans et statistiques</a></li>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_parameters" -->
   <li> <a href="/cgi-bin/koha/admin/admin-home.pl">Administration Koha</a><ul>
            <li><a href="/cgi-bin/koha/admin/systempreferences.pl">Préférences système</a></li>
        </ul></li>
        
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools" -->
    <li><a href="/cgi-bin/koha/tools/tools-home.pl">Outils</a></li>
    <!-- /TMPL_IF -->
    <li><a href="/cgi-bin/koha/about.pl">A propos de Koha</a></li>
	</ul>
    <!-- TMPL_IF NAME="IntranetNav" -->
        <!-- TMPL_VAR NAME="IntranetNav" -->
    <!-- /TMPL_IF -->
	
</div>
</div>