
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl"><!-- TMPL_VAR NAME="LibraryName" --></a></h1><!-- Begin Stopwords Resident Search Box -->
<div id="header_search">
	<div id="syspref_search" class="residentsearch">
	<p class="tip">System preference search:</p>
	    <form action="/cgi-bin/koha/admin/systempreferences.pl" method="post">
        <input type="text" size="40" name="searchfield" value="<!-- TMPL_VAR NAME="searchfield" -->" />
		<input type="hidden" value="all" name="tab" />
        <input type="submit" name="ok" class="submit" value="Search" />
    </form>
	</div>
    <!-- TMPL_INCLUDE NAME="patron-search-box.inc" -->
	<!-- TMPL_IF NAME="CAN_user_catalogue" -->
	<div id="catalog_search" class="residentsearch" style="display:none;">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" value="Submit" class="submit" />
		</form>
	</div>
	<!-- /TMPL_IF -->
			<ul>
			<li><a href="/cgi-bin/koha/admin/roadtype.pl#syspref_search">Search System Preferences</a></li>
			<!-- TMPL_IF NAME="CAN_user_circulate" --><li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check Out</a></li><!-- /TMPL_IF -->
			<!-- TMPL_IF NAME="CAN_user_catalogue" --><li><a href="/cgi-bin/koha/catalogue/search.pl#catalog_search">Search the Catalog</a></li><!-- /TMPL_IF -->
			</ul>	
</div>
<!-- End Stopwords Resident Search Box -->
