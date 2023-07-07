[% USE Koha %]
[% USE I18N %]
[% USE Branches %]
[% USE raw %]
[% USE Asset %]
[% USE To %]

[%# Display a simple form %]
[% BLOCK patron_search_filters_simple  %]
    <form id="patron_search_form">
        <div class="hint">Enter patron card number or partial name:</div>
        <input type="text" size="40" id="search_patron_filter" class="focus" autocomplete="off" />
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
[%- SET searchtype = Koha.Preference('DefaultPatronSearchMethod') -%]
[% BLOCK patron_search_filters %]
    <form id="patron_search_form">
        <fieldset class="brief">
            <h3>Search for patron</h3>
            <ol>
                <li>
                    <label for="search_patron_filter">Search:</label>
                    <input type="text" id="search_patron_filter" value="[% search_filter | html %]" class="focus" />
                </li>

                [% FOR f IN filters %]
                    [% SWITCH f %]
                    [% CASE 'branch' %]
                        <li>
                            <label for="branchcode_filter">Library:</label>
                            <select id="branchcode_filter">
                                [% SET libraries = Branches.all( only_from_group => 1 ) %]
                                [% IF libraries.size != 1 %]
                                    <option value="">Any</option>
                                [% END %]
                                [% FOREACH l IN libraries %]
                                    <option value="[% l.branchcode | html %]">[% l.branchname | html %]</option>
                                [% END %]
                            </select>
                        </li>
                    [% CASE 'category' %]
                        <li>
                            <label for="categorycode_filter">Category:</label>
                            <select id="categorycode_filter">
                                <option value="">Any</option>
                                [% FOREACH category IN categories %]
                                    <option value="[% category.categorycode | html %]">[% category.description | html %]</option>
                                [% END %]
                            </select>
                        </li>
                    [% CASE 'sort1' %]
                        <li>
                            <label for="sort1_filter">Sort1:</label>
                            [% PROCESS 'av-build-dropbox.inc' name="sort1_filter", category="Bsort1", empty=1, size = 20 %]
                        </li>
                    [% CASE 'sort2' %]
                        <li>
                            <label for="sort2_filter">Sort2:</label>
                            [% PROCESS 'av-build-dropbox.inc' name="sort2_filter", category="Bsort2", empty=1, size = 20 %]
                        </li>
                    [% CASE 'search_field' %]
                        <li>
                            [% INCLUDE patron_fields_dropdown %]
                        </li>
                    [% CASE 'search_type' %]
                        <li>
                            <label for="searchtype_filter">Search type:</label>
                            <select name="searchtype" id="searchtype_filter">
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
            <fieldset class="action">
                <input type="submit" class="btn btn-primary" value="Search" />
                <input type="button" value="Clear" id="clear_search" />
            </fieldset>
        </fieldset>
    </form>
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

    [% IF filter == 'suggestions_managers' %]
        <div class="hint">Only staff with superlibrarian or suggestions_manage permissions are returned in the search results</div>
    [% ELSIF filter == 'orders_managers' %]
        <div class="hint">Only staff with superlibrarian or acquisitions permissions (or order_manage permission if granular permissions are enabled) are returned in the search results</div>
    [% ELSIF filter == 'funds_owners' OR filter == 'funds_users' %]
        <div class="hint">Only staff with superlibrarian or acquisitions permissions (or budget_modify permission if granular permissions are enabled) are returned in the search results</div>
    [% ELSIF filter == 'erm_users' %]
        <div class="hint">Only staff with superlibrarian or ERM permissions are returned in the search results</div>
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


    <h3 style="display: none;">Patrons found for: <span id="searchpattern"></span></h3>

    <div id="[% table_id | html %]_search_results" style="display:none;">

        <div id="info" class="dialog message" style="display: none;"></div>
        <div id="error" class="dialog alert" style="display: none;"></div>

        <input type="hidden" id="firstletter_filter" value="" />
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
                            [% CASE 'dateexpiry' %]<th>Expires on</td>
                            [% CASE 'borrowernotes' %]<th>Notes</th>
                            [% CASE 'phone' %]<th>Phone</th>
                            [% CASE 'checkouts' %]<th>Checkouts</th>
                            [% CASE 'account_balance' %]<th>Fines</th>
                            [% CASE 'action' %]<th>&nbsp;</th>
                        [% END %]
                    [% END %]
                </tr>
              </thead>
            <tbody></tbody>
        </table>
    </div>

<!-- Patron preview modal -->
<div class="modal" id="patronPreview" tabindex="-1" role="dialog" aria-labelledby="patronPreviewLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="patronPreviewLabel"></h4>
            </div>
            <div class="modal-body">
                <div id="loading">
                    <img src="[% interface | html %]/[% theme | html %]/img/spinner-small.gif" alt="" /> Loading
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
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
[%# columns: list of columns that will be displayed. Possible values are: 'checkbox', 'cardnumber', 'dateofbirth', 'address', 'name', 'name-address', 'branch', 'category', 'dateexpiry', 'borrowernotes, 'phone', 'checkouts', 'account_balance', 'action' %]
[%# preview_on_name_click: Open a modal window with patron's info when the name is clicked %]
[%# actions: list of buttons to display in the action column. Possible values are: 'select', 'add', 'edit', 'checkout' %]
[%# sticky_header and sticky_to: If we need a sticky header %]
[%# callback: name of the JS function that will be called when a patron is selected. Only work with action=select %]
[%# display_search_description: boolean, default off. Display the description of the search %]
[% BLOCK patron_search_js %]

    [% IF redirect_if_one_result && !redirect_url %]
        <script>console.log("Wrong call of patron_search_js - missing redirect_url");</script>
    [% END %]

    <script>
        let categories = [% To.json(categories) | $raw %].map(e => {
            e['_id'] = e.categorycode.toLowerCase();
            e['_str'] = e.description;
            return e;
        });
        let categories_map = categories.reduce((map, e) => {
            map[e._id] = e;
            return map;
        }, {});
        let libraries  = [% To.json(libraries) | $raw %].map(e => {
            e['_id'] = e.branchcode;
            e['_str'] = e.branchname;
            return e;
        });
        let libraries_map = libraries.reduce((map, e) => {
            map[e._id] = e;
            return map;
        }, {});

        [% IF Koha.Preference('ExtendedPatronAttributes') && extended_attribute_types %]
            let extended_attribute_types = [% To.json(extended_attribute_types || []) | $raw %];
        [% END %]

        $(document).ready(function() {
            $('select#sort1_filter').select2({allowClear:true});
            $('select#sort2_filter').select2({allowClear:true});
        });
    </script>

    [% INCLUDE 'datatables.inc' %]
    [% INCLUDE 'js-patron-get-age.inc' %]
    [% INCLUDE 'js-patron-format.inc' %]
    [% INCLUDE 'js-patron-format-address.inc' %]
    [% IF sticky_header %]
        [% Asset.js("lib/hc-sticky.js") | $raw %]
    [% END %]

    <script>
        var first_draw = 0;
        let patrons_table;
        var Sticky;
        var singleBranchMode = '[% singleBranchMode | html %]';
        let logged_in_library_id = "[% Branches.GetLoggedInBranchcode | html %]";
        [% IF do_not_defer_loading %]
            let defer_loading = 0;
        [% ELSE %]
            let defer_loading = 1;
        [% END %]

        /* popstate event triggered by forward and back button. Need to refresh search */
        window.addEventListener('popstate', (event) => {
            getSearchByLocation( false );
        });

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

            $("#info").hide();
            $("#error").hide();

            // Build the aLengthMenu
            var aLengthMenu = [
                [% Koha.Preference('PatronsPerPage') | html %], 10, 20, 50, 100, -1
            ];
            jQuery.unique(aLengthMenu);
            aLengthMenu.sort(function( a, b ){
                // Put "All" at the end
                if ( a == -1 ) {
                    return 1;
                } else if ( b == -1 ) {
                    return -1;
                }
                return parseInt(a) < parseInt(b) ? -1 : 1;}
            );
            var aLengthMenuLabel = [];
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
                    let start_with = $("#firstletter_filter").val()
                    if (!start_with) return "";
                    return { "like": start_with + "%" }
                },
                "-and": function(){
                    let filters = [];

                    let search_type = $("#searchtype_filter").val() || "contains";
                    let search_fields = $("#searchfieldstype_filter").val();
                    let pattern = $("#search_patron_filter").val();

                    filters = buildPatronSearchQuery(
                        pattern,
                        {
                            search_type: search_type,
                            search_fields: search_fields,
                            ...(typeof extended_attribute_types != 'undefined' && {extended_attribute_types: extended_attribute_types})
                        }
                    );

                    let f_sort1 = $("#sort1_filter").val();
                    if ( f_sort1 ) {
                        filters.push({
                            "me.sort1": f_sort1
                        });
                    }
                    let f_sort2 = $("#sort2_filter").val();
                    if ( f_sort2 ) {
                        filters.push({
                            "me.sort2": f_sort2
                        });
                    }

                    return filters;
                }
            };

            [% UNLESS default_sort_column %]
                [% default_sort_column = "name" %]
            [% END %]
            [% SET order_column_index = 0 %]
            [% SET embed = ['extended_attributes'] %]
            patrons_table = $("#[% table_id | html %]").kohaTable({
                "ajax": {
                    "url": patron_search_url,
                    "dataSrc": function ( json ) {
                        [% IF redirect_if_one_result %]
                            // redirect if there is only 1 result.
                            if ( first_draw && json.recordsFiltered == 1 ) {
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
                "iDeferLoading": defer_loading,
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
                                    return "<label for='check" + data + "' class='content_hidden'>" + _("Select patron") + "</label><input type='checkbox' id='check" + data + "' class='selection' name='borrowernumber' value='" + data + "' />";
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
                                "data": "me.surname:me.firstname:me.middle_name:me.othernames:me.street_number:me.address:me.address2:me.city:me.state:me.postal_code:me.country",
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
                                        r += "<li>" + _("Email: ") + "<a href='mailto:" + encodeURIComponent(row.email) + "'>" + escape_str(row.email) + "</a></li>";
                                    }
                                    r += '</ul></div>'

                                    return r;
                                }
                            }
                            [% CASE 'name-address' %]
                            {
                                "data": "me.surname:me.firstname:me.othernames:me.street_number:me.address:me.address2:me.city:me.state:me.postal_code:me.country",
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
                                        r += "<li>" + _("Email: ") + "<a href='mailto:" + encodeURIComponent(row.email) + "'>" + escape_str(row.email) + "</a></li>";
                                    }
                                    r += '</ul></div>'

                                    return r;
                                }
                            }
                            [% CASE 'name' %]
                            {
                                "data": "me.surname:me.firstname:me.middle_name:me.othernames",
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
                                "data": "library_id",
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    let library_name = libraries_map[data].branchname
                                    if( !singleBranchMode && data == logged_in_library_id ) {
                                        return "<span class=\"currentlibrary\">" + escape_str(library_name) + "</span>";
                                    } else {
                                        return escape_str(library_name);
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
                                "searchable": true,
                                "orderable": true,
                                "render": function( data, type, row, meta ) {
                                    return data ? escape_str($date(data)) : "";
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
                                        return "<span class='overdue'><strong>"+row.overdues_count + "</strong></span>";
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

                            [% CASE 'action' %]
                            {
                                "data": function( row, type, val, meta ) {

                                    let patron_id = encodeURIComponent(row.patron_id);
                                    let action_node = "";
                                    [% FOR action IN actions %]
                                    [% SWITCH action %]
                                    [% CASE 'select' %]
                                        let patron_str = JSON.stringify(row);
                                        action_node += '<a href="#" class="btn btn-default btn-xs select_user" data-borrowernumber="' + patron_id + '">' + _("Select") + '</a>';
                                        let input_node = $('<input type="hidden" id="borrower_data' + patron_id + '" name="borrower_data'+ patron_id + '"/>');
                                        $(input_node).val(patron_str);
                                        action_node += $(input_node).prop('outerHTML');
                                    [% CASE 'add' %]
                                        action_node += '<a href="#" class="btn btn-default btn-xs add_user" data-borrowernumber="' + patron_id + '" data-firstname="' + encodeURIComponent(row.firstname) + '" data-surname="' + encodeURIComponent(row.surname) + '">' + _("Add") + '</a><input type="hidden" id="borrower_data' + patron_id + '" name="borrower_data'+ patron_id + '" />';
                                    [% CASE 'edit' %]
                                        action_node += '<a href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=' + patron_id + '" class="btn btn-default btn-xs"><i class="fa-solid fa-pencil" aria-hidden="true"></i> ' + _("Edit") + '</a>';
                                    [% CASE 'checkout' %]
                                        [% IF CAN_user_circulate_circulate_remaining_permissions %]
                                            action_node += '<a class="btn btn-default btn-xs" href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=' + patron_id + '"><i class="fa fa-barcode"></i> ' + _("Check out") + '</a>';
                                        [% END %]
                                    [% END %]
                                    [% END %]
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
                'bAutoWidth': false,
                'lengthMenu': [aLengthMenu, aLengthMenuLabel],
                'sPaginationType': 'full_numbers',
                "pageLength": [% Koha.Preference('PatronsPerPage') | html %],
                [% IF sticky_header %]
                "initComplete": function(settings, json) {
                    $("#[% sticky_header | html %]").show();
                    Sticky = $("#[% sticky_header | html %]");
                    Sticky.hcSticky({
                        stickTo: "#[% sticky_to | html %]",
                        stickyClass: "floating"
                    });
                },
                [% END %]
            }, typeof table_settings !== 'undefined' ? table_settings : null, 1, additional_filters);

            $("#patron_search_form").on('submit', filter);
            $("#patron_search_form").on('submit', update_search_type);
            $(".filterByLetter").on("click",function(e){
                e.preventDefault();
                filterByFirstLetterSurname($(this).text(), true);
            });
            $("body").on("click",".add_user",function(e){
                e.preventDefault();
                var borrowernumber = $(this).data("borrowernumber");
                var firstname = $(this).data("firstname");
                var surname = $(this).data("surname");
                add_user( borrowernumber, firstname + " " + surname );
            });

            $("body").on("click",".select_user",function(e){
                e.preventDefault();
                var borrowernumber = $(this).data("borrowernumber");
                var borrower_data = $("#borrower_data"+borrowernumber).val();
                select_user( borrowernumber, JSON.parse(borrower_data) );
            });

            $("body").on("click",".patron_preview", function( e ){
                e.preventDefault();
                var borrowernumber = $(this).data("borrowernumber");
                var page = "/cgi-bin/koha/members/moremember.pl?print=brief&borrowernumber=" + borrowernumber;
                $("#patronPreview .modal-body").load( page + " div.container-fluid" );
                $('#patronPreview').modal({show:true});
            });

            $("#patronPreview").on('hidden.bs.modal', function (e) {
                $("#patronPreview .modal-body").html("<img src=\"[% interface | html %]/[% theme | html %]/img/spinner-small.gif\" alt=\"\" /> Loading");
            });

            $("#clear_search").on("click",function(e){
                e.preventDefault();
                clearFilters();
                $("#searchpattern").parent().hide();
            });

            if ( !defer_loading ) {
                $("#patron_search_form").submit();
            }

            /* Initial page load does not trigger the popstate event, so we explicitly call this */
            getSearchByLocation( false );

        });

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

        function update_search_type(){
            $("#searchtype").val($("#searchtype_filter").val());
        }

        function update_search_description(){
            var searched = $("#searchfieldstype_filter").find("option:selected").text();
            if ( $("#search_patron_filter").val() ) {
                if ( $("#searchtype_filter").val() == 'starts_with' ) {
                    searched += _(" starting with ");
                } else {
                    searched += _(" containing ");
                }
                searched += "'" + $("#search_patron_filter").val() + "'";
            }
            if ( $("#firstletter_filter").val() ) {
                searched += _(" begins with ") + "'" + $("#firstletter_filter").val() +"'";
            }
            if ( $("#categorycode_filter").val() ) {
                searched += _(" with category ") + "'" + $("#categorycode_filter").find("option:selected").text() + "'";
            }
            if ( $("#branchcode_filter").val() ) {
                searched += _(" in library ") + $("#branchcode_filter").find("option:selected").text();
            }
            if ( $("#sort1_filter").val() ) {
                searched += _(" with sort1 ")
                if ( $("select#sort1_filter") ) {
                    searched += $("select#sort1_filter").find("option:selected").text();
                }
                else {
                    searched += $("#sort1_filter").val();
                }
            }
            if ( $("#sort2_filter").val() ) {
                searched += _(" with sort2 ");
                if ( $("select#sort2_filter") ) {
                    searched += $("select#sort2_filter").find("option:selected").text();
                }
                else {
                    searched += $("#sort2_filter").val();
                }
            }
            $("#searchpattern").text(searched);
            $("#searchpattern").parent().show();
        }

        function filter() {
            [% IF redirect_if_attribute_equal %]
                let filter = $("#search_patron_filter").val();
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
                            alert( _("An error occurred. Check the logs") );
                        }
                    });
                }
            [% END %]
            $("#firstletter_filter").val('');
            $("#[% table_id | html %]_search_results").show();

            let table_dt = patrons_table.DataTable();
            [% FOR c IN columns %]
                [% SWITCH c %]
                [% CASE 'branch' %]
                    library_id = $("#branchcode_filter").val() || "";
                    patrons_table.find('thead tr:eq(1) th[data-filter="libraries"] select').val(library_id);
                    table_dt.column([% loop.count - 1 %]).search(library_id ? '^'+library_id+'$' : '');
                [% CASE 'category' %]
                    let category_id = $("#categorycode_filter").val() || "";
                    patrons_table.find('thead tr:eq(1) th[data-filter="categories"] select').val(category_id);
                    table_dt.column([% loop.count - 1 %]).search(category_id ? '^'+category_id+'$' : '');
                [% END %]
            [% END %]
            table_dt.search("");
            first_draw = 1; // Only redirect if we are coming from here
            table_dt.draw();
            [% IF display_search_description %]
                update_search_description();
            [% END %]
            return false;
        }

        function clearFilters() {
            $("#searchfieldstype_filter option:first").prop("selected", true);
            $("#searchtype_filter option[value='[% searchtype || 'contains' | html %]']").prop("selected", true);
            $("#categorycode_filter option:first").prop("selected", true);
            $("#branchcode_filter option:first").prop("selected", true);
            $("#sort1_filter").val('').trigger("change");
            $("#sort2_filter").val('').trigger("change");
            $("#firstletter_filter").val('');
            $("#search_patron_filter").val('');
            /* remove any search string added by firstletter search */
            history.pushState( {}, null, window.location.href.split("?" )[0]);
            $("#[% table_id | html %]_search_results").hide();
            [% IF display_search_description %]
                update_search_description();
            [% END %]
        }

        // User has clicked on a letter
        function filterByFirstLetterSurname(letter, setstate ) {
            $("#firstletter_filter").val(letter);

            $("#[% table_id | html %]_search_results").show();

            if ( setstate ) {
                history.pushState( null, null, "?firstletter=" + letter );
            }

            patrons_table.DataTable().draw();
            [% IF display_search_description %]
                update_search_description();
            [% END %]
        }

        // modify parent window owner element
        function add_user(borrowernumber, borrowername) {
            var p = window.opener;
            // In one place (serials/routing.tt), the page is reload on every add
            // We have to wait for the page to be there
            function wait_for_opener () {
                if ( ! $(opener.document).find('body').size() ) {
                    setTimeout(wait_for_opener, 500);
                } else {
                    [%# Note that add_user could sent data instead of borrowername too %]
                    $("#info").hide();
                    $("#error").hide();
                    if ( p.add_user(borrowernumber, borrowername) < 0 ) {
                        $("#error").html(_("Patron '%s' is already in the list.").format(borrowername));
                        $("#error").show();
                    } else {
                        $("#info").html(_("Patron '%s' added.").format(borrowername));
                        $("#info").show();
                    }
                }
            }
            wait_for_opener();
        }
        function select_user(borrowernumber, data) {
            var p = window.opener;
            if ( p.document.getElementById("selected_patron_id") ) {
                p.document.getElementById("selected_patron_id").value = borrowernumber;
            } else {
                [%  IF callback %]
                    p.[% callback | html %](borrowernumber, data);
                [%  ELSE %]
                    p.select_user(borrowernumber, data);
                [% END %]
            }
            window.close();
        }
    </script>
[% END %]
