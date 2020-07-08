[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Main page Resident Search Box -->

<div id="header_search">
    [% INCLUDE 'patron-search-box.inc' %]
[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
<div id="checkin_search" class="residentsearch">
    <label class="tip" for="ret_barcode">Scan a barcode to check in:</label>
    <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
        <input name="barcode" class="head-searchbox" id="ret_barcode" size="40" accesskey="r" type="text" />
        <input value="Submit" class="submit" type="submit" />
    </form>
</div>
<div id="renew_search" class="residentsearch">
    <label class="tip" for="ren_barcode">Scan a barcode to renew:</label>
        <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
            <input class="head-searchbox" name="barcode" id="ren_barcode" size="40" type="text" />
            <input value="Submit" class="submit" type="submit" />
        </form>
    </div>
[% END %]

[% IF CAN_user_borrowers_edit_borrowers %]
<div id="patron_search" class="residentsearch">
    <label class="tip" for="searchmember">Enter patron card number or partial name:</label>
    <form action="/cgi-bin/koha/members/member.pl" method="post">
        <input name="searchmember" class="head-searchbox" id="searchmember" size="40" type="text" autocomplete="off" />
        <input type="hidden" name="quicksearch" value="1" />
        <input value="Submit" class="submit" type="submit" />
    </form>
</div>[% END %]
[% IF ( CAN_user_catalogue ) %]
<div id="catalog_search" class="residentsearch">
    <label class="tip" for="search-form">Enter search keywords:</label>
    <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
        [% IF ( Koha.Preference('IntranetCatalogSearchPulldown') ) %][% INCLUDE 'search_indexes.inc' %][% END %]
        <input type="text" name="q" id="search-form" class="head-searchbox" size="40" accesskey="q" />
        <input type="submit" class="submit" value="Submit"/>
    </form>
</div>[% END %]

<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#checkin_search">Check in</a></li>[% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#renew_search">Renew</a></li>[% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]<li><a class="keep_text" href="#patron_search">Search patrons</a></li>[% END %]
    [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
</ul>

</div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Main page Resident Search Box -->
