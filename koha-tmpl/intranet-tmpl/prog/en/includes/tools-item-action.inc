[% IF action == 'ignore' AND num_items == 0 %]
    No items were found during staging
    <input type ="hidden" name="item_action" value="ignore">
[% ELSE %]
    [% IF ( class_name ) %]
        <select name="item_action" id="item_action" class="[% class_name | html %]">
    [% ELSE %]
        <select name="item_action" id="item_action">
    [% END %]
        [% IF ( action == 'always_add' ) %]
            <option value="always_add" selected="selected">
        [% ELSE %]
            <option value="always_add">
        [% END %]
            Always add items</option>
        [% IF ( action == 'add_only_for_matches' ) %]
            <option value="add_only_for_matches" selected="selected">
        [% ELSE %]
            <option value="add_only_for_matches">
        [% END %]
            Add items only if matching bib was found</option>
        [% IF ( action == 'add_only_for_new' ) %]
            <option value="add_only_for_new" selected="selected">
        [% ELSE %]
            <option value="add_only_for_new">
        [% END %]
            Add items only if no matching bib was found</option>
        [% IF ( action == 'replace' ) %]
            <option value="replace" selected="selected">
        [% ELSE %]
            <option value="replace">
        [% END %]
            Replace items if matching bib was found (only for existing items)</option>
        [% IF ( action == 'ignore' ) %]
            <option value="ignore" selected="selected">
        [% ELSE %]
            <option value="ignore">
        [% END %]
        Ignore items</option>
    </select>
[% END %]
