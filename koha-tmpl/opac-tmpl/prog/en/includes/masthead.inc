<div id="members">
	<ul><!-- TMPL_IF NAME="loggedinusername" --><li><span class="members">Welcome, <a href="/cgi-bin/koha/opac-user.pl"><span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></a></span></li><li><a class="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a></li><!-- TMPL_ELSE --><li><a href="/cgi-bin/koha/opac-user.pl">Log in to Your Account</a></li><!-- /TMPL_IF -->
	</ul>	
</div>

<div id="opac-main-search" class="yui-g">

   <div id="masthead">
   <h1 id="libraryname" <!-- TMPL_IF NAME="opacsmallimage" -->style="background-image: url('<!-- TMPL_VAR NAME="opacsmallimage" -->');"><!-- /TMPL_IF --><a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_IF NAME="LibraryName" --><!-- TMPL_VAR NAME="LibraryName" --><!-- TMPL_ELSE -->Koha Online Catalog<!-- /TMPL_IF --></a></h1>
   </div>

<div id="fluid">
<div id="fluid-offset">
<div id="fluid-content-1">
    <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform">
	<label for="masthead_search"> Search <!-- TMPL_IF name="mylibraryfirst" --> <!-- TMPL_IF name="loggedinusername" -->(in <!-- TMPL_VAR name="LoginBranchcode" --> only)<!-- /TMPL_IF --><!-- /TMPL_IF --></label>
	<select name="idx" id="masthead_search">
	<!-- TMPL_IF NAME="ms_kw" -->
        <option selected="selected" value="">Library Catalog</option>
		<!-- TMPL_ELSE -->
        <option value="">Library Catalog</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_ti" -->
        <option selected="selected" value="ti">Title</option>
		<!-- TMPL_ELSE -->
        <option value="ti">Title</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_au" -->
        <option selected="selected" value="au">Author</option>
		<!-- TMPL_ELSE -->
        <option value="au">Author</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_su" -->
        <option selected="selected" value="su">Subject</option>
		<!-- TMPL_ELSE -->
        <option value="su">Subject</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_isbn" -->
		<option selected="selected" value="isbn">ISBN</option>
		<!-- TMPL_ELSE -->
		<option value="isbn">ISBN</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_se" -->
        <option selected="selected" value="se">Series</option>
		<!-- TMPL_ELSE -->
        <option value="se">Series</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_callnum" -->
        <option selected="selected" value="callnum">Call Number</option>
		<!-- TMPL_ELSE -->
        <option value="callnum">Call Number</option>
		<!-- /TMPL_IF --></select>
<!-- TMPL_IF NAME="ms_value" -->
        <input type="text" name="q" value="<!-- TMPL_VAR NAME="ms_value" -->"  style="width: 40%;" />
<!-- TMPL_ELSE -->
        <input type="text" name="q" style="width: 40%;" />
<!-- /TMPL_IF -->
        <!-- TMPL_IF name="mylibraryfirst" --><!-- TMPL_IF name="loggedinusername" -->
            <input name="limit" value="<!-- TMPL_VAR name="LoginBranchcode" -->" type="hidden" />
        <!-- /TMPL_IF --><!-- /TMPL_IF -->
        <input type="submit" value="Search" class="submit" />
    </form>
	
	<div id="moresearches"><a href="/cgi-bin/koha/opac-search.pl">Advanced Search</a><!-- TMPL_IF name="OpacBrowser" --> | <a href="/cgi-bin/koha/opac-browser.pl">Browse by Hierarchy</a><!-- /TMPL_IF --><!-- TMPL_IF name="OpacAuthorities" --> | <a href="/cgi-bin/koha/opac-authorities-home.pl">Browse by Subject</a><!-- /TMPL_IF --><!-- TMPL_IF name="OpacCloud" --> | <a href="/cgi-bin/koha/opac-tags_subject.pl">Tag Cloud</a><!-- /TMPL_IF --><!-- TMPL_IF name="OpacTopissue" --> | <a href="/cgi-bin/koha/opac-topissues.pl">Most Popular</a><!-- /TMPL_IF --></div>

</div>
<div id="fluid-content-2">

