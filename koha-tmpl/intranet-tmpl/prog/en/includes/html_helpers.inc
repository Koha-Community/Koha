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

[% BLOCK options_for_authorised_values %]
    [% FOREACH av IN authorised_values %]
        [% IF av.authorised_value == selected_av %]
            <option value="[% av.authorised_value | html %]" selected="selected">[% av.lib | html %]</option>
        [% ELSE %]
            <option value="[% av.authorised_value | html %]">[% av.lib | html %]</option>
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
                    [% IF ( subfield.mandatory ) %]
                        <label class="required">[% subfield.subfield | html %] - [% subfield.marc_lib | $raw %]</label>
                    [% ELSE %]
                       <label>[% subfield.subfield | html %] - [% subfield.marc_lib | $raw %]</label>
                    [% END %]

                    [% SET mv = subfield.marc_value %]
                    [% IF ( mv.type == 'hidden' ) %]
                        <input type="hidden" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]">
                    [% ELSIF ( mv.type == 'select' ) %]
                        [% IF ( mv.readonly || subfield.IS_RETURN_CLAIM ) %]
                            <select name="[% kohafield | html %]" id="[%- mv.id | html -%]" class="input_marceditor [% kohafield | html %]" readonly="readonly" disabled="disabled" data-width="50%">
                        [% ELSE %]
                            <select name="[% kohafield | html %]" id="[%- mv.id | html -%]" class="input_marceditor select2 [% kohafield | html %]" data-category="[% mv.category | html %]" data-width="50%">
                        [% END %]

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
                                [%  ELSE %]
                                    <option value="[%- aval | html -%]">[%- mv.labels.$aval | html -%]</option>
                                [% END %]
                            [% END %]
                        [% END %]
                        [% UNLESS matched || ( ( kohafield == 'items.damaged' || kohafield == 'items.itemlost' || kohafield == 'items.withdrawn' || kohafield == 'items.notforloan' ) && mv.default == '0' ) %]
                        [%# If the current value is not in the authorised list  and is not a field where 0 means unset #%]
                                <option value="[%- mv.default | html -%]" selected="selected">[%- mv.default | html -%] (Not an authorised value)</option>
                            </select>
                            <span style="float:right;" title="The current value [% mv.default | html %] is not configured for the authorised value category controlling this subfield"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i></span>
                        [% ELSE %]
                            </select>
                        [% END %]
                    [% ELSIF ( mv.type == 'text_auth' ) %]
                        [% IF mv.readonly %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" readonly="readonly" />
                        [% ELSE %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" />
                            [% SET dopop = "Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=\"${mv.authtypecode}\"&index=${mv.id}','${mv.id}')" %]
                            <a href="#" class="buttonDot"  onclick="[%- dopop | html -%]; return false;" title="Tag editor">...</a>
                        [% END %]
                    [% ELSIF ( mv.type == 'text_plugin' ) %]
                        [% IF mv.readonly %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" readonly="readonly" />
                        [% ELSE %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" />
                            [% IF ( mv.nopopup ) %]
                                <a href="#" id="buttonDot_[%- mv.id | html -%]" class="[%- mv.class | html -%]" title="No  popup">...</a>
                            [% ELSE  %]
                                <a href="#" id="buttonDot_[%- mv.id | html -%]" class="[%- mv.class | html -%]" title="Tag editor">...</a>
                            [% END %]
                            [% UNLESS no_plugin %][%# FIXME - from batchMod-edit, jQuery is included at the end of the template and cataloguing plugins are not working in this situation %]
                                [%- mv.javascript | $raw -%]
                            [% END %]
                        [% END %]
                    [% ELSIF ( mv.type == 'text' ) %]
                        [% IF mv.readonly %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" readonly="readonly" />
                        [% ELSE %]
                            <input type="text" id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" maxlength="[%- mv.maxlength | html -%]" value="[%- mv.value | html -%]" />
                        [% END %]
                    [% ELSIF ( mv.type == 'textarea' ) %]
                        [% IF mv.readonly %]
                            <textarea id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" rows="5" cols="64" readonly="readonly" >[% mv.value | html %]</textarea>
                        [% ELSE %]
                            <textarea id="[%- mv.id | html -%]" name="[% kohafield | html %]" class="input_marceditor [% kohafield | html %]" rows="5" cols="64" >[% mv.value | html %]</textarea>
                        [% END %]
                    [% END %]

                    [% IF subfield.kohafield == 'items.more_subfields_xml' %]
                        <input type="hidden" name="items.more_subfields_xml" value="[% subfield.subfield | html %]" />
                    [% END %]
                    <input type="hidden" name="tag"       value="[% subfield.tag | html %]" />
                    <input type="hidden" name="kohafield" value="[% subfield.kohafield | html %]" /> [%# We should not need that but all item forms are not rewritten yet %]
                    <input type="hidden" name="subfield"  value="[% subfield.subfield | html %]" />
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
                            <input type="checkbox" id="row[% subfield.tag | html %][% subfield.subfield | html %][% subfield.random | html %]" title="Check to delete subfield [% subfield.subfield | html %]" name="disable_input" value="[% kohafield | html %]" />
                        [% ELSE %]
                            <span class="required">Required</span>
                        [% END %]
                    [% ELSE %]
                        [% IF ( subfield.mandatory ) %] <span class="required">Required</span>
                        [% ELSIF ( subfield.important ) %] <span class="important">Important</span>
                        [% END %]
                    [% END %]

                    [% IF add_regex %]
                        [% IF (mv.type == 'text' || mv.type == 'text_plugin' || mv.type == 'textarea' ) %]
                            <a href="#" name="[% kohafield | html %]_field_regex" class="field_regex" id="[% subfield.id | html %]" >RegEx</a>
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
    [% IF display_columns_selection %][%# Needs js/pages/batchMod.js %]
        [% IF checkboxes_edit OR checkboxes_delete %]
            <div class="btn-toolbar selections-toolbar">
                <a id="selectallbutton" href="#"><i class="fa fa-check"></i> Select all</a> | <a id="clearallbutton" href="#"><i class="fa fa-remove"></i> Clear all</a> | <a id="clearonloanbutton" href="#">Clear on loan</a>
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
            </p> <!-- /#selections -->
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
                        <th data-colname="[% item_header.column_name | html %]">
                    [% ELSE %]
                        <th>
                    [% END %]
                        [% item_header.header_value | html %]
                    </th>
                [% END %]
            </tr>
        </thead>
        <tbody>
            [% FOREACH item IN items %]
                [% SET can_be_edited = ! ( Koha.Preference('IndependentBranches') && ! logged_in_user.is_superlibrarian && item.homebranch != Branches.GetLoggedInBranchname() ) %]

                <tr>
                    <td>[% item.index + 1 | html %]</td>
                    [% IF checkboxes_edit %]
                        [% UNLESS can_be_edited%]
                            <td class="error">Cannot edit</td>
                        [% ELSE %]
                            <td>
                                <input type="checkbox" name="itemnumber" value="[% item.itemnumber | html %]" id="row[% item.itemnumber | html %]" checked="checked" data-is-onloan="[% item.is_checked_out | html %]" />
                            </td>
                        [% END %]
                    [% ELSIF checkboxes_delete %]
                        [% UNLESS can_be_edited %]
                            <td class="error">Cannot delete</td>
                        [% ELSE %]
                            [% IF item.safe_to_delete %]
                                <td><input type="checkbox" name="itemnumber" value="[% item.itemnumber | html %]" id="row[% item.itemnumber | html %]" checked="checked" /></td>
                            [% ELSE %]
                                [% SET messages = item.safe_to_delete.messages %]
                                [% FOR m IN messages %]
                                    [% SWITCH m.message %]
                                    [% CASE "book_on_loan" %][% SET cannot_delete_reason = t("Item is checked out") %]
                                    [% CASE "not_same_branch" %][% SET cannot_delete_reason = t("Item does not belong to your library") %]
                                    [% CASE "book_reserved" %][% SET cannot_delete_reason = t("Item has a waiting hold") %]
                                    [% CASE "linked_analytics" %][% SET cannot_delete_reason = t("Item has linked analytics") %]
                                    [% CASE "last_item_for_hold" %][% SET cannot_delete_reason = t("Last item for bibliographic record with biblio-level hold on it") %]
                                    [% CASE %][% SET cannot_delete_reason = t("Unknown reason") _ '(' _ m.message _ ')' %]
                                    [% END %]
                                [% END %]

                                <td><input type="checkbox" name="itemnumber" value="[% item.itemnumber | html %]" id="row[% item.itemnumber | html %]" disabled="disabled" title="[% cannot_delete_reason | html %]"/></td>
                            [% END %]

                        [% END %]
                    [% END %]
                    <td>
                        <label for="row[% item.itemnumber | html %]">
                            <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% item.biblionumber | uri %]">
                                [% item.biblio.title | html %]
                            </a>
                            [% IF ( item.biblio.author ) %], by [% item.biblio.author | html %][% END %]
                        </label>
                    </td>
                    <td class="holds_count">
                        [% IF item.holds %]
                            [% IF item.item_holds %]
                                <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% item.biblionumber | uri %]" title="Holds on this item: [% item.item_holds | html %] / Total holds on this record: [% item.holds | html -%]" >
                            [% ELSE %]
                                <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% item.biblionumber | uri %]" title="No holds on this item / Total holds on this record: [% item.holds | html -%]" >
                            [% END %]
                        [% ELSE %]
                            [% IF item.holds %]
                                <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% item.biblionumber | uri %]" title="Holds on this record: [% item.holds | html -%]" >
                            [% ELSE %]
                                <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% item.biblionumber | uri %]" title="No holds on this record" >
                            [% END %]
                        [% END # /IF item.holds %]
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
    </table> <!-- /#itemst -->
</div>
[% END %]

[%# BOOTSTRAP TAB WRAPPER USAGE
    [ WRAPPER tabs id= "tabs_container_id" ]
        [ WRAPPER tabs_nav ]
            [ WRAPPER tab_item tabname= "tab_name_1" bt_active= 1 ] Tab text 1 [ END ]
            [ WRAPPER tab_item tabname= "tab_name_2" ] Tab text 2 [ END ]
            ...
        [ END ]
        [ WRAPPER tab_panels ]
            [ WRAPPER tab_panel tabname="tab_name_1" bt_active= 1 ] Panel contents 1 [ END ]
            [ WRAPPER tab_panel tabname="tab_name_2" ] Panel contents 2 [ END ]
            ...
        [ END ]
    [ END ]
 %]

[% BLOCK tabs %]
    [% IF ( id ) %]
        <div id="[% id | html %]" class="toptabs">
    [% ELSE %]
        <div class="toptabs">
    [% END %]
        [% content | $raw %]
    </div>
[% END %]

[% BLOCK tabs_nav %]
    <ul class="nav nav-tabs" role="tablist">
        [% content | $raw %]
    </ul>
[% END %]

[% BLOCK tab_item %]
    [% IF ( bt_active ) %]
        <li role="presentation" class="active">
    [% ELSE %]
        <li role="presentation">
    [% END %]
        <a href="#[% tabname | uri %]_panel" data-tabname="[% tabname | uri %]" aria-controls="[% tabname | uri %]_panel" role="tab" data-toggle="tab">
            [% content | $raw %]
        </a>
    </li>
[% END %]

[% BLOCK tab_panels %]
    <div class="tab-content">
        [% content | $raw %]
    </div>
[% END %]

[% BLOCK tab_panel %]
    [% IF ( bt_active ) %]
        <div role="tabpanel" class="tab-pane active" id="[% tabname | html %]_panel">
    [% ELSE %]
        <div role="tabpanel" class="tab-pane" id="[% tabname | html %]_panel">
    [% END %]
        [% content| $raw %]
    </div>
[% END %]

[%# BOOTSTRAP BREADCRUMBS WRAPPER USAGE
    [ WRAPPER breadcrumbs ]
        [ Home breadcrumb automatically included ]
        [ WRAPPER breadcrumb_item ]
            <a href="/cgi-bin/koha/module/module-home.pl"> Module </a>
        [ END ]

        [ IF op == 'add_form' ]
            [ WRAPPER breadcrumb_item ]
                <a href="/cgi-bin/koha/module/page.pl"> Module page </a>
            [ END ]
            [ WRAPPER breadcrumb_item bc_active = 1 ]
                Add form
            [ END ]

        [ ELSIF op == 'delete_confirm' ]
            [ WRAPPER breadcrumb_item ]
                <a href="/cgi-bin/koha/module/page.pl"> Module page </a>
            [ END ]
            [ WRAPPER breadcrumb_item bc_active = 1 ]
                Confirm deletion
            [ END ]

        [ ELSE ]
            [ WRAPPER breadcrumb_item bc_active = 1 ]
                Module page
            [ END ]
        [ END #/IF op = add_form ]

    [ END #/ WRAPPER breadcrumbs ]
 %]

[%# Used to build breadcrumb navigation nav %]
[% BLOCK breadcrumbs %]
    <nav id="breadcrumbs" aria-label="Breadcrumb" class="breadcrumb">
        <ol>
            [%# Include the Home link every time %]
            [% WRAPPER breadcrumb_item %]
                <a href="/cgi-bin/koha/mainpage.pl">Home</a>
            [% END %]
            [% content | $raw %]
        </ol>
    </nav>
[% END %]

[%# Used to build individual breadcrumb items in the breadcrumb nav %]
[% BLOCK breadcrumb_item %]
    [% IF ( bc_active ) %]
        <li>
            <a href="#" aria-current="page">
                [% content | $raw %]
            </a>
        </li>
    [% ELSE %]
        <li>
            [% content | $raw %]
        </li>
    [% END %]
[% END %]
