[% USE Branches %]
[% USE Koha %]
[% PROCESS 'patronfields.inc' %]
[% IF CAN_user_borrowers_edit_borrowers %]
    <div id="patron_search" class="residentsearch">
        <form method="post" action="/cgi-bin/koha/members/member.pl">
            <input type="hidden" name="quicksearch" value="1" />

            <span class="form-title">
                <label class="control-label">Search patrons</label>
            </span>

            <span class="form-content">
                [% IF ( Koha.Preference('RetainPatronsSearchTerms') ) %]
                    <input name="searchmember" id="searchmember" class="head-searchbox form-control" type="text" placeholder="Enter patron card number or partial name" size="25" value="[% searchmember | html %]"/>
                [% ELSE %]
                    <input name="searchmember" id="searchmember" class="head-searchbox form-control" type="text" placeholder="Enter patron card number or partial name" size="25"/>
                [% END %]

                <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <div class="form-extra-content">
                <div>
                    <label for="searchfieldstype" class="control-label">Search fields</label>
                    <select name="searchfieldstype" id="searchfieldstype" class="form-control">
                        [% SET standard = Koha.Preference('DefaultPatronSearchFields') || 'firstname,middle_name,surname,othernames,cardnumber,userid' %]
                        [% default_fields = [ standard, 'surname', 'cardnumber', 'email', 'borrowernumber', 'userid', 'phone', 'address', 'dateofbirth', 'sort1', 'sort2' ] %]
                        [% search_options = default_fields.merge(standard.split(',')).unique %]
                        [% FOREACH s_o IN search_options %]
                            [% display_name = PROCESS patron_fields name=s_o %]
                            [% NEXT IF !display_name.length %]
                            [% IF searchfieldstype == s_o %]
                                <option value="[% s_o | html %]">[% display_name | $raw %]</option>
                            [% ELSE %]
                                <option value="[% s_o | html %]">[% display_name | $raw %]</option>
                            [% END %]
                        [% END %]
                    </select>
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
