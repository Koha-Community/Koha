[% BLOCK selectoptionopen %]
    [% IF value == selected %]<option value='[% value | html %]' selected='selected'>
    [% ELSE %]<option value='[% value | html %]'>
    [% END %]
[% END %]
