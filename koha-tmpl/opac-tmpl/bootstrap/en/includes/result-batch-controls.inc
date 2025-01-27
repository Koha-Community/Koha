<div class="selections-toolbar toolbar noprint">
    [% IF ( OpacHighlightedWords && results ) %]
        <div class="highlight_controls noprint">
            <a href="#" class="btn btn-link btn-sm highlight_toggle" id="highlight_toggle_off"><i class="fa-fw fa-solid fa-pencil" aria-hidden="true"></i> Unhighlight</a>
            <a href="#" class="btn btn-link btn-sm highlight_toggle" id="highlight_toggle_on"><i class="fa-fw fa-solid fa-pencil" aria-hidden="true"></i> Highlight</a>
        </div>
    [% END %]

    <div class="check_control">
        <!-- checkall, clearall are now needed for placehold -->
        <span class="clearall">
            <a id="CheckAll" class="btn btn-link btn-sm" href="#">Select all</a>
        </span>
        <span class="checkall">
            <a id="CheckNone" class="btn btn-link btn-sm" href="#">Clear all</a>
        </span>
    </div>

    <div class="links">
        [% IF ( TagsInputEnabled || CartEnabled || ListsEnabled || MultiHolds ) %]
            <span class="selections">Select titles to:</span>
        [% END %]

        [% IF ( CartEnabled ) %]
            <div class="btn-group">
                <button id="addtocart" class="btn btn-link btn-xs"> <i class="fa fa-shopping-cart" aria-hidden="true"></i> Add to cart </button>
            </div>
        [% END %]

        [% IF ( ListsEnabled ) %]
            <div class="btn-group">
                <button type="button" class="btn btn-link btn-xs dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i class="fa fa-list" aria-hidden="true"></i> Add to list <span class="caret"></span>
                </button>
                <div class="dropdown-menu">
                    [% IF add_to_some_private_shelves.count %]
                        <h6 class="dropdown-header">Your lists</h6>
                        [% SET number_of_private_shelves = 0 %]
                        [% FOREACH s IN add_to_some_private_shelves %]
                            [% IF shelfnumber != s.shelfnumber %]
                                <a href="#" class="dropdown-item addtolist" data-shelfnumber="[% s.shelfnumber | html %]">[% s.shelfname | html %]</a>
                                [% SET number_of_private_shelves = number_of_private_shelves + 1 %]
                                [% IF number_of_private_shelves == 10 %][% LAST %][% END %]
                            [% END %]
                        [% END %]
                    [% END %]
                    [% IF add_to_some_public_shelves.count %]
                        <h6 class="dropdown-header">Public lists</h6>
                        [% SET number_of_public_shelves = 0 %]
                        [% FOREACH s IN add_to_some_public_shelves %]
                            [% IF shelfnumber != s.shelfnumber %]
                                <a href="#" data-shelfnumber="[% s.shelfnumber | html %]" class="dropdown-item addtolist">[% s.shelfname | html %]</a>
                                [% SET number_of_public_shelves = number_of_public_shelves + 1 %]
                                [% IF number_of_public_shelves == 10 %][% LAST %][% END %]
                            [% END %]
                        [% END %]
                    [% END %]
                    <div class="dropdown-divider"></div>
                    [% IF add_to_some_private_shelves.count > 10 or add_to_some_public_shelves.count > 10 %]
                        <a href="#" class="dropdown-item addtolist morelists">More lists</a>
                    [% END %]
                    <a href="#" class="dropdown-item addtolist newlist">New list</a>
                </div>
            </div>
            [% IF loggedinusername && can_remove_biblios %]
                <button class="btn btn-link btn-sm disabled removeitems tag_hides"> <i class="fa fa-fw fa-remove" aria-hidden="true"></i> Remove from list </button>
            [% END %]
        [% END # /IF virtualshelves %]

        [% IF ( MultiHolds ) %]
            <button class="btn btn-link btn-sm hold disabled" type="button"> <i class="fa fa-fw fa-bookmark" aria-hidden="true"></i> Place hold </button>
        [% END %]

        [% IF ( TagsInputEnabled ) %]
            <span id="tagsel_span">
                <button id="tagsel_tag" class="btn btn-link btn-sm disabled" type="submit" style="display:none"><i class="fa fa-fw fa-tag" aria-hidden="true"></i> Tag</button>
            </span>
        [% END %]
    </div>
    <!-- / .links -->
    [% IF ( TagsInputEnabled ) %]
        <div id="tagsel_form" style="display:none">
            <label for="tagsel_new">New tag:</label>
            <input type="text" name="tagsel_new" id="tagsel_new" maxlength="100" />
            <input id="tagsel_button" name="tagsel_button" class="tagsel_button btn btn-sm btn-primary" title="Add" type="submit" value="Add" />
            <a href="#" id="tagsel_cancel">(done)</a>
        </div>
        <div id="tagsel_status" class="tagsel_tatus" style="display:none;"> Tag status here. </div>
    [% END %]
</div>
<!-- / .selections-toolbar -->
