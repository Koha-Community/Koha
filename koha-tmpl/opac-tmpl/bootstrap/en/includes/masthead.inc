[% USE Koha %]
[% USE Branches %]
[% SET OpacLangSelectorMode = Koha.Preference('OpacLangSelectorMode') %]
<div id="wrap">
    <div id="header-region" class="noprint">
        <div class="navbar navbar-inverse navbar-static-top">
            <div class="navbar-inner">
                <div class="container-fluid">
                    <h1 id="logo">
                        <a class="brand" href="/cgi-bin/koha/opac-main.pl">
                            [% IF ( LibraryNameTitle ) %]
                                [% LibraryNameTitle %]
                            [% ELSE %]
                                Koha online
                            [% END %]
                        </a>
                    </h1>
                    [% IF ( Koha.Preference( 'opacbookbag' ) == 1 ) %]
                        <div id="cartDetails" class="cart-message">Your cart is empty.</div>
                    [% END %]
                    <ul class="nav">
                        [% IF ( Koha.Preference( 'opacbookbag' ) == 1 ) %]
                            <li class="dropdown">
                                <a href="#" title="Collect items you are interested in" class="dropdown-toggle" id="cartmenulink" data-toggle="dropdown" role="button">
                                    <i id="carticon" class="icon-shopping-cart icon-white"></i> <span class="cartlabel">Cart</span> <span id="basketcount"></span> <b class="caret"></b>
                                </a>
                                <ul aria-labelledby="cartmenulink" role="menu" class="dropdown-menu">
                                    <li role="presentation">
                                        <a href="#" id="cartmenuitem" class="cart-message" tabindex="-1" role="menuitem">Your cart is empty.</a>
                                    </li>
                                </ul>
                            </li>
                        [% END %]
                        [% IF ( Koha.Preference( 'virtualshelves' ) == 1 ) && ( Koha.Preference( 'opacbookbag' ) == 1 ) %]
                            <li class="divider-vertical"></li>
                        [% END %]
                        [% IF ( Koha.Preference( 'virtualshelves' ) == 1 ) %]
                            <li class="dropdown">
                                <a href="#" title="Show lists" class="dropdown-toggle" id="listsmenu" data-toggle="dropdown" role="button"><i class="icon-list icon-white"></i> <span class="listslabel">Lists</span> <b class="caret"></b></a>
                                <ul aria-labelledby="listsmenu" role="menu" class="dropdown-menu">
                                [% IF some_public_shelves.count %]
                                    <li role="presentation"><a href="/cgi-bin/koha/opac-shelves.pl?op=list&amp;category=2" tabindex="-1" role="menuitem"><strong>Public lists</strong></a></li>
                                    [% SET number_of_public_shelves = 0 %]
                                    [% FOREACH s IN some_public_shelves %]
                                        <li role="presentation"><a href="/cgi-bin/koha/opac-shelves.pl?op=view&amp;shelfnumber=[% s.shelfnumber %]&amp;sortfield=[% s.sortfield %]" tabindex="-1" role="menuitem">[% s.shelfname |html %]</a></li>
                                        [% SET number_of_public_shelves = number_of_public_shelves + 1 %]
                                        [% IF number_of_public_shelves >= 10 %][% LAST %][% END %]
                                    [% END %]
                                    [% IF some_public_shelves > 10 %]
                                        <li role="presentation"><a href="/cgi-bin/koha/opac-shelves.pl?op=list&amp;category=2" tabindex="-1" role="menuitem" class="listmenulink">View All</a></li>
                                    [% END %]
                                [% ELSE %]
                                    <li role="presentation"><a href="#" tabindex="-1" class="menu-inactive" role="menuitem">No public lists</a></li>
                                [% END %]
                                <li class="divider" role="presentation"></li>
                                [% IF Koha.Preference( 'opacuserlogin' ) == 1 %]
                                    <li role="presentation"><a href="/cgi-bin/koha/opac-shelves.pl?op=list&amp;category=1" tabindex="-1" role="menuitem"><strong>Your lists</strong></a></li>
                                    [% IF loggedinusername %]
                                        [% IF some_private_shelves.count %]
                                            [% SET number_of_private_shelves = 0 %]
                                            [% FOREACH s IN some_private_shelves %]
                                                <li role="presentation"><a href="/cgi-bin/koha/opac-shelves.pl?op=view&amp;shelfnumber=[% s.shelfnumber %]&amp;sortfield=[% s.sortfield %]" tabindex="-1" role="menuitem">[% s.shelfname |html %]</a></li>
                                                [% SET number_of_private_shelves = number_of_private_shelves + 1 %]
                                                [% IF number_of_private_shelves >= 10 %][% LAST %][% END %]
                                            [% END %]
                                            [% IF some_private_shelves > 10 %]
                                                <li role="presentation"><a href="/cgi-bin/koha/opac-shelves.pl?op=list&amp;category=1" tabindex="-1" role="menuitem" class="listmenulink">View All</a></li>
                                            [% END %]
                                        [% ELSE %]
                                            <li role="presentation"><a href="#" tabindex="-1" class="menu-inactive" role="menuitem">No private lists</a></li>
                                        [% END %]
                                            <li role="presentation"><a href="/cgi-bin/koha/opac-shelves.pl?op=add_form" tabindex="-1" role="menuitem" class="listmenulink">New list</a></li>
                                    [% ELSE %]
                                        [% IF Koha.Preference('casAuthentication') %]
                                            [%# CAS authentication is too complicated for modal window %]
                                            <li role="presentation"><a href="/cgi-bin/koha/opac-user.pl" tabindex="-1" class="menu-inactive" role="menuitem">Log in to create your own lists</a></li>
                                        [% ELSE %]
                                            <li role="presentation"><a href="/cgi-bin/koha/opac-user.pl" tabindex="-1" class="menu-inactive loginModal-trigger" role="menuitem">Log in to create your own lists</a></li>
                                        [% END %]
                                    [% END # / IF loggedinusername %]
                                [% END # / IF opacuserlogin %]
                                </ul> <!-- / .dropdown-menu -->
                            </li> <!-- / .dropdown -->
                        [% END # / IF virtualshelves %]
                    </ul> <!-- / .nav -->
                    [% IF Koha.Preference( 'virtualshelves' ) == 1 %]<div id="listsDetails"></div>[% END %]
                    [% IF Koha.Preference( 'opacuserlogin' ) == 1 || opaclanguagesdisplay || EnableOpacSearchHistory %]
                        <a id="user-menu-trigger" class="pull-right" href="#"><i class="icon-user"></i> <span class="caret"></span></a>
                        <div id="members">
                            <ul class="nav pull-right">

                                [% INCLUDE 'masthead-langmenu.inc' %]

                                [% IF Koha.Preference( 'opacuserlogin' ) == 1 %]
                                    [% UNLESS ( loggedinusername ) %]
                                        [% IF Koha.Preference('casAuthentication') %]
                                            [%# CAS authentication is too complicated for modal window %]
                                            <li><a class="login-link" href="/cgi-bin/koha/opac-user.pl">Log in to your account</a></li>
                                        [% ELSIF ( Koha.Preference('GoogleOpenIDConnect') == 1 ) %]
                                            <li><a class="login-link" href="/cgi-bin/koha/svc/auth/googleopenidconnect" role="button" data-toggle="modal">Log in to your account</a></li>
                                        [% ELSE %]
                                            <li><a href="/cgi-bin/koha/opac-user.pl" class="login-link loginModal-trigger" role="button" data-toggle="modal">Log in to your account</a></li>
                                        [% END %]
                                    [% END %]
                                    [% IF ( loggedinusername ) %]
                                        <li><p class="members navbar-text">Welcome, <a class="login-link" href="/cgi-bin/koha/opac-user.pl"><span class="loggedinusername">[% USER_INFO.title %] [% USER_INFO.firstname %] [% USER_INFO.surname %]</span></a></p></li>
                                        <li class="divider-vertical"></li>
                                    [% END %]
                                [% END %]
                                [% IF EnableOpacSearchHistory %]
                                    <li><p class="navbar-text"><a class="login-link" href="/cgi-bin/koha/opac-search-history.pl" title="View your search history">Search history</a> [<a class="logout clearsh" href="/cgi-bin/koha/opac-search-history.pl?action=delete" title="Delete your search history">x</a>]</p></li>
                                    <li class="divider-vertical"></li>
                                [% END %]
                                [% IF Koha.Preference( 'opacuserlogin' ) == 1 %]
                                    [% IF ( loggedinusername ) %]
                                        <li><p class="navbar-text">
                                            <a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">
                                            Log out</a></p></li>
                                    [% END %]
                                [% END %]
                            </ul>
                        </div> <!-- /members -->
                    [% END # IF opacuserlogin %]
                </div> <!-- /container-fluid -->
            </div> <!-- /navbar-inner -->
        </div> <!-- /navbar -->

        [% IF ( opacheader ) %]
            <div class="container-fluid">
                <div class="row-fluid">
                    <div id="opacheader">
                        [% opacheader %]
                    </div>
                </div>
            </div>
        [% END %]
    </div> <!-- / header-region -->

    <div class="container-fluid">
        <div class="row-fluid">
            <div id="opac-main-search">
            <div class="span12">
                [% IF ( OpacPublic ) %]
                    [% UNLESS ( advsearch ) %]
                        [% IF ( Koha.Preference( 'OpacAddMastheadLibraryPulldown' ) == 1 ) %]
                            <div class="mastheadsearch librarypulldown">
                        [% ELSE %]
                            <div class="mastheadsearch">
                        [% END %]
                        [% IF Koha.Preference('OpacCustomSearch') == '' %]
                            <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform" class="form-inline">
                                <label for="masthead_search"> Search
                                    [% UNLESS ( Koha.Preference( 'OpacAddMastheadLibraryPulldown' ) == 1 ) %]
                                        [% IF ( mylibraryfirst ) %]
                                            (in [% Branches.GetName( mylibraryfirst ) %] only)
                                        [% END %]
                                    [% END %]
                                </label>

                                <select name="idx" id="masthead_search">
                                [% IF ( ms_kw ) %]
                                    <option selected="selected" value="">Library catalog</option>
                                [% ELSE %]
                                    <option value="">Library catalog</option>
                                [% END # /ms_kw %]
                                [% IF ( ms_ti ) %]
                                    <option selected="selected" value="ti">Title</option>
                                [% ELSE %]
                                    <option value="ti">Title</option>
                                [% END # /ms_ti %]
                                [% IF ( ms_au ) %]
                                    <option selected="selected" value="au">Author</option>
                                [% ELSE %]
                                    <option value="au">Author</option>
                                [% END # /ms_au%]
                                [% IF ( ms_su ) %]
                                    <option selected="selected" value="su">Subject</option>
                                [% ELSE %]
                                    <option value="su">Subject</option>
                                [% END # /ms_su %]
                                [% IF ( ms_nb ) %]
                                    <option selected="selected" value="nb">ISBN</option>
                                [% ELSE %]
                                    <option value="nb">ISBN</option>
                                [% END # /ms_nb%]
                                [% IF ( ms_se ) %]
                                    <option selected="selected" value="se">Series</option>
                                [% ELSE %]
                                    <option value="se">Series</option>
                                [% END # /ms_se %]
                                [% IF ( Koha.Preference('OPACNumbersPreferPhrase') ) %]
                                    [% IF ( ms_callnum ) %]
                                            <option selected="selected" value="callnum,phr">Call number</option>
                                    [% ELSE %]
                                        <option value="callnum,phr">Call number</option>
                                    [% END #/ms_callnum %]
                                [% ELSE %]
                                    [% IF ( ms_callnum ) %]
                                        <option selected="selected" value="callnum">Call number</option>
                                    [% ELSE %]
                                        <option value="callnum">Call number</option>
                                    [% END # /ms_callnum %]
                                [% END # /IF OPACNumbersPreferPhrase %]
                                </select>

                                [% UNLESS ( Koha.Preference( 'OpacAddMastheadLibraryPulldown' ) == 1 ) %]
                                    <div class="input-append nolibrarypulldown">
                                [% END %]
                                [% IF ( ms_value ) %]
                                    <input type="text" title="Type search term" class="transl1" id = "translControl1" name="q" value="[% ms_value |html %]" /><span id="translControl"></span>
                                [% ELSE %]
                                    <input type="text" title="Type search term" class="transl1" id = "translControl1" name="q" /><span id="translControl"></span>
                                [% END # /ms_value %]

                                [% UNLESS ( Koha.Preference( 'OpacAddMastheadLibraryPulldown' ) == 1 ) %]
                                    <button type="submit" id="searchsubmit" class="btn btn-primary">Go</button>
                                    </div>
                                [% END %]

                                [% IF ( Koha.Preference( 'OpacAddMastheadLibraryPulldown' ) == 1 ) %]
                                    <div class="input-append">
                                        <select name="branch_group_limit" id="select_library">
                                            <option value="">All libraries</option>

                                            [% IF LibrarySearchGroups %]<optgroup label="Libraries">[% END %]

                                            [% FOREACH BranchesLoo IN BranchesLoop %]
                                                [% IF ( BranchesLoo.selected ) %]<option selected="selected" value="branch:[% BranchesLoo.value %]">[% BranchesLoo.branchname %]</option>
                                                [% ELSE %]<option value="branch:[% BranchesLoo.value %]">[% BranchesLoo.branchname %]</option>[% END %]
                                            [% END %]

                                            [% IF LibrarySearchGroups %]
                                                </optgroup>
                                                <optgroup label="Groups">
                                                    [% FOREACH lsg IN LibrarySearchGroups %]
                                                        [% IF lsg.id == opac_name %]
                                                            <option selected="selected" value="multibranchlimit-[% lsg.id %]">[% lsg.title %]</option>
                                                        [% ELSE %]
                                                            <option value="multibranchlimit-[% lsg.id %]">[% lsg.title %]</option>
                                                        [% END # / bc.selected %]
                                                    [% END %]
                                                </optgroup>
                                            [% END # / BranchCategoriesLoop %]
                                        </select>
                                        <button type="submit" id="searchsubmit" class="btn btn-primary">Go</button>
                                    </div>
                                [% ELSE %]
                                    [% IF ( opac_limit_override ) %]
                                        [% IF ( opac_search_limit ) %]
                                            <input name="limit" value="[% opac_search_limit %]" type="hidden" />
                                        [% END %]
                                    [% ELSE %]
                                        [% IF ( mylibraryfirst ) %]
                                            <input name="limit" value="branch:[% mylibraryfirst %]" type="hidden" />
                                        [% END %]
                                    [% END # / opac_limit_override %]
                                [% END # / OpacAddMastheadLibraryPulldown %]

                            </form>
                        [% ELSE # / Koha.Preference('OpacCustomSearch') == '' %]
                            [% Koha.Preference('OpacCustomSearch') %]
                        [% END # / Koha.Preference('OpacCustomSearch') == '' %]
                        </div> <!-- / .mastheadsearch -->
                    [% END # / UNLESS advsearch %]

                    <div class="row-fluid">
                            <div id="moresearches">
                                <ul>
                                    <li><a href="/cgi-bin/koha/opac-search.pl">Advanced search</a></li>
                                    [% IF ( Koha.Preference( 'UseCourseReserves' ) == 1 ) %]<li><a href="/cgi-bin/koha/opac-course-reserves.pl">Course reserves</a></li>[% END %]
                                    [% IF Koha.Preference( 'OpacBrowser' ) == 1 %]<li><a href="/cgi-bin/koha/opac-browser.pl">Browse by hierarchy</a></li>[% END %]
                                    [% IF Koha.Preference( 'OpacAuthorities' ) == 1 %]<li><a href="/cgi-bin/koha/opac-authorities-home.pl">Authority search</a></li>[% END %]
                                    [% IF ( ( Koha.Preference( 'opacuserlogin' ) == 1 ) && ( Koha.Preference( 'reviewson' ) == 1 ) && ( Koha.Preference( 'OpacShowRecentComments' ) == 1 ) ) %]<li><a href="/cgi-bin/koha/opac-showreviews.pl">Recent comments</a></li>[% END %]
                                    [% IF Koha.Preference( 'TagsEnabled' ) == 1 %]<li><a href="/cgi-bin/koha/opac-tags.pl">Tag cloud</a></li>[% END %]
                                    [% IF Koha.Preference( 'OpacCloud' ) == 1 %]<li><a href="/cgi-bin/koha/opac-tags_subject.pl">Subject cloud</a></li>[% END %]
                                    [% IF Koha.Preference( 'OpacTopissue' ) == 1 %]<li><a href="/cgi-bin/koha/opac-topissues.pl">Most popular</a></li>[% END %]
                                    [% IF Koha.Preference( 'suggestion' ) == 1 %]
                                        [% IF Koha.Preference( 'AnonSuggestions' ) == 1 %]
                                            <li><a href="/cgi-bin/koha/opac-suggestions.pl">Purchase suggestions</a></li>
                                        [% ELSIF ( ( Koha.Preference( 'OPACViewOthersSuggestions' ) == 1 ) ) %]
                                            <li><a href="/cgi-bin/koha/opac-suggestions.pl">Purchase suggestions</a></li>
                                        [% END %]
                                    [% END %]
                                </ul>
                            </div> <!-- /#moresearches -->
                    </div> <!-- /.row-fluid -->

                [% END # / OpacPublic %]
            </div> <!-- /.span10 -->
            </div> <!-- /.opac-main-search -->
        </div> <!-- / .row-fluid -->
    </div> <!-- /.container-fluid -->

    <!-- Login form hidden by default, used for modal window -->
    <div id="loginModal" class="modal hide" tabindex="-1" role="dialog" aria-labelledby="modalLoginLabel" aria-hidden="true">
        <div class="modal-header">
            <button type="button" class="closebtn" data-dismiss="modal" aria-hidden="true">×</button>
            <h3 id="modalLoginLabel">Log in to your account</h3>
        </div>
        <form action="/cgi-bin/koha/opac-user.pl" method="post" name="auth" id="modalAuth">
            <div class="modal-body">
                [% IF ( shibbolethAuthentication ) %]
                    [% IF ( invalidShibLogin ) %]
                        <!-- This is what is displayed if shibboleth login has failed to match a koha user -->
                        <div class="alert alert-info">
                            <p>Sorry, your Shibboleth identity does not match a valid library identity. If you have a local login, you may use that below.</p>
                        </div>
                    [% ELSE %]
                        <h4>Shibboleth login</h4>
                        <p>If you have a Shibboleth account, please <a href="[% shibbolethLoginUrl %]">click here to login</a>.</p>
                        <h4>Local Login</h4>
                    [% END %]
                [% END %]
                <input type="hidden" name="koha_login_context" value="opac" />
                <fieldset class="brief">
                    <label for="muserid">Login:</label><input type="text" id="muserid" name="userid" />
                    <label for="mpassword">Password:</label><input type="password" id="mpassword" name="password" />
                    [% IF Koha.Preference( 'OpacLoginInstructions' ) %]
                        <div id="nologininstructions-modal" class="nologininstructions">
                            [% Koha.Preference( 'OpacLoginInstructions' ) %]
                        </div>
                    [% END %]
                    [% IF Koha.Preference('OpacPasswordChange') && Koha.Preference('OpacResetPassword') %]
                        <div id="forgotpassword-modal" class="forgotpassword">
                            <p><a href="/cgi-bin/koha/opac-password-recovery.pl">Forgot your password?</a></p>
                        </div>
                    [% END %]
                    [% IF PatronSelfRegistration && PatronSelfRegistrationDefaultCategory %]
                        <div id="patronregistration-modal" class="patronregistration">
                            <p>Don't have an account? <a href="/cgi-bin/koha/opac-memberentry.pl">Register here.</a></p>
                        </div>
                    [% END %]
                </fieldset>
            </div>
            <div class="modal-footer">
                <input type="submit" class="btn btn-primary" value="Log in" />
                <a href="#" data-dismiss="modal" aria-hidden="true" class="cancel">Cancel</a>
            </div>
        </form> <!-- /#auth -->
    </div>  <!-- /#modalAuth  -->
