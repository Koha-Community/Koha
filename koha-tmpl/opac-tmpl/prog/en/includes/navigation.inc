<div id="menu">
        <ul>
            <!-- TMPL_VAR NAME="OpacNav" -->
            <li><a href="/cgi-bin/koha/opac-main.pl">Search Home</a></li>
            <li><a href="/cgi-bin/koha/opac-search.pl">Advanced Search</a></li>
            <!-- TMPL_IF name="OpacBrowser" -->
                <li><a href="/cgi-bin/koha/opac-browser.pl">Browse Catalogue</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacAuthorities" -->
                <li><a href="/cgi-bin/koha/opac-authorities-home.pl">Authorities Headings</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacTopissue" -->
                <li><a href="/cgi-bin/koha/opac-topissues.pl">Top Issues</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacCloud" -->
                <li><a href="/cgi-bin/koha/opac-tags_subject.pl">Subject Cloud</a></li>
            <!-- /TMPL_IF -->
            <li>
                <a href="#" onclick="javascript:openBasket();" title="A &quot;shopping cart&quot; for your selections">Book Bag<span id="basket">
                    <script language="javascript" type="text/javascript">
                        if(basketcount){ document.write(basketcount) };
                    </script></span>
                </a>
            </li>
            <!-- TMPL_IF NAME="loggedinusername" -->
                <!-- TMPL_IF name="virtualshelves" -->
                    <li><a href="/cgi-bin/koha/opac-shelves.pl">Virtual Shelves</a></li>
                <!-- /TMPL_IF -->
                <!-- TMPL_IF name="suggestion" -->
                    <li><a href="opac-suggestions.pl">Suggestions</a></li>
                <!-- /TMPL_IF -->
            <!-- /TMPL_IF -->
        </ul>
        <br />
    <div id="login">
        <!-- TMPL_IF NAME="loggedinusername" -->
            <a href="/cgi-bin/koha/opac-user.pl"><b>User Info</b></a>
            <li>Logged in as: <b> <!-- TMPL_VAR NAME="loggedinusername" --> </b></li>
            <li><a href="/cgi-bin/koha/opac-logout.pl?logout=Log Out">Log Out</a></li>
        <!-- TMPL_ELSE -->
            <form action="/cgi-bin/koha/opac-user.pl" method="POST" name="auth" id="auth">
                <li>
                    <label for="userid">Login:</label>
                    <input type="text" id="userid" size="10" name="userid" />
                </li>
                <li>
                    <label for="password">Pass: </label>
                    <input type="password" id="password" size="10" name="password" />
                </li>
                <li>
                    <input type="submit" value="Log In" class="submit" />
                </li>
                </form>
        <!-- /TMPL_IF -->
    </div>
 </div>

 <div id="main"> <!-- MAIN Body start here -->
