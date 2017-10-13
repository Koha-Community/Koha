[% BLOCK options_for_libraries %]
    [% FOREACH l IN libraries %]
        [% IF l.selected %]
            <option value="[% prefix %][% l.branchcode | html %]" selected="selected">[% l.branchname %]</option>
        [% ELSE %]
            <option value="[% prefix %][% l.branchcode | html %]">[% l.branchname |html %]</option>
        [% END%]
    [% END %]
[% END %]

[% BLOCK options_for_authorised_value_categories %]
    [% FOREACH avc IN authorised_value_categories %]
        [% IF avc.selected %]
            <option value="[% avc.category %]" selected="selected">[% avc.category %]</option>
        [% ELSE %]
            <option value="[% avc.category %]">[% avc.category %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_item_types %]
    [% FOREACH itemtype IN itemtypes %]
        [% IF itemtype.itemtype == selected_itemtype %]
            <option value="[% itemtype.itemtype %]" selected="selected">
        [% ELSE %]
            <option value="[% itemtype.itemtype %]">
        [% END %]
            [% itemtype.translated_description %]
        </option>
    [% END %]
[% END %]
