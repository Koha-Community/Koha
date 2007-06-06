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
    <label for="masthead_search">Search</label>
    <form name="searchform" method="POST" action="/cgi-bin/koha/opac-search.pl" id="searchform">
        <input type="text" name="q" style="width: 30%;"/>
        <input type="submit" value="Search" class="submit" />
    </form>
    <a href="/cgi-bin/koha/opac-search.pl">more search options</a>
</div>