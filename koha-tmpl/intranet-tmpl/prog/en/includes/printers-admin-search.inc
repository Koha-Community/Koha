<!-- Begin Members Resident Search Box -->
<div id="header_search">
	<div id="printer_search" class="residentsearch">
	<p class="tip">Printer Search:</p>
<form action="<!-- TMPL_VAR NAME="script_name" -->" method="post">
                <input type="text" size="40" name="description" value="<!-- TMPL_VAR NAME="searchfield" -->" />
                <input type="submit" name="submit" value="Search" />
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
                    <input type="hidden" name="idx" value="kw,wrdl" />
                    <input type="submit" name="op" id="opac-submit" value="Submit"  class="form-submit" />
		</form>
	</div>
			<ul>
			<li><a href="/cgi-bin/koha/admin/printers.pl#printer_search">Search Printers</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li>
			<li><a href="/cgi-bin/koha/catalogue/advsearch.pl#catalog_search">Search the Catalog</a></li>
			</ul>	
</div>
<!-- End Members Resident Search Box -->