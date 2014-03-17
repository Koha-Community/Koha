[% USE AuthorisedValues %]
[%#
    Parameters:
    name: tthe name of the select element
    category: the authorised value category
    default: the default authorised value to select
    class: the css class of the select element
    size: the size to use for the input (generated if not authorised value category exist).
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
      <option value="[% av.value %]" selected="selected">[% av.label %]</option>
    [% ELSE %]
      <option value="[% av.value %]">[% av.label %]</option>
    [% END %]
  [% END %]
  </select>
[% ELSE %]
  <input type="text" id="[% name %]" name="[% name %]" size="[% size %]" value="[% default %]" class="[% class %]" />
[% END %]
