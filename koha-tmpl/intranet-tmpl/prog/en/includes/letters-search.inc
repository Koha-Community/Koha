
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl"><!-- TMPL_VAR NAME="LibraryName" --></a></h1><!-- Begin Notices Resident Search Box -->
<div id="header_search">
	<div id="notices_search" class="residentsearch">
	<p class="tip">Search Existing Notices:</p>
<form action="/cgi-bin/koha/tools/letter.pl" method="post">
		<input type="text" name="searchfield" size="40" value="" />
                <input type="submit" class="submit" name="search" value="Search" />
        </form>	
	</div>
    <!-- TMPL_INCLUDE NAME="patron-search-box.inc" -->
	<!-- TMPL_IF NAME="CAN_user_catalogue" -->
	<div id="catalog_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" name="op" value="Submit"  class="submit" />
		</form>
	</div><!-- /TMPL_IF -->
			<ul>
			<li><a href="/cgi-bin/koha/admin/currency.pl#notices_search">Search Notices</a></li>
			<!-- TMPL_IF NAME="CAN_user_circulate" --><li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li><!-- /TMPL_IF -->
			<!-- TMPL_IF NAME="CAN_user_catalogue" --><li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li><!-- /TMPL_IF -->
			</ul>	
</div>
<!-- End Notices Resident Search Box -->
