[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Cities Resident Search Box -->
<div id="header_search">
	<div id="city_search" class="residentsearch">
	<form action="[% script_name | html %]" method="post">
        <label class="tip" for="city_name_filter">City search:</label>
        <input class="head-searchbox" type="text" name="city_name_filter" id="city_name_filter" value="[% city_name_filter | html %]" size="40" />
		<input type="submit" name="submit" value="OK" class="submit" />
	</form>
	</div>

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]

			<ul>
            <li><a class="keep_text" href="#city_search">Search cities</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>	
</div>
</div>
<!-- End Cities Resident Search Box -->
