[% USE Koha %]
[% USE I18N %]
[% USE Branches %]
[% USE ExtendedAttributeTypes %]
[% USE Categories %]
[% USE raw %]
[% USE Asset %]
[% USE To %]
[% USE AuthorisedValues %]
[% SET search_results_block_id = 'searchresults' %]
[% SET av_bsort1 = AuthorisedValues.Get('Bsort1') %]
[% SET av_bsort2 = AuthorisedValues.Get('Bsort2') %]

[%# Display a simple form %]
[% BLOCK patron_search_filters_simple  %]
    <form method="get" class="patron_search_form">
        <div class="hint">Enter patron card number or partial name:</div>
        <input type="text" size="40" id="search_patron_filter_simple" class="search_patron_filter focus" autocomplete="off" />
        <input type="submit" class="btn btn-primary" value="Search" />
    </form>
[% END %]

[%# Display a complex patron search form %]
[%# - Search: input %]
[%# You can then pass a list of filters %]
[%# - branch: select library list %]
[%# - category: select patron category list %]
[%# - sort1: select patron sort1 field %]
[%# - sort2: select patron sort2 field %]
[%# - search_field: select patron field list %]
[%# - search_type: select 'contains' or 'starts with' %]
[%- searchtype = searchtype || Koha.Preference('DefaultPatronSearchMethod') -%]
[% BLOCK patron_search_filters %]
    [% SET has_patron_search_filters_block = 1 %]
    <aside>
        <form method="get" class="patron_search_form">
            <fieldset class="brief">
                <h3>Search for patron</h3>
                <ol>
                    <li>
                        <label>Search:</label>
                        <input type="text" id="search_patron_filter" class="search_patron_filter focus" value="[% search_filter | html %]" />
                    </li>

                    [% FOR f IN filters %]
                        [% SWITCH f %]
                        [% CASE 'branch' %]
                            <li>
                                <label>Library:</label>
                                <select class="branchcode_filter">
                                    [% SET libraries = Branches.all( only_from_group => 1 ) %]
                                    [% IF libraries.size != 1 %]
                                        <option value="">Any</option>
                                    [% END %]
                                    [% FOREACH l IN libraries %]
                                        [% IF (l.branchcode == branchcode_filter) %]
                                            <option value="[% l.branchcode | html %]" selected="selected">[% l.branchname | html %]</option>
                                        [% ELSE %]
                                            <option value="[% l.branchcode | html %]">[% l.branchname | html %]</option>
                                        [% END %]
                                    [% END %]
                                </select>
                            </li>
                        [% CASE 'category' %]
                            <li>
                                <label>Category:</label>
                                <select class="categorycode_filter">
                                    <option value="">Any</option>
                                    [% FOREACH category IN Categories.limited.unblessed %]
                                        [% IF ( category.categorycode == categorycode_filter ) %]
                                            <option value="[% category.categorycode | html %]" selected="selected">[% category.description | html %]</option>
                                        [% ELSE %]
                                            <option value="[% category.categorycode | html %]">[% category.description | html %]</option>
                                        [% END %]
                                    [% END %]
                                </select>
                            </li>
                        [% CASE 'sort1' %]
                            <li>
                                <label>Sort 1:</label>
                                [% PROCESS 'av-build-dropbox.inc' no_id => 1, name="sort1_filter", category="Bsort1", empty=1, size = 20 %]
                            </li>
                        [% CASE 'sort2' %]
                            <li>
                                <label>Sort 2:</label>
                                    [% PROCESS 'av-build-dropbox.inc' no_id => 1, name="sort2_filter", category="Bsort2", empty=1, size = 20 %]
                            </li>
                        [% CASE 'search_field' %]
                            <li>
                                [% INCLUDE patron_fields_dropdown %]
                            </li>
                        [% CASE 'search_type' %]
                            <li>
                                <label>Search type:</label>
                                <select name="searchtype" class="searchtype_filter">
                                    [% IF searchtype == "starts_with" %]
                                        <option value='starts_with' selected="selected">Starts with</option>
                                        <option value="contains">Contains</option>
                                    [% ELSE %]
                                        <option value='starts_with'>Starts with</option>
                                        <option value="contains" selected="selected">Contains</option>
                                    [% END %]
                                </select>
                            </li>
                        [% END %]
                    [% END %]
                </ol>
            </fieldset>
            <fieldset class="action">
                <input type="submit" class="btn btn-primary" value="Search" />
                <input type="button" value="Clear" class="btn btn-default clear_search" />
            </fieldset>
        </form>
    </aside>
[% END %]

[%# Display the table with: %]
[%# - At the top a hint about a possible filter %]
[%# - Browse by last name %]
[%# - The table %]
[%# Get the following parameters: %]
[%# - filter: can be 'suggestions_managers', 'orders_managers', 'funds_owners', 'funds_users' or 'erm_users' to filter patrons on their permissions %]
[%# - table_id: the ID of the table %]
[%# open_on_row_click: See patron_search_js %]
[%# columns: See patron_search_js %]
[% BLOCK patron_search_table %]

    [% UNLESS table_id %]
        [% SET table_id = "memberresultst" %]
    [% END %]

    [% IF filter == 'suggestions_managers' %]
        <div class="alert alert-info">Only staff with superlibrarian or full suggestions permissions are returned in the search results</div>
    [% ELSIF filter == 'orders_managers' OR filter == 'baskets_managers' %]
        <div class="alert alert-info">Only staff with superlibrarian or acquisitions permissions (or order_manage permission if granular permissions are enabled) are returned in the search results</div>
    [% ELSIF filter == 'funds_owners' OR filter == 'funds_users' %]
        <div class="alert alert-info">Only staff with superlibrarian or acquisitions permissions (or budget_modify permission if granular permissions are enabled) are returned in the search results</div>
    [% ELSIF filter == 'erm_users' %]
        <div class="alert alert-info">Only staff with superlibrarian or ERM permissions are returned in the search results</div>
    [% END %]

    <div class="browse">
        Browse by last name:
        [% SET alphabet = Koha.Preference('alphabet').split(' ') %]
        [% UNLESS alphabet.size %]
            [% alphabet = ['A' .. 'Z'] %]
        [% END %]
        [% FOREACH letter IN alphabet %]
            <a href="#" class="filterByLetter">[% letter | html %]</a>
        [% END %]
    </div>

    <h3 style="display: none;">Patrons found for: <span class="searchpattern"></span></h3>

    <div id="[% table_id | html %]_search_results" style="display:none;">

        <div class="info alert alert-info" style="display: none; margin: 1em 0;"></div>
        <div class="error alert alert-warning" style="display: none; margin: 1em 0"></div>

        <input type="hidden" class="firstletter_filter" value="" />
        [% IF open_on_row_click %]
        <table id="[% table_id | html %]" class="selections-table">
        [% ELSE %]
        <table id="[% table_id | html %]">
        [% END %]
            <thead>
                <tr>
                    [% FOR column IN columns %]
                        [% SWITCH column %]
                            [% CASE 'checkbox' %]<th class="noExport"></th>
                            [% CASE 'cardnumber' %]<th>Card</th>
                            [% CASE 'dateofbirth' %]<th>Date of birth</th>
                            [% CASE 'name' %]<th>Name</th>
                            [% CASE 'name-address' %]<th>Name</th>
                            [% CASE 'address' %]<th>Address</th>
                            [% CASE 'address-library' %]<th>Address</th>
                            [% CASE 'branch' %]<th data-filter="libraries">Library</th>
                            [% CASE 'category' %]<th data-filter="categories">Category</th>
                            [% CASE 'dateexpiry' %]<th>Expires on</th>
                            [% CASE 'borrowernotes' %]<th>Notes</th>
                            [% CASE 'phone' %]<th>Phone</th>
                            [% CASE 'checkouts' %]<th>Checkouts</th>
                            [% CASE 'account_balance' %]<th>Fines</th>
                            [% CASE 'sort1' %]
                                [% IF av_bsort1.size %]
                                    <th data-filter="av_bsort1">Sort 1</th>
                                [% ELSE %]
                                    <th>Sort 1</th>
                                [% END %]
                            [% CASE 'sort2' %]
                                [% IF av_bsort2.size %]
                                    <th data-filter="av_bsort2">Sort 2</th>
                                [% ELSE %]
                                    <th>Sort 2</th>
                                [% END %]
                            [% CASE 'action' %]<th class="noExport">&nbsp;</th>
                        [% END %]
                    [% END %]
                </tr>
              </thead>
            <tbody></tbody>
        </table>
    </div>

<!-- Patron preview modal -->
<div class="modal" id="patronPreview" tabindex="-1" role="dialog" aria-labelledby="patronPreviewLabel">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-body">
                <div id="loading">
                    <img src="[% interface | html %]/[% theme | html %]/img/spinner-small.gif" alt="" /> Loading
                </div>
            </div>
        </div>
    </div>
</div>

[% END %]

[%# Integrate all the JS code, outside of a script tag %]
[%# Get the following parameters: %]
[%# - redirect_if_one_result: Redirect to the patron if the search returns only one result, note that it will not redirect if filters of the DT are used (this is a feature) %]
[%# - redirect_url: The URL to use, the borrowernumber parameter will be added %]
[%# - redirect_if_attribute_equal: Name of the attribute to use for the redirect. Query using this attribute, before the normal search %]
[%# filter: Same as patron_search_table %]
[%# open_on_row_click: boolean, default off. Will allow to select a patron by clicking on the whole tr element %]
[%# columns: list of columns that will be displayed. Possible values are: 'checkbox', 'cardnumber', 'dateofbirth', 'address', 'name', 'name-address', 'branch', 'category', 'dateexpiry', 'borrowernotes, 'phone', 'checkouts', 'account_balance', 'sort1', 'sort2', 'action' %]
[%# preview_on_name_click: Open a modal window with patron's info when the name is clicked %]
[%# actions: list of buttons to display in the action column. Possible values are: 'select', 'add', 'edit', 'checkout' %]
[%# callback: name of the JS function that will be called when a patron is selected. Only work with action=select %]
[%# display_search_description: boolean, default off. Display the description of the search %]
[%# adjust_history: boolean, default off. Change the current url when a first letter is selected %]
[%# defer_loading: boolean, default on. If true, it will not load the table until a search is triggered %]
[% BLOCK patron_search_js %]

    [% IF redirect_if_one_result && !redirect_url %]
        <script>console.log("Wrong call of patron_search_js - missing redirect_url");</script>
    [% END %]

    <script>
        [% SET libraries = Branches.all %]
        [% SET categories = Categories.all.unblessed %]
        var categories = [% To.json(categories) | $raw %].map(e => {
            e['_id'] = e.categorycode.toLowerCase();
            e['_str'] = e.description;
            return e;
        });
        var categories_map = categories.reduce((map, e) => {
            map[e._id] = e;
            return map;
        }, {});
        var libraries  = [% To.json(libraries) | $raw %].map(e => {
            e['_id'] = e.branchcode;
            e['_str'] = e.branchname;
            return e;
        });
        var libraries_map = libraries.reduce((map, e) => {
            map[e._id] = e;
            return map;
        }, {});


        var av_bsort1= [% To.json(av_bsort1) | $raw %].map( e => {
            e['_id'] = e.authorised_value;
            e['_str'] = e.lib;
            return e;
        });
        var av_bsort1_map = av_bsort1.reduce((map, e) => {
            map[e._id] = e;
            return map;
        }, {});
        var av_bsort2= [% To.json(av_bsort2) | $raw %].map( e => {
            e['_id'] = e.authorised_value;
            e['_str'] = e.lib;
            return e;
        });
        var av_bsort2_map = av_bsort2.reduce((map, e) => {
            map[e._id] = e;
            return map;
        }, {});

        [% IF Koha.Preference('ExtendedPatronAttributes') %]
            [% SET extended_attribute_types = ExtendedAttributeTypes.codes( staff_searchable => 1, searched_by_default => 1 ) %]
            [% IF ( extended_attribute_types ) %][% extended_attribute_types = [ extended_attribute_types ]  %][% END %]
            var extended_attribute_types = [% To.json(extended_attribute_types || []) | $raw %];
        [% END %]

        $(document).on("shown.bs.modal", function(){
            $('select[name="sort1_filter"]').select2({allowClear:true});
            $('select[name="sort2_filter"]').select2({allowClear:true});
        }).on("hidden.bs.modal", function(){
            ["sort1_filter", "sort2_filter"].forEach(function(item){
                if( $('select[name=' +  item + ']').data("select2") ){
                    $('select[name=' +  item + ']').select2("destroy");
                }
            });
        });
    </script>

    [% INCLUDE 'datatables.inc' %]
    [% INCLUDE 'js-patron-get-age.inc' %]
    [% INCLUDE 'js-patron-format.inc' %]
    [% INCLUDE 'js-patron-format-address.inc' %]

    <script>
    {

        function get_patron_search_form(){
            let parent_block = $("#[% search_results_block_id | html %]");
            let patron_search_form = parent_block.parent().find(".patron_search_form");
            if ( !patron_search_form.length ) patron_search_form = $(".patron_search_form");
            return patron_search_form;
        }
        let first_draw = 0;
        let patrons_table;
        let singleBranchMode = '[% singleBranchMode | html %]';
        let logged_in_library_id = "[% Branches.GetLoggedInBranchcode | html %]";
        let defer_loading = Number( '[% defer_loading | html %]' || 1 );
        [% IF adjust_history %]
            /* popstate event triggered by forward and back button. Need to refresh search */
            window.addEventListener('popstate', (event) => {
                getSearchByLocation( false );
            });
        [% END %]

        [% SWITCH filter %]
        [% CASE 'suggestions_managers' %]
            let patron_search_url = '/api/v1/suggestions/managers';
        [% CASE 'baskets_managers' %]
            let patron_search_url = '/api/v1/acquisitions/baskets/managers';
        [% CASE 'funds_owners' %]
            let patron_search_url = '/api/v1/acquisitions/funds/owners';
        [% CASE 'funds_users' %]
            let patron_search_url = '/api/v1/acquisitions/funds/users';
        [% CASE 'erm_users' %]
            let patron_search_url = '/api/v1/erm/users';
        [% CASE %]
            let patron_search_url = '/api/v1/patrons';
        [% END %]

        $(document).ready(function(){

            let parent_block = $("#[% search_results_block_id | html %]");
            let patron_search_form = get_patron_search_form();

            parent_block.find(".info").hide();
            parent_block.find(".error").hide();

            // Build the aLengthMenu
            let aLengthMenu = [
                ...new Set([[% Koha.Preference('PatronsPerPage') | html %], 10, 20, 50, 100, -1])
            ];
            aLengthMenu.sort(function( a, b ){
                // Put "All" at the end
                if ( a == -1 ) {
                    return 1;
                } else if ( b == -1 ) {
                    return -1;
                }
                return parseInt(a) < parseInt(b) ? -1 : 1;}
            );
            let aLengthMenuLabel = [];
            $(aLengthMenu).each(function(){
                if ( this == -1 ) {
                    // Label for -1 is "All"
                    aLengthMenuLabel.push(_("All"));
                } else {
                    aLengthMenuLabel.push(this);
                }
            });

            let additional_filters = {
                surname: function(){
                    let start_with = parent_block.find(".firstletter_filter").val()
                    if (!start_with) return "";
                    return { "like": start_with + "%" }
                },
                "-and": function(){
                    let filters = [];

                    let search_type = patron_search_form.find(".searchtype_filter").val();
                    let search_fields = patron_search_form.find(".searchfieldstype_filter").val() || "standard";
                    let pattern = patron_search_form.find(".search_patron_filter").val();

                    filters = buildPatronSearchQuery(
                        pattern,
                        {
                            search_type: search_type,
                            search_fields: search_fields,
                            ...(typeof extended_attribute_types != 'undefined' && {extended_attribute_types: extended_attribute_types})
                        }
                    );

                    let f_sort1 = patron_search_form.find("select[name='sort1_filter']").val();
                    if ( f_sort1 ) {
                        filters.push({
                            "me.sort1": f_sort1
                        });
                    }
                    let f_sort2 = patron_search_form.find("select[name='sort2_filter']").val();
                    if ( f_sort2 ) {
                        filters.push({
                            "me.sort2": f_sort2
                        });
                    }

                    return filters;
                }
            };
            let external_filter_nodes = {};
            [% IF has_patron_search_filters_block %]
                external_filter_nodes = {
                    search_patron_filter: '.search_patron_filter',
                    firstletter_filter: '.firstletter_filter',
                    searchtype_filter: '.searchtype_filter',
                    searchfieldstype_filter: '.searchfieldstype_filter',
                    categorycode_filter: '.categorycode_filter',
                    branchcode_filter: '.branchcode_filter'
                };
            [% END %]

            [% UNLESS default_sort_column %]
                [% default_sort_column = "name" %]
            [% END %]
            [% SET order_column_index = 0 %]
            [% SET embed = ['extended_attributes','library'] %]
            let table_node = $("#[% table_id | html %]");
            patrons_table = table_node.kohaTable({
                "ajax": {
                    "url": patron_search_url,
                    "dataSrc": function ( json ) {
                        [% IF redirect_if_one_result %]
                            // redirect if there is only 1 result.
                            // Do not redirect if state has been loaded
                            let loaded_from_state = table_node.data('loaded_from_state');
                            if ( !loaded_from_state && first_draw && json.recordsFiltered == 1 ) {
                                let url = '[% redirect_url | url %]'.indexOf("?") != -1
                                    ? '[% redirect_url | url %]&borrowernumber=' + json.data[0].patron_id
                                    : '[% redirect_url | url %]?borrowernumber=' + json.data[0].patron_id;
                                document.location.href = url;
                                return false;
                            }
                            first_draw = 0;
                        [% END %]
                        return json.data;
                    }
                },
                [% IF open_on_row_click OR preview_on_name_click OR remember_selections %]
                "drawCallback": function( settings ) {
                    var api = this.api();
                    var data = api.data();
                    if ( data.length == 0 ) return;

                    [% IF open_on_row_click %]
                    $.each($(this).find("tbody tr"), function(index, tr) {
                        let url = "[% on_click_url | url %]&borrowernumber=" + data[index].patron_id;
                        $(tr).off('click').on('click', function() {
                            document.location.href = url;
                        }).addClass('clickable');
                        $(tr).find("a.patron_name").attr('href', url);
                    });
                    [% END %]
                    [% IF preview_on_name_click %]
                    $.each($(this).find("tbody tr"), function(index, tr) {
                        $(tr).find("a.patron_name").addClass("patron_preview");
                    });
                    [% END %]
                    [% IF remember_selections %]
                        prepSelections();
                    [% END %]
                },
                [% END %]
                "deferLoading": defer_loading,
                "columns": [
                    [% FOR column IN columns %]
                        [% IF default_sort_column == column %]
                            [% order_column_index = loop.count - 1%]
                        [% END %]
                        [% SWITCH column %]
                            [% CASE 'checkbox' %]
                            {
                                "data": "patron_id",
                                "searchable": false,
                                "orderable": false,
                                "render": function( data, type, row, meta ) {
                                    return "<label for='check" + data + "' class='content_hidden'>" + _("Select patron") + "</label><input type='checkbox' class='check" + data + " selection' name='borrowernumber' value='" + data + "' />";
                                }
                            }
                            [% CASE 'cardnumber' %]
                            {
                                "data": "cardnumber",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    let patron_id = encodeURIComponent(row.patron_id);
                                    [% IF !open_on_row_click AND CAN_user_circulate_circulate_remaining_permissions %]
                                        return "<a href=\"/cgi-bin/koha/circ/circulation.pl?borrowernumber=" + patron_id + "\" title=\"[% I18N.t("Check out") | html %]\" class=\"patron_name\" data-borrowernumber=\"" + patron_id + "\" style=\"white-space:nowrap\">" + escape_str(data) + "</a>";
                                    [% ELSE %]
                                        return escape_str(data);
                                    [% END %]
                                }

                            }
                            [% CASE 'dateofbirth' %]
                            {
                                "data": "date_of_birth",
                                "type": "date",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    return data ? "<span class=\"dateofbirth\">" + escape_str($date(data)) + "<span class=\"agehint\"> (" + _("%s years").format($get_age(data)) + ")</span></span>" : "";
                                }
                            }
                            [% CASE 'address' %]
                            {
                                "data": "me.street_number:me.address:me.address2:me.city:me.state:me.postal_code:me.country",
                                "searchable": true,
                                "orderable": true,
                                 "render": function( data, type, row, meta ) {
                                    let r = '<div class="address"><ul>';
                                    r += $format_address(row, { no_line_break: true, include_li: true });
                                    r += '</div></ul>';
                                    return r;
                                }
                            }
                            [% CASE 'address-library' %]
                            {
                                "data": "me.street_number:me.address:me.address2:me.city:me.state:me.postal_code:me.country",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    let r = '<div class="address"><ul>';
                                    r += $format_address(row, { no_line_break: true, include_li: true });
                                    r += '</div></ul>';
                                    r += " " + escape_str(libraries_map[row.library_id].branchname);
                                    return r;
                                }
                            }
                            [% CASE 'name-address' %]
                            {
                                "data": "me.surname:me.preferred_name:me.firstname:me.middle_name:me.othernames:me.street_number:me.address:me.address2:me.city:me.state:me.postal_code:me.country",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    let patron_id = encodeURIComponent(row.patron_id);
                                    let r = '';
                                    [% IF ! open_on_row_click %]
                                    r += "<a href=\"/cgi-bin/koha/members/moremember.pl?borrowernumber=" + patron_id + "\" class=\"patron_name\" data-borrowernumber=\"" + patron_id + "\" style=\"white-space:nowrap\">" + $patron_to_html(row, { invert_name: 1 }) + "</a>";
                                    [% ELSE %]
                                    r += $patron_to_html(row, { invert_name: 1 });
                                    [% END %]
                                    r += '<br/>';
                                    r += '<div class="address"><ul>';
                                    r += $format_address(row, { no_line_break: true, include_li: true });

                                    if ( row.email ) {
                                        r += "<li class=\"patron_email\">" + _("Email: ") + "<a href='mailto:" + encodeURIComponent(row.email) + "'>" + escape_str(row.email) + "</a></li>";
                                    }
                                    r += '</ul></div>'

                                    return r;
                                }
                            }
                            [% CASE 'name' %]
                            {
                                "data": "me.surname:me.preferred_name:me.firstname:me.middle_name:me.othernames",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    let patron_id = encodeURIComponent(row.patron_id);
                                    [% IF ! open_on_row_click %]
                                    return "<a href=\"/cgi-bin/koha/members/moremember.pl?borrowernumber=" + patron_id + "\" class=\"patron_name\" data-borrowernumber=\"" + patron_id + "\" style=\"white-space:nowrap\">" + $patron_to_html(row, { invert_name: 1 }) + "</a>";
                                    [% ELSE %]
                                    return $patron_to_html(row, { invert_name: 1 });
                                    [% END %]
                                }
                            }
                            [% CASE 'branch' %]
                            {
                                "data": "library.name:me.library_id",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    if( !singleBranchMode && row.library.library_id == logged_in_library_id ) {
                                        return "<span class=\"currentlibrary\">" + escape_str(row.library.name) + "</span>";
                                    } else {
                                        return escape_str(row.library.name);
                                    }
                                }
                            }
                            [% CASE 'category' %]
                            {
                                "data": "category_id",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    return escape_str(categories_map[data.toLowerCase()].description);
                                }
                            }
                            [% CASE 'dateexpiry' %]
                            {
                                "data": "expiry_date",
                                "type": "date",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    return "<span class=\"dateexpiry" + (new Date(data) < new Date() ? ' expired' : '') + "\">" + (data ? escape_str($date(data)) : '') + "</span>";
                                }
                            }
                            [% CASE 'borrowernotes' %]
                            {
                                "data": "staff_notes",
                                "searchable": true,
                                "orderable": true,
                                [%# We don't escape here, we allow html tag in staff notes %]
                            }
                            [% CASE 'phone' %]
                            {
                                "data": "phone",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    return escape_str(data);
                                }
                            }
                            [% CASE 'checkouts' %][% embed.push('checkouts+count', 'overdues+count') %]
                            {
                                "data": "",
                                "searchable": false,
                                "orderable": false,
                                "render": function( data, type, row, meta ) {
                                    if ( row.overdues_count ) {
                                        return "<span class='overdue'><strong>"+row.overdues_count + "</strong></span>" + " / " + row.checkouts_count;
                                    } else {
                                        return "0 / " + row.checkouts_count;
                                    }
                                }
                            }
                            [% CASE 'account_balance' %][% embed.push('account_balance') %]
                            {
                                "data": "",
                                "searchable": false,
                                "orderable": false,
                                "render": function( data, type, row, meta ) {
                                    let r = "<span style='text-align: right; display: block;'><a href=\"/cgi-bin/koha/members/boraccount.pl?borrowernumber="+row.patron_id+"\">";
                                    let balance_str = row.account_balance || 0;
                                    balance_str = balance_str.escapeHtml().format_price();
                                    if ( row.account_balance < 0 ) {
                                        // FIXME Format price here
                                        r += "<span class='credit'>" + balance_str + "</span>";
                                    } else if ( row.account_balance > 0 ) {
                                        r += "<span class='debit'><strong>" + balance_str  + "</strong></span>"
                                    } else {
                                        r += balance_str;
                                    }
                                    r += "</a></span>";
                                    return r;
                                }
                            }


                            [% CASE 'sort1' %]
                            {
                                "data": "statistics_1",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    if (data === null) return '';
                                    let bsort1 = av_bsort1_map[data.toString()];
                                    return escape_str(bsort1 ? bsort1.lib : data);
                                }
                            }

                            [% CASE 'sort2' %]
                            {
                                "data": "statistics_2",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    if (data === null) return '';
                                    let bsort2 = av_bsort2_map[data.toString()];
                                    return escape_str(bsort2 ? bsort2.lib : data);
                                }
                            }


                            [% CASE 'action' %]
                            {
                                "data": function( row, type, val, meta ) {

                                    let patron_id = encodeURIComponent(row.patron_id);
                                    let action_node = "";
                                    [% FOR action IN actions %]
                                    [% SWITCH action %]
                                    [% CASE 'select' %]
                                        action_node += '<a href="#" class="btn btn-default btn-xs select_user" data-borrowernumber="' + patron_id + '">' + _("Select") + '</a>';
                                    [% CASE 'add' %]
                                        action_node += '<a href="#" class="btn btn-default btn-xs add_user" data-borrowernumber="' + patron_id + '">' + _("Add") + '</a>';
                                    [% CASE 'edit' %]
                                        action_node += '<a href="/cgi-bin/koha/members/memberentry.pl?op=edit_form&amp;destination=circ&amp;borrowernumber=' + patron_id + '" class="btn btn-default btn-xs"><i class="fa-solid fa-pencil" aria-hidden="true"></i> ' + _("Edit") + '</a>';
                                    [% CASE 'checkout' %]
                                        [% IF CAN_user_circulate_circulate_remaining_permissions %]
                                            action_node += '<a class="btn btn-default btn-xs" href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=' + patron_id + '"><i class="fa fa-barcode"></i> ' + _("Check out") + '</a>';
                                        [% END %]
                                    [% END %]
                                    [% END %]

                                    let patron_str = JSON.stringify(row);
                                    let input_node = $('<input type="hidden" name="borrower_data'+ patron_id + '"/>');
                                    $(input_node).val(patron_str);
                                    action_node += $(input_node).prop('outerHTML');

                                    return action_node;
                                },
                                "searchable": false,
                                "orderable": false
                            }
                        [% END %]
                        [% UNLESS loop.last %],[% END %]
                    [% END %]
                ],
                'embed': [% To.json(embed) | $raw %],
                "order": [[ [% order_column_index | html %], "asc" ]],
                "autoWidth": false,
                'lengthMenu': [aLengthMenu, aLengthMenuLabel],
                "pagingType": 'full_numbers',
                "pageLength": [% Koha.Preference('PatronsPerPage') | html %],
                [% IF sticky_header %]
                    "initComplete": function(settings, json) {
                        $("#[% sticky_header | html %]").show();
                    },
                [% END %]
                fixedHeader: false,
            }, typeof table_settings !== 'undefined' ? table_settings : null, 1, additional_filters, undefined, external_filter_nodes);

            patron_search_form.on('submit', filter);
            patron_search_form.on('submit', update_search_type);
            patron_search_form.on('submit', function(){
                parent_block.find(".searchheader").show();
            });


            $(".filterByLetter").on("click",function(e){
                e.preventDefault();
                filterByFirstLetterSurname($(this).text(), true);
            });
            patrons_table.on("click",".add_user",function(e){
                e.preventDefault();
                var borrowernumber = $(this).data("borrowernumber");
                var borrower_data = JSON.parse(patrons_table.find("input[name='borrower_data"+borrowernumber+"']").val());
                modal_add_user( borrowernumber, $patron_to_html( borrower_data, { display_cardnumber: false, url: false } ) );
            });
            patrons_table.on("click",".select_user",function(e){
                e.preventDefault();
                var borrowernumber = $(this).data("borrowernumber");
                var borrower_data = JSON.parse(patrons_table.find("input[name='borrower_data"+borrowernumber+"']").val());
                modal_select_user( borrowernumber, borrower_data );
                $(this).closest(".modal").modal('hide');
            });

            patrons_table.on("click",".patron_preview", function( e ){
                e.preventDefault();
                var borrowernumber = $(this).data("borrowernumber");
                var page = "/cgi-bin/koha/members/moremember.pl?print=brief&borrowernumber=" + borrowernumber;
                $("#patron_preview_modal").load( page + " div.container-fluid", function(){
                    $("#patron_preview_modal").find(".close_window").on("click", function(){
                        $('#patron_preview_modal').html(_("Loading...")).removeClass("show");
                    });
                });
                $("#patron_preview_modal").addClass("show");
            });

            $("#patronPreview").on('hidden.bs.modal', function (e) {
                $("#patronPreview .modal-body").html("<img src=\"[% interface | html %]/[% theme | html %]/img/spinner-small.gif\" alt=\"\" /> Loading");
            });

            patron_search_form.find(".clear_search").on("click",function(e){
                e.preventDefault();
                clearFilters();
                parent_block.find(".searchpattern").parent().hide();
            });

            let loaded_from_state = patrons_table.data('loaded_from_state');
            if ( !defer_loading || loaded_from_state ) {
                patron_search_form.submit();
            }

            [% IF adjust_history %]
                /* Initial page load does not trigger the popstate event, so we explicitly call this */
                getSearchByLocation( false );
            [% END %]
        });

        [% IF adjust_history %]
            function getSearchByLocation( setstate ){
                /* Check to see if the URL contains a search parameter */
                if( location.search != ""){
                    var params = new URLSearchParams( location.search );
                    var firstletter = params.get("firstletter");
                    /* Check to see if search is a first letter param */
                    if( firstletter ){
                        /* Trigger function to return search results by letter */
                        filterByFirstLetterSurname( firstletter, setstate );
                    }
                }
            }
        [% END %]

        function update_search_type(){
            $("#searchtype").val($("#searchtype_filter").val());
        }

        function update_search_description(){
            let parent_block = $("#[% search_results_block_id | html %]");
            let patron_search_form = get_patron_search_form();
            var searched = patron_search_form.find(".searchfieldstype_filter").find("option:selected").text();
            let pattern = patron_search_form.find(".search_patron_filter").val();
            if ( pattern ) {
                if ( patron_search_form.find(".searchtype_filter").val() == 'starts_with' ) {
                    searched += _(" starting with ");
                } else {
                    searched += _(" containing ");
                }
                searched += "'" + pattern + "'";
            }
            let firstletter_filter = parent_block.find(".firstletter_filter").val();
            if ( firstletter_filter ) {
                searched += _(" begins with ") + "'" + firstletter_filter +"'";
            }

            if ( patron_search_form.find(".categorycode_filter").val() ) {
                searched += _(" with category ") + "'" + patron_search_form.find(".categorycode_filter option:selected").text() + "'";
            }
            if ( patron_search_form.find(".branchcode_filter").val() ) {
                searched += _(" in library ") + patron_search_form.find(".branchcode_filter option:selected").text();
            }
            if ( patron_search_form.find("select[name='sort1_filter']").val() ) {
                searched += _(" with sort1 ")
                if ( patron_search_form.find("select[name='sort1_filter']") ) {
                    searched += patron_search_form.find("select[name='sort1_filter'] option:selected").text();
                }
                else {
                    searched += paron_search_form.find("select[name='sort1_filter']").val();
                }
            }
            if ( patron_search_form.find("select[name='sort2_filter']").val() ) {
                searched += _(" with sort2 ")
                if ( patron_search_form.find("select[name='sort2_filter']") ) {
                    searched += patron_search_form.find("select[name='sort2_filter'] option:selected").text();
                }
                else {
                    searched += paron_search_form.find("select[name='sort2_filter']").val();
                }
            }
            parent_block.find(".searchpattern").text(searched).parent().show();
        }

        function filter() {
            let parent_block = $("#[% search_results_block_id | html %]");
            let patron_search_form = get_patron_search_form();
            [% IF redirect_if_attribute_equal %]
                let filter = patron_search_form.find(".search_patron_filter").val();
                if ( filter ) {
                    $.ajax({
                        data: { cardnumber: filter, _match: 'exact' },
                        type: 'GET',
                        url: patron_search_url,
                        success: function(data) {
                            if ( data.length == 1 ) {
                                let url = '[% redirect_url | url %]'.indexOf("?") != -1
                                    ? '[% redirect_url | url %]&borrowernumber=' + data[0].patron_id
                                    : '[% redirect_url | url %]?borrowernumber=' + data[0].patron_id;
                                document.location.href = url;
                                return false;
                            }
                        },
                        error: function() {
                            alert( _("An error occurred. Check the logs for details.") );
                        }
                    });
                }
            [% END %]
            parent_block.find(".firstletter_filter").val('');
            $("#[% table_id | html %]_search_results").show();

            let table_dt = patrons_table.DataTable();
            let loaded_from_state = patrons_table.data('loaded_from_state');
            if ( !loaded_from_state ) {
                table_dt.search("").columns().search("");
                [% FOR c IN columns %]
                    [% SWITCH c %]
                    [% CASE 'branch' %]
                        let library_id = patron_search_form.find(".branchcode_filter").val() || "";
                        patrons_table.find('thead tr:eq(1) th[data-filter="libraries"] select').val(library_id);
                        table_dt.column([% loop.count - 1 %]).search(library_id ? '^'+library_id+'$' : '');
                    [% CASE 'category' %]
                        let category_id = patron_search_form.find(".categorycode_filter").val() || "";
                        patrons_table.find('thead tr:eq(1) th[data-filter="categories"] select').val(category_id.toLowerCase());
                        table_dt.column([% loop.count - 1 %]).search(category_id ? '^'+category_id+'$' : '');
                    [% END %]
                [% END %]
            }
            patrons_table.data('loaded_from_state', false);
            first_draw = 1; // Only redirect if we are coming from here
            table_dt.draw();
            [% IF display_search_description %]
                update_search_description();
            [% END %]
            return false;
        }

        function clearFilters() {
            let parent_block = $("#[% search_results_block_id | html %]");
            let patron_search_form = get_patron_search_form();
            patron_search_form.find(".searchfieldstype_filter option:first").prop("selected", true);
            patron_search_form.find(".searchtype_filter option[value='[% searchtype | html %]']").prop("selected", true);
            patron_search_form.find(".categorycode_filter option:first").prop("selected", true);
            patron_search_form.find(".branchcode_filter option:first").prop("selected", true);
            patron_search_form.find("select[name='sort1_filter']").val('').trigger("change");
            patron_search_form.find("select[name='sort2_filter']").val('').trigger("change");
            parent_block.find(".firstletter_filter").val('');
            patron_search_form.find(".search_patron_filter").val('');
            [% IF adjust_history %]
                /* remove any search string added by firstletter search */
                history.pushState( {}, null, window.location.href.split("?" )[0]);
            [% END %]
            $("#[% table_id | html %]_search_results").hide();
            [% IF display_search_description %]
                update_search_description();
            [% END %]
        }

        // User has clicked on a letter
        function filterByFirstLetterSurname(letter, setstate ) {
            let parent_block = $("#[% search_results_block_id | html %]");
            parent_block.find(".firstletter_filter").val(letter);

            $("#[% table_id | html %]_search_results").show();

            [% IF adjust_history %]
                if ( setstate ) {
                    history.pushState( null, null, "?firstletter=" + letter );
                }
            [% END %]

            patrons_table.DataTable().draw();
            [% IF display_search_description %]
                update_search_description();
            [% END %]
        }

        // modify parent window owner element
        function modal_add_user(borrowernumber, borrowername) {
            [%# Note that add_user could sent data instead of borrowername too %]
            let parent_block = $("#[% search_results_block_id | html %]");
            parent_block.find(".info").hide();
            parent_block.find(".error").hide();
            if ( add_user(borrowernumber, borrowername) < 0 ) {
                parent_block.find(".error").html(_("Patron '%s' is already in the list.").format(borrowername)).show();
            } else {
                parent_block.find(".info").html(_("Patron '%s' added.").format(borrowername)).show();
            }
        }
        function modal_select_user(borrowernumber, data) {
            if ( document.getElementById("selected_patron_id") ) {
                document.getElementById("selected_patron_id").value = borrowernumber;
            } else {
                [% IF callback %]
                    [% callback | html %](borrowernumber, data);
                [% ELSE %]
                    select_user(borrowernumber, data);
                [% END %]
            }
        }
    }
    </script>
[% END %]


[% BLOCK patron_search_modal %]
    [% UNLESS patron_search_modal_id %]
        [% patron_search_modal_id = "patron_search_modal" %]
    [% END %]
    [% UNLESS table_id %]
        [% table_id = "memberresultst" %]
    [% END %]

    [% search_results_block_id = patron_search_modal_id _ '_searchresults' %]

    <div id="[% patron_search_modal_id | html %]" class="modal modal-full patron_search_modal" tabindex="-1" role="dialog" aria-labelledby="patronSearchLabel" aria-hidden="true" data-backdrop="">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title" id="patronSearchLabel">[% modal_title | html %]</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    [% PROCESS patron_search_filters filters => ['branch','category','sort1','sort2'] %]

                    <div id="[% search_results_block_id | html %]" class="search_results_block"> <!-- FIXME removed style from #searchresults, is that bad? -->
                        [% IF columns.grep('checkbox').size %]
                            <div class="searchheader fh-fixedHeader" style="display:none;">
                                <div>
                                    <a href="#" class="btn btn-link select_all"><i class="fa fa-check"></i> Select all</a>
                                    |
                                    <a href="#" class="btn btn-link clear_all"><i class="fa fa-remove"></i> Clear all</a>
                                    <button class="add-selected btn btn-sm btn-default" type="submit">Add selected patrons</button>
                                </div>
                            </div>
                        [% END %]
                        [% PROCESS patron_search_table table_id => table_id, columns => columns %]
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default cancel" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    <div id="patron_preview_modal" class="basicModal"></div>

    <script>
        $(document).ready(function() {
            let parent_block = $("#[% search_results_block_id | html %]");
            parent_block.find(".select_all").on("click",function(e){
                e.preventDefault();
                parent_block.find(".selection").prop("checked", true).change();
            });
            parent_block.find(".clear_all").on("click",function(e){
                e.preventDefault();
                parent_block.find(".selection").prop("checked", false).change();
            });
            parent_block.find(".searchheader").hide();
            parent_block.find(".clear_search").on("click",function(e){$("#searchheader").hide();});

            parent_block.find('.add-selected').on('click', function(e) {
                e.preventDefault();
                var counter = 0;
                parent_block.find('tr:has(.selection:checked) .add_user').each(function(){
                    var borrowernumber = $(this).data('borrowernumber');
                    var firstname = $(this).data('firstname');
                    var surname = $(this).data('surname');
                    add_user( borrowernumber, firstname + ' ' + surname );
                    counter++;
                });
                parent_block.find('.info').html(_("%s Patrons added.").format(counter)).show();
            });
        });
    </script>
[% END %]
