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
