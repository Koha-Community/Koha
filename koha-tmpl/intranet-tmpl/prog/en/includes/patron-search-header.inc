[% USE Koha %]
[% USE Branches %]
[% USE Categories %]
[% USE raw %]
[% PROCESS 'html_helpers.inc' %]
[% PROCESS 'patronfields.inc' %]
<div class="gradient">
<div id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></div><!-- Begin Patrons Resident Search Box -->
<div id="header_search">
    <div id="patron_search" class="residentsearch">
    <form action="/cgi-bin/koha/members/member.pl" method="post">
        <label class="tip" for="searchmember">Enter patron card number or partial name:</label>
    <div class="autocomplete">
        [% IF ( Koha.Preference('RetainPatronsSearchTerms') ) %]
        <input id="searchmember" data-toggle="tooltip" size="25" class="head-searchbox" name="searchmember" type="text" value="[% searchmember | html %]" autocomplete="off" />
        [% ELSE %]
        <input id="searchmember" data-toggle="tooltip" size="25" class="head-searchbox" name="searchmember" type="text" autocomplete="off" />
        [% END %]
        <input type="hidden" name="quicksearch" value="1" />
        <span class="filteraction" id="filteraction_off"> <a href="#">[-]</a></span>
        <span class="filteraction" id="filteraction_on"> <a href="#">[+]</a></span>
        <input value="Search" class="submit" type="submit" />
    </div>



    <div id="filters">
        <p><label for="searchfieldstype">Search fields:</label>
            <select name="searchfieldstype" id="searchfieldstype">
              [% SET standard = Koha.Preference('DefaultPatronSearchFields') || 'firstname,middle_name,surname,othernames,cardnumber,userid' %]
              [% default_fields = [ standard, 'surname', 'cardnumber', 'email', 'borrowernumber', 'userid', 'phone', 'address', 'dateofbirth', 'sort1', 'sort2' ] %]
              [% search_options = default_fields.merge(standard.split(',')).unique %]
              [% FOREACH s_o IN search_options %]
                  [% display_name = PROCESS patron_fields name=s_o %]
                  [% NEXT IF !display_name.length %]
                  [% IF searchfieldstype == s_o %]
                      <option selected="selected" value="[% s_o | html %]">[% display_name | $raw %]</option>
                  [% ELSE %]
                      <option value="[% s_o | html %]">[% display_name | $raw %]</option>
                  [% END %]
              [% END %]
            </select>
        </p>
        <p>
            <label for="searchtype">Search type:</label>
            <select name="searchtype" id="searchtype">
              [% IF searchtype == 'start_with' %]
                  <option selected="selected" value='start_with'>Starts with</option>
                  <option value='contain'>Contains</option>
              [% ELSE %]
                  <option value='start_with'>Starts with</option>
                  <option selected="selected" value='contain'>Contains</option>
              [% END %]
            </select>
        </p>

        <p>
            <label for="branchcode">Library: </label>
            [% SET branches = Branches.all( selected => branchcode_filter, only_from_group => 1 ) %]
            <select name="branchcode_filter" id="branchcode">
                [% IF branches.size != 1 %]
                  <option value="">Any</option>
                [% END %]
                [% PROCESS options_for_libraries libraries => branches %]
            </select>
        </p>

        <p>
            <label for="categorycode">Category: </label>
            [% SET categories = Categories.all() %]
            <select name="categorycode_filter" id="categorycode">
                <option value="">Any</option>
                [% FOREACH category IN categories %]
                    [% IF category.categorycode == categorycode_filter %]
                        <option value="[% category.categorycode | html %]" selected="selected">[% category.description | html %]</option>
                    [% ELSE %]
                        <option value="[% category.categorycode | html %]">[% category.description | html %]</option>
                    [% END %]
                [% END %]
            </select>
        </p>
    </div>
    </form>
</div>
    [% INCLUDE 'patron-search-box.inc' %]

    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
    <div id="checkin_search" class="residentsearch">
    <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
        <label class="tip" for="ret_barcode">Scan a barcode to check in:</label>
    <input class="head-searchbox" name="barcode" id="ret_barcode" size="40" accesskey="r" type="text" />
    <input value="Submit" class="submit" type="submit" />
    </form>
    </div>
        <div id="renew_search" class="residentsearch">
            <form method="post" action="/cgi-bin/koha/circ/renew.pl" autocomplete="off">
                <label class="tip" for="ren_barcode">Scan a barcode to renew:</label>
                <input class="head-searchbox" name="barcode" id="ren_barcode" size="40" type="text" />
                <input value="Submit" class="submit" type="submit" />
            </form>
        </div>
    [% END %]

    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a class="keep_text" href="#patron_search">Search patrons</a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#circ_search">Check out</a></li>[% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#checkin_search">Check in</a></li>[% END %]
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a class="keep_text" href="#renew_search">Renew</a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a class="keep_text" href="#catalog_search">Search the catalog</a></li>[% END %]
    </ul>
</div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Patrons Resident Search Box -->
