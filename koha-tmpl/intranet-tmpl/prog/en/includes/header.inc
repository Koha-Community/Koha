[% USE Branches %]
<div id="header" class="navbar navbar-default">
    <div class="container-fluid">
        <ul id="toplevelmenu" class="nav navbar-nav">
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a href="/cgi-bin/koha/circ/circulation-home.pl">Circulation</a></li>[% END %]
            [% IF CAN_user_borrowers_edit_borrowers %]<li><a href="/cgi-bin/koha/members/members-home.pl">Patrons</a></li>[% END %]
            <li class="dropdown">
                <a href="/cgi-bin/koha/catalogue/search.pl" class="dropdown-toggle" data-toggle="dropdown">Search <b class="caret"></b></a>
                <ul class="dropdown-menu dropdown-menu-right">
                    [% IF ( CAN_user_catalogue ) %]<li><a href="/cgi-bin/koha/catalogue/search.pl">Advanced search</a></li>
                    <li><a href="/cgi-bin/koha/catalogue/itemsearch.pl">Item search</a></li>[% END %]
                </ul>
            </li>
            [% IF ( intranetbookbag ) %]
                <li>
                    <a href="#" id="cartmenulink">Cart<span id="basketcount"></span></a>
                </li>
            [% END %]
            [% IntranetNav %]
            <li class="dropdown">
                <a href="/cgi-bin/koha/mainpage.pl" class="dropdown-toggle" data-toggle="dropdown">More <b class="caret"></b></a>
                <ul class="dropdown-menu dropdown-menu-right">
                    <li><a href="/cgi-bin/koha/virtualshelves/shelves.pl">Lists</a></li>
                    [% IF ( CAN_user_editcatalogue_edit_catalogue || CAN_user_editcatalogue_edit_items ) %]
                        <li><a href="/cgi-bin/koha/cataloguing/addbooks.pl">Cataloging</a></li>
                    [% END %]
                    [% IF ( CAN_user_acquisition ) %]
                        <li><a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions</a></li>
                    [% END %]
                    <li><a href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a></li>
                    [% IF Koha.Preference('ILLModule') && CAN_user_ill %]
                        <li><a href="/cgi-bin/koha/ill/ill-requests.pl">ILL Requests</a></li>
                    [% END %]
                    [% IF ( CAN_user_serials ) %]
                        <li><a href="/cgi-bin/koha/serials/serials-home.pl">Serials</a></li>
                    [% END %]
                    [% IF ( UseCourseReserves ) %]
                        <li><a href="/cgi-bin/koha/course_reserves/course-reserves.pl">Course reserves</a></li>
                    [% END %]
                    [% IF ( CAN_user_reports ) %]
                        <li><a href="/cgi-bin/koha/reports/reports-home.pl">Reports</a></li>
                    [% END %]
                    [% IF ( CAN_user_tools ) %]
                        <li><a href="/cgi-bin/koha/tools/tools-home.pl">Tools</a></li>
                    [% END %]
                    [% IF ( CAN_user_parameters ) %]
                        <li><a href="/cgi-bin/koha/admin/admin-home.pl">Administration</a></li>
                    [% END %]
                    <li><a href="/cgi-bin/koha/about.pl">About Koha</a></li>
                </ul>
            </li>
        </ul>
        <ul class="nav navbar-nav navbar-right">
            [% IF ( loggedinusername ) %]
            <li class="dropdown">
                <a href="#" id="logged-in-menu" role="button" class="dropdown-toggle" data-toggle="dropdown">
                    <span id="logged-in-info-brief">
                        <i class="fa fa-user"></i>
                    </span>
                    <span id="logged-in-info-full">
                        <span class="loggedinusername">[% loggedinusername %]</span>
                        <span class="separator">|</span>
                        [% IF ( AutoLocation ) %]
                            <brand>
                                [% LoginBranchname %]
                            </brand>
                        [% ELSE %]
                            <strong>
                                [% IF ( LoginBranchname == 'NO_LIBRARY_SET' ) %]
                                    NO LIBRARY SET
                                [% ELSE %]
                                    <span class="logged-in-branch-name">[% LoginBranchname %]</span>
                                    <span class="logged-in-branch-code content_hidden">[% Branches.GetLoggedInBranchcode %]</span>
                                [% END %]
                            </strong>
                        [% END %]
                    </span>
                    <b class="caret"></b>
                </a>
                <ul class="dropdown-menu dropdown-menu-left" role="menu" aria-labelledby="logged-in-menu">

                    <li class="loggedin-menu-label">
                        Logged in as:<br />
                        <span class="loggedinusername">[% loggedinusername %]</span>
                    </li>
                    <li class="loggedin-menu-label">
                        [% IF ( AutoLocation ) %]
                            <brand>
                                [% LoginBranchname %]
                            </brand>
                        [% ELSE %]
                            [% IF ( LoginBranchname == 'NO_LIBRARY_SET' ) %]
                                NO LIBRARY SET
                            [% ELSE %]
                                Location: <br />
                                <span class="logged-in-branch-name">[% LoginBranchname %]</span>
                                <span class="logged-in-branch-code content_hidden">[% Branches.GetLoggedInBranchcode %]</span>
                            [% END %]
                        [% END %]
                    </li>

                    <li role="separator" class="loggedin-menu-label divider"></li>
                    [% IF ( IndependentBranches ) %]
                        [% IF ( CAN_user_management || CAN_user_editcatalogue_edit_catalogue ) %]
                    <li>
                        <a class="toplinks" href="/cgi-bin/koha/circ/selectbranchprinter.pl">Set library</a>
                    </li>
                        [% END %]
                    [% ELSE %]
                    <li>
                        <a class="toplinks" href="/cgi-bin/koha/circ/selectbranchprinter.pl">Set library</a>
                    </li>
                    [% END %]
                    [% IF EnableSearchHistory %]
                    <li>
                        <a class="toplinks" href="/cgi-bin/koha/catalogue/search-history.pl">Search history</a>
                    </li>
                    [% END %]
                    [% IF loggedinusernumber %]
                        <li class ="toplinks-myaccount">
                            <a class="toplinks" href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% loggedinusernumber %]">My account</a>
                        </li>
                        <li class="toplinks-mycheckouts">
                            <a class="toplinks" href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% loggedinusernumber %]">My checkouts</a>
                        </li>
                    [% END %]
                    <li>
                        <a id="logout" class="toplinks" href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log out</a>
                    </li>
                </ul>
            </li>
            [% INCLUDE 'langmenu-staff-top.inc' %]
            <li>
                <a class="toplinks" href="/cgi-bin/koha/help.pl" id="helper"><i class="fa fa-question-circle"></i> <span>Help</span></a>
            </li>
            [% ELSE %]
            <li class="loggedout">
                <span>
                    <a href="/cgi-bin/koha/mainpage.pl" id="login">Log in</a>
                    <span class="separator">|</span>
                    <a class="toplinks" href="/cgi-bin/koha/help.pl" id="helper"><i class="fa fa-question-circle"></i> <span>Help</span></a>
                </span>
            </li>
            [% END %]
        </ul>
    </div>
    [% IF ( intranetbookbag ) %]<div id="cartDetails">Your cart is empty.</div>[% END %]
</div>
