[% BLOCK options_for_libraries %]
    [% FOREACH l IN libraries %]
        [% IF l.selected %]
            <option value="[% prefix | html %][% l.branchcode | html %]" selected="selected">[% l.branchname | html %]</option>
        [% ELSE %]
            <option value="[% prefix | html %][% l.branchcode | html %]">[% l.branchname | html %]</option>
        [% END%]
    [% END %]
[% END %]

[% BLOCK options_for_desks %]
    <option id="nodesk" value="">---</option>
    [% FOREACH d IN desks %]
        [% IF d.branchcode == branch %]
          [% IF selected == d.desk_id %]
            <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]" selected="selected">[% d.desk_name | html %]</option>
          [% ELSE %]
            <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]" >[% d.desk_name | html %]</option>
          [% END %]
        [% ELSE %]
            <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]" disabled hidden>[% d.desk_name | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_registers %]
    <!-- <option hidden disabled selected value> -- select an option -- </option> -->
    <option id="noregister"[% IF register_required %] disabled selected [% END %] value="">-- None --</option>
    [% FOREACH r IN registers %]
        [% IF r.branch == branch %]
            [% IF r.selected %]
                <option class="[% r.branch | html %] [% IF r.branch_default %]default[% END %]" value="[% r.id | html %]" selected="selected">[% r.name | html %]</option>
            [% ELSE %]
                <option class="[% r.branch | html %] [% IF r.branch_default %]default[% END %]" value="[% r.id | html %]">[% r.name | html %]</option>
            [% END%]
        [% ELSE %]
            <option class="[% r.branch | html %] [% IF r.branch_default %]default[% END %]" value="[% r.id | html %]" disabled hidden>[% r.name | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_authorised_value_categories %]
    [% FOREACH avc IN authorised_value_categories %]
        [% IF avc.selected %]
            <option value="[% avc.category | html %]" selected="selected">[% avc.category | html %]</option>
        [% ELSE %]
            <option value="[% avc.category | html %]">[% avc.category | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_item_types %]
    [% FOREACH itemtype IN itemtypes %]
        [% IF itemtype.itemtype == selected_itemtype %]
            <option value="[% itemtype.itemtype | html %]" selected="selected">
        [% ELSE %]
            <option value="[% itemtype.itemtype | html %]">
        [% END %]
            [% itemtype.translated_description | html %]
        </option>
    [% END %]
[% END %]
