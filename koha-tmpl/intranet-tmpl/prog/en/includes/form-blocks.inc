[% BLOCK selectoption %]
    [% IF value == selected %]<option value='[% value %]' selected='selected'>[% text %]</option>
    [% ELSE %]<option value='[% value %]'>[% text %]</option>
    [% END %]
[% END %]
