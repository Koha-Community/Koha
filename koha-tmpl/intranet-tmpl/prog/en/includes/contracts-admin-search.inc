[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Patrons Admin Resident Search Box -->

<div id="header_search">
	<div id="contract_description_search" class="residentsearch">
	<form action="[% script_name | html %]" method="post">
        <label class="tip" for="searchfield">Search by contract name or/and description:</label>
        <input class="head-searchbox" type="text" name="searchfield" id="searchfield" size="40" value="[% searchfield | html %]" />
		<input type="submit" class="submit" name="search" value="Search" />
	</form>	
	</div>

    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]

	<ul>
            <li><a class="keep_text" href="#contract_description_search">Search contracts</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
	</ul>
</div>
</div><!-- /gradient -->
<!-- End Patrons Admin Resident Search Box -->
