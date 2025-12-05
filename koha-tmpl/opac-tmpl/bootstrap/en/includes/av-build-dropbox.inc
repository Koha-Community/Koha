[% USE AuthorisedValues %]
[%# Parameters: %] 
[%# name: the name of the select element %]
[%# category: the authorised value category %]
[%# default: the default authorised value to select %]
[%# class: the CSS class of the select element %]
[%# size: the size to use for the input (generated if the authorised value category does not exist). %]

[% SET avs = AuthorisedValues.GetAuthValueDropbox( category ) %]
[% DEFAULT class = '' size = 20 %]

[% IF avs.count %]
  [% IF required %]
      <select id="[% name | html %]" name="[% name | html %]" class="[% class | html %]" required="required">
  [% ELSE %]
      <select id="[% name | html %]" name="[% name | html %]" class="[% class | html %]">
  [% END %]
  [% IF blank %]
    <option value="">None</option>
  [% END %]
  [% FOR av IN avs %]
    [% IF av.authorised_value == default %]
      <option value="[% av.authorised_value | html %]" selected="selected">[% IF av.lib_opac %][% av.lib_opac | html_entity %][% ELSE %][% av.lib | html_entity %][% END %]</option>
    [% ELSE %]
      <option value="[% av.authorised_value | html %]">[% IF av.lib_opac %][% av.lib_opac | html_entity %][% ELSE %][% av.lib | html_entity %][% END %]</option>
    [% END %]
  [% END %]
  </select>
[% ELSE %]
  <input type="text" id="[% name | html %]" name="[% name | html %]" size="[% size | html %]" value="[% default | html_entity %]" class="[% class | html %]" />
[% END %]
