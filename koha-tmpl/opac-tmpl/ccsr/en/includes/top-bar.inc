<div id="top-bar">
<ul id="menu-left">
    <!-- [% IF ( opacbookbag ) %] -->
        <li>
            <span id="cmspan"></span>
            <div id="cartDetails">Your cart is empty.</div>
        </li>
    <!-- [% END %] -->

    [% IF ( virtualshelves ) %]

    <li id="listsmenulink">
        <a href="/cgi-bin/koha/opac-shelves.pl"  class="">
            <span>Lists</span>
        </a>
    <div id="listsmenu" class="yuimenu" style="display: none">
        <h4>Public lists</h4>
            [% IF ( pubshelves ) %]
                <ul class="first-of-type">
                [% FOREACH pubshelvesloo IN pubshelvesloop %]
                <li class="yuimenuitem"><a href="/cgi-bin/koha/opac-shelves.pl?viewshelf=[% pubshelvesloo.shelfnumber %]&amp;sortfield=[% pubshelvesloo.sortfield %]">[% pubshelvesloo.shelfname |html %]</a></li>
                [% END %]
                <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl?display=publicshelves">[View All]</a></li>
            </ul>
            [% ELSE %]
            No public lists
            [% END %]
      [% IF ( opacuserlogin ) %]
        <h4>Your lists</h4>
        [% IF ( loggedinusername ) %]
            [% IF ( barshelves ) %]
                <ul class="first-of-type">
                [% FOREACH barshelvesloo IN barshelvesloop %]
                <li class="yuimenuitem"><a href="/cgi-bin/koha/opac-shelves.pl?viewshelf=[% barshelvesloo.shelfnumber %]&amp;sortfield=[% barshelvesloo.sortfield %]">[% barshelvesloo.shelfname |html %]</a></li>
                [% END %]
            <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl?display=privateshelves">[View all]</a></li>
            </ul>
            [% ELSE %]
                <ul class="first-of-type">
            <li>No private lists</li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl?display=privateshelves">[New list]</a></li></ul>
            [% END %]
        [% ELSE %]
            <ul class="first-of-type"><li><a href="/cgi-bin/koha/opac-user.pl">Log in to create your own lists</a></li></ul>
        [% END %]
      [% END %]
    </div><!-- /listmenu /virtualshelves -->
[% END %]
<div id="listsDetails"></div>

</li>
</ul>

    <div id="members">
      [% IF ( opacuserlogin ) %]
        <ul>
    [% UNLESS ( loggedinusername ) %]
                   <li><a href="/cgi-bin/koha/opac-user.pl">Log in to your account</a></li>[% END %]
                [% IF ( loggedinusername ) %]
                    <li><span class="members">Welcome, <a href="/cgi-bin/koha/opac-user.pl"><span class="loggedinusername">[% FOREACH USER_INF IN USER_INFO %][% USER_INF.title %] [% USER_INF.firstname %] [% USER_INF.surname %][% END %]</span></a></span></li>

                [% END %]
                [% IF ( ShowOpacRecentSearchLink ) %]
                    <li><a href="/cgi-bin/koha/opac-search-history.pl" title="View your search history">Search history</a></li>
                [% END %]
 [% IF ( loggedinusername ) %]<li>[% IF persona %]<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1" onclick='navigator.id.logout();'>[% ELSE %]<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">[% END %]Log Out</a></li>[% END %]
        </ul>
      [% END %]
    </div>

    <div class="clear"></div>

</div>
