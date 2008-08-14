
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl"><!-- TMPL_VAR NAME="LibraryName" --></a></h1><!-- Begin Serials Resident Search Box -->
<div id="header_search">
	<div id="subscription_search" class="residentsearch">
	<p class="tip">Search Subscriptions:</p>
 <form action="/cgi-bin/koha/serials/serials-home.pl" method="get"><!-- TMPL_IF NAME="routing" --><input type="hidden" name="routing" value="<!-- TMPL_VAR NAME="routing" -->" /><!-- /TMPL_IF --><input type="hidden" name="searched" value="1" /> <label for="ISSN_filter">ISSN:</label> <input type="text" size="10" maxlength="11" name="ISSN_filter" id="ISSN_filter" value="<!-- TMPL_VAR name="ISSN_filter" -->" /> <label for="title_filter">Title:</label> <input type="text" size="20" maxlength="40" name="title_filter" id="title_filter" value="<!-- TMPL_VAR name="title_filter" -->" /><input type="submit" value="Search" class="submit" />
</form>
	</div>
    <!-- TMPL_INCLUDE NAME="patron-search-box.inc" -->
	<!-- TMPL_IF NAME="CAN_user_catalogue" -->
	<div id="catalog_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" value="Submit"  class="submit" />
		</form>
	</div>
	<!-- /TMPL_IF -->
			<ul>
			<li><a href="/cgi-bin/koha/serials/serials-home.pl#subscription_search">Search Subscriptions</a></li>
			<!-- TMPL_IF NAME="CAN_user_circulate" --><li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li><!-- /TMPL_IF -->
			<!-- TMPL_IF NAME="CAN_user_catalogue" --><li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li><!-- /TMPL_IF -->
			</ul>	
</div>
<!-- End Serials Resident Search Box -->
