<div id="menu">
        <ul>
            <!-- TMPL_VAR NAME="OpacNav" -->
            <li><a href="/cgi-bin/koha/opac-main.pl">Recherche simple</a></li>
            <li><a href="/cgi-bin/koha/opac-search.pl">Recherche avancée</a></li>
            <!-- TMPL_IF name="OpacBrowser" -->
                <li><a href="/cgi-bin/koha/opac-browser.pl">Feuilleter le catalogue</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacAuthorities" -->
                <li><a href="/cgi-bin/koha/opac-authorities-home.pl">Vedettes autorités</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacTopissue" -->
                <li><a href="/cgi-bin/koha/opac-topissues.pl">Palmarès</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacCloud" -->
                <li><a href="/cgi-bin/koha/opac-tags_subject.pl">Nuage de sujets</a></li>
            <!-- /TMPL_IF -->
            <li>
                <a href="#" onclick="javascript:openBasket();" title='Un "panier" pour vos sélections'>Panier<span id="basket">
                    <script language="javascript" type="text/javascript">
                        if(basketcount){ document.write(basketcount) };
                    </script></span>
                </a>
            </li>
            <!-- TMPL_IF NAME="loggedinusername" -->
                <!-- TMPL_IF name="virtualshelves" -->
                    <li><a href="/cgi-bin/koha/opac-shelves.pl">Etagères virtuelles</a></li>
                <!-- /TMPL_IF -->
                <!-- TMPL_IF name="suggestion" -->
                    <li><a href="opac-suggestions.pl">Suggestions</a></li>
                <!-- /TMPL_IF -->
            <!-- /TMPL_IF -->
        </ul>
        <br />
    <!-- TMPL_IF NAME="loggedinusername" -->
        <a href="/cgi-bin/koha/opac-user.pl"><b>Info utilisateur</b></a>
        <li>Connecté en tant que <b> <!-- TMPL_VAR NAME="loggedinusername" --> </b></li>
        <li><a href="/cgi-bin/koha/opac-logout.pl?logout=Log Out">Déconnexion</a></li>
    <!-- TMPL_ELSE -->
           <form action="/cgi-bin/koha/opac-user.pl" method="POST" name="auth" id="auth">
            <li>
                <label for="userid">Utilisateur</label>
                <input type="text" id="userid" size="10" name="userid" />
            </li>
            <li>
                <label for="password">Mot de passe </label>
                <input type="password" id="password" size="10" name="password" />
            </li>
            <li>
                <input type="submit" value="Se connecter" class="submit">
            </li>
            </form>
    <!-- /TMPL_IF -->
 </div>

 <div id="main"> <!-- MAIN Body start here -->
