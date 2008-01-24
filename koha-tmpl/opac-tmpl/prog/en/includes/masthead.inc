<div class="yui-g">
<div id="libraryname"><h1 id="library"><a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_IF NAME="LibraryName" --><!-- TMPL_VAR NAME="LibraryName" --><!-- TMPL_ELSE -->Koha Online Catalog<!-- /TMPL_IF --></a></h1>
</div>

<div id="corner"><!-- TMPL_IF NAME="opacbookbag" --><a class="cart" href="/cgi-bin/koha/opac-basket.pl" onclick="openBasket(); return false;" title="A &quot;shopping cart&quot; for your selections">Book Bag<span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a><!-- /TMPL_IF --><!-- TMPL_IF NAME="opaclanguagesdisplay" --><div id="languages">
	<ul>
		<!-- TMPL_LOOP NAME="languages" --><li><a href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="language" -->"><!-- TMPL_VAR NAME="label" --></a> </li><!-- /TMPL_LOOP -->
	</ul></div><!-- /TMPL_IF --></div></div>

<div id="members">
	<ul>
	<!-- TMPL_IF NAME="virtualshelves" -->
		<li><a href="/cgi-bin/koha/opac-shelves.pl">Lists</a>
		<!-- TMPL_IF NAME="FIXME_barshelves" --><--! FIXME: Owen, you can take it from here!  Make it "barshelves" for proof/demo. -->
			<ul>
			<!-- TMPL_LOOP NAME="barshelvesloop" -->
			<li><a href="/cgi-bin/koha/opac-shelves.pl?viewshelf=<!-- TMPL_VAR NAME="shelfnumber" -->">
				<!-- TMPL_VAR NAME="shelfname" -->
			</a></li>
			<!-- /TMPL_LOOP -->
			</ul>
		<!-- /TMPL_IF -->
		</li>
	<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="loggedinusername" --><li><a href="/cgi-bin/koha/opac-user.pl">Your Account</a></li><!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="loggedinusername" -->
	<li><span class="members">Logged in as <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></span></li>
	<li><a class="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a></li>
	<!-- TMPL_ELSE --><li><a href="/cgi-bin/koha/opac-user.pl">Your Account</a></li>
	<!-- /TMPL_IF -->
	</ul>	
</div>

<div id="opac-main-search" class="yui-g">

   <div id="masthead">
   <h1 id="libraryname"><a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_IF NAME="LibraryName" --><!-- TMPL_VAR NAME="LibraryName" --><!-- TMPL_ELSE -->Koha Online Catalog<!-- /TMPL_IF --></a></h1>
   </div>

<div id="fluid">
<div id="fluid-offset">
<div id="fluid-content-1">
    <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform">
	<label for="masthead_search"> Search <!-- TMPL_IF name="mylibraryfirst" --> <!-- TMPL_IF name="loggedinusername" -->(in <!-- TMPL_VAR name="LoginBranchcode" --> only)<!-- /TMPL_IF --><!-- /TMPL_IF --></label>
	<select name="idx" id="masthead_search">
        <option <!-- TMPL_IF NAME="ms_kw" -->selected="selected"<!-- /TMPL_IF --> value="">Library Catalog</option>
        <option <!-- TMPL_IF NAME="ms_ti" -->selected="selected"<!-- /TMPL_IF --> value="ti">Title</option>
        <option <!-- TMPL_IF NAME="ms_au" -->selected="selected"<!-- /TMPL_IF --> value="au">Author</option>
        <option <!-- TMPL_IF NAME="ms_su" -->selected="selected"<!-- /TMPL_IF --> value="su">Subject</option>
		<option <!-- TMPL_IF NAME="ms_isbn" -->selected="selected"<!-- /TMPL_IF --> value="isbn">ISBN</option>
        <option <!-- TMPL_IF NAME="ms_se" -->selected="selected"<!-- /TMPL_IF --> value="se">Series</option>
        <option <!-- TMPL_IF NAME="ms_callnum" -->selected="selected"<!-- /TMPL_IF --> value="callnum">Call Number</option>
</select>
        <input type="text" name="q" <!-- TMPL_IF NAME="ms_value" -->value="<!-- TMPL_VAR NAME="ms_value" -->" <!-- /TMPL_IF --> style="width: 30%;" />
        <!-- TMPL_IF name="mylibraryfirst" --><!-- TMPL_IF name="loggedinusername" -->
            <input name="limit" value="<!-- TMPL_VAR name="LoginBranchcode" -->" type="hidden" />
        <!-- /TMPL_IF --><!-- /TMPL_IF -->
        <input type="submit" value="Search" class="submit" />
    </form>
     <a href="/cgi-bin/koha/opac-search.pl">Advanced Search</a>

</div>
</div>
</div>

</div>

	<div id="breadcrumbs" class="yui-g">

<!-- TMPL_IF NAME="searchdesc" --><p><!-- TMPL_IF name="total" --><strong>&ldquo;<!-- TMPL_VAR NAME="query_desc" --><!-- TMPL_VAR NAME="limit_desc" -->&rdquo; </strong>returned <!-- TMPL_VAR NAME="total" --> results. <!-- TMPL_IF NAME="available" -->Showing only <strong>available</strong> items. <a href="/cgi-bin/koha/opac-search.pl?<!-- TMPL_VAR NAME="query_cgi" --><!-- TMPL_VAR NAME="limit_cgi_not_availablity" -->">Show all items</a><!-- TMPL_ELSE -->Limit to <a href="/cgi-bin/koha/opac-search.pl?<!-- TMPL_VAR NAME="query_cgi" --><!-- TMPL_VAR NAME="limit_cgi" -->&amp;limit=available">currently available items.</a><!-- /TMPL_IF --><!-- TMPL_IF NAME="related" --> (related searches: <!-- TMPL_LOOP NAME="related" --><!-- TMPL_VAR NAME="related_search" --><!-- /TMPL_LOOP -->). <!-- /TMPL_IF -->

<!-- TMPL_ELSE -->
<!-- TMPL_IF NAME="searchdesc" -->
<strong>No Result found !</strong>
<p>
    No results match your search for <span style="font-weight: bold;">&ldquo;<!-- TMPL_VAR NAME="query_desc" --><!-- TMPL_VAR NAME="limit_desc" -->&rdquo;</span> in <!-- TMPL_VAR NAME="LibraryName" --> Catalog.
</p>
<!-- TMPL_ELSE -->
<strong> No result found !</strong>
<p>
    You did not specify any search criteria.
</p>
</div>
<!-- /TMPL_IF -->
<!-- /TMPL_IF --></p><!-- /TMPL_IF -->
</div>
