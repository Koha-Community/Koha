
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Printers Resident Search Box -->
<div id="header_search">
	<div id="printer_search" class="residentsearch">
	<p class="tip">Printer Search:</p>
<form action="[% script_name %]" method="post">
                <input type="text" size="40" name="description" value="[% searchfield %]" />
                <input type="submit" name="submit" value="Search" />
        </form>
	</div>
    [% INCLUDE 'patron-search-box.inc' %]
	[% IF ( CAN_user_catalogue ) %]
	<div id="catalog_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" value="Submit"  class="submit" />
		</form>
	</div>
	[% END %]
			<ul>
			<li><a href="/cgi-bin/koha/admin/printers.pl#printer_search">Search Printers</a></li>
			[% IF ( CAN_user_circulate ) %]<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li>[% END %]
			[% IF ( CAN_user_catalogue ) %]<li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li>[% END %]
			</ul>	
</div>
<!-- End Printers Resident Search Box -->
