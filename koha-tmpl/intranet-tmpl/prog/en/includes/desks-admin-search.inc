[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName|html %]</a></h1><!-- Begin Desks Resident Search Box -->
<div id="header_search">
        <div id="desk_search" class="residentsearch">
        <form action="[% script_name|html %]" method="post">
            <label class="tip" for="desk_name">Desk search:</label>
        <input class="head-searchbox" type="text" name="desk_name" id="desk_name" value="[% searchfield|html %]" size="40" />
                <input type="submit" name="submit" value="OK" class="submit" />
        </form>
        </div>

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]

                        <ul>
            <li><a class="keep_text" href="#desk_search">Search desks</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
                        </ul>
</div>
</div>
<!-- End Desks Resident Search Box -->
