[% BLOCK options_for_libraries %]
    [% FOREACH l IN libraries %]
        [% IF l.selected %]
            <option value="[% l.branchcode | html %]" selected="selected">[% l.branchname | html %]</option>
        [% ELSE %]
            <option value="[% l.branchcode | html %]">[% l.branchname | html %]</option>
        [% END%]
    [% END %]
[% END %]

[% BLOCK koha_news_block %]
    [% IF ( news.content && news.content.count > 0 ) %]
        <div id="[% news.location | html %]">
            [% FOREACH n IN news.content %]
                <div class="[% n.lang | html %]_item">
                    [% IF ( n.title && news.blocktitle ) %]
                        <h4 class="[% n.lang | html %]_header">[% n.title | html %]</h4>
                    [% END %]
                    <div class="[% n.lang | html %]_body">[% n.content | $raw %]</div>
                </div>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK biblio_a_href -%]
    [%- IF Koha.Preference('BiblioDefaultView') == 'marc' -%]
        [%- SET this_biblio_href = "/cgi-bin/koha/opac-MARCdetail.pl?biblionumber=" -%]
    [%- ELSIF Koha.Preference('BiblioDefaultView') == 'isbd' -%]
        [%- SET this_biblio_href = "/cgi-bin/koha/opac-ISBDdetail.pl?biblionumber=" -%]
    [%- ELSE -%]
        [%- SET this_biblio_href = "/cgi-bin/koha/opac-detail.pl?biblionumber=" -%]
    [%- END -%]
    [%- this_biblio_href | url %][% biblionumber | url -%]
[%- END %]

[% # BOOTSTRAP TAB WRAPPER USAGE                                                                         %]
[% #     [ WRAPPER tabs id= "tabs_container_id" ]                                                        %]
[% #         [ WRAPPER tabs_nav ]                                                                        %]
[% #             [ WRAPPER tab_item tabname= "tab_name_1" bt_active= 1 ] <span>Tab text 1</span> [ END ] %]
[% #             [ WRAPPER tab_item tabname= "tab_name_2" ] <span>Tab text 2</span> [ END ]              %]
[% #             ...                                                                                     %]
[% #         [ END ]                                                                                     %]
[% #         [ WRAPPER tab_panels ]                                                                      %]
[% #             [ WRAPPER tab_panel tabname="tab_name_1" bt_active= 1 ] Panel contents 1 [ END ]        %]
[% #             [ WRAPPER tab_panel tabname="tab_name_2" ] Panel contents 2 [ END ]                     %]
[% #             ...                                                                                     %]
[% #         [ END ]                                                                                     %]
[% #     [ END ]                                                                                         %]

[% BLOCK tabs %]
    [% IF ( id ) %]
        <div id="[% id | html %]" class="toptabs">
    [% ELSE %]
        <div class="toptabs">
    [% END %]
        [% content | $raw %]
    </div>
[% END %]

[% BLOCK tabs_nav %]
    <ul class="nav nav-tabs" role="tablist">
        [% content | $raw %]
    </ul>
[% END %]

[% BLOCK tab_item %]
    <li class="nav-item" role="presentation">
        [% IF ( bt_active ) %]
            [% SET link_class="nav-link active" %]
            [% SET aria_selected="true" %]
        [% ELSE %]
            [% SET link_class="nav-link" %]
            [% SET aria_selected="false" %]
        [% END %]
        [% IF ( tabid ) %]
            [% SET our_tab_id = tabid %]
        [% ELSE %]
            [% SET our_tab_id = tabname %]
        [% END %]
        <a href="#[% tabname | uri %]_panel" class="[% link_class | html %]" id="[% our_tab_id | html %]-tab" data-toggle="tab" data-target="#[% tabname | html %]_panel" data-tabname="[% tabname | uri %]" aria-controls="[% tabname | uri %]_panel" role="tab" aria-selected="[% aria_selected | html %]">
            [% content | $raw %]
        </a>
    </li>
[% END %]

[% BLOCK tab_panels %]
    [% IF ( id ) %]
        <div class="tab-content" id="[% id | html %]_content">
    [% ELSE %]
        <div class="tab-content">
    [% END %]
        [% content | $raw %]
    </div>
[% END %]

[% BLOCK tab_panel %]
    [% IF ( bt_active ) %]
        <div role="tabpanel" class="tab-pane show active" id="[% tabname | html %]_panel" aria-labelledby="[% tabname | html %]-tab">
    [% ELSE %]
        <div role="tabpanel" class="tab-pane" id="[% tabname | html %]_panel" aria-labelledby="[% tabname | html %]-tab">
    [% END %]
        [% content| $raw %]
    </div>
[% END %]
