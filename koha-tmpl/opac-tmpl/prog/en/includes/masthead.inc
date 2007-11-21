<div id="masthead">
<h1 id="libraryname"><a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_VAR NAME="LibraryName" --></a></h1>
</div>

<div id="members">
	<ul>
	<!--TMPL_IF NAME="virtualshelves" --><li><a href="/cgi-bin/koha/opac-shelves.pl">Virtual Shelves</a></li><!-- /TMPL_IF --><!-- TMPL_IF NAME="loggedinusername" --><li><a href="/cgi-bin/koha/opac-user.pl">Your Account</a></li><!-- /TMPL_IF --><!-- TMPL_IF NAME="loggedinusername" --><li><span class="members">Logged in as <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></span></li><li><a class="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a></li><!-- TMPL_ELSE --><li><a href="/cgi-bin/koha/opac-user.pl">Your Account</a></li><!-- /TMPL_IF -->
	</ul>	
</div>

<div id="opac-main-search">
   
    <form name="searchform" method="post" action="/cgi-bin/koha/opac-search.pl" id="searchform">
	<label for="masthead_search"> Search <!-- TMPL_IF name="mylibraryfirst" --> <!-- TMPL_IF name="loggedinusername" -->(in <!-- TMPL_VAR name="LoginBranchcode" --> only)<!-- /TMPL_IF --><!-- /TMPL_IF --></label>
	<select name="idx" id="masthead_search">
        <option selected="selected" value="">Library Catalog</option>
        <option value="ti">Title</option>
        <option value="au">Author</option>
        <option value="su">Subject</option>
		<option value="isbn">ISBN</option>
        <option value="se">Series</option>
        <option value="callnum">Call Number</option>
</select>
        <input type="text" name="q" style="width: 30%;" />
        <!-- TMPL_IF name="mylibraryfirst" --><!-- TMPL_IF name="loggedinusername" -->
            <input name="limit" value="<!-- TMPL_VAR name="LoginBranchcode" -->" type="hidden" />
        <!-- /TMPL_IF --><!-- /TMPL_IF -->
        <input type="submit" value="Search" class="submit" />
    </form>
     <a href="/cgi-bin/koha/opac-search.pl">Advanced Search</a>
</div>

<div id="corner"><!-- TMPL_IF NAME="opacbookbag" --><a class="cart" href="/cgi-bin/koha/opac-basket.pl" onclick="openBasket(); return false;" title="A &quot;shopping cart&quot; for your selections">Book Bag<span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a><!-- /TMPL_IF --><!-- TMPL_IF NAME="opaclanguagesdisplay" --><div id="languages">
	<ul>
		<!-- TMPL_LOOP NAME="languages" --><li><a href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="language" -->"><!-- TMPL_VAR NAME="label" --></a> </li><!-- /TMPL_LOOP -->
	</ul></div><!-- /TMPL_IF --></div>

	<div id="breadcrumbs" class="yui-g">
<!-- TMPL_IF NAME="searchdesc" --><p><!-- TMPL_IF name="total" --><strong>&ldquo;<!-- TMPL_VAR NAME="searchdesc" -->&rdquo; </strong>returned <!-- TMPL_VAR NAME="total" --> results. <!-- TMPL_IF NAME="available" -->Showing only <strong>available</strong> items. <a href="/cgi-bin/koha/opac-search.pl?q=<!-- TMPL_VAR NAME="searchdesc" -->">Show all items</a><!-- TMPL_ELSE -->Limit to <a href="/cgi-bin/koha/opac-search.pl?q=<!-- TMPL_VAR NAME="searchdesc" -->&amp;limit=available">currently available items.</a><!-- /TMPL_IF --><!-- TMPL_IF NAME="related" --> (related searches: <!-- TMPL_LOOP NAME="related" --><!-- TMPL_VAR NAME="related_search" --><!-- /TMPL_LOOP -->). <!-- /TMPL_IF -->  <!-- <a href="http://a9.com/-/opensearch/search/B0007WF826/<!-- TMPL_VAR NAME="searchdesc" -->?count=10&amp;startPage=1"><img title="RSS Feed for search <!-- TMPL_VAR NAME="searchdesc" -->" alt="RSS Feed for search <!-- TMPL_VAR NAME="searchdesc" -->" src="<!-- TMPL_VAR NAME="themelang" -->/../images/feed-icon-16x16.png" border="0" /></a> -->
<!-- TMPL_ELSE -->
<strong>&ldquo;<!-- TMPL_VAR NAME="searchdesc" -->&rdquo;</strong>
<!-- TMPL_VAR NAME="search_error" --> 
<!-- /TMPL_IF --></p><!-- /TMPL_IF -->
</div>