[% BLOCK options_for_libraries %]
    [% FOREACH l IN libraries %]
        [% IF l.selected %]
            <option value="[% l.branchcode | html %]" selected="selected">[% l.branchname %]</option>
        [% ELSE %]
            <option value="[% l.branchcode | html %]">[% l.branchname %]</option>
        [% END%]
    [% END %]
[% END %]
