<template>
    <BaseResource :routeAction="routeAction" :instancedResource="this" />
</template>

<script>
import { inject } from "vue";
import BaseResource from "./../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "SIP2AccountResource",
    components: {
        BaseResource,
    },
    props: {
        routeAction: String,
    },
    emits: ["select-resource"],
    setup(props) {
        const explodeValues = (value, delimiter) => {
            if (!value) return null;
            return Array.isArray(value) ? value : value.split(delimiter);
        };

        const getSIPFields = () => [
            { value: "AA", description: "AA" },
            { value: "AB", description: "AB" },
            { value: "AC", description: "AC" },
            { value: "AD", description: "AD" },
            { value: "AE", description: "AE" },
            { value: "AF", description: "AF" },
            { value: "AG", description: "AG" },
            { value: "AH", description: "AH" },
            { value: "AJ", description: "AJ" },
            { value: "AL", description: "AL" },
            { value: "AM", description: "AM" },
            { value: "AN", description: "AN" },
            { value: "AO", description: "AO" },
            { value: "AP", description: "AP" },
            { value: "AQ", description: "AQ" },
            { value: "AR", description: "AR" },
            { value: "AS", description: "AS" },
            { value: "AT", description: "AT" },
            { value: "AU", description: "AU" },
            { value: "AV", description: "AV" },
            { value: "AW", description: "AW" },
            { value: "AX", description: "AX" },
            { value: "AY", description: "AY" },
            { value: "AZ", description: "AZ" },
            { value: "BA", description: "BA" },
            { value: "BB", description: "BB" },
            { value: "BC", description: "BC" },
            { value: "BD", description: "BD" },
            { value: "BE", description: "BE" },
            { value: "BF", description: "BF" },
            { value: "BG", description: "BG" },
            { value: "BH", description: "BH" },
            { value: "BI", description: "BI" },
            { value: "BJ", description: "BJ" },
            { value: "BK", description: "BK" },
            { value: "BL", description: "BL" },
            { value: "BM", description: "BM" },
            { value: "BN", description: "BN" },
            { value: "BO", description: "BO" },
            { value: "BP", description: "BP" },
            { value: "BQ", description: "BQ" },
            { value: "BR", description: "BR" },
            { value: "BS", description: "BS" },
            { value: "BT", description: "BT" },
            { value: "BU", description: "BU" },
            { value: "BV", description: "BV" },
            { value: "BW", description: "BW" },
            { value: "BX", description: "BX" },
            { value: "BY", description: "BY" },
            { value: "BZ", description: "BZ" },
            { value: "CA", description: "CA" },
            { value: "CB", description: "CB" },
            { value: "CC", description: "CC" },
            { value: "CD", description: "CD" },
            { value: "CE", description: "CE" },
            { value: "CF", description: "CF" },
            { value: "CG", description: "CG" },
            { value: "CH", description: "CH" },
            { value: "CI", description: "CI" },
            { value: "CJ", description: "CJ" },
            { value: "CK", description: "CK" },
            { value: "CL", description: "CL" },
            { value: "CM", description: "CM" },
            { value: "CN", description: "CN" },
            { value: "CO", description: "CO" },
            { value: "CP", description: "CP" },
            { value: "CQ", description: "CQ" },
            { value: "CR", description: "CR" },
            { value: "CS", description: "CS" },
            { value: "CT", description: "CT" },
            { value: "CV", description: "CV" },
            { value: "CY", description: "CY" },
            { value: "DA", description: "DA" },
            { value: "PB", description: "PB" },
            { value: "PC", description: "PC" },
            { value: "PI", description: "PI" },
        ];

        const resourceAttrs = [
            {
                name: "login_id",
                required: true,
                type: "text",
                label: __("Staff userid for SIP2 authentication"),
                group: "Details",
                toolTip: __(
                    "Must match the userid of an existing Koha user with appropriate circulation permissions"
                ),
            },
            {
                name: "sip_institution_id",
                type: "relationshipSelect",
                label: __("Institution"),
                required: true,
                showElement: {
                    type: "text",
                    value: "institution.name",
                    link: {
                        href: "/cgi-bin/koha/sip2/institutions",
                        slug: "sip_institution_id",
                    },
                },
                relationshipAPIClient: APIClient.sip2.institutions,
                relationshipOptionLabelAttr: "name",
                relationshipRequiredKey: "sip_institution_id",
                group: "Details",
            },
            {
                name: "allow_additional_materials_checkout",
                type: "boolean",
                label: __("Allow additional materials checkout"),
                group: "Details",
                hideIn: ["List"],
                toolTip: __(
                    "If enabled, allows patrons to check out items via SIP even if the item has additional materials"
                ),
            },
            {
                name: "allow_empty_passwords",
                type: "boolean",
                label: __("Allow empty passwords"),
                group: "Details",
                hideIn: ["List"],
            },
            {
                name: "allow_fields",
                type: "select",
                allowMultipleChoices: true,
                defaultValue: null,
                options: getSIPFields(),
                requiredKey: "value",
                selectLabel: "description",
                label: __("Allow fields"),
                group: "Details",
                hideIn: ["List"],
                toolTip: __(
                    "Hides all fields not in the list, it is the inverse of hide_fields ( hide_fields takes precedence )"
                ),
            },
            {
                name: "blocked_item_types",
                type: "relationshipSelect",
                allowMultipleChoices: true,
                defaultValue: null,
                relationshipAPIClient: APIClient.item.item_types,
                relationshipOptionLabelAttr: "description",
                relationshipRequiredKey: "item_type_id",
                label: __("Blocked item types"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "List of item types that are blocked from being issued at this SIP account"
                ),
            },
            {
                name: "checked_in_ok",
                type: "boolean",
                label: __("Checked in OK"),
                hideIn: ["List"],
                group: "Details",
            },
            {
                name: "convert_nonprinting_characters",
                type: "text",
                label: __("Convert nonprinting characters"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Convert control and non-space separator characters into the given string"
                ),
            },
            {
                name: "cr_item_field",
                type: "select",
                label: __("CR item field"),
                options: [
                    {
                        value: "shelving_location",
                        description: __("Shelving location"),
                    },
                    {
                        value: "collection_code",
                        description: __("Collection code"),
                    },
                ],
                requiredKey: "value",
                selectLabel: "description",
                hideIn: ["List"],
                group: "Details",
                defaultValue: "collection_code",
                toolTip: __(
                    "Arbitrary item field to be used as the value for the CR field. Defaults to 'collection_code'"
                ),
            },
            {
                name: "ct_always_send",
                type: "boolean",
                label: __("CT always send"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __("Always send the CT field, even if it is empty"),
            },
            {
                name: "cv_send_00_on_success",
                type: "boolean",
                label: __("CV always send 00 on success"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    'Checkin success message to return a CV field of value "00" rather than no CV field at all'
                ),
            },
            {
                name: "cv_triggers_alert",
                type: "boolean",
                label: __("CV triggers alert"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Only set the alert flag if a value in the CV field is sent"
                ),
            },
            {
                name: "delimiter",
                type: "text",
                label: __("Delimiter"),
                placeholder: "|",
                group: "Details",
            },
            {
                name: "disallow_overpayment",
                type: "boolean",
                label: __("Disallow overpayment"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Set if over-paying a patron's account via SIP2 should fail, rather than create a credit on the account"
                ),
            },
            {
                name: "encoding",
                type: "select",
                label: __("Encoding"),
                options: [
                    { value: "utf8", description: __("utf8") },
                    { value: "ascii", description: __("ascii") },
                ],
                defaultValue: null,
                requiredKey: "value",
                selectLabel: "description",
                group: "Details",
            },
            {
                name: "error_detect",
                type: "boolean",
                label: __("Error detect"),
                group: "Details",
            },
            {
                name: "format_due_date",
                type: "boolean",
                label: __("Format due date"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Set to format the due date in the current DateFormat syspref"
                ),
            },
            {
                name: "hide_fields",
                type: "select",
                allowMultipleChoices: true,
                defaultValue: null,
                options: getSIPFields(),
                requiredKey: "value",
                selectLabel: "description",
                label: __("Hide fields"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Hides all fields in the list, it is the inverse of allow_fields ( hide_fields takes precedence )"
                ),
            },
            {
                name: "holds_block_checkin",
                type: "boolean",
                label: __("Holds block checkin"),
                hideIn: ["List"],
                group: "Details",
            },
            {
                name: "holds_get_captured",
                type: "boolean",
                label: __("Holds get captured"),
                hideIn: ["List"],
                group: "Details",
            },
            {
                name: "inhouse_item_types",
                type: "relationshipSelect",
                allowMultipleChoices: true,
                defaultValue: null,
                relationshipAPIClient: APIClient.item.item_types,
                relationshipOptionLabelAttr: "description",
                relationshipRequiredKey: "item_type_id",
                label: __("Inhouse item types"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Item types that can only do in house checkouts via SIP self check machines"
                ),
            },
            {
                name: "inhouse_patron_categories",
                type: "relationshipSelect",
                allowMultipleChoices: true,
                defaultValue: null,
                relationshipAPIClient: APIClient.patron.categories,
                relationshipOptionLabelAttr: "name",
                relationshipRequiredKey: "patron_category_id",
                label: __("Inhouse patron categories"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Patron categories that can only do in house checkouts via SIP self check machines"
                ),
            },
            {
                name: "lost_block_checkout",
                type: "number",
                label: __("Lost block checkout"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "If a patron has more than a certain number of lost items (default is 1), a flag is set"
                ),
                placeholder: "1",
            },
            {
                name: "lost_block_checkout_value",
                type: "number",
                label: __("Lost block checkout value"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Specifies the minimum value of a lost item to be counted towards the lost_block_checkout threshold."
                ),
                placeholder: "1",
            },
            {
                name: "lost_status_for_missing",
                type: "select",
                label: __("Lost status for missing"),
                avCat: "av_lost",
                defaultValue: null,
                hideIn: ["List"],
                group: "Details",
            },
            {
                name: "overdues_block_checkout",
                type: "boolean",
                label: __("Overdues block checkout"),
                hideIn: ["List"],
                group: "Details",
            },
            {
                name: "payment_type_writeoff",
                type: "text",
                label: __("Payment type writeoff"),
                hideIn: ["List"],
                group: "Details",
                placeholder: "06",
            },
            {
                name: "prevcheckout_block_checkout",
                type: "boolean",
                label: __("Previous checkout block checkout"),
                hideIn: ["List"],
                group: "Details",
            },
            {
                name: "register_id",
                type: "relationshipSelect",
                label: __("Cash register"),
                relationshipAPIClient: APIClient.cash.cash_registers,
                relationshipOptionLabelAttr: "name", // attr of the related resource used for display
                relationshipRequiredKey: "cash_register_id",
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Only required if system preference UseCashRegisters is enabled"
                ),
            },
            {
                name: "seen_on_item_information",
                type: "select",
                label: __("Seen on item information"),
                options: [
                    { value: "mark_found", description: __("Mark found") },
                    { value: "keep_lost", description: __("Keep lost") },
                ],
                defaultValue: null,
                requiredKey: "value",
                selectLabel: "description",
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "If set, the item information SIP message will update the datelastseen field for items. For lost items, will either keep them as'lost' or mark them as 'found' depending on the setting"
                ),
            },
            {
                name: "send_patron_home_library_in_af",
                type: "boolean",
                label: __("Send patron home library in AF"),
                hideIn: ["List"],
                group: "Details",
            },
            {
                name: "show_checkin_message",
                type: "boolean",
                label: __("Show checkin message"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "If enabled, successful checking responses will contain an AF screen message"
                ),
            },
            {
                name: "show_outstanding_amount",
                type: "boolean",
                label: __("Show outstanding amount"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "If enabled, if the patron has outstanding charges, the total outstanding amount is displayed on SIP checkout"
                ),
            },
            {
                name: "terminator",
                type: "select",
                options: [
                    { value: "CRLF", description: "CRLF" },
                    { value: "CR", description: "CR" },
                ],
                defaultValue: null,
                requiredKey: "value",
                selectLabel: "description",
                label: __("Terminator"),
                placeholder: "CRLF",
                group: "Details",
            },
            {
                name: "custom_patron_fields",
                type: "relationshipWidget",
                showElement: {
                    type: "table",
                    columnData: "custom_patron_fields",
                    hidden: account => !!account.custom_patron_fields?.length,
                    columns: [
                        {
                            name: __("Field"),
                            value: "field",
                        },
                        {
                            name: __("Template"),
                            value: "template",
                        },
                    ],
                },
                hideIn: ["List"],
                group: __("SIP response mappings"),
                componentProps: {
                    resourceRelationships: {
                        resourceProperty: "custom_patron_fields",
                    },
                    relationshipStrings: {
                        nameLowerCase: __("custom patron field"),
                        nameUpperCase: __("Custom patron field"),
                        namePlural: __("custom patron fields"),
                    },
                    newRelationshipDefaultAttrs: {
                        type: "object",
                        value: {
                            field: null,
                            template: null,
                        },
                    },
                },
                relationshipFields: [
                    {
                        name: "field",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "XY",
                        label: __("Field"),
                    },
                    {
                        name: "template",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "[% patron.dateexpiry %]",
                        label: __("Template"),
                    },
                ],
            },
            {
                name: "patron_attributes",
                type: "relationshipWidget",
                showElement: {
                    type: "table",
                    columnData: "patron_attributes",
                    hidden: account => !!account.patron_attributes?.length,
                    columns: [
                        {
                            name: __("Field"),
                            value: "field",
                        },
                        {
                            name: __("Code"),
                            value: "code",
                        },
                    ],
                },
                hideIn: ["List"],
                group: __("SIP response mappings"),
                componentProps: {
                    resourceRelationships: {
                        resourceProperty: "patron_attributes",
                    },
                    relationshipStrings: {
                        nameLowerCase: __("patron attribute"),
                        nameUpperCase: __("Patron attribute"),
                        namePlural: __("patron attributes"),
                    },
                    newRelationshipDefaultAttrs: {
                        type: "object",
                        value: {
                            field: null,
                            code: null,
                        },
                    },
                },
                relationshipFields: [
                    {
                        name: "field",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "XY",
                        label: __("Field"),
                    },
                    {
                        name: "code",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "CODE",
                        label: __("Code"),
                    },
                ],
            },
            {
                name: "custom_item_fields",
                type: "relationshipWidget",
                showElement: {
                    type: "table",
                    columnData: "custom_item_fields",
                    hidden: account => !!account.custom_item_fields?.length,
                    columns: [
                        {
                            name: __("Field"),
                            value: "field",
                        },
                        {
                            name: __("Template"),
                            value: "template",
                        },
                    ],
                },
                hideIn: ["List"],
                group: __("SIP response mappings"),
                componentProps: {
                    resourceRelationships: {
                        resourceProperty: "custom_item_fields",
                    },
                    relationshipStrings: {
                        nameLowerCase: __("custom item field"),
                        nameUpperCase: __("Custom item field"),
                        namePlural: __("custom item fields"),
                    },
                    newRelationshipDefaultAttrs: {
                        type: "object",
                        value: {
                            field: null,
                            template: null,
                        },
                    },
                },
                relationshipFields: [
                    {
                        name: "field",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "IN",
                        label: __("Field"),
                    },
                    {
                        name: "template",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "[% item.itemnumber %]",
                        label: __("Template"),
                    },
                ],
            },
            {
                name: "item_fields",
                type: "relationshipWidget",
                showElement: {
                    type: "table",
                    columnData: "item_fields",
                    hidden: account => !!account.item_fields?.length,
                    columns: [
                        {
                            name: __("Field"),
                            value: "field",
                        },
                        {
                            name: __("Code"),
                            value: "code",
                        },
                    ],
                },
                hideIn: ["List"],
                group: __("SIP response mappings"),
                componentProps: {
                    resourceRelationships: {
                        resourceProperty: "item_fields",
                    },
                    relationshipStrings: {
                        nameLowerCase: __("item field"),
                        nameUpperCase: __("Item field"),
                        namePlural: __("item fields"),
                    },
                    newRelationshipDefaultAttrs: {
                        type: "object",
                        value: {
                            field: null,
                            code: null,
                        },
                    },
                },
                relationshipFields: [
                    {
                        name: "field",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "XY",
                        label: __("Field"),
                    },
                    {
                        name: "code",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "permanent_location",
                        label: __("Code"),
                    },
                ],
            },
            {
                name: "sort_bin_mappings",
                type: "relationshipWidget",
                showElement: {
                    type: "table",
                    columnData: "sort_bin_mappings",
                    hidden: account => !!account.sort_bin_mappings?.length,
                    columns: [
                        {
                            name: __("Mapping"),
                            value: "mapping",
                        },
                    ],
                },
                hideIn: ["List"],
                group: __("SIP response mappings"),
                componentProps: {
                    resourceRelationships: {
                        resourceProperty: "sort_bin_mappings",
                    },
                    relationshipStrings: {
                        nameLowerCase: __("sort bin mapping"),
                        nameUpperCase: __("Sort bin mapping"),
                        namePlural: __("sort bin mappings"),
                    },
                    newRelationshipDefaultAttrs: {
                        type: "object",
                        value: {
                            mapping: null,
                        },
                    },
                },
                relationshipFields: [
                    {
                        name: "mapping",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "CPL:location:eq:OFFICE:2",
                        label: __("Mapping"),
                    },
                ],
            },
            {
                name: "screen_msg_regexs",
                type: "relationshipWidget",
                showElement: {
                    type: "table",
                    columnData: "screen_msg_regexs",
                    hidden: account => !!account.screen_msg_regexs?.length,
                    columns: [
                        {
                            name: __("Find"),
                            value: "find",
                        },
                        {
                            name: __("Replace"),
                            value: "replace",
                        },
                    ],
                },
                hideIn: ["List"],
                group: __("SIP response mappings"),
                componentProps: {
                    resourceRelationships: {
                        resourceProperty: "screen_msg_regexs",
                    },
                    relationshipStrings: {
                        nameLowerCase: __("screen msg regex"),
                        nameUpperCase: __("Screen msg regex"),
                        namePlural: __("screen msg regexs"),
                    },
                    newRelationshipDefaultAttrs: {
                        type: "object",
                        value: {
                            find: null,
                            replace: null,
                        },
                    },
                },
                relationshipFields: [
                    {
                        name: "find",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "Greetings from Koha.",
                        label: __("Find"),
                    },
                    {
                        name: "replace",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "Welcome to your library!",
                        label: __("Replace"),
                    },
                ],
            },
            {
                name: "system_preference_overrides",
                type: "relationshipWidget",
                showElement: {
                    type: "table",
                    columnData: "system_preference_overrides",
                    hidden: account =>
                        !!account.system_preference_overrides?.length,
                    columns: [
                        {
                            name: __("Variable"),
                            value: "variable",
                        },
                        {
                            name: __("Value"),
                            value: "value",
                        },
                    ],
                },
                hideIn: ["List"],
                group: __("Syspref overrides"),
                componentProps: {
                    resourceRelationships: {
                        resourceProperty: "system_preference_overrides",
                    },
                    relationshipStrings: {
                        nameLowerCase: __("system preference override"),
                        nameUpperCase: __("System preference override"),
                        namePlural: __("system preference overrides"),
                    },
                    newRelationshipDefaultAttrs: {
                        type: "object",
                        value: {
                            variable: null,
                            value: null,
                        },
                    },
                },
                relationshipFields: [
                    {
                        name: "variable",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "AllFinesNeedOverride",
                        label: __("Variable"),
                    },
                    {
                        name: "value",
                        required: true,
                        indexRequired: true,
                        type: "text",
                        placeholder: "1",
                        label: __("Value"),
                    },
                ],
            },
            {
                name: "ae_field_template",
                type: "textarea",
                label: __("AE field template"),
                placeholder:
                    "[% patron.surname %][% IF patron.firstname %], [% patron.firstname %][% END %]",
                hideIn: ["List"],
                group: "Templates",
            },
            {
                name: "av_field_template",
                type: "textarea",
                label: __("AV field template"),
                placeholder:
                    "[% accountline.description %] [% accountline.amountoutstanding | format('%.2f') %]",
                hideIn: ["List"],
                group: "Templates",
            },
            {
                name: "da_field_template",
                type: "textarea",
                label: __("DA field template"),
                placeholder:
                    "[% patron.surname %][% IF patron.firstname %], [% patron.firstname %][% END %]",
                hideIn: ["List"],
                group: "Templates",
            },
        ];

        const additionalToolbarButtons = (resource, componentData) => {
            const buttons = {
                form: [
                    {
                        title: $__("Submit"),
                        form: componentData.resourceForm,
                    },
                    {
                        to: {
                            name: "SIP2AccountsList",
                        },
                        title: $__("Cancel"),
                        cssClass: "btn btn-link",
                    },
                ],
            };
            return buttons;
        };

        const baseResource = useBaseResource({
            resourceName: "account",
            nameAttr: "login_id",
            idAttr: "sip_account_id",
            components: {
                show: "SIP2AccountsShow",
                list: "SIP2AccountsList",
                add: "SIP2AccountsFormAdd",
                edit: "SIP2AccountsFormAddEdit",
            },
            apiClient: APIClient.sip2.accounts,
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this account?"
                ),
                deleteSuccessMessage: $__("Account %s deleted"),
                displayName: $__("Account"),
                editLabel: $__("Edit account #%s"),
                emptyListMessage: $__("There are no accounts defined"),
                newLabel: $__("New account"),
            },
            table: {
                resourceTableUrl:
                    APIClient.sip2.httpClient._baseURL + "accounts",
                options: { embed: "institution" },
            },
            additionalToolbarButtons,
            stickyToolbar: ["Form"],
            embedded: props.embedded,
            formGroupsDisplayMode: "accordion",
            resourceAttrs,
            props,
            moduleStore: "SIP2Store",
        });

        const tableOptions = {
            url: () => baseResource.getResourceTableUrl(),
            options: { embed: "institution" },
            table_settings: accounts_table_settings,
            actions: {
                0: ["show"],
                "-1": ["edit", "delete"],
            },
        };

        const onFormSave = async (e, accountToSave) => {
            e.preventDefault();

            const account = JSON.parse(JSON.stringify(accountToSave));
            const sip_account_id = account.sip_account_id;

            delete account.sip_account_id;
            delete account.institution;

            account.allow_fields = account.allow_fields?.join(",");
            account.hide_fields = account.hide_fields?.join(",");
            account.inhouse_item_types = account.inhouse_item_types?.join(",");
            account.inhouse_patron_categories =
                account.inhouse_patron_categories?.join(",");
            account.blocked_item_types = account.blocked_item_types?.join("|");

            if (!account.terminator) account.terminator = null;

            if (account.convert_nonprinting_characters === "") {
                account.convert_nonprinting_characters = null;
            }

            account.item_fields = account.item_fields?.map(
                ({ account_id, account_item_field_id, ...rest }) => rest
            );
            account.patron_attributes = account.patron_attributes?.map(
                ({ account_id, account_patron_attribute_id, ...rest }) => rest
            );

            const client = APIClient.sip2.accounts;

            try {
                if (sip_account_id) {
                    await client.update(account, sip_account_id);
                    baseResource.setMessage(__("Account updated"));
                } else {
                    await client.create(account);
                    baseResource.setMessage(__("Account created"));
                }

                baseResource.router.push({ name: "SIP2AccountsList" });
            } catch (error) {
                // Handle errors if needed
            }
        };

        const afterResourceFetch = (componentData, resource, caller) => {
            if (caller === "form") {
                resource.allow_fields = explodeValues(
                    resource.allow_fields,
                    ","
                );
                resource.blocked_item_types = explodeValues(
                    resource.blocked_item_types,
                    "|"
                );
                resource.hide_fields = explodeValues(resource.hide_fields, ",");
                resource.inhouse_item_types = explodeValues(
                    resource.inhouse_item_types,
                    ","
                );
                resource.inhouse_patron_categories = explodeValues(
                    resource.inhouse_patron_categories,
                    ","
                );
                resource.lost_status_for_missing =
                    resource.lost_status_for_missing
                        ? resource.lost_status_for_missing.toString()
                        : null;
            }
        };

        return {
            ...baseResource,
            tableOptions,
            getSIPFields,
            explodeValues,
            onFormSave,
            afterResourceFetch,
        };
    },
};
</script>
