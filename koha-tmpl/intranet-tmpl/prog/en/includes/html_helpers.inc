[% BLOCK options_for_libraries %]
    [% FOREACH l IN libraries %]
        [% IF l.selected %]
            <option value="[% prefix | html %][% l.branchcode | html %]" selected="selected">[% l.branchname | html %]</option>
        [% ELSE %]
            <option value="[% prefix | html %][% l.branchcode | html %]">[% l.branchname | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_desks %]
    <option id="nodesk" value="">---</option>
    [% FOREACH d IN desks %]
        [% IF d.branchcode == branch %]
            [% IF selected == d.desk_id || ( selected == '' && loop.first ) %]
                <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]" selected="selected">[% d.desk_name | html %]</option>
            [% ELSE %]
                <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]">[% d.desk_name | html %]</option>
            [% END %]
        [% ELSE %]
            <option class="[% d.branchcode | html %]" value="[% d.desk_id | html %]" disabled style="display: none">[% d.desk_name | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_registers %]
    [% FOREACH r IN registers %]
        [% IF r.branch == Branches.GetLoggedInBranchcode %]
            [% IF r.selected %]
                <option class="[%- r.branch | html -%][%- IF r.branch_default -%][% ' ' | html %]default[%- END -%]" value="[% r.id | html %]" selected="selected">[% r.name | html %]</option>
            [% ELSE %]
                <option class="[%- r.branch | html -%][%- IF r.branch_default -%][% ' ' | html %]default[%- END -%]" value="[% r.id | html %]">[% r.name | html %]</option>
            [% END %]
        [% ELSE %]
            <option class="[%- r.branch | html -%][%- IF r.branch_default -%][% ' ' | html %]default[%- END -%]" value="[% r.id | html %]" disabled="disabled" style="display: none">[% r.name | html %]</option>
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

[% BLOCK options_for_authorised_values_multiselect %]
    [% FOREACH av IN authorised_values %]
        [% is_selected = 0 %]
        [% IF selected_av %]
            [% IF selected_av.defined && selected_av.size.defined %]
                [% FOREACH sel IN selected_av %]
                    [% IF sel == av.authorised_value %]
                        [% is_selected = 1 %]
                        [% LAST %]
                    [% END %]
                [% END %]
            [% ELSE %]
                [% IF av.authorised_value == selected_av %]
                    [% is_selected = 1 %]
                [% END %]
            [% END %]
        [% END %]
        [% IF is_selected %]
            <option value="[% av.authorised_value | html %]" selected="selected">[% av.lib | html %]</option>
        [% ELSE %]
            <option value="[% av.authorised_value | html %]">[% av.lib | html %]</option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK options_for_item_types %]
    [% FOREACH itemtype IN itemtypes %]
        [% IF itemtype.itemtype == selected_itemtype %]
            <option value="[% itemtype.itemtype | html %]" selected="selected"> [% itemtype.translated_description | html %] </option>
        [% ELSE %]
            <option value="[% itemtype.itemtype | html %]"> [% itemtype.translated_description | html %] </option>
        [% END %]
    [% END %]
[% END %]

[% BLOCK biblio_a_href -%]
    [%- IF Koha.Preference('IntranetBiblioDefaultView') == 'marc' && Koha.Preference('viewMARC') -%]
        [%- SET this_biblio_href = "/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=" -%]
    [%- ELSIF Koha.Preference('IntranetBiblioDefaultView') == 'labeled_marc' && Koha.Preference('viewLabeledMARC') -%]
        [%- SET this_biblio_href = "/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=" -%]
    [%- ELSIF Koha.Preference('IntranetBiblioDefaultView') == 'isbd' && Koha.Preference('viewISBD') -%]
        [%- SET this_biblio_href = "/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=" -%]
    [%- ELSE -%]
        [%- SET this_biblio_href = "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" -%]
    [%- END -%]
    [%- this_biblio_href | url %][% biblionumber | url -%]
