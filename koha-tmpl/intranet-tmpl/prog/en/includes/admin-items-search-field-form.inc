<ul>
  <li>
    <label for="name">Name</label>
    [% IF field %]
      <input type="text" name="name" value="[% field.name %]" disabled="disabled">
      <input type="hidden" name="name" value="[% field.name %]">
    [% ELSE %]
      <input type="text" name="name" />
    [% END %]
  </li>
  <li>
    <label for="label">Label</label>
    [% IF field %]
      <input type="text" name="label" value="[% field.label %]" />
    [% ELSE %]
      <input type="text" name="label" />
    [% END %]
  </li>
  <li>
    <label for="tagfield">MARC field</label>
    <select name="tagfield">
      [% FOREACH tagfield IN ['001'..'999'] %]
        [% IF field && field.tagfield == tagfield %]
          <option value="[% tagfield %]" selected="selected">[% tagfield %]</option>
        [% ELSE %]
          <option value="[% tagfield %]">[% tagfield %]</option>
        [% END %]
      [% END %]
    </select>
  </li>
  <li>
    <label for="tagsubfield">MARC subfield</label>
    <select name="tagsubfield">
      [% codes = [''] %]
      [% codes = codes.merge([0..9], ['a'..'z']) %]
      [% FOREACH tagsubfield IN codes %]
        [% IF field && field.tagsubfield == tagsubfield %]
          <option value="[% tagsubfield %]" selected="selected">[% tagsubfield %]</option>
        [% ELSE %]
          <option value="[% tagsubfield %]">[% tagsubfield %]</option>
        [% END %]
      [% END %]
    </select>
  </li>
  <li>
    <label for="authorised_values_category">Authorised values category</label>
    <select name="authorised_values_category">
      <option value="">- None -</option>
      [% FOREACH category IN authorised_values_categories %]
        [% IF field && field.authorised_values_category == category %]
          <option value="[% category %]" selected="selected">[% category %]</option>
        [% ELSE %]
          <option value="[% category %]">[% category %]</option>
        [% END %]
      [% END %]
    </select>
  </li>
</ul>
