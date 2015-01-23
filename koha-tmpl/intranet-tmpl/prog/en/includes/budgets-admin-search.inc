[% USE Koha %]
[% USE Branches %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Fund Admin Resident Search Box -->

<div id="header_search">
    <div id="budgets_search" class="residentsearch">
        <p class="tip">Search funds:</p>
        <form action="/cgi-bin/koha/admin/aqbudgets.pl" method="post">
            <label for="filter_budgetname">Fund code: </label><input class="query" type="text" name="filter_budgetname" id="filter_budgetname" size="20" value="[% filter_budgetname | html %]" />
            <label for="filter_budgetbranch">Library: </label>
            <select name="filter_budgetbranch" id="filter_budgetbranch" style="width:10em;">
                <option value=""></option>
                    [% FOREACH branchloo IN Branches.all( selected => selected_branchcode ) %]
                        [% IF branchloo.selected %]
                        <option value="[% branchloo.branchcode | html %]" selected="selected">[% branchloo.branchname | html %]</option>
                        [% ELSE %]
                        <option value="[% branchloo.branchcode | html %]" >[% branchloo.branchname | html %]</option>
                        [% END %]
                    [% END %]
            </select>
          <input type="hidden"  name="budget_period_id" value="[% budget_period_id | html %]" />
          <input type="submit" class="submit" name="filter" value="Submit" />
        </form>
    </div>

[% INCLUDE 'patron-search-box.inc' %]

    [% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
    <p class="tip">Enter search keywords:</p>
        <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
             [% IF ( Koha.Preference('IntranetCatalogSearchPulldown') ) %][% INCLUDE 'search_indexes.inc' %][% END %]
             <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="query form-text" />
                <input type="submit" value="Submit"  class="submit" />
        </form>
    </div>[% END %]
            <ul>
            <li><a class="keep_text" href="#budgets_search">Search funds</a></li>
            [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
            </ul>
</div>
</div>
<!-- End Suggestions Resident Search Box -->
