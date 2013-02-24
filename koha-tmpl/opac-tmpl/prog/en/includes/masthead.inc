<div id="header-wrapper"><div id="members">
  [% IF ( opacuserlogin ) %]
	<ul>
[% UNLESS ( loggedinusername ) %]
               <li><a href="/cgi-bin/koha/opac-user.pl">Log in to your account</a></li>[% END %]
            [% IF ( loggedinusername ) %]
                <li><span class="members">Welcome, <a href="/cgi-bin/koha/opac-user.pl"><span class="loggedinusername">[% FOREACH USER_INF IN USER_INFO %][% USER_INF.title %] [% USER_INF.firstname %] [% USER_INF.surname %][% END %]</span></a></span></li>

            [% END %]
            [% IF ( ShowOpacRecentSearchLink ) %]
                <li><a href="/cgi-bin/koha/opac-search-history.pl" title="View your search history">Search history</a> [<a class="logout" href="/cgi-bin/koha/opac-search-history.pl?action=delete" title="Delete your search history" onclick="return confirm(MSG_DELETE_SEARCH_HISTORY);">x</a>]</li>
            [% END %]
			[% IF ( loggedinusername ) %]<li>[% IF persona %]<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1" onclick='navigator.id.logout();'>[% ELSE %]<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">[% END %]Log Out</a></li>[% END %]
   	</ul>	
  [% END %]
</div>
  [% IF ( opacheader ) %]
	[% opacheader %]
  [% END %]
<div id="opac-main-search" class="yui-g">
   [% IF ( opacsmallimage ) %]
   <h1 id="libraryname" style="background-image: url('[% opacsmallimage %]');">
   [% ELSE %]
   <h1 id="libraryname">
   [% END %]<a href="/cgi-bin/koha/opac-main.pl">[% IF ( LibraryName ) %][% LibraryName %][% ELSE %]Koha Online Catalog[% END %]</a></h1>

<div id="fluid">

[% IF ( OpacPublic ) %]
<div id="fluid-offset">
[% UNLESS ( advsearch ) %]<form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform">
    <label for="masthead_search" class="left"> Search 
	[% UNLESS ( OpacAddMastheadLibraryPulldown ) %]
            [% IF ( mylibraryfirst ) %] (in [% mylibraryfirst %] only)[% END %]
	[% END %]
    </label>

	<select name="idx" id="masthead_search" class="left">
	[% IF ( ms_kw ) %]
        <option selected="selected" value="">Library catalog</option>
		[% ELSE %]
        <option value="">Library catalog</option>
		[% END %]
		[% IF ( ms_ti ) %]
        <option selected="selected" value="ti">Title</option>
		[% ELSE %]
        <option value="ti">Title</option>
		[% END %]
		[% IF ( ms_au ) %]
        <option selected="selected" value="au">Author</option>
		[% ELSE %]
        <option value="au">Author</option>
		[% END %]
		[% IF ( ms_su ) %]
        <option selected="selected" value="su">Subject</option>
		[% ELSE %]
        <option value="su">Subject</option>
		[% END %]
		[% IF ( ms_nb ) %]
		<option selected="selected" value="nb">ISBN</option>
		[% ELSE %]
		<option value="nb">ISBN</option>
		[% END %]
		[% IF ( ms_se ) %]
        <option selected="selected" value="se">Series</option>
		[% ELSE %]
        <option value="se">Series</option>
		[% END %]
                [% IF ( numbersphr ) %]
                [% IF ( ms_callnum ) %]
        <option selected="selected" value="callnum,phr">Call number</option>
                [% ELSE %]
        <option value="callnum,phr">Call number</option>
                [% END %]
                [% ELSE %]
                [% IF ( ms_callnum ) %]
        <option selected="selected" value="callnum">Call number</option>
                [% ELSE %]
        <option value="callnum">Call number</option>
                [% END %]
                [% END %]</select>
[% IF ( ms_value ) %]
        <input type="text" title="Type search term" id = "transl1" name="q" value="[% ms_value |html %]" class="left" style="width: 35%; font-size: 111%;"/><div id="translControl"></div>
[% ELSE %]
        <input type="text" title="Type search term" id = "transl1" name="q" class="left" style="width: 35%; font-size: 111%;"/><div id="translControl"></div>
[% END %]
   [% IF ( OpacAddMastheadLibraryPulldown ) %]
      <select name="limit" id="select_library" class="left">
         <option value="">All libraries</option>
         [% FOREACH BranchesLoo IN BranchesLoop %]
            [% IF ( BranchesLoo.selected ) %]<option selected="selected" value="branch:[% BranchesLoo.value %]">[% BranchesLoo.branchname %]</option>
            [% ELSE %]<option value="branch:[% BranchesLoo.value %]">[% BranchesLoo.branchname %]</option>[% END %]
         [% END %]
      </select>
   [% ELSE %]
      [% IF ( opac_limit_override ) %]
          [% IF ( opac_search_limit ) %]
            <input name="limit" value="[% opac_search_limit %]" type="hidden" />
          [% END %]
      [% ELSE %]
          [% IF ( mylibraryfirst ) %] 
               <input name="limit" value="branch:[% mylibraryfirst %]" type="hidden" />
          [% END %]
      [% END %]
   [% END %]


    <input type="submit" value="Go" id="searchsubmit" class="left" />
