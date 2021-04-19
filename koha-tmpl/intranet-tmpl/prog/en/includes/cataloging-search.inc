[% USE Koha %]
<div class="gradient">
<div id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></div><!-- Begin Cataloging Resident Search Box -->
    <div id="header_search">
        <div id="addbooks_search" class="residentsearch">
            <form name="search" action="addbooks.pl">
                <label class="tip" for="cat_search">Search the catalog and the reservoir:</label>
                <input class="head-searchbox" type="text" name="q" id="cat_search" size="40" />
                <input type="submit" class="submit" value="Submit" />
            </form>
        </div>

        [% INCLUDE 'patron-search-box.inc' %]

        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
        <div id="checkin_search" class="residentsearch">
            <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
                <label class="tip" for="ret_barcode">Scan a barcode to check in:</label>
                <input class="head-searchbox" type="text" name="barcode" id="ret_barcode" size="40" />
                <input value="Submit" class="submit" type="submit" />
            </form>
        </div>
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
            <li><a class="keep_text" href="#addbooks_search">Cataloging search</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#checkin_search">Check in</a></li>[% END %]
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#renew_search">Renew</a></li>[% END %]
            <li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>
        </ul>
    </div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Cataloging Resident Search Box -->
