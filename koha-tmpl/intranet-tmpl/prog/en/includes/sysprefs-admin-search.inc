
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Stopwords Resident Search Box -->
<div id="header_search">
	<div id="syspref_search" class="residentsearch">
	<p class="tip">System preference search:</p>
	    <form action="/cgi-bin/koha/admin/preferences.pl" method="post">
        <input type="text" size="40" name="searchfield" value="[% searchfield %]" />
		<input type="hidden" value="all" name="tab" />
        <input type="submit" name="ok" class="submit" value="Search" />
    </form>
	</div>
    [% INCLUDE 'patron-search-box.inc' %]
	[% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" value="Submit" class="submit" />
		</form>
	</div>
	[% END %]
			<ul>
            <li><a href="#syspref_search">Search system preferences</a></li>
            [% IF ( CAN_user_circulate ) %]<li><a href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>	
</div>
<!-- End Stopwords Resident Search Box -->
