<div id="onlinehelp">
    <a href="#" onclick="javascript:window.open('/cgi-bin/koha/help.pl','Koha_Help','width=600,height=600,toolbar=false,scrollbars=yes');">[?]</a>
</div>
<div id="mainmenu">
<h3><a href="/cgi-bin/koha/mainpage.pl">Koha Staff Client</a></h3>
    <!-- TMPL_IF NAME="CAN_user_circulate" -->
    <a href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
    <ul>
       <li>
       <form method="post" action="/cgi-bin/koha/circ/circulation.pl">
        <label for="navfindborrower">Iss<span class="accesskey">u</span>e to:</label>
            <input id="navfindborrower" name="findborrower" type="text" size="10" accesskey="u" />
            <input type="hidden" name="branch" value="<!-- TMPL_VAR name="branch" -->" />
            <input type="hidden" name="printer" value="<!-- TMPL_VAR name="printer" -->" />
            <input type="submit" class="submit" value="OK" />
       </form>
       </li>
       <li>
        <a accesskey="r" href="/cgi-bin/koha/circ/returns.pl"><span class="accesskey">R</span>eturns</a>
       </li>
        <li><a href="/cgi-bin/koha/circ/branchtransfers.pl">Transfers</a></li>
     </ul>
     <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_borrowers" -->
    <a href="/cgi-bin/koha/members/members-home.pl">Borrowers</a>
    <ul>
        <li><form action="/cgi-bin/koha/members/member.pl" method="post">
           <label for="navmember">Sear<span class="accesskey">c</span>h:&nbsp;</label>
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
                            <span class="accesskey">S</span>earch:&nbsp;
                        </label><input type="text" id="navkeyword" name="q" size="10" accesskey="s" />
                        <input type="submit" value=" OK " class="submit" />
                        </form>
                     </li>
                    <li><a href="/cgi-bin/koha/bookshelves/shelves.pl">Virtual Shelves</a></li>
                    <li><a href="/cgi-bin/koha/reviews/reviewswaiting.pl">Reviews</a></li>
                </ul>
                <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_editcatalogue" -->
    <a href="/cgi-bin/koha/cataloguing/addbooks.pl">Cataloguing</a>
    <ul>
        <li><a href="/cgi-bin/koha/cataloguing/addbiblio.pl">Add MARC</a></li>
        <li><a href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a></li>
        <li><a href="/cgi-bin/koha/serials/serials-home.pl">Serials</a></li>
        <li><a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions</a></li>
    </ul>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_catalogue" -->
    <ul>
    <li><a href="/cgi-bin/koha/reports/reports-home.pl">Reports</a></li>
    </ul>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_parameters" -->
    <a href="/cgi-bin/koha/admin/admin-home.pl">Koha administration</a>
        <ul>
            <li><a href="/cgi-bin/koha/admin/systempreferences.pl">System preferences</a></li>
        </ul>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="CAN_user_tools" -->
    <a href="/cgi-bin/koha/tools/tools-home.pl">Tools</a>
    <!-- /TMPL_IF -->
    <a href="/cgi-bin/koha/about.pl">About Koha</a>
    <!-- TMPL_IF NAME="loggedinusername" -->
    <ul>
    <li>
        <b> Login information</b> :
    </li>
    </ul>
    <ul>
     <li>Logged in as: <b> <!-- TMPL_VAR NAME="loggedinusername" --> </b></li>
        <li> Library : <b><!-- TMPL_VAR NAME="LoginBranchname" --></b></li>
        <!-- TMPL_IF NAME="AutoLocation" -->
            <li>autolocate activated</li>
    <!-- TMPL_ELSE -->
        <li><a href="/cgi-bin/koha/circ/selectbranchprinter.pl">Change Settings</a></li>
    <!-- /TMPL_IF -->
    </ul>
    
    <ul>
        <li><a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a></li>
    </ul>
    <!-- /TMPL_IF -->
    <!-- TMPL_IF NAME="IntranetNav" -->
        <!-- TMPL_VAR NAME="IntranetNav" -->
    <!-- /TMPL_IF -->
</div>
