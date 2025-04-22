[% USE AuthorisedValues %]
[% USE Branches %]
[% USE ClassSources %]
[% USE ItemTypes %]
[% IF wrap_fieldset != 0 %]
    <fieldset class="rows" id="additional_fields_form_section">
        <legend>Additional fields</legend>
        [% PROCESS build_additional_fields_ol %]
    </fieldset>
[% ELSE %]
    [% PROCESS build_additional_fields_ol %]
[% END %]

[% BLOCK build_additional_fields_ol %]
    <ol>
        [% FOR field IN available %]
            [% authorised_value_category = field.effective_authorised_value_category %]
            [% IF authorised_value_category %]
                <li>
                    <label for="additional_field_[% field.id | html %]"> [% field.name | html %]: </label>
                    [% IF ( field.marcfield && field.marcfield_mode == 'get' ) || !field.repeatable %]
                        <select name="additional_field_[% field.id | html %]" id="additional_field_[% field.id | html %]" [% IF field.marcfield && field.marcfield_mode == 'get' %]class="marcfieldget" disabled[% END %]>
                            [% IF !field.repeatable %]
                                [% IF batch_edit %]
                                    <option value="">No change</option>
                                [% ELSE %]
                                    <option value=""></option>
                                [% END %]
                            [% END %]
                            [% IF authorised_value_category == 'branches' %]
                                [% FOREACH branch IN Branches.all() %]
                                    [% IF branch.branchcode == values.${field.id}.0 %]
                                        <option value="[% branch.branchcode | html %]" selected="selected">[% branch.branchname | html %]</option>
                                    [% ELSE %]
                                        <option value="[% branch.branchcode | html %]">[% branch.branchname | html %]</option>
                                    [% END %]
                                [% END %]
                            [% ELSIF authorised_value_category == 'cn_source' %]
                                [% FOREACH class_source IN ClassSources.all({ selected => values.${field.id} }) %]
                                    [% IF class_source.cn_source == values.${field.id}.0 %]
                                        <option value="[% class_source.cn_source | html %]" selected="selected">[% class_source.description | html %]</option>
                                    [% ELSE %]
                                        <option value="[% class_source.cn_source | html %]">[% class_source.description | html %]</option>
                                    [% END %]
                                [% END %]
                            [% ELSIF authorised_value_category == 'itemtypes' %]
                                [% FOREACH itemtype IN ItemTypes.Get() %]
                                    [% IF itemtype.itemtype == values.${field.id}.0 %]
                                        <option value="[% itemtype.itemtype | html %]" selected="selected">[% itemtype.description | html %]</option>
                                    [% ELSE %]
                                        <option value="[% itemtype.itemtype | html %]">[% itemtype.description | html %]</option>
                                    [% END %]
                                [% END %]
                            [% ELSE %]
                                [% FOREACH av IN AuthorisedValues.GetAuthValueDropbox( authorised_value_category ) %]
                                    [% IF av.authorised_value == values.${field.id}.0 %]
                                        <option value="[% av.authorised_value | html %]" selected="selected">[% av.lib | html %]</option>
                                    [% ELSE %]
                                        <option value="[% av.authorised_value | html %]">[% av.lib | html %]</option>
                                    [% END %]
                                [% END %]
                            [% END %]
                        </select>
                    [% ELSE %]
                        [% FOREACH av IN AuthorisedValues.GetAuthValueDropbox( authorised_value_category ) %]
                            [% SET av_field_value_rendered = 0 %]
                            [% FOR value IN values.${field.id} %]
                                [% IF av.authorised_value == value %]
                                    <label class="radio">
                                        <input type="checkbox" id="additional_field_[% field.id | html %]" checked name="additional_field_[% field.id | html %]" value="[% av.authorised_value | html %]" />[% av.lib | html %]
                                    </label>
                                    [% SET av_field_value_rendered = 1 %]
                                [% END %]
                            [% END %]
                            [% IF !av_field_value_rendered %]
                                <label class="radio"> <input type="checkbox" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" value="[% av.authorised_value | html %]" />[% av.lib | html %] </label>
                            [% END %]
                        [% END %]
                    [% END %]
                    [% IF !search_form %]
                        <span>(Authorised values for [% authorised_value_category | html %])</span>
                        [% IF field.marcfield && field.marcfield_mode == 'get' %]
                            This value will be filled with the [% field.marcfield | html %] subfield of the selected bibliographic record.
                        [% ELSIF field.marcfield && field.marcfield_mode == 'set' %]
                            This value will be saved to the [% field.marcfield | html %] subfield of the selected bibliographic record.
                        [% END %]
                    [% END %]
                </li>
            [% ELSIF field.marcfield && field.marcfield_mode == 'get' %]
                <li>
                    <label for="additional_field_[% field.id | html %]"> [% field.name | html %]: </label>
                    <input type="text" value="[% values.${field.id}.0 | html %]" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" readonly="readonly" />
                    [% IF !search_form %]
                        This value will be filled with the [% field.marcfield | html %] subfield of the selected bibliographic record.
                    [% END %]
                </li>
            [% ELSE %]
                [% SET text_field_value_rendered = 0 %]
                [% FOR value IN values.${field.id} %]
                    <li>
                        <label for="additional_field_[% field.id | html %]"> [% field.name | html %]: </label>
                        <input type="text" value="[% value | html %]" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" />
                        [% UNLESS search_form == 1 %]
                            <a href="#" class="clear_attribute"><i class="fa fa-fw fa-trash-can"></i> Clear</a>
                        [% END %]
                        [% IF field.repeatable && !search_form %]
                            <a href="#" class="clone_attribute"><i class="fa fa-fw fa-plus"></i> New</a>
                        [% END %]
                        [% SET text_field_value_rendered = 1 %]
                        [% IF field.marcfield && field.marcfield_mode == 'set' && !search_form %]
                            This value will be saved to the [% field.marcfield | html %] subfield of the selected bibliographic record.
                        [% END %]
                    </li>
                [% END %]
                [% IF !text_field_value_rendered %]
                    <li>
                        <label for="additional_field_[% field.id | html %]"> [% field.name | html %]: </label>
                        [% IF batch_edit %]
                            <input type="text" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" placeholder="No change" />
                        [% ELSE %]
                            <input type="text" id="additional_field_[% field.id | html %]" name="additional_field_[% field.id | html %]" />
                        [% END %]
                        [% UNLESS search_form == 1 %]
                            <a href="#" class="clear_attribute"><i class="fa fa-fw fa-trash-can"></i> Clear</a>
                        [% END %]
                        [% IF field.repeatable && !search_form %]
                            <a href="#" class="clone_attribute"><i class="fa fa-fw fa-plus"></i> New</a>
                        [% END %]
                        [% IF field.marcfield && field.marcfield_mode == 'set' && !search_form %]
                            This value will be saved to the [% field.marcfield | html %] subfield of the selected bibliographic record.
                        [% END %]
                    </li>
                [% END %]
            [% END %]
        [% END %]
    </ol>
[% END %]
