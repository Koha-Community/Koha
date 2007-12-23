<div class="yui-g"><div id="corner"><!-- TMPL_IF NAME="opacbookbag" --><a class="cart" href="/cgi-bin/koha/opac-basket.pl" onclick="openBasket(); return false;" title="A &quot;shopping cart&quot; for your selections">Book Bag<span id="basket"><script language="javascript" type="text/javascript">if(basketcount){ document.write(basketcount) };</script></span></a><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="opaclanguagesdisplay" --><div id="language">
	<ul><!-- TMPL_LOOP NAME="languages" --><li><a href="/cgi-bin/koha/changelanguage.pl?language=<!-- TMPL_VAR NAME="language" -->"><!-- TMPL_VAR NAME="label" --></a> </li><!-- /TMPL_LOOP -->
	</ul></div><!-- /TMPL_IF --></div></div>

<div id="members">
	<ul>
	<!--TMPL_IF NAME="virtualshelves" --><li><a href="/cgi-bin/koha/opac-shelves.pl">Lists</a></li><!-- /TMPL_IF --><!-- TMPL_IF NAME="loggedinusername" --><li><a href="/cgi-bin/koha/opac-user.pl">Your Account</a></li><!-- /TMPL_IF --><!-- TMPL_IF NAME="loggedinusername" --><li><span class="members">Logged in as <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></span></li><li><a class="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a></li><!-- TMPL_ELSE --><li><a href="/cgi-bin/koha/opac-user.pl">Your Account</a></li><!-- /TMPL_IF -->
	</ul>	
</div>

<div id="opac-main-search" class="clearfix">

   <div id="masthead">
   <h1 id="libraryname"><a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_IF NAME="LibraryName" --><!-- TMPL_VAR NAME="LibraryName" --><!-- TMPL_ELSE -->Koha Online Catalog<!-- /TMPL_IF --></a></h1>
   </div>

</div>
