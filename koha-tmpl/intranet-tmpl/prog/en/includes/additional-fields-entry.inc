[% USE AuthorisedValues %]
[% IF wrap_fieldset != 0 %]
<fieldset class="rows">
    <legend>Additional fields</legend>
    <ol>
[% END %]
        [% FOR field IN available %]
            <li>
                <label for="additional_field_[% field.id | html %]"> [% field.name | html %]: </label>
                [% IF field.authorised_value_category %]
                    <select name="additional_field_[% field.id | html %]" id="additional_field_[% field.id | html %]">
                        <option value=""></option>
                        [% FOREACH av IN AuthorisedValues.GetAuthValueDropbox( field.authorised_value_category ) %]
                            [% IF av.authorised_value == values.${field.id} %]
                                <option value="[% av.authorised_value | html %]" selected="selected">[% av.lib | html %]</option>
                            [% ELSE %]
                                <option value="[% av.authorised_value | html %]">[% av.lib | html %]</option>
                            [% END %]
                        [% END %]
                    </select> <span>(Authorised values for [% field.authorised_value_category | html %])</span>
                [% ELSE %]
                    [% IF field.marcfield %]
                        <input type="text" value="[% values.${field.id} | html %]" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" readonly="readonly" />
                        This value will be filled with the [% field.marcfield | html %] subfield of the selected biblio.
                    [% ELSE %]
                        <input type="text" value="[% values.${field.id} | html %]" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" />
                    [% END %]
                [% END %]
            </li>
        [% END %]
[% IF wrap_fieldset != 0 %]
    </ol>
</fieldset>
[% END %]
