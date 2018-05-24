[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Checkin Resident Search Box -->
<div id="header_search">
[% INCLUDE 'patron-search-box.inc' %]

[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
<div id="renew_search" class="residentsearch">
    <p class="tip">Scan a barcode to renew:</p>
    <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
        <input class="head-searchbox" name="barcode" id="ren_barcode" size="40" />
        <input value="Submit" class="submit" type="submit" />
    </form>
</div>
[% END %]

[% IF ( CAN_user_catalogue ) %]
<div id="catalog_search" class="residentsearch">
    <p class="tip">Enter search keywords:</p>
    <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
        [% IF ( Koha.Preference('IntranetCatalogSearchPulldown') ) %][% INCLUDE 'search_indexes.inc' %][% END %]
        <input class="head-searchbox" type="text" name="q" id="search-form" size="40" />
        <input type="submit" class="submit" value="Submit"/>
    </form>
</div>
[% END %]
<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#renew_search">Renew</a></li>[% END %]
    [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
</ul>   

</div>
</div><!-- /gradient -->
<!-- End Checkin Resident Search Box -->
