[% PROCESS 'html_helpers.inc' %]
<ol>
  <li>
      [% IF field %]
          <span class="label">Name: </span>
          [% field.name | html %]
          <input type="hidden" name="name" value="[% field.name | html %]">
      [% ELSE %]
          <label class="required" for="name">Name: </label>
          <input type="text" name="name" id="name" class="required" required="required" />
          <span class="required">Required</span>
      [% END %]
  </li>
  <li>
    <label class="required" for="label">Label: </label>
    [% IF field %]
        <input type="text" name="label" id="label" value="[% field.label | html %]" class="required" required="required" />
    [% ELSE %]
        <input type="text" name="label" id="label" class="required" required="required" />
    [% END %]
          <span class="required">Required</span>
  </li>
  <li>
    <label for="tagfield" required="required">MARC field: </label>
    <select id="tagfield" name="tagfield" class="required" required="required">
      [% FOREACH tagfield IN ['001'..'999'] %]
        [% IF field && field.tagfield == tagfield %]
          <option value="[% tagfield | html %]" selected="selected">[% tagfield | html %]</option>
        [% ELSE %]
          <option value="[% tagfield | html %]">[% tagfield | html %]</option>
        [% END %]
      [% END %]
    </select>
    <span class="required">Required</span>
  </li>
  <li>
    <label for="tagsubfield">MARC subfield: </label>
    <select id="tagsubfield" name="tagsubfield">
      [% codes = [''] %]
      [% codes = codes.merge([0..9], ['a'..'z']) %]
      [% FOREACH tagsubfield IN codes %]
        [% IF field && field.tagsubfield == tagsubfield %]
          <option value="[% tagsubfield | html %]" selected="selected">[% tagsubfield | html %]</option>
        [% ELSE %]
          <option value="[% tagsubfield | html %]">[% tagsubfield | html %]</option>
        [% END %]
      [% END %]
    </select>
  </li>
  <li>
    <label for="authorised_values_category">Authorised values category: </label>
    <select id="authorised_values_category" name="authorised_values_category">
      <option value="">- None -</option>
      [% PROCESS options_for_authorised_value_categories authorised_value_categories => AuthorisedValues.GetCategories( selected => field.authorised_values_category ) %]
    </select>
  </li>
</ol>
