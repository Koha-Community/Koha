[% USE AuthorisedValues %]
[% IF wrap_fieldset != 0 %]
<fieldset class="rows">
    <legend>Additional fields</legend>
    <ol>
[% END %]
        [% FOR field IN available %]
            <li>
                <label for="additional_field_[% field.id %]"> [% field.name %]: </label>
                [% IF field.authorised_value_category %]
                    <select name="additional_field_[% field.id %]" id="additional_field_[% field.id %]">
                        [% FOREACH av IN AuthorisedValues.Get( field.authorised_value_category, values.${field.name} ) %]
                            [% IF av.selected %]
                                <option value="[% av.authorised_value %]" selected="selected">[% av.lib %]</option>
                            [% ELSE %]
                                <option value="[% av.authorised_value %]">[% av.lib %]</option>
                            [% END %]
                        [% END %]
                    </select> (Authorised values for [% field.authorised_value_category %])
                [% ELSE %]
                    [% IF field.marcfield %]
                        <input type="text" value="[% values.${field.name} %]" id="additional_field_[% field.id %]" name="additional_field_[% field.id %]" readonly="readonly" />
                        This value will be filled with the [% field.marcfield %] subfield of the selected biblio.
                    [% ELSE %]
                        <input type="text" value="[% values.${field.name} %]" id="additional_field_[% field.id %]" name="additional_field_[% field.id %]" />
                    [% END %]
                [% END %]
            </li>
        [% END %]
[% IF wrap_fieldset != 0 %]
    </ol>
</fieldset>
[% END %]
