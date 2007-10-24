<div id="menu">
			
            <!-- TMPL_VAR NAME="OpacNav" -->
            <li><a href="/cgi-bin/koha/opac-main.pl">Recherche simple</a></li>
            <li><a href="/cgi-bin/koha/opac-search.pl">Recherche avancée</a></li>
            <li>Feuilleter le catalogue :</li>
            
            <ul>
            <!-- TMPL_IF name="OpacBrowser" -->
                <li><a href="/cgi-bin/koha/opac-browser.pl">par hiérarchie</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacAuthorities" -->
                <li><a href="/cgi-bin/koha/opac-authorities-home.pl">par autorités</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacTopissue" -->
                <li><a href="/cgi-bin/koha/opac-topissues.pl">par palmarès</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacCloud" -->
                <li><a href="/cgi-bin/koha/opac-tags_subject.pl">par nuage sujet</a></li>
            <!-- /TMPL_IF -->
            
            <!-- TMPL_IF NAME="opacbookbag"-->
            <li>
                <a href="#" onclick="javascript:openBasket();" title='Un "panier" pour vos sélections'>Panier<span id="basket">
                    <script language="javascript" type="text/javascript">
                        if(basketcount){ document.write(basketcount) };
                    </script></span>
                </a>
            </li>
            </ul>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF NAME="loggedinusername" -->
                <!-- TMPL_IF name="virtualshelves" -->
                    <li><a href="/cgi-bin/koha/opac-shelves.pl">Etagères virtuelles</a></li>
                <!-- /TMPL_IF -->
                <!-- TMPL_IF name="suggestion" -->
                    <li><a href="opac-suggestions.pl">Suggestions</a></li>
                <!-- /TMPL_IF -->
            <!-- /TMPL_IF -->
            
 </div>

 <div id="main"> <!-- MAIN Body start here -->