<script type="text/javascript">
$(document).ready(function() {
	  //  <!-- TMPL_IF NAME="opacbookbag" -->var cartButton = new YAHOO.widget.Button("cartmenulink");<!-- /TMPL_IF -->
		//<!--TMPL_IF NAME="virtualshelves" -->var listsButton = new YAHOO.widget.Button("listsmenulink");<!-- /TMPL_IF -->
 });
 
   <!--TMPL_IF NAME="virtualshelves" -->YAHOO.util.Event.onContentReady("listsmenu", function () {
        var listMenu = new YAHOO.widget.Menu("listsmenu", { lazyload: true });
		listMenu.render();
		listMenu.cfg.setProperty("context", ["listsmenulink", "tr", "br"]);
		listMenu.subscribe("show", listMenu.focus);
        function positionlistMenu() {
                    listMenu.align("tr", "br");
		}
		YAHOO.util.Event.addListener("listsmenulink", "click", listMenu.show, null, listMenu);
		YAHOO.widget.Overlay.windowResizeEvent.subscribe(positionlistMenu);
    });<!-- /TMPL_IF -->
    
		<!-- TMPL_IF NAME="opacbookbag" -->function init() {
			
			var cartOverlay = new YAHOO.widget.Overlay("cartDetails", { context:["cartmenulink","tr","br"],
																	  visible:false,
																	  width:"200px" } );
			cartOverlay.render();
			
	//		var cartOverlay = new YAHOO.widget.Overlay("cartDetails", { context:["cartmenulink","tr","br"],
	//																				  visible:false,
	//																				  width:"200px" } );
	//		cartOverlay.setBody("Your cart has "+basketcount+" items in it");
	//		cartOverlay.render(document.body);

			YAHOO.util.Event.addListener("cartmenulink", "mouseover", cartOverlay.show, cartOverlay, true);
			YAHOO.util.Event.addListener("cartmenulink", "mouseout", cartOverlay.hide, cartOverlay, true);
			YAHOO.util.Event.addListener("cartmenulink", "click", cartOverlay.hide, cartOverlay, true);
		}

		YAHOO.util.Event.addListener(window, "load", init);<!-- /TMPL_IF -->
</script>

<!-- TMPL_IF NAME="opacbookbag" --><a id="cartmenulink" href="/cgi-bin/koha/opac-basket.pl">Cart<span id="basket"></span></a><!-- /TMPL_IF -->
<!--TMPL_IF NAME="virtualshelves" --><a id="listsmenulink" href="#">Lists</a><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="opacbookbag" --><div id="cartDetails" style="visibility:hidden">Your cart is empty.</div><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="virtualshelves" -->
<div id="listsmenu" class="yuimenu">
    <div class="bd">
<!-- TMPL_IF NAME="loggedinusername" --><h4>Your Lists</h4>
		<!-- TMPL_IF NAME="barshelves" -->
			<ul class="first-of-type">
			<!-- TMPL_LOOP NAME="barshelvesloop" -->
			<li class="yuimenuitem"><a href="/cgi-bin/koha/opac-shelves.pl?viewshelf=<!-- TMPL_VAR NAME="shelfnumber" -->"><!-- TMPL_VAR NAME="shelfname" --></a></li>
			<!-- /TMPL_LOOP -->
			</ul>   
		<!-- /TMPL_IF -->
			<ul class="second-of-type">
            <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl">Manage Lists</a></li>
        </ul>
		</li><!-- TMPL_ELSE --><ul class="first-of-type"><li><a href="/cgi-bin/koha/opac-user.pl">Log in to Create Your Own Lists</a></li></ul><!-- /TMPL_IF -->
	  </div>
</div>
<!-- /TMPL_IF -->


</div>
</div>
</div>

</div>

	<div id="breadcrumbs" class="yui-g">

<!-- TMPL_IF NAME="searchdesc" --><p><!-- TMPL_IF name="total" --><strong>&ldquo;<!-- TMPL_VAR NAME="query_desc" --><!-- TMPL_VAR NAME="limit_desc" -->&rdquo; </strong>returned <!-- TMPL_VAR NAME="total" --> results. <!-- TMPL_IF NAME="related" --> (related searches: <!-- TMPL_LOOP NAME="related" --><!-- TMPL_VAR NAME="related_search" --><!-- /TMPL_LOOP -->). <!-- /TMPL_IF -->

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
