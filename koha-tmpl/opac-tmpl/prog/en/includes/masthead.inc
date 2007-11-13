<div id="masthead">
<h1 id="libraryname"><a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_VAR NAME="LibraryName" --></a></h1>
</div>

<div id="members">
	<ul><!--TMPL_IF NAME="virtualshelves" --><li><a href="/cgi-bin/koha/opac-shelves.pl">Virtual Shelves</a></li><!-- /TMPL_IF --><!-- TMPL_IF NAME="loggedinusername" --><li><a href="/cgi-bin/koha/opac-user.pl">Your Account</a></li><!-- /TMPL_IF --><!-- TMPL_IF NAME="loggedinusername" --><li><span class="members">Logged in as <span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></span></li><li><a class="logout" href="/cgi-bin/koha/opac-logout.pl">Log Out</a></li><!-- TMPL_ELSE --><li><a href="/cgi-bin/koha/opac-user.pl">Your Account</a></li><!-- /TMPL_IF -->
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
