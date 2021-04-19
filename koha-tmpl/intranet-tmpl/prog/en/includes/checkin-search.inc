[% USE Koha %]
<div class="gradient">
<div id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></div><!-- Begin Checkin Resident Search Box -->
<div id="header_search">
[% INCLUDE 'patron-search-box.inc' %]

[% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
<div id="renew_search" class="residentsearch">
    <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
        <label class="tip" for="ren_barcode">Scan a barcode to renew:</label>
        <input class="head-searchbox" type="text" name="barcode" id="ren_barcode" size="40" />
        <input value="Submit" class="submit" type="submit" />
    </form>
</div>
[% END %]

[% INCLUDE 'catalogue-search-box.inc' %]
<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#renew_search">Renew</a></li>[% END %]
    [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
</ul>   

</div>
</div><!-- /gradient -->
<!-- End Checkin Resident Search Box -->
