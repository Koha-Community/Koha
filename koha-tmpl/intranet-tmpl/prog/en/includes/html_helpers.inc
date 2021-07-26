[% BLOCK options_for_libraries %]
    [% FOREACH l IN libraries %]
        [% IF l.selected %]
            <option value="[% prefix | html %][% l.branchcode | html %]" selected="selected">[% l.branchname | html %]</option>
        [% ELSE %]
            <option value="[% prefix | html %][% l.branchcode | html %]">[% l.branchname | html %]</option>
        [% END%]
    [% END %]
[% END %]

[% BLOCK options_for_desks %]
    <option id="nodesk" value="">---</option>
    [% FOREACH d IN desks %]
        [% IF d.branchcode == branch %]
          [% IF selected == d.desk_id %]
            <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]" selected="selected">[% d.desk_name | html %]</option>
          [% ELSE %]
            <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]" >[% d.desk_name | html %]</option>
          [% END %]
        [% ELSE %]
            <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]" disabled hidden>[% d.desk_name | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_registers %]
    [% FOREACH r IN registers %]
        [% IF r.branch == Branches.GetLoggedInBranchcode %]
            [% IF r.selected %]
                <option class="[%- r.branch | html -%][%- IF r.branch_default -%] default[%- END -%]" value="[% r.id | html %]" selected="selected">[% r.name | html %]</option>
            [% ELSE %]
                <option class="[%- r.branch | html -%][%- IF r.branch_default -%] default[%- END -%]" value="[% r.id | html %]">[% r.name | html %]</option>
            [% END%]
        [% ELSE %]
            <option class="[%- r.branch | html -%][%- IF r.branch_default -%] default[%- END -%]" value="[% r.id | html %]" disabled style="display: none">[% r.name | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_authorised_value_categories %]
    [% FOREACH avc IN authorised_value_categories %]
        [% IF avc.selected %]
            <option value="[% avc.category | html %]" selected="selected">[% avc.category | html %]</option>
        [% ELSE %]
            <option value="[% avc.category | html %]">[% avc.category | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_item_types %]
    [% FOREACH itemtype IN itemtypes %]
        [% IF itemtype.itemtype == selected_itemtype %]
            <option value="[% itemtype.itemtype | html %]" selected="selected">
        [% ELSE %]
            <option value="[% itemtype.itemtype | html %]">
        [% END %]
            [% itemtype.translated_description | html %]
        </option>
    [% END %]
[% END %]

[% BLOCK subfields_for_item %]
    <ol>
        [% FOREACH subfield IN subfields %]
            [% IF subfield.kohafield == 'items.more_subfields_xml' %]
                [% SET kohafield = 'items.more_subfields_xml_' _ subfield.subfield %]
            [% ELSE %]
                [% SET kohafield = subfield.kohafield %]
            [% END %]

            <li>
                <div class="subfield_line" style="[% subfield.visibility | html %]" id="subfield[% subfield.tag | html %][% subfield.subfield | html %][% subfield.random | html %]">
                    [% IF ( subfield.mandatory ) %]
                        <label class="required">[% subfield.subfield | html %] - [% subfield.marc_lib | $raw %]</label>
                    [% ELSE %]
                       <label>[% subfield.subfield | html %] - [% subfield.marc_lib | $raw %]</label>
                    [% END %]

                    [% SET mv = subfield.marc_value %]
                    [% IF ( mv.type == 'hidden' ) %]
                        <input type="hidden" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]">
                    [% ELSIF ( mv.type == 'select' ) %]
                        [% IF ( mv.readonly || subfield.IS_RETURN_CLAIM ) %]
                            <select name="[% kohafield | html %]" id="[%- mv.id | html -%]" class="input_marceditor" readonly="readonly" disabled="disabled" data-width="50%">
                        [% ELSE %]
                            <select name="[% kohafield | html %]" id="[%- mv.id | html -%]" class="input_marceditor select2" data-category="[% mv.category | html %]" data-width="50%">
                        [% END %]

                        [% FOREACH aval IN mv.values %]
                            [% IF aval == mv.default %]
                                <option value="[%- aval | html -%]" selected="selected">[%- mv.labels.$aval | html -%]</option>
                            [% ELSE %]
                                [% IF subfield.IS_LOST_AV && Koha.Preference("ClaimReturnedLostValue") && aval == Koha.Preference("ClaimReturnedLostValue") %]
                                    <option disabled="disabled" value="[%- aval | html -%]" title="Return claims must be processed from the patron details page">[%- mv.labels.$aval | html -%]</option>
                                [%  ELSE %]
                                    <option value="[%- aval | html -%]">[%- mv.labels.$aval | html -%]</option>
                                [% END %]
                            [% END %]
                        [% END %]
                        </select>
                    [% ELSIF ( mv.type == 'text_auth' ) %]
                        [% IF mv.readonly %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" readonly="readonly" />
                        [% ELSE %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" />
                            [% SET dopop = "Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=\"${mv.authtypecode}\"&index=${mv.id}','${mv.id}')" %]
                            <a href="#" class="buttonDot"  onclick="[%- dopop | html -%]; return false;" title="Tag editor">...</a>
                        [% END %]
                    [% ELSIF ( mv.type == 'text_plugin' ) %]
                        [% IF mv.readonly %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" readonly="readonly" />
                        [% ELSE %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" />
                            [% IF ( mv.nopopup ) %]
                                <a href="#" id="buttonDot_[%- mv.id | html -%]" class="[%- mv.class | html -%]" title="No popup">...</a>
                            [% ELSE  %]
                                <a href="#" id="buttonDot_[%- mv.id | html -%]" class="[%- mv.class | html -%]" title="Tag editor">...</a>
                            [% END %]
                            [%- mv.javascript | $raw -%]
                        [% END %]
                    [% ELSIF ( mv.type == 'text' ) %]
                        [% IF mv.readonly %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" readonly="readonly" />
                        [% ELSE %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" />
                        [% END %]
                    [% ELSIF ( mv.type == 'textarea' ) %]
                        [% IF mv.readonly %]
                            <textarea id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" rows="5" cols="64" readonly="readonly" >[% mv.value | html %]</textarea>
                        [% ELSE %]
                            <textarea id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor" rows="5" cols="64" >[% mv.value | html %]</textarea>
                        [% END %]
                    [% END %]

                    [% IF subfield.kohafield == 'items.more_subfields_xml' %]
                        <input type="hidden" name="items.more_subfields_xml" value="[% subfield.subfield | html %]" />
                    [% END %]
                    <input type="hidden" name="tag"       value="[% subfield.tag | html %]" />
                    <input type="hidden" name="subfield"  value="[% subfield.subfield | html %]" />
                    <input type="hidden" name="mandatory" value="[% subfield.mandatory | html %]" />
                    <input type="hidden" name="important" value="[% subfield.important | html %]" />

                    [% IF add_regex %]
                        <span name="regex_fields" style="display: none;">
                            s/<input type="text" id="[% mv.id | html %]" name="regex_search" placeholder="regex pattern" />/
                            <input type="text" id="[% mv.id | html %]" name="regex_replace" placeholder="regex replacement" />/
                            <input type="text" id="[% mv.id | html %]" name="regex_modifiers" placeholder="ig" size="3" />
                        </span>
                    [% END %]

                    [% IF add_delete_checkbox %]
                        [% UNLESS ( subfield.mandatory ) %]
                            <input type="checkbox" id="row[% subfield.tag | html %][% subfield.subfield | html %][% subfield.random | html %]" title="Check to delete subfield [% subfield.subfield | html %]" name="disable_input" value="[% subfield.subfield | html %]" />
                        [% ELSE %]
                            <span class="required">Required</span>
                        [% END %]
                    [% ELSE %]
                        [% IF ( subfield.mandatory ) %] <span class="required">Required</span>
                        [% ELSIF ( subfield.important ) %] <span class="important">Important</span>
                        [% END %]
                    [% END %]

                    [% IF add_regex %]
                        [% IF (mv.type == 'text' || mv.type == 'text2' || mv.type == 'textarea' ) %]
                            <a href="#" name="field_regex" id="[% subfield.id | html %]" >RegEx</a>
                        [% END %]
                    [% END %]

                    [% IF ( subfield.repeatable ) %]
                        <a href="#" class="buttonPlus" onclick="CloneItemSubfield(this.parentNode.parentNode); return false;">
                            <img src="[% interface | html %]/[% theme | html %]/img/clone-subfield.png" alt="Clone" title="Clone this subfield" />
                        </a>
                    [% END %]

                    <span class="hint" id="hint[% subfield.tag | html %][% subfield.subfield | html %][% subfield.random | html %]"></span>

                </div>
            </li>
        [% END %]
    </ol>
[% END %]
