<!-- member-search-box.inc -->
[% USE Branches %]
[% USE Categories %]
[% USE Koha %]
[% PROCESS 'patronfields.inc' %]
[% IF CAN_user_borrowers_edit_borrowers %]
    [% IF( bs_tab_active ) %]
        <div id="patron_search" role="tabpanel" class="tab-pane active">
    [% ELSE %]
        <div id="patron_search" role="tabpanel" class="tab-pane">
    [% END %]
        <form method="post" action="/cgi-bin/koha/members/member.pl">
            <input type="hidden" name="quicksearch" value="1" />

            <div class="form-title">
                <label class="control-label">Search patrons</label>
            </div>

            <div class="form-content">
                [% IF ( Koha.Preference('RetainPatronsSearchTerms') ) %]
                    <input name="searchmember" id="searchmember" class="head-searchbox form-control" type="text" placeholder="Enter patron card number or partial name" size="25" value="[% searchmember | html %]"/>
                [% ELSE %]
                    <input name="searchmember" id="searchmember" class="head-searchbox form-control" type="text" placeholder="Enter patron card number or partial name" size="25"/>
                [% END %]

                <button type="button" class="form-extra-content-toggle"><i class="fa-solid fa-sliders"></i></button>
            </div>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <div class="form-extra-content">
                <div>
                    [% INCLUDE patron_fields_dropdown search_box=1 %]
                </div>

                <div>
                    <label for="searchtype" class="control-label">Search type</label>
                    <select name="searchtype" id="searchtype" class="form-control">
                        [% IF searchtype == 'start_with' %]
                            <option value='start_with'>Starts with</option>
                            <option value='contain'>Contains</option>
                        [% ELSE %]
                            <option value='start_with'>Starts with</option>
                            <option value='contain'>Contains</option>
                        [% END %]
                    </select>
                </div>

                <div>
                    [% SET branches = Branches.all( selected => branchcode_filter, only_from_group => 1 ) %]
                    <label for="branchcode" class="control-label">Library</label>
                    <select name="branchcode_filter" id="branchcode" class="form-control">
                        [% IF branches.size != 1 %]
                            <option value="">Any</option>
                        [% END %]
                        [% PROCESS options_for_libraries libraries => branches %]
                    </select>
                </div>

                <div>
                    [% SET categories = Categories.all() %]
                    <label for="categorycode" class="control-label">Category</label>
                    <select name="categorycode_filter" id="categorycode" class="form-control">
                        <option value="">Any</option>
                        [% FOREACH category IN categories %]
                            [% IF category.categorycode == categorycode_filter %]
                                <option value="[% category.categorycode | html %]" selected="selected">[% category.description | html %]</option>
                            [% ELSE %]
                                <option value="[% category.categorycode | html %]">[% category.description | html %]</option>
                            [% END %]
                        [% END %]
                    </select>
                </div>
            </div>
        </form>
    </div>
[% END %]
<!-- /member-search-box.inc -->
