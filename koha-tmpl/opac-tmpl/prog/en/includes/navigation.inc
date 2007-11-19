<div id="menu">
            
            <ul>
            <!-- TMPL_VAR NAME="OpacNav" -->
            <li><a href="/cgi-bin/koha/opac-main.pl">Search Home</a></li>
            <li><a href="/cgi-bin/koha/opac-search.pl">Advanced Search</a></li>
			  <!-- TMPL_IF NAME="opacbookbag"-->
            <li>
                <a href="#" onclick="javascript:openBasket();" title="A &quot;shopping cart&quot; for your selections">Book Bag<span id="basket">
                    <script language="javascript" type="text/javascript">
                        if(basketcount){ document.write(basketcount) };
                    </script></span>
                </a>
            </li>
            <!-- /TMPL_IF -->          
            <!-- TMPL_IF NAME="loggedinusername" -->
                <!-- TMPL_IF name="virtualshelves" -->
                    <li><a href="/cgi-bin/koha/opac-shelves.pl">Virtual Shelves</a></li>
                <!-- /TMPL_IF -->
                <!-- TMPL_IF name="suggestion" -->
                    <li><a href="opac-suggestions.pl">Suggestions</a></li>
                <!-- /TMPL_IF -->
            <!-- /TMPL_IF -->
            <li>Browse catalogue: <ul> <!-- TMPL_IF name="OpacBrowser" -->
                <li><a href="/cgi-bin/koha/opac-browser.pl">by hierarchy</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacAuthorities" -->
                <li><a href="/cgi-bin/koha/opac-authorities-home.pl">by headings</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacTopissue" -->
                <li><a href="/cgi-bin/koha/opac-topissues.pl">by top issues</a></li>
            <!-- /TMPL_IF -->
            <!-- TMPL_IF name="OpacCloud" -->
                <li><a href="/cgi-bin/koha/opac-tags_subject.pl">by cloud</a></li>
            <!-- /TMPL_IF --></ul></li>
            </ul>
            
 </div>