[% IF ( opacbookbag ) %]<span id="cmspan"></span>[% END %]

[% IF ( virtualshelves ) %]<a href="/cgi-bin/koha/opac-shelves.pl" id="listsmenulink">Lists</a>[% END %]
    </form>
[% ELSE %]
<div style="width:80%;*margin-bottom:-30px;">
[% IF ( virtualshelves ) %]<a href="/cgi-bin/koha/opac-shelves.pl" id="listsmenulink">Lists</a>[% END %][% IF ( opacbookbag ) %]<span id="cmspan"></span>[% END %]
</div>
[% END %]

<div id="moresearches">
<a href="/cgi-bin/koha/opac-search.pl">Advanced search</a>
[% IF ( OpacBrowser ) %]<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-browser.pl">Browse by hierarchy</a>[% END %]
[% IF ( OpacAuthorities ) %]<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-authorities-home.pl">Browse by author or subject</a>[% END %]
[% IF ( opacuserlogin && reviewson && OpacShowRecentComments ) %]<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-showreviews.pl">Recent comments</a>[% END %]
[% IF ( TagsEnabled ) %]<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-tags.pl">Tag cloud</a>[% END %]
[% IF ( OpacCloud ) %]<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-tags_subject.pl">Subject cloud</a>[% END %]
[% IF ( OpacTopissue ) %]<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-topissues.pl">Most popular</a>[% END %]
[% IF ( suggestion ) %]
  [% IF ( AnonSuggestions ) %]<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-suggestions.pl">Purchase suggestions</a>
  [% ELSIF ( OPACViewOthersSuggestions ) %]<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-suggestions.pl">Purchase suggestions</a>
  [% END %]
[% END %]
</div>
 </div>
</div>

[% END %]  <!-- OpacPublic --> 

[% IF ( opacbookbag ) %]<div id="cartDetails">Your cart is empty.</div>[% END %]

[% IF ( virtualshelves ) %]
<div id="listsmenu" class="yuimenu" style="display: none">
    <div class="bd">
    <h4>Public lists</h4>
		[% IF ( pubshelves ) %]
			<ul class="first-of-type">
			[% FOREACH pubshelvesloo IN pubshelvesloop %]
			<li class="yuimenuitem"><a href="/cgi-bin/koha/opac-shelves.pl?viewshelf=[% pubshelvesloo.shelfnumber %]&amp;sortfield=[% pubshelvesloo.sortfield %]">[% pubshelvesloo.shelfname |html %]</a></li>
			[% END %]
			<li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl?display=publicshelves">[View All]</a></li>
        </ul>
		[% ELSE %]
        No public lists
		[% END %]
  [% IF ( opacuserlogin ) %]
    <h4>Your lists</h4>
	[% IF ( loggedinusername ) %]
		[% IF ( barshelves ) %]
			<ul class="first-of-type">
			[% FOREACH barshelvesloo IN barshelvesloop %]
			<li class="yuimenuitem"><a href="/cgi-bin/koha/opac-shelves.pl?viewshelf=[% barshelvesloo.shelfnumber %]&amp;sortfield=[% barshelvesloo.sortfield %]">[% barshelvesloo.shelfname |html %]</a></li>
			[% END %]
        <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl?display=privateshelves">[View all]</a></li>
        </ul>
		[% ELSE %]
			<ul class="first-of-type">
        <li>No private lists</li>
        <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl?display=privateshelves">[New list]</a></li></ul>
		[% END %]
	[% ELSE %]
        <ul class="first-of-type"><li><a href="/cgi-bin/koha/opac-user.pl">Log in to create your own lists</a></li></ul>
	[% END %]
  [% END %]
	  </div>
</div><!-- /listmenu /virtualshelves -->
[% END %]
<div id="listsDetails"></div>
</div>
</div>
<div id="breadcrumbs" class="yui-g">
[% IF ( searchdesc ) %]<p>[% IF ( total ) %]<strong>Your search returned [% total |html %] results.</strong> [% IF ( related ) %] (related searches: [% FOREACH relate IN related %][% relate.related_search %][% END %]). [% END %]
<a href="[% OPACBaseURL %]/cgi-bin/koha/opac-search.pl?[% query_cgi |html |url %][% limit_cgi |html | url %]&amp;count=[% countrss |html %]&amp;sort_by=acqdate_dsc&amp;format=rss2" class="rsssearchlink"><img src="/opac-tmpl/prog/images/feed-icon-16x16.png" alt="Subscribe to this search" title="Subscribe to this search" class="rsssearchicon"/></a>
[% ELSE %]
<strong>No results found!</strong>
<p>
    [% IF ( searchdesc ) %]
    No results found for that in [% LibraryName %] catalog. <a href="[% OPACBaseURL %]/cgi-bin/koha/opac-search.pl?[% query_cgi | html | url %][% limit_cgi | html | url %]&amp;format=rss2" class="rsssearchlink"><img src="/opac-tmpl/prog/images/feed-icon-16x16.png" alt="Subscribe to this search" title="Subscribe to this search" border="0" class="rsssearchicon"/></a>
    [% ELSE %]
    You did not specify any search criteria.
    [% END %]
</p>
[% IF ( OPACNoResultsFound ) %]
<div id="noresultsfound">
[% OPACNoResultsFound %]
</div>
[% END %]

</div>
[% END %]</p>[% END %]</div>
