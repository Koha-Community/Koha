<div class="gradient">
    <h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1>

    <!-- Begin main page resident search box -->
    <div id="header_search">
        [% INCLUDE 'patron-search-box.inc' %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
            <div id="checkin_search" class="residentsearch">
                <label class="tip" for="ret_barcode">Scan a barcode to check in:</label>
                <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
                    <input type="text" name="barcode" class="head-searchbox" id="ret_barcode" size="40" accesskey="r" />
                    <input value="Submit" class="submit" type="submit" />
                </form>
            </div>
            <div id="renew_search" class="residentsearch">
                <label class="tip" for="ren_barcode">Scan a barcode to renew:</label>
                <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
                    <input type="text" class="head-searchbox" name="barcode" id="ren_barcode" size="40" />
                    <input value="Submit" class="submit" type="submit" />
                </form>
            </div>
        [% END %]

        [% IF CAN_user_borrowers_edit_borrowers %]
            <div id="patron_search" class="residentsearch">
                <label class="tip" for="searchmember">Enter patron card number or partial name:</label>
                <form action="/cgi-bin/koha/members/member.pl" method="post">
                    <input name="searchmember" class="head-searchbox" id="searchmember" size="40" type="text" />
                    <input type="hidden" name="quicksearch" value="1" />
                    <input value="Submit" class="submit" type="submit" />
                </form>
            </div>
        [% END %]

        <ul>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
                <li><a class="keep_text" href="#circ_search">Check out</a></li>
            [% END %]
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
                <li><a class="keep_text" href="#checkin_search">Check in</a></li>
            [% END %]
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
                <li><a class="keep_text" href="#renew_search">Renew</a></li>
            [% END %]
            [% IF CAN_user_borrowers_edit_borrowers %]
                <li><a class="keep_text" href="#patron_search">Search patrons</a></li>
            [% END %]
        </ul>

    </div><!-- /#header_search -->
    <!-- End advanced search page resident search box -->

</div><!-- /.gradient -->
