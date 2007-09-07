<!-- Begin Resident Search Box -->
<div id="header_search">
	<div class="tip" id="residenttip">Enter patron card number or partial name:</div>
	<div id="circ_search">
	<form action="/cgi-bin/koha/circ/circulation.pl" method="post">
			<label for="findborrower"> </label>
    <input id="findborrower" name="findborrower" size="40" class="focus" type="text" />
	<input name="branch" value="CPL" type="hidden" />
    <input name="printer" value="" type="hidden" />
	<input value="Submit" type="submit" />
	</form>
	</div>	
	<div id="catalog_search">
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" name="op" id="opac-submit" value="Submit"  class="form-submit" />
		</form>
	</div>
			<ul class="link-tabs">
			<li class="on"><a id="showCircSearch" href="/cgi-bin/koha/circ/circulation.pl">Check Out</a></li>
			<li class="off"><a id="showCatSearch" href="/cgi-bin/koha/catalogue/advsearch.pl">Search the Catalog</a></li>
			</ul>	
</div>
<!-- End Resident Search Box -->