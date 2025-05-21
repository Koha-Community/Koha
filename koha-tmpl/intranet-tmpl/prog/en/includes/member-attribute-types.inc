[% BLOCK 'memberentry_patron_attributes_form' %]
    [% UNLESS ( no_patron_attribute_types ) %]
        <fieldset class="rows" id="memberentry_patron_attributes">
            <legend class="expanded" id="patron_attributes_lgd">
                <i class="fa fa-caret-down" aria-hidden="true"></i>
                Additional attributes and identifiers
            </legend>
            <div class="attributes_tables">
                <input type="hidden" name="setting_extended_patron_attributes" value="1" />
                [% FOREACH pa_loo IN patron_attributes %]
                    <ol class="attributes_table">
                        <div id="aai_[% pa_loo.class | html %]">
                            [% IF pa_loo.class %]
                                <h3 id="[% pa_loo.class | html %]_lgd">[% pa_loo.lib | html %]</h3>
                            [% END %]
                            [% FOREACH patron_attribute IN pa_loo.items %]
                                <li data-category_code="[% patron_attribute.category_code | html %]" data-pa_code="[% patron_attribute.code | replace('[^a-zA-Z0-9_-]', '') %]">
                                    [% IF patron_attribute.mandatory %]
                                        <label for="[% patron_attribute.form_id | html %]" class="required" required="required">[% patron_attribute.description | html %]: </label>
                                    [% ELSE %]
                                        <label for="[% patron_attribute.form_id | html %]">[% patron_attribute.description | html %]: </label>
                                    [% END %]
                                    [% IF ( patron_attribute.use_dropdown ) %]
                                        <select id="[% patron_attribute.form_id | html %]" name="[% patron_attribute.form_id | html %]" [% IF patron_attribute.mandatory %]required="required"[% END %]>
                                            <option value=""></option>
                                            [% FOREACH auth_val_loo IN patron_attribute.auth_val_loop %]
                                                [% IF auth_val_loo.authorised_value == patron_attribute.value %]
                                                    <option value="[% auth_val_loo.authorised_value | html %]" selected="selected"> [% auth_val_loo.lib | html %] </option>
                                                [% ELSE %]
                                                    <option value="[% auth_val_loo.authorised_value | html %]"> [% auth_val_loo.lib | html %] </option>
                                                [% END %]
                                            [% END %]
                                        </select>
                                    [% ELSE %]
                                        [% IF patron_attribute.mandatory %]
                                            [% IF patron_attribute.is_date %]
                                                <input
                                                    type="text"
                                                    id="[% patron_attribute.form_id | html %]"
                                                    name="[% patron_attribute.form_id | html %]"
                                                    maxlength="10"
                                                    size="10"
                                                    value="[% patron_attribute.value | html %]"
                                                    required="required"
                                                    class="flatpickr"
                                                />
                                            [% ELSE %]
                                                <textarea rows="2" cols="30" id="[% patron_attribute.form_id | html %]" name="[% patron_attribute.form_id | html %]" required="required">
[% patron_attribute.value | html %]</textarea
                                                >
                                            [% END %]
                                        [% ELSE %]
                                            [% IF patron_attribute.is_date %]
                                                <input
                                                    type="text"
                                                    id="[% patron_attribute.form_id | html %]"
                                                    name="[% patron_attribute.form_id | html %]"
                                                    maxlength="10"
                                                    size="10"
                                                    value="[% patron_attribute.value | html %]"
                                                    class="flatpickr"
                                                />
                                            [% ELSE %]
                                                <textarea rows="2" cols="30" id="[% patron_attribute.form_id | html %]" name="[% patron_attribute.form_id | html %]">[% patron_attribute.value | html %]</textarea>
                                            [% END %]
                                        [% END %]
                                    [% END # /IF ( patron_attribute.use_dropdown ) %]
                                    <input type="hidden" id="[% patron_attribute.form_id | html %]_code" name="[% patron_attribute.form_id | html %]_code" value="[% patron_attribute.code | html %]" />
                                    [% IF ( !patron_attribute.is_date ) %]
                                        <a href="#" class="clear_attribute"><i class="fa fa-fw fa-trash-can"></i> Clear</a>
                                    [% END %]
                                    [% IF ( patron_attribute.repeatable ) %]
                                        <a href="#" class="clone_attribute"><i class="fa fa-fw fa-plus"></i> New</a>
                                    [% END %]
                                    [% IF patron_attribute.mandatory %]<span class="required">Required</span>[% END %]
                                </li>
                            [% END # /FOREACH patron_attribute %]
                        </div>
                    </ol>
                [% END # /FOREACH pa_loo %]
            </div>
            <!-- /.attributes_tables -->
        </fieldset>
        <!-- /#memberentry_patron_attributes -->
    [% END # UNLESS ( no_patron_attribute_types ) %]
[% END %]
