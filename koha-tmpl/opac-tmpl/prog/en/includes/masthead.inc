<div id="masthead-image">
        <!-- TMPL_IF NAME="opacsmallimage" -->
        <img alt="<!-- TMPL_VAR NAME="LibraryName" -->" src="<!-- TMPL_VAR NAME="opacsmallimage" -->" />
        <!-- TMPL_ELSE -->
			<img src="/opac-tmpl/<!-- TMPL_VAR name="theme" -->/images/koha-logo-blue.png" alt="koha logo"/>

        <!-- /TMPL_IF -->
</div>
<div id="masthead">
        <!-- TMPL_VAR NAME="LibraryName" -->
</div>
<div id="opac-main-search">
    Search
    <!-- TMPL_IF name="mylibraryfirst" --> <!-- TMPL_IF name="loggedinusername" -->(in <!-- TMPL_VAR name="LoginBranchcode" --> only)<!-- /TMPL_IF --><!-- /TMPL_IF -->
    <form name="searchform" method="post" action="/cgi-bin/koha/opac-search.pl" id="searchform">
        <input type="text" name="q" style="width: 30%;" />
        <!-- TMPL_IF name="mylibraryfirst" --><!-- TMPL_IF name="loggedinusername" -->
            <input name="limit" value="<!-- TMPL_VAR name="LoginBranchcode" -->" type="hidden" />
        <!-- /TMPL_IF --><!-- /TMPL_IF -->
        <input type="hidden" name="idx" value="kw,wrdl" />
        <input type="submit" value="OK" class="submit" />
    </form>
    <a href="/cgi-bin/koha/opac-search.pl">more search options</a>
</div>
