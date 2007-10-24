<!-- Begin Members Resident Search Box -->
<div id="header_search">
	<div id="patron_search" class="residentsearch">
	<p class="tip">Enter patron card number or partial name:</p>
	<form action="/cgi-bin/koha/members/member.pl" method="post">
    <input id="searchmember" size="25" name="member" type="text" />
    order by:
    <select name="orderby" id="searchorderby">
    <option value="surname,firstname">Surname</option>
    <option value="cardnumber">Cardnumber</option>
    </select>
    <input value="Search" type="submit" />
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
			<li><a href="/cgi-bin/koha/members/members-home.pl#patron_search">Search Patrons</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li>
			<li><a href="/cgi-bin/koha/catalogue/advsearch.pl#catalog_search">Search the Catalog</a></li>
			</ul>	
</div>
<!-- End Members Resident Search Box -->