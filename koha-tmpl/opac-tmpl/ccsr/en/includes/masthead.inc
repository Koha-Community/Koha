<div id="header-wrapper">

<div id="top-bar">
<ul id="menu-left">
    <!-- [% IF ( opacbookbag ) %] -->
        <li>
            <span id="cmspan"></span>
            <div id="cartDetails">Your cart is empty.</div>
        </li>
    <!-- [% END %] -->

    [% IF ( virtualshelves ) %]

    <li id="listsmenulink">
        <a href="/cgi-bin/koha/opac-shelves.pl"  class="">
            <span>Lists</span>
        </a>
    <div id="listsmenu" class="yuimenu" style="display: none">
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
    </div><!-- /listmenu /virtualshelves -->
[% END %]
<div id="listsDetails"></div>

</li>
</ul>

    <div id="members">
      [% IF ( opacuserlogin ) %]
        <ul>
    [% UNLESS ( loggedinusername ) %]
                   <li><a href="/cgi-bin/koha/opac-user.pl">Log in to your account</a></li>[% END %]
                [% IF ( loggedinusername ) %]
                    <li><span class="members">Welcome, <a href="/cgi-bin/koha/opac-user.pl"><span class="loggedinusername">[% FOREACH USER_INF IN USER_INFO %][% USER_INF.title %] [% USER_INF.firstname %] [% USER_INF.surname %][% END %]</span></a></span></li>

                [% END %]
                [% IF ( ShowOpacRecentSearchLink ) %]
                    <li><a href="/cgi-bin/koha/opac-search-history.pl" title="View your search history">Search history</a></li>
                [% END %]
 [% IF ( loggedinusername ) %]<li>[% IF persona %]<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1" onclick='navigator.id.logout();'>[% ELSE %]<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">[% END %]Log Out</a></li>[% END %]
        </ul>
      [% END %]
    </div>

    <div class="clear"></div>

</div>

<div id="opac-main-search" class="yui-g">

<a class="logo" href="/cgi-bin/koha/opac-main.pl">
  [% UNLESS ( opacsmallimage ) %]
      [% UNLESS ( LibraryName ) %]
    <img src="/opac-tmpl/ccsr/images/logo-koha.png" alt="Koha Online Catalog" />
      [% ELSE %]
    <img src="/opac-tmpl/ccsr/images/logo-koha.png" alt="[% LibraryName %] Online Catalog" />
      [% END %]
  [% ELSE %]
      [% UNLESS ( LibraryName ) %]
    <img src="[% opacsmallimage %]" alt="Koha Online Catalog" />
      [% ELSE %]
    <img src="[% opacsmallimage %]" alt="[% LibraryName %] Online Catalog" />
      [% END %]
  [% END %]
</a>

<div id="fluid">

[% IF ( OpacPublic ) %]
<div id="fluid-offset">
[% UNLESS ( advsearch ) %]
[% IF ( OpacAddMastheadLibraryPulldown ) %]
    [% IF ( OpacShowFiltersPulldownMobile and not OpacShowLibrariesPulldownMobile ) or ( not OpacShowFiltersPulldownMobile and OpacShowLibrariesPulldownMobile ) %]
        <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform" class="multi-libraries single-field-mobile">
    [% ELSE %]
        <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform" class="multi-libraries">
    [% END %]
[% ELSE %]
    <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform" class="single-library">
[% END %]
    <label for="masthead_search" class="left"> Search
    [% UNLESS ( OpacAddMastheadLibraryPulldown ) %]
            [% IF ( mylibraryfirst ) %] (in [% mylibraryfirst %] only)[% END %]
    [% END %]
    </label>
    [% IF ( OpacShowFiltersPulldownMobile ) %]
        <div id="filters">
    [% ELSE %]
        <div id="filters" class="mobile-hidden">
    [% END %]
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
        [% IF ( ms_callnum ) %]
        <option selected="selected" value="callnum">Call number</option>
        [% ELSE %]
        <option value="callnum">Call number</option>
        [% END %]</select>
    </div>

<div class="input-wrapper">
[% IF ( ms_value ) %]
        <input type="text" id = "transl1" name="q" value="[% ms_value |html %]" class="left" style="width: 35%; font-size: 111%;"/><div id="translControl"></div>
[% ELSE %]
        <input type="text" id = "transl1" name="q" class="left" style="width: 35%; font-size: 111%;"/><div id="translControl"></div>
[% END %]
</div>

   [% IF ( OpacAddMastheadLibraryPulldown ) %]
        [% IF ( OpacShowLibrariesPulldownMobile ) %]
            <div id="libraries">
        [% ELSE %]
            <div id="libraries" class="mobile-hidden">
        [% END %]

        <select name="branch_group_limit" id="select_library" class="left">
           <option value="">All libraries</option>
           <optgroup label="Libraries">
               [% FOREACH BranchesLoo IN BranchesLoop %]
                  [% IF ( BranchesLoo.selected ) %]<option selected="selected" value="branch:[% BranchesLoo.value %]">[% BranchesLoo.branchname %]</option>
                  [% ELSE %]<option value="branch:[% BranchesLoo.value %]">[% BranchesLoo.branchname %]</option>[% END %]
               [% END %]
           </optgroup>
           [% IF BranchCategoriesLoop %]
               <optgroup label="Groups">
                   [% FOREACH bc IN BranchCategoriesLoop %]
                       [% IF ( bc.selected ) %]
                           <option selected="selected" value="multibranchlimit-[% bc.categorycode %]">[% bc.categoryname %]</option>
                       [% ELSE %]
                           <option value="multibranchlimit-[% bc.categorycode %]">[% bc.categoryname %]</option>
                       [% END %]
                   [% END %]
               </optgroup>
           [% END %]
        </select>

    </div>
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

    <div class="clear"></div>

    </form>
[% ELSE %] <!--advsearch -->
    [% IF ( OpacAddMastheadLibraryPulldown ) %]
        [% IF ( OpacShowFiltersPulldownMobile and not OpacShowLibrariesPulldownMobile ) or ( not OpacShowFiltersPulldownMobile and OpacShowLibrariesPulldownMobile ) %]
            <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform" class="multi-libraries single-field-mobile">
        [% ELSE %]
            <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform" class="multi-libraries">
        [% END %]
    [% ELSE %]
        <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform" class="single-library">
    [% END %]
    <label for="masthead_search" class="left"> Search
    [% UNLESS ( OpacAddMastheadLibraryPulldown ) %]
            [% IF ( mylibraryfirst ) %] (in [% mylibraryfirst %] only)[% END %]
    [% END %]
    </label>
    [% IF ( OpacShowFiltersPulldownMobile ) %]
        <div id="filters" class="transparent">
    [% ELSE %]
        <div id="filters" class="transparent mobile-hidden">
    [% END %]
        <select name="idx" id="masthead_search" class="left" disabled="disabled">
            <option selected="selected" value="">Library Catalog</option>
        </select>
    </div>

<div class="input-wrapper">
    <input type="text" id = "transl1" name="q" class="left transparent" style="width: 35%; font-size: 111%;" disabled="disabled"/><div id="translControl"></div>
</div>

   [% IF ( OpacAddMastheadLibraryPulldown ) %]
        [% IF ( OpacShowLibrariesPulldownMobile ) %]
            <div id="libraries">
        [% ELSE %]
            <div id="libraries" class="mobile-hidden">
        [% END %]
          <select name="limit" id="select_library" class="left transparent">
             <option value="">All Libraries</option>
          </select>
        </div>
   [% END %]


    <input type="submit" value="Go" id="searchsubmit" class="left transparent" disabled="disabled" />
[% IF ( opacbookbag ) %]<span id="cmspan"></span>[% END %]

    <div class="clear"></div>

    </form>
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

<div id="libraryname">
    [% IF ( opacheader ) %]
        <h1>
            [% opacheader %]
        </h1>
  [% END %]
</div>

[% END %]  <!-- OpacPublic -->

</div>
</div>

<div id="container">
<div id="ctn_lt">
<div id="ctn_rt">
<div id="ctn_lb">
<div id="ctn_rb">

<div id="breadcrumbs" class="yui-g">
<p><a href="/cgi-bin/koha/opac-main.pl" title="Home">Home</a>
[% IF ( searchdesc ) %]<span class="rsaquo"> &rsaquo; </span><a href="/cgi-bin/koha/opac-search.pl" title="Search">Search</a><span class="rsaquo"> &rsaquo; </span>
[% IF ( total ) %]<strong>Your search returned [% total |html %] results.</strong>
[% IF ( related ) %] (related searches: [% FOREACH relate IN related %][% relate.related_search %][% END %]). [% END %]
<a href="[% OPACBaseURL %]/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;count=[% countrss |html %]&amp;sort_by=acqdate_dsc&amp;format=rss2" class="rsssearchlink">
<img src="/opac-tmpl/ccsr/images/feed-icon-16x16.png" alt="Subscribe to this search" title="Subscribe to this search" border="0" class="rsssearchicon"/></a>
[% ELSE %]
<strong>No results found!</strong>
<p>
    [% IF ( searchdesc ) %]
    No results found for that in [% LibraryName %] catalog. <a href="[% OPACBaseURL %]/cgi-bin/koha/opac-search.pl?[% query_cgi |html %][% limit_cgi |html %]&amp;format=rss2" class="rsssearchlink"><img src="/opac-tmpl/ccsr/images/feed-icon-16x16.png" alt="Subscribe to this search" title="Subscribe to this search" border="0" class="rsssearchicon"/></a>
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

<div class="ctn_in">
