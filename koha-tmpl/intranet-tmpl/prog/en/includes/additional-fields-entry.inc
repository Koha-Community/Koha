[% USE AuthorisedValues %]
[% USE Branches %]
[% USE ClassSources %]
[% USE ItemTypes %]
[% IF wrap_fieldset != 0 %]
<fieldset class="rows">
    <legend>Additional fields</legend>
    <ol>
[% END %]
        [% FOR field IN available %]
        [% authorised_value_category = field.effective_authorised_value_category %]
            <li>
                <label for="additional_field_[% field.id | html %]"> [% field.name | html %]: </label>
                [% IF authorised_value_category %]
                    [% IF field.marcfield && field.marcfield_mode == 'get' %]
                        <select name="additional_field_[% field.id | html %]" id="additional_field_[% field.id | html %]" disabled>
                    [% ELSE %]
                        <select name="additional_field_[% field.id | html %]" id="additional_field_[% field.id | html %]">
                    [% END %]
                        <option value=""></option>
                        [% IF authorised_value_category == 'branches' %]
                            [% FOREACH branch IN Branches.all() %]
                                [% IF branch.branchcode == values.${field.id} %]
                                    <option value="[% branch.branchcode | html %]" selected="selected">[% branch.branchname | html %]</option>
                                [% ELSE %]
                                    <option value="[% branch.branchcode | html %]">[% branch.branchname | html %]</option>
                                [% END %]
                            [% END %]
                        [% ELSIF authorised_value_category == 'cn_source' %]
                            [% FOREACH class_source IN ClassSources.all({ selected => values.${field.id} }) %]
                                [% IF class_source.cn_source == values.${field.id} %]
                                    <option value="[% class_source.cn_source | html %]" selected="selected">[% class_source.description | html %]</option>
                                [% ELSE %]
                                    <option value="[% class_source.cn_source | html %]">[% class_source.description | html %]</option>
                                [% END %]
                            [% END %]
                        [% ELSIF authorised_value_category == 'itemtypes' %]
                            [% FOREACH itemtype IN ItemTypes.Get() %]
                                [% IF itemtype.itemtype == values.${field.id} %]
                                    <option value="[% itemtype.itemtype | html %]" selected="selected">[% itemtype.description | html %]</option>
                                [% ELSE %]
                                    <option value="[% itemtype.itemtype | html %]">[% itemtype.description | html %]</option>
                                [% END %]
                            [% END %]
                        [% ELSE %]
                            [% FOREACH av IN AuthorisedValues.GetAuthValueDropbox( authorised_value_category ) %]
                                [% IF av.authorised_value == values.${field.id} %]
                                    <option value="[% av.authorised_value | html %]" selected="selected">[% av.lib | html %]</option>
                                [% ELSE %]
                                    <option value="[% av.authorised_value | html %]">[% av.lib | html %]</option>
                                [% END %]
                            [% END %]
                        [% END %]
                    </select> <span>(Authorised values for [% authorised_value_category | html %])</span>
                [% ELSIF field.marcfield && field.marcfield_mode == 'get' %]
                    <input type="text" value="[% values.${field.id} | html %]" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" readonly="readonly" />
                [% ELSE %]
                    <input type="text" value="[% values.${field.id} | html %]" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" />
                [% END %]

                [% IF field.marcfield && field.marcfield_mode == 'get' %]
                    This value will be filled with the [% field.marcfield | html %] subfield of the selected biblio.
                [% ELSIF field.marcfield && field.marcfield_mode == 'set' %]
                    This value will be saved to the [% field.marcfield %] subfield of the selected biblio.
                [% END %]
            </li>
        [% END %]
[% IF wrap_fieldset != 0 %]
    </ol>
</fieldset>
[% END %]
