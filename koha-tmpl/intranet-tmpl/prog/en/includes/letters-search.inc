<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Notices Resident Search Box -->
<div id="header_search">
	<div id="notices_search" class="residentsearch">
    <p class="tip">Search existing notices:</p>
<form action="/cgi-bin/koha/tools/letter.pl" method="post">
        <input class="head-searchbox" type="text" name="searchfield" size="40" value="" />
                <input type="submit" class="submit" name="search" value="Search" />
        </form>	
	</div>
    [% INCLUDE 'patron-search-box.inc' %]
	[% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
            <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="head-searchbox form-text" />
				<input type="submit" name="op" value="Submit"  class="submit" />
		</form>
	</div>[% END %]
			<ul>
            <li><a onclick="keep_text(0)" href="#notices_search">Search notices</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a onclick="keep_text(1)" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a onclick="keep_text(2)" href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>	
</div>
</div><!-- /gradient -->
<!-- End Notices Resident Search Box -->
