[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Notices Resident Search Box -->
<div id="header_search">
	<div id="notices_search" class="residentsearch">
<form action="/cgi-bin/koha/tools/letter.pl" method="post">
        <label class="tip" for="searchfield">Search existing notices:</label>
        <input class="head-searchbox" type="text" name="searchfield" id="searchfield" size="40" value="" />
                <input type="submit" class="submit" name="search" value="Search" />
        </form>	
	</div>
    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]
			<ul>
            <li><a class="keep_text" href="#notices_search">Search notices</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>	
</div>
</div><!-- /gradient -->
<!-- End Notices Resident Search Box -->
