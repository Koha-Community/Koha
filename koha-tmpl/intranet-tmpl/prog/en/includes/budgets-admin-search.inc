[% USE Koha %]
[% USE Branches %]
<div id="header_search">

    <div id="budgets_search" class="residentsearch">
        <form action="/cgi-bin/koha/admin/aqbudgets.pl" method="post">
            <input type="hidden" name="budget_period_id" value="[% budget_period_id | html %]" />

            <span class="form-title">
                <label class="control-label">Search funds</label>
            </span>

            <span class="form-content">
                <input class="query form-control" type="text" name="filter_budgetname" id="filter_budgetname" value="[% filter_budgetname | html %]" placeholder="Search funds" />

                <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
            </span>

            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <div class="form-extra-content">
                <label for="filter_budgetbranch">Library</label>

                <select name="filter_budgetbranch" id="filter_budgetbranch" class="form-control">
                    <option value="">All libraries</option>
                    [% FOREACH branchloo IN Branches.all( selected => selected_branchcode ) %]
                        [% IF branchloo.selected %]
                            <option value="[% branchloo.branchcode | html %]" selected="selected">[% branchloo.branchname | html %]</option>
                        [% ELSE %]
                            <option value="[% branchloo.branchcode | html %]" >[% branchloo.branchname | html %]</option>
                        [% END %]
                    [% END %]
                </select>
            </div>
        </form>
    </div>

    [% INCLUDE 'patron-search-box.inc' %]

    [% INCLUDE 'catalogue-search-box.inc' %]

    <ul>
        <li><a title="Search funds" href="#budgets_search" class="keep_text"><i class="fa fa-credit-card"></i> <span class="tab-title">Search funds</span></a></li>
        [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]<li><a title="Check out" href="#circ_search" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Check out</span></a></li>[% END %]
        [% IF ( CAN_user_catalogue ) %]<li><a title="Search catalog" href="#catalog_search" class="keep_text"><i class="fa fa-fw fa-search"></i> <span class="tab-title">Search catalog</span></a></li>[% END %]
    </ul>
</div><!-- /header_search -->

<!-- End Suggestions Resident Search Box -->
