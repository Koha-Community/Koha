    [% IF ( intranetbookbag ) %]<div id="cartDetails">Your cart is empty.</div>[% END %]

    <div id="header" class="clearfix">
        <div id="toplevelnav">
            <ul id="toplevelmenu">
                [% IF ( CAN_user_circulate ) %]<li><a class="toplinks" href="/cgi-bin/koha/circ/circulation-home.pl">Circulation</a></li>[% END %]
                [% IF ( CAN_user_borrowers ) %]<li><a class="toplinks" href="/cgi-bin/koha/members/members-home.pl">Patrons</a></li>[% END %]
                [% IF ( CAN_user_catalogue ) %]<li><a class="toplinks" href="/cgi-bin/koha/catalogue/search.pl">Search</a></li>[% END %]
                [% IF ( intranetbookbag ) %]
                    <li><a class="toplinks" href="#" id="cartmenulink">Cart<span id="basketcount"></span></a></li>
                [% END %]
                [% IntranetNav %]
                <li class="more">
                    <a class="toplinks" id="showmore" href="/cgi-bin/koha/mainpage.pl">More</a>
                    <div id="moremenu">
                        <div class="bd">
                            <ul>
                            <li><a href="/cgi-bin/koha/virtualshelves/shelves.pl">Lists</a></li>
                            [% IF ( CAN_user_editcatalogue_edit_catalogue || CAN_user_editcatalogue_edit_items ) %]
                            <li><a href="/cgi-bin/koha/cataloguing/addbooks.pl">Cataloging</a></li>
                            [% END %]
                            [% IF ( CAN_user_acquisition ) %]
                            <li><a href="/cgi-bin/koha/acqui/acqui-home.pl">Acquisitions</a></li>
                            [% END %]
                            [% IF ( CAN_user_editauthorities ) %]
                            <li><a href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a></li>
                            [% END %]
                            [% IF ( CAN_user_serials ) %]
                            <li><a href="/cgi-bin/koha/serials/serials-home.pl">Serials</a></li>
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
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    <div id="login_controls">
        [% IF ( AutoLocation ) %]
            <strong>
            [% LoginBranchname %]
            </strong>
        [% ELSE %]
            <strong>
            [% IF ( LoginBranchname == 'NO_LIBRARY_SET' ) %]
                NO LIBRARY SET
            [% ELSE %]
                [% LoginBranchname %]
            [% END %]
            </strong>
            [% IF ( IndependantBranches ) %]
                [% IF ( CAN_user_management || CAN_user_editcatalogue_edit_catalogue ) %]
                    ( <a class="toplinks" href="/cgi-bin/koha/circ/selectbranchprinter.pl">Set library</a> )
                [% END %]
            [% ELSE %]
                ( <a class="toplinks" href="/cgi-bin/koha/circ/selectbranchprinter.pl">Set library</a> )
            [% END %]
        |
        [% END %]
        [% IF ( loggedinusername ) %]
            <span class="loggedinusername">
                [% loggedinusername %]
            </span>
            [% IF ( intranetbookbag ) %]
            ( <a class="toplinks" href="/cgi-bin/koha/mainpage.pl?logout.x=1" onclick="clearHoldFor(); delBasket('main', true);">Log out</a> ) |
            [% ELSE %]
            ( <a class="toplinks" href="/cgi-bin/koha/mainpage.pl?logout.x=1" onclick="clearHoldFor();">Log out</a> ) |
            [% END %]
        [% ELSE %]
            You are not logged in |
        [% END %]
        <a class="toplinks" href="/cgi-bin/koha/help.pl" id="helper" onclick="var link=window.open('','Koha_Help','width=600,height=600,toolbar=false,scrollbars=yes'); link.location='/cgi-bin/koha/help.pl'; return false;">[ ? ]</a>
    </div>
</div>	
