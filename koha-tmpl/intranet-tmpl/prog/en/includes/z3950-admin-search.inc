[% USE Koha %]
<div class="gradient">
<div id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></div><!-- Begin z3950 Admin Resident Search Box -->
<div id="header_search">
    <div id="z3950_search" class="residentsearch">
	<form action="/cgi-bin/koha/admin/z3950servers.pl" method="post">
        <label class="tip" for="searchfield">Z39.50/SRU server search:</label>
                <input class="head-searchbox" type="text" name="searchfield" id="searchfield" size="40" value="[% searchfield | html %]" />
                <input type="submit" class="submit" name="search" value="Search" />
        </form>
	</div>

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]

			<ul>
            <li><a class="keep_text" href="#z3950_search">Search Z39.50/SRU servers</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>	
</div>
</div>
<!-- End Members Resident Search Box -->
