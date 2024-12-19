[% IF account.item_action == 'ignore' AND num_items == 0 %]
    No items were found during staging
    <input type ="hidden" name="item_action" value="ignore">
[% ELSE %]
    <select name="item_action" id="item_action" class="[% class_name | html %]">
        <option value="always_add" [% IF account.item_action == 'always_add' %]selected="selected"[% END %]>
            Always add items</option>
        <option value="add_only_for_matches" [% IF account.item_action == 'add_only_for_matches' %]selected="selected"[% END %]>
            Add items only if matching bib was found</option>
        <option value="add_only_for_new" [% IF account.item_action == 'add_only_for_new' %]selected="selected"[% END %]>
            Add items only if no matching bib was found</option>
        <option value="replace" [% IF account.item_action == 'replace' %]selected="selected"[% END %]>
            Replace items if matching bib was found (only for existing items)</option>
        <option value="ignore" [% IF account.item_action == 'ignore' %]selected="selected"[% END %]>
        Ignore items</option>
    </select>
[% END %]
