<!-- Begin Members Resident Search Box -->
<div id="header_search">
	<div id="suggestions_search" class="residentsearch">
	<p class="tip">Suggestions Search:</p>
	<form action="/cgi-bin/koha/acqui/newordersuggestion.pl" method="get">
	<label for="searchtitle">Title:</label> <input type="text" id="searchtitle" name="title" value="<!-- TMPL_VAR NAME="title"-->" />
    <label for="searchauthor">Author:</label> <input type="text" id="searchauthor" name="author" value="<!-- TMPL_VAR NAME="author" -->" />
    <label for="searchpublishercode">Publisher:</label> <input type="text" id="searchpublishercode" name="publishercode" value="<!-- TMPL_VAR NAME="publishercode"-->" />
    <input type="submit" class="button" value="Search Suggestions" />
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
				<input type="submit" value="Submit"  class="form-submit" />
		</form>
	</div>
			<ul>
			<li><a href="/cgi-bin/koha/acqui/newordersuggestion.pl?booksellerid=<!-- TMPL_VAR NAME="supplierid" -->&amp;basketno=<!-- TMPL_VAR NAME="basketno" -->#suggestions_search">Search Printers</a></li>
			<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li>
			<li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li>
			</ul>	
</div>
<!-- End Members Resident Search Box -->
