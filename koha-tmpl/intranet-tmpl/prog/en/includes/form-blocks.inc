[% BLOCK selectoptionopen %]
    [% IF value == selected %]<option value='[% value %]' selected='selected'>
    [% ELSE %]<option value='[% value %]'>
    [% END %]
[% END %]
