[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Circulation Resident Search Box -->

<div id="header_search">
    [% INCLUDE 'patron-search-box.inc' %]
[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
<div id="checkin_search" class="residentsearch">
    <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
        <label class="tip" for="ret_barcode">Scan a barcode to check in:</label>
        <input class="head-searchbox" name="barcode" id="ret_barcode" size="40" accesskey="r" type="text" />
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
    [% INCLUDE 'catalogue-search-box.inc' %]

<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#checkin_search">Check in</a></li>[% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#renew_search">Renew</a></li>[% END %]
    [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
</ul>   

</div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Circulation Resident Search Box -->
