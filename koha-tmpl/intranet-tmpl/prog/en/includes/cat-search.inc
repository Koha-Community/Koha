[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Catalogue Resident Search Box -->
<div id="header_search">

[% INCLUDE 'patron-search-box.inc' %]

[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
<div id="checkin_search" class="residentsearch">
    <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
        <label class="tip" for="ret_barcode">Scan a barcode to check in:</label>
        <input class="head-searchbox" name="barcode" id="ret_barcode" size="40" type="text" />

        <input value="Submit" class="submit" type="submit" />
    </form>
</div>
<div id="renew_search" class="residentsearch">
    <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
        <label class="tip" for="ren_barcode">Scan a barcode to renew:</label>
        <input class="head-searchbox" name="barcode" id="ren_barcode" size="40" type="text" />
        <input value="Submit" class="submit" type="submit" />
    </form>
</div>
[% END %]

[% IF ( CAN_user_catalogue ) %]
<div id="catalog_search" class="residentsearch">
    <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
        [% IF ( Koha.Preference('IntranetCatalogSearchPulldown') ) %]
            <label class="tip" for="search-form">Enter search keywords:</label>
            [% INCLUDE 'search_indexes.inc' %]
        [% ELSE %]
            <label class="tip" for="search-form">Enter search keywords:</label>
        [% END %]
        <input type="text" name="q" id="search-form" size="40" value="[% ms_value | html %]" title="Enter the terms you wish to search for." class="head-searchbox form-text" />
        <input type="submit" class="submit" value="Submit" />
    </form>
</div>
[% END %]

<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#checkin_search">Check in</a></li>[% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#renew_search">Renew</a></li>[% END %]
    [% IF ( CAN_user_catalogue ) %]<li class="ui-tabs-active"><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
</ul>

</div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Catalogue Resident Search Box -->
