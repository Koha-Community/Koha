<!-- Begin Members Resident Search Box -->
<div id="header_search">
	<div id="notices_search" class="residentsearch">
	<p class="tip">Search Existing Notices:</p>
<form action="/cgi-bin/koha/tools/letter.pl" method="post">
		<input type="text" name="searchfield" size="40" value="" />
                <input type="submit" name="Search" value="Search" />
        </form>	
	</div>
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
	<div id="catalog_search" class="residentsearch">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" name="op" value="Submit"  class="form-submit" />
		</form>
	</div>
			<ul>
			<li><a href="/cgi-bin/koha/admin/currency.pl#notices_search">Search Notices</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li>
			<li><a href="/cgi-bin/koha/catalogue/advsearch.pl#catalog_search">Search the Catalog</a></li>
			</ul>	
</div>
<!-- End Members Resident Search Box -->
