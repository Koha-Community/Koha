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
    [% IF ( news.size > 0 ) %]
        [% FOREACH n IN news %]
            <div class="[% n.lang | html %]_item">
                [% IF ( n.title ) %]
                    <h4 class="[% n.lang | html %]_header">[% n.title | html %]</h4>
                [% END %]
                <div class="[% n.lang | html %]_body">[% n.content | $raw %]</div>
            </div>
        [% END %]
    [% END %]
[% END %]
