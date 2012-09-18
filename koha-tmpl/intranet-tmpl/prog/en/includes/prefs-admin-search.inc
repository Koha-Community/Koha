<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Stopwords Resident Search Box -->
<div id="header_search">
	<div id="syspref_search" class="residentsearch">
	<p class="tip">System preference search:</p>
	    <form action="/cgi-bin/koha/admin/preferences.pl">
        <input type="hidden" name="tab" value="[% last_tab %]" />
        <input type="hidden" name="op" value="search" />
        <input type="text" size="40" name="searchfield" value="[% searchfield |html %]" />
        <input type="submit" class="submit" value="Search" />
    </form>
	</div>
    [% INCLUDE 'patron-search-box.inc' %]
	[% IF ( CAN_user_catalogue ) %]
	<div id="catalog_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" value="Submit" class="submit" />
		</form>
	</div>
	[% END %]
			<ul>
			<li><a href="/cgi-bin/koha/admin/roadtype.pl#syspref_search">Search System Preferences</a></li>
			[% IF ( CAN_user_circulate ) %]<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li>[% END %]
			[% IF ( CAN_user_catalogue ) %]<li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li>[% END %]
			</ul>
</div>
<!-- End Stopwords Resident Search Box -->