[%- END %]

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
                    <label [% IF subfield.mandatory %]class="required"[% END %]>[% subfield.subfield | html %] - <span title="[% subfield.marc_lib | html %]">[% subfield.marc_lib | html %]</span></label>

                    [% SET mv = subfield.marc_value %]
                    [% IF ( mv.type == 'hidden' ) %]
                        <input type="hidden" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- subfield.maxlength | html -%]" value="[%- mv.value | html -%]" />
                    [% ELSIF ( mv.type == 'select' ) %]
                        [% SET select_readonly = '' %]
                        [% SET select_disabled = '' %]
                        [% IF ( mv.readonly || subfield.IS_RETURN_CLAIM ) %]
                            [% SET select_class = 'input_marceditor ' _ kohafield %]
                            [% SET select_readonly = 'readonly="readonly"' %]
                            [% SET select_disabled = 'disabled="disabled"' %]
                        [% ELSE %]
                            [% SET select_class = 'input_marceditor select2 ' _ kohafield %]
                        [% END %]

                        <select
                            name="[% kohafield | html %]"
                            id="[%- mv.id | html -%]"
                            class="input_marceditor [% select_class | html %]"
                            [% select_readonly | html %]
                            [% select_disabled | html %]
                            data-category="[% mv.category | html %]"
                            data-width="50%"
                        >
                            [% SET matched = 0 %]
                            [% FOREACH aval IN mv.values %]
                                [% IF aval == mv.default %]
                                    [% SET matched = 1 %]
                                    <option value="[%- aval | html -%]" selected="selected">[%- mv.labels.$aval | html -%]</option>
                                [% ELSE %]
                                    [% IF subfield.IS_LOST_AV && Koha.Preference("ClaimReturnedLostValue") && aval == Koha.Preference("ClaimReturnedLostValue") %]
                                        <option disabled="disabled" value="[%- aval | html -%]" title="Return claims must be processed from the patron details page">[%- mv.labels.$aval | html -%]</option>
                                    [% ELSIF subfield.IS_LOST_AV && Koha.Preference("BundleLostValue") && aval == Koha.Preference("BundleLostValue") %]
                                        <option disabled="disabled" value="[%- aval | html -%]" title="Bundle losses are set at checkin automatically">[%- mv.labels.$aval | html -%]</option>
                                    [% ELSE %]
                                        <option value="[%- aval | html -%]">[%- mv.labels.$aval | html -%]</option>
                                    [% END %]
                                [% END %]
                            [% END %]
                            [% UNLESS matched || ( ( kohafield == 'items.damaged' || kohafield == 'items.itemlost' || kohafield == 'items.withdrawn' || kohafield == 'items.notforloan' ) && mv.default == '0' ) %]
                                [%# If the current value is not in the authorised list  and is not a field where 0 means unset #%]
                                <option value="[%- mv.default | html -%]" selected="selected">[%- mv.default | html -%] (Not an authorised value)</option>
                            [% END %]
                        </select>
                        [% UNLESS matched || ( ( kohafield == 'items.damaged' || kohafield == 'items.itemlost' || kohafield == 'items.withdrawn' || kohafield == 'items.notforloan' ) && mv.default == '0' ) %]
                            <span style="float:right;" title="The current value [% mv.default | html %] is not configured for the authorised value category controlling this subfield"
                                ><i class="fa fa-exclamation-triangle" aria-hidden="true"></i
                            ></span>
                        [% END %]
                    [% ELSIF ( mv.type == 'text_auth' ) %]
                        [% IF mv.readonly %]
                            <input
                                type="text"
                                id="[%- mv.id | html -%]"
                                name="[% kohafield | html %]"
                                class="input_marceditor [% kohafield | html %]"
                                maxlength="[%- subfield.maxlength | html -%]"
                                value="[%- mv.value | html -%]"
                                readonly="readonly"
                            />
                        [% ELSE %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- subfield.maxlength | html -%]" value="[%- mv.value | html -%]" />
                            [% SET dopop = "Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=\"${mv.authtypecode}\"&index=${mv.id}','${mv.id}')" %]
                            <a href="#" class="buttonDot tag_editor" onclick="[%- dopop | html -%]; return false;" title="Tag editor">...</a>
                        [% END %]
                    [% ELSIF ( mv.type == 'text_plugin' ) %]
                        [% IF mv.readonly %]
                            <input
                                type="text"
                                id="[%- mv.id | html -%]"
                                name="[% kohafield | html %]"
                                class="input_marceditor [% kohafield | html %]"
                                maxlength="[%- subfield.maxlength | html -%]"
                                value="[%- mv.value | html -%]"
                                readonly="readonly"
                            />
                        [% ELSE %]
                            <input
                                type="text"
                                id="[%- mv.id | html -%]"
                                name="[% kohafield | html %]"
                                class="input_marceditor framework_plugin [% kohafield | html %]"
                                maxlength="[%- subfield.maxlength | html -%]"
                                value="[%- mv.value | html -%]"
                                data-plugin="[% mv.plugin | html %]"
                            />
                            [% IF ( mv.nopopup ) %]
                                <a href="#" id="buttonDot_[%- mv.id | html -%]" class="[%- mv.class | html -%] tag_editor framework_plugin" title="No popup" data-plugin="[% mv.plugin | html %]">...</a>
                            [% ELSE %]
                                <a href="#" id="buttonDot_[%- mv.id | html -%]" class="[%- mv.class | html -%] tag_editor framework_plugin" title="Tag editor" data-plugin="[% mv.plugin | html %]">...</a>
                            [% END %]
                            [% UNLESS no_plugin %]
                                [%# FIXME - from batchMod-edit, jQuery is included at the end of the template and cataloguing plugins are not working in this situation %]
                                [%- mv.javascript | $raw -%]
                            [% END %]
                        [% END %]
                    [% ELSIF ( mv.type == 'text' ) %]
                        [% IF mv.readonly %]
                            <input
                                type="text"
                                id="[%- mv.id | html -%]"
                                name="[% kohafield | html %]"
                                class="input_marceditor [% kohafield | html %]"
                                maxlength="[%- subfield.maxlength | html -%]"
                                value="[%- mv.value | html -%]"
                                readonly="readonly"
                            />
                        [% ELSE %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- subfield.maxlength | html -%]" value="[%- mv.value | html -%]" />
                        [% END %]
                    [% ELSIF ( mv.type == 'textarea' ) %]
                        [% IF mv.readonly %]
                            <textarea id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" rows="5" cols="64" readonly="readonly">[% mv.value | html %]</textarea>
                        [% ELSE %]
                            <textarea id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" rows="5" cols="64">[% mv.value | html %]</textarea>
                        [% END %]
                    [% ELSIF ( mv.type == 'date_field' ) %]
                        <input type="text" id="[% mv.id | html %]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %] flatpickr" value="[% mv.value | html %]" class="flatpickr" data-flatpickr-set-to-today="true" />
                    [% ELSIF ( mv.type == 'datetime_field' ) %]
                        <input
                            type="text"
                            id="[% mv.id | html %]"
                            name="[% kohafield | html %]"
                            class="input_marceditor [% kohafield | html %] flatpickr"
                            value="[% mv.value | html %]"
                            data-flatpickr-enable-time="true"
                            data-flatpickr-set-to-today="true"
                        />
                    [% END %]

                    [% IF subfield.kohafield == 'items.more_subfields_xml' %]
                        <input type="hidden" name="items.more_subfields_xml" value="[% subfield.subfield | html %]" />
                    [% END %]
                    <input type="hidden" name="tag" value="[% subfield.tag | html %]" />
                    <input type="hidden" name="kohafield" value="[% subfield.kohafield | html %]" /> [%# We should not need that but all item forms are not rewritten yet %]
                    <input type="hidden" name="subfield" value="[% subfield.subfield | html %]" />
                    <input type="hidden" name="mandatory" value="[% subfield.mandatory | html %]" />
                    <input type="hidden" name="important" value="[% subfield.important | html %]" />

                    [% IF add_regex %]
                        <span name="regex_fields" style="display: none;">
                            s/<input type="text" name="[% kohafield | html %]_regex_search" class="regex_search" placeholder="regex pattern" />/
                            <input type="text" name="[% kohafield | html %]_regex_replace" class="regex_replace" placeholder="regex replacement" />/
                            <input type="text" name="[% kohafield | html %]_regex_modifiers" class="regex_modifiers" placeholder="ig" size="3" />
                        </span>
                    [% END %]

                    [% IF add_delete_checkbox %]
                        [% UNLESS ( subfield.mandatory ) %]
                            <input
                                type="checkbox"
                                id="row[% subfield.tag | html %][% subfield.subfield | html %][% subfield.random | html %]"
                                title="Check to delete subfield [% subfield.subfield | html %]"
                                name="disable_input"
                                value="[% kohafield | html %]"
                            />
                        [% ELSE %]
                            <span class="required">Required</span>
                        [% END %]
                    [% ELSE %]
                        [% IF ( subfield.mandatory ) %]
                            <span class="required">Required</span>
                        [% ELSIF ( subfield.important ) %]
                            <span class="important">Important</span>
                        [% END %]
                    [% END %]

                    [% IF add_regex %]
                        [% IF (mv.type == 'text' || mv.type == 'text_plugin' || mv.type == 'textarea' ) %]
                            <a href="#" name="[% kohafield | html %]_field_regex" class="field_regex" id="[% subfield.id | html %]">RegEx</a>
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

[% BLOCK items_table_batchmod %]
    <div class="page-section">
        [% IF display_columns_selection %]
            [%# Needs js/pages/batchMod.js %]
            [% IF checkboxes_edit OR checkboxes_delete %]
                <div class="btn-toolbar selections-toolbar">
                    <a id="selectallbutton" href="#"><i class="fa fa-check"></i> Select all</a> | <a id="clearallbutton" href="#"><i class="fa fa-times"></i> Clear all</a> | <a id="clearonloanbutton" href="#">Clear on loan</a>
                </div>
            [% END %]

            <div id="cataloguing_additem_itemlist">
                <p id="selections">
                    <strong>Show/hide columns:</strong>
                    <span class="selected">
                        <input type="checkbox" checked="checked" id="showall" />
                        <label for="showall">Show all columns</label>
                    </span>
                    <span>
                        <input type="checkbox" id="hideall" />
                        <label for="hideall">Hide all columns</label>
                    </span>

                    [% FOREACH header IN item_header_loop %]
                        <span class="selected">
                            <input id="checkheader[% loop.count | html %]" type="checkbox" checked="checked" />
                            <label for="checkheader[% loop.count | html %]">[% header.header_value | html %]</label>
                        </span>
                    [% END %]
                </p>
                <!-- /#selections -->
            </div>
        [% END %]
        [% SET date_fields = [ 'dateaccessioned', 'onloan', 'datelastseen', 'datelastborrowed', 'replacementpricedate' ] %]
        <table id="itemst">
            <thead>
                <tr>
                    <th></th>
                    [% IF checkboxes_edit OR checkboxes_delete %]
                        <th></th>
                    [% END %]
                    <th class="anti-the">Title</th>
                    <th class="holds_count" title="Item holds / Total holds">Holds</th>
                    [% FOREACH item_header IN headers %]
                        [% IF item_header.column_name %]
                            <th data-colname="[% item_header.column_name | html %]"> [% item_header.header_value | html %] </th>
                        [% ELSE %]
                            <th> [% item_header.header_value | html %] </th>
                        [% END %]
                    [% END %]
                </tr>
            </thead>
            <tbody>
                [% FOREACH item IN items %]
                    [% SET can_be_edited = !item.nomod && !( Koha.Preference('IndependentBranches') && ! logged_in_user && item.homebranch != Branches.GetLoggedInBranchname() ) %]

                    <tr>
                        <td>[% item.index + 1 | html %]</td>
                        [% IF checkboxes_edit %]
                            [% UNLESS can_be_edited %]
                                <td class="error">
                                    <i class="fa fa-times fa-lg" title="Cannot edit"></i>
                                </td>
                            [% ELSE %]
                                <td>
                                    <input type="checkbox" name="itemnumber" value="[% item.itemnumber | html %]" id="row[% item.itemnumber | html %]" checked="checked" data-is-onloan="[% item.is_checked_out | html %]" />
                                </td>
                            [% END %]
                        [% ELSIF checkboxes_delete %]
                            [% UNLESS can_be_edited %]
                                <td class="error">
                                    <i class="fa fa-times fa-lg" title="Cannot delete"></i>
                                </td>
                            [% ELSE %]
                                [% IF item.safe_to_delete %]
                                    <td><input type="checkbox" name="itemnumber" value="[% item.itemnumber | html %]" id="row[% item.itemnumber | html %]" checked="checked" /></td>
                                [% ELSE %]
                                    [% SET messages = item.safe_to_delete.messages %]
                                    [% FOR m IN messages %]
                                        [% SWITCH m.message %]
                                        [% CASE "book_on_loan" %]
                                            [% SET cannot_delete_reason = t("Item is checked out") %]
                                        [% CASE "not_same_branch" %]
                                            [% SET cannot_delete_reason = t("Item does not belong to your library") %]
                                        [% CASE "book_reserved" %]
                                            [% SET cannot_delete_reason = t("Item has a waiting hold") %]
                                        [% CASE "linked_analytics" %]
                                            [% SET cannot_delete_reason = t("Item has linked analytics") %]
                                        [% CASE "last_item_for_hold" %]
                                            [% SET cannot_delete_reason = t("Last item for bibliographic record with biblio-level hold on it") %]
                                        [% CASE %]
                                            [% SET cannot_delete_reason = t("Unknown reason") _ '(' _ m.message _ ')' %]
                                        [% END %]
                                    [% END %]

                                    <td class="error">
                                        <i class="fa fa-times fa-lg" title="[% cannot_delete_reason | html %]"></i>
                                    </td>
                                [% END %]
                            [% END %]
                        [% END %]
                        <td>
                            <label for="row[% item.itemnumber | html %]">
                                <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% item.biblionumber | uri %]"> [% item.biblio.title | html %] </a>
                                [% IF ( item.biblio.author ) %], by [% item.biblio.author | html %][% END %]
                            </label>
                        </td>
                        <td class="holds_count">
                            [% IF item.holds %]
                                [% IF item.item_holds %]
                                    [% SET a_title = tx("Holds on this item: {item_holds} / Total holds on this record: {total_holds}", { item_holds=item.item_holds, total_holds=item.holds }) %]
                                [% ELSE %]
                                    [% SET a_title = tx("No holds on this item / Total holds on this record: {total_holds}", { total_holds=item.holds }) %]
                                [% END %]
                            [% ELSE %]
                                [% IF item.holds %]
                                    [% SET a_title = tx("Holds on this record: {total_holds}", { total_holds=item.holds }) %]
                                [% ELSE %]
                                    [% SET a_title = t("No holds on this record") %]
                                [% END %]
                            [% END # /IF item.holds %]
                            <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% item.biblionumber | uri %]" title="[% a_title | html %]">
                                [% IF item.holds %]
                                    [% item.item_holds | html %]/[% item.holds | html %]
                                [% ELSE %]
                                    [% item.holds | html %]
                                [% END %]
                            </a>
                        </td>
                        [% FOREACH header IN headers %]
                            [% SET attribute = header.attribute %]
                            [% IF header.attribute AND date_fields.grep('^' _ attribute _ '$').size %]
                                <td data-order="[% item.$attribute | html %]">[% item.$attribute | $KohaDates %]</td>
                            [% ELSE %]
                                <td>[% item.$attribute | html %]</td>
                            [% END %]
                        [% END %]
                    </tr>
                [% END # /FOREACH items %]
            </tbody>
        </table>
        <!-- /#itemst -->
    </div>
[% END %]

[%# BOOTSTRAP TAB WRAPPER USAGE                                                                         %]
[%#     [ WRAPPER tabs id= "tabs_container_id" ]                                                        %]
[%#         [ WRAPPER tabs_nav ]                                                                        %]
[%#             [ WRAPPER tab_item tabname= "tab_name_1" bt_active= 1 ] <span>Tab text 1</span> [ END ] %]
[%#             [ WRAPPER tab_item tabname= "tab_name_2" ] <span>Tab text 2</span> [ END ]              %]
[%#             ...                                                                                     %]
[%#         [ END ]                                                                                     %]
[%#         [ WRAPPER tab_panels ]                                                                      %]
[%#             [ WRAPPER tab_panel tabname="tab_name_1" bt_active= 1 ] Panel contents 1 [ END ]        %]
[%#             [ WRAPPER tab_panel tabname="tab_name_2" ] Panel contents 2 [ END ]                     %]
[%#             ...                                                                                     %]
[%#         [ END ]                                                                                     %]
[%#     [ END ]                                                                                         %]

[% BLOCK tabs %]
    [% IF ( id ) %]
        <div id="[% id | html %]" class="toptabs"> [% content | $raw %] </div>
    [% ELSE %]
        <div class="toptabs"> [% content | $raw %] </div>
    [% END %]
[% END %]

[% BLOCK tabs_nav %]
    <ul class="nav nav-tabs" role="tablist">
        [% content | $raw %]
    </ul>
[% END %]

[% BLOCK tab_item %]
    <li [% IF id %]id="[% id | html %]"[% END %] class="nav-item" role="presentation">
        [% IF ( bt_active ) %]
            [% IF (linktab) %]
                <a class="nav-link active" href="?tab=[% tabname | url %]" id="[% tabname | html %]-tab"> [% content | $raw %] </a>
            [% ELSE %]
                <a
                    class="nav-link active"
                    href="#[% tabname | uri %]_panel"
                    id="[% tabname | html %]-tab"
                    data-tabname="[% tabname | uri %]"
                    aria-controls="[% tabname | uri %]_panel"
                    role="tab"
                    data-bs-toggle="tab"
                    data-bs-target="#[% tabname | uri %]_panel"
                >
                    [% content | $raw %]
                </a>
            [% END %]
        [% ELSE %]
            [% IF (linktab) %]
                <a class="nav-link" href="?tab=[% tabname | url %]" id="[% tabname | uri %]-tab"> [% content | $raw %] </a>
            [% ELSE %]
                <a
                    class="nav-link"
                    href="#[% tabname | uri %]_panel"
                    id="[% tabname | uri %]-tab"
                    data-tabname="[% tabname | uri %]"
                    aria-controls="[% tabname | uri %]_panel"
                    role="tab"
                    data-bs-toggle="tab"
                    data-bs-target="#[% tabname | uri %]_panel"
                >
                    [% content | $raw %]
                </a>
            [% END %]
        [% END %]
    </li>
[% END %]

[% BLOCK tab_panels %]
    <div class="tab-content"> [% content | $raw %] </div>
[% END %]

[% BLOCK tab_panel %]
    [% IF ( bt_active ) %]
        <div class="tab-pane show active" id="[% tabname | html %]_panel" role="tabpanel" aria-labelledby="[% tabname | html %]-tab" tabindex="0"> [% content| $raw %] </div>
    [% ELSE %]
        <div class="tab-pane" id="[% tabname | html %]_panel" role="tabpanel" aria-labelledby="[% tabname | html %]-tab" tabindex="0"> [% content| $raw %] </div>
    [% END %]
[% END %]

[%# BOOTSTRAP BREADCRUMBS WRAPPER USAGE                                       %]
[%#    [ WRAPPER breadcrumbs ]                                                %]
[%#        [ Home breadcrumb automatically included ]                         %]
[%#        [ WRAPPER breadcrumb_item ]                                        %]
[%#            <a href="/cgi-bin/koha/module/module-home.pl"> Module </a>     %]
[%#        [ END ]                                                            %]

[%#        [ IF op == 'add_form' ]                                            %]
[%#            [ WRAPPER breadcrumb_item ]                                    %]
[%#                <a href="/cgi-bin/koha/module/page.pl"> Module page </a>   %]
[%#            [ END ]                                                        %]
[%#            [ WRAPPER breadcrumb_item bc_active = 1 ]                      %]
[%#                <span>Add form</span>                                      %]
[%#            [ END ]                                                        %]

[%#        [ ELSIF op == 'delete_confirm' ]                                   %]
[%#            [ WRAPPER breadcrumb_item ]                                    %]
[%#                <a href="/cgi-bin/koha/module/page.pl"> Module page </a>   %]
[%#            [ END ]                                                        %]
[%#            [ WRAPPER breadcrumb_item bc_active = 1 ]                      %]
[%#                <span>Confirm deletion</span>                              %]
[%#            [ END ]                                                        %]

[%#        [ ELSE ]                                                           %]
[%#            [ WRAPPER breadcrumb_item bc_active = 1 ]                      %]
[%#                <span>Module page</span>                                   %]
[%#            [ END ]                                                        %]
[%#        [ END #/IF op = add_form ]                                         %]

[%#    [ END #/ WRAPPER breadcrumbs ]                                         %]

[%# Used to build breadcrumb navigation nav %]
[% BLOCK breadcrumbs %]
    <nav id="breadcrumbs" aria-label="Breadcrumb">
        <ol class="breadcrumb">
            [%# Include the Home link every time %]
            [% WRAPPER breadcrumb_item %]
                <a href="/cgi-bin/koha/mainpage.pl" title="Home"><span class="visually-hidden-focusable">Home</span></a>
            [% END %]
            [% content | $raw %]
        </ol>
    </nav>
[% END %]

[%# Used to build individual breadcrumb items in the breadcrumb nav %]
[% BLOCK breadcrumb_item %]
    [% IF content.trim %]
        [% IF ( bc_active ) %]
            <li class="breadcrumb-item active" aria-current="page">
                <a href="#"> [% content | $raw %] </a>
            </li>
        [% ELSE %]
            <li class="breadcrumb-item"> [% content | $raw %] </li>
        [% END %]
    [% END %]
[% END %]

[%# [ WRAPPER accordion panelgroup_id="accordion container id" ] %]
[%#     [ WRAPPER accordion_item ]                               %]
[%#         [ WRAPPER accordion_heading panel_id = "panel id" ]  %]
[%#             [Clickable panel heading ]                       %]
[%#         [ END ]                                              %]
[%#         [ WRAPPER accordion_panel panel_id = "panel id" ]    %]
[%#             [Expanding content panel]                        %]
[%#         [ END ]                                              %]
[%#     [ END ]                                                  %]
[%# [ END ]                                                      %]

[% BLOCK accordion %]
    <div class="panel-group" id="[% panelgroup_id | $raw %]_group" role="tablist" aria-multiselectable="true"> [% content | $raw %] </div>
[% END %]

[% BLOCK accordion_item %]
    <div class="panel panel-default"> [% content | $raw %] </div>
[% END %]

[% BLOCK accordion_heading %]
    <div class="panel-heading" role="tab" id="[% panel_id | $raw %]_heading">
        <h2 class="panel-title">
            <a
                id="[% panel_id | $raw %]Toggle"
                href="#[% panel_id | $raw %]_panel"
                class="collapsed"
                role="button"
                data-bs-toggle="collapse"
                data-parent="#[% panelgroup_id | $raw %]_group"
                aria-expanded="false"
                aria-controls="[% panel_id | $raw %]_panel"
            >
                [% content | $raw %]
            </a>
        </h2>
    </div>
    <!-- /.panel-heading -->
[% END %]

[% BLOCK accordion_panel %]
    <div id="[% panel_id | $raw %]_panel" class="panel-collapse collapse" role="tabpanel" aria-labelledby="[% panel_id | $raw %]_heading">
        <div class="panel-body"> [% content | $raw %] </div>
        <!-- /.panel-body -->
    </div>
    <!-- /.panel-collapse -->
[% END %]

[% BLOCK acquisitions_filter_form %]
    <form action="/cgi-bin/koha/acqui/histsearch.pl" method="get">
        [% IF ( context == "sidebar" ) %]
            <fieldset class="brief">
                <h4>Search orders</h4>
                [% INCLUDE 'filter-orders.inc' context == context %]
                <input type="hidden" name="do_search" value="1" />
            </fieldset>
        [% ELSE %]
            <fieldset class="rows">
                <legend>Search orders</legend>
                [% INCLUDE 'filter-orders.inc' context == context %]
                <input type="hidden" name="do_search" value="1" />
            </fieldset>
        [% END %]
        <fieldset class="action">
            <input type="submit" class="btn btn-primary" value="Search" />
        </fieldset>
    </form>
[% END %]

[% BLOCK modal_wrapper %]
    <div id="[% modal_id | html %]" class="modal modal-lg audio-alert-action [% IF noblock %]noblock[% ELSE %]block[% END %]" [% UNLESS noblock %]data-bs-backdrop="static" data-bs-keyboard="false"[% END %]>
        <div class="modal-dialog">
            <div class="modal-content">
                <form class="modal-form" method="post" action="[% modal_action | $raw %]" id="[% modal_id | html %]-form">
                    [% INCLUDE 'csrf-token.inc' %]

                    <div class="modal-header" id="[% modal_id | html %]-header">
                        <h1 class="modal-title"> [% modal_header_text | html %] </h1>
                    </div>
                    <div class="modal-body" id="[% modal_id | html %]-body"> [% content | $raw %] </div>
                    <div class="modal-footer" id="[% modal_id | html %]-footer">
                        [% footer_has_content = 0 %]

                        [% IF modal_confirm_text %]
                            <button
                                type="submit"
                                class="btn btn-default confirm"
                                id="[% modal_id | html %]-confirm"
                                [% IF modal_confirm_name %]name="[% modal_confirm_name | html %]"[% END %]
                                [% IF modal_confirm_val %]value="[% modal_confirm_val | html %]"[% END %]
                                [% IF modal_confirm_accesskey %]accesskey="[% modal_confirm_accesskey | html %]"[% END %]
                            >
                                <i class="fa fa-check"></i>
                                [% modal_confirm_text | html %] [% IF modal_confirm_accesskey %]([% modal_confirm_accesskey | html %])[% END %]
                            </button>
                            [% footer_has_content = 1 %]
                        [% END %]
                        [% IF modal_custom_confirm %]
                            [% modal_custom_confirm | $raw %]
                            [% footer_has_content = 1 %]
                        [% END %]
                        [% IF modal_print_text && modal_print_url %]
                            <button
                                type="button"
                                class="btn btn-default openWin"
                                data-bs-dismiss="modal"
                                id="[% modal_id | html %]-print"
                                [% IF modal_print_name %]name="[% modal_print_name | html %]"[% END %]
                                data-url="[% modal_print_url | $raw %]"
                                [% IF modal_print_accesskey %]accesskey="[% modal_print_accesskey | html %]"[% END %]
                            >
                                <i class="fa fa-print"></i>
                                [% modal_print_text | html %] [% IF modal_print_accesskey %]([% modal_print_accesskey | html %])[% END %]
                            </button>
                            [% footer_has_content = 1 %]
                        [% END %]
                        [% IF modal_custom_utility_button %]
                            [% modal_custom_utility_button | $raw %]
                            [% footer_has_content = 1 %]
                        [% END %]
                        [% IF modal_deny_text %]
                            <button
                                [% IF modal_deny_action == "submit" %]type="submit"[% ELSE %]type="button"[% END %]
                                [% IF modal_deny_action == "dismiss" %]data-bs-dismiss="modal"[% END %]
                                class="btn btn-default deny"
                                id="[% modal_id | html %]-deny"
                                [% IF modal_deny_name %]name="[% modal_deny_name | html %]"[% END %]
                                [% IF modal_deny_val %]value="[% modal_deny_val | html %]"[% END %]
                                [% IF modal_deny_accesskey %]accesskey="[% modal_deny_accesskey | html %]"[% END %]
                            >
                                <i class="fa fa-times"></i>
                                [% modal_deny_text | html %] [% IF modal_deny_accesskey %]([% modal_deny_accesskey | html %])[% END %]
                            </button>
                            [% footer_has_content = 1 %]
                        [% END %]
                        [% IF modal_custom_deny %]
                            [% modal_custom_deny | $raw %]
                            [% footer_has_content = 1 %]
                        [% END %]
                        [% IF modal_footer_append %]
                            [% modal_footer_append | $raw %]
                            [% footer_has_content = 1 %]
                        [% END %]
                        [% IF !footer_has_content %]
                            <button type="button" data-bs-dismiss="modal" class="btn btn-default" id="[% modal_id | html %]-ok">[% t('OK') | html %]</button>
                        [% END %]
                    </div>
                    <input type="hidden" name="op" value="cud-null" /> [%# Must be passed in the content of the modal %]
                </form>
            </div>
        </div>
    </div>
[% END %]
