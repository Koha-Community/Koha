[% USE Koha %]
<div class="gradient">
<div id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></div>
<div id="header_search">
	<div id="syspref_search" class="residentsearch">
	    <form action="/cgi-bin/koha/admin/preferences.pl">
            <label class="tip" for="searchfield">System preference search:</label>
        <input type="hidden" name="tab" value="[% last_tab | html %]" />
        <input type="hidden" name="op" value="search" />
        <input class="head-searchbox" type="text" size="40" name="searchfield" id="searchfield" value="">
        <input type="submit" class="submit" value="Search" />
    </form>
	</div>
    [% INCLUDE 'patron-search-box.inc' %]
    [% INCLUDE 'catalogue-search-box.inc' %]
			<ul>
            <li><a class="keep_text" href="#syspref_search">Search system preferences</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>
</div>
</div>
