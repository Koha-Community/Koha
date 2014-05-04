[% USE AuthorisedValues %]
[%#
    Parameters:
    name: the name of the select element
    category: the authorised value category
    default: the default authorised value to select
    class: the CSS class of the select element
    size: the size to use for the input (generated if the authorised value category does not exist).
%]

[% SET avs = AuthorisedValues.GetAuthValueDropbox( category, default ) %]
[% DEFAULT
    class = ''
    size = 20
%]

[% IF avs %]
  <select id="[% name %]" name="[% name %]" class="[% class %]" >
  [% FOR av IN avs %]
    [% IF av.default %]
      <option value="[% av.value %]" selected="selected">[% av.label | html_entity %]</option>
    [% ELSE %]
      <option value="[% av.value %]">[% av.label | html_entity %]</option>
    [% END %]
  [% END %]
  </select>
[% ELSE %]
  <input type="text" id="[% name %]" name="[% name %]" size="[% size %]" value="[% default | html_entity %]" class="[% class %]" />
[% END %]
