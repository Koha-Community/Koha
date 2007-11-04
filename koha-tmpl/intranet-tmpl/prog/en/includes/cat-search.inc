<!-- Begin Circulation Resident Search Box -->
<div id="header_search">
	<div id="circ_search" class="residentsearch">
	<p class="tip">Enter patron card number or partial name:</p>
	<form action="/cgi-bin/koha/circ/circulation.pl" method="post">
			<label for="findborrower"> </label>
    <input id="findborrower" name="findborrower" size="40" class="focus" type="text" />
	<input name="branch" value="<!-- TMPL_VAR name="branch" -->" type="hidden" />
    <input name="printer" value="" type="hidden" />
	<input value="Submit" type="submit" />
	</form>
	</div>
	

<div id="checkin_search" class="residentsearch">
    <p class="tip">Scan a barcode to check in:</p>
    <form method="post" action="/cgi-bin/koha/circ/returns.pl">
        <input name="barcode" id="ret_barcode" size="40" maxlength="14" />
        <input value="Submit" type="submit" />
    </form>
</div>
	
	<div id="catalog_search" class="residentsearch">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" class="form-submit" value="Submit" />
		</form>
	</div>
			<ul>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li>
    <li><a href="/cgi-bin/koha/circ/returns.pl#checkin_search">Check In</a></li>
			<li class="tabs-selected"><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li>
			</ul>	
</div>
<!-- End Circulation Resident Search Box -->
