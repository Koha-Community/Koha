[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1>
<div id="header_search">
	<div id="syspref_search" class="residentsearch">
	<p class="tip">System preference search:</p>
	    <form action="/cgi-bin/koha/admin/preferences.pl">
        <input type="hidden" name="tab" value="[% last_tab | html %]" />
        <input type="hidden" name="op" value="search" />
        <input class="head-searchbox" type="text" size="40" name="searchfield" value="">
        <input type="submit" class="submit" value="Search" />
    </form>
	</div>
    [% INCLUDE 'patron-search-box.inc' %]
	[% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
             [% IF ( Koha.Preference('IntranetCatalogSearchPulldown') ) %][% INCLUDE 'search_indexes.inc' %][% END %]
             <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="head-searchbox form-text" />
				<input type="submit" value="Submit" class="submit" />
		</form>
	</div>
	[% END %]
			<ul>
            <li><a class="keep_text" href="#syspref_search">Search system preferences</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>
</div>
</div>
