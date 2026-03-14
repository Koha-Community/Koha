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
        const SIP2Store = inject("SIP2Store");
        const { sysprefs } = storeToRefs(SIP2Store);

        const explodeValues = (value, delimiter) => {
            if (!value) return null;
            return Array.isArray(value) ? value : value.split(delimiter);
        };

        const getSIPFields = () => [
            { value: "AA", description: "AA - " + __("Patron identifier") },
            { value: "AB", description: "AB - " + __("Item identifier") },
            { value: "AC", description: "AC - " + __("Terminal password") },
            { value: "AD", description: "AD - " + __("Patron password") },
            { value: "AE", description: "AE - " + __("Personal name") },
            { value: "AF", description: "AF - " + __("Screen message") },
            { value: "AG", description: "AG - " + __("Print line") },
            { value: "AH", description: "AH - " + __("Due date") },
            { value: "AJ", description: "AJ - " + __("Title identifier") },
            { value: "AL", description: "AL - " + __("Blocked card message") },
            { value: "AM", description: "AM - " + __("Library name") },
            { value: "AN", description: "AN - " + __("Terminal location") },
            { value: "AO", description: "AO - " + __("Institution ID") },
            { value: "AP", description: "AP - " + __("Current location") },
            { value: "AQ", description: "AQ - " + __("Permanent location") },
            { value: "AR", description: "AR - " + __("Unused") },
            { value: "AS", description: "AS - " + __("Hold items") },
            { value: "AT", description: "AT - " + __("Overdue items") },
            { value: "AU", description: "AU - " + __("Charged items") },
            { value: "AV", description: "AV - " + __("Fine items") },
            { value: "AW", description: "AW - " + __("Unused") },
            { value: "AX", description: "AX - " + __("Unused") },
            { value: "AY", description: "AY - " + __("Sequence number") },
            { value: "AZ", description: "AZ - " + __("Checksum") },
            { value: "BA", description: "BA - " + __("Unused") },
            { value: "BB", description: "BB - " + __("Unused") },
            { value: "BC", description: "BC - " + __("Unused") },
            { value: "BD", description: "BD - " + __("Home address") },
            { value: "BE", description: "BE - " + __("Email address") },
            { value: "BF", description: "BF - " + __("Home phone") },
            { value: "BG", description: "BG - " + __("Owner") },
            { value: "BH", description: "BH - " + __("Currency type") },
            { value: "BI", description: "BI - " + __("Cancel") },
            { value: "BJ", description: "BJ - " + __("Unused") },
            { value: "BK", description: "BK - " + __("Transaction ID") },
            { value: "BL", description: "BL - " + __("Valid patron") },
            { value: "BM", description: "BM - " + __("Renewed items") },
            { value: "BN", description: "BN - " + __("Unrenewed items") },
            { value: "BO", description: "BO - " + __("Fee acknowledged") },
            { value: "BP", description: "BP - " + __("Start item") },
            { value: "BQ", description: "BQ - " + __("End item") },
            { value: "BR", description: "BR - " + __("Queue position") },
            { value: "BS", description: "BS - " + __("Pickup location") },
            { value: "BT", description: "BT - " + __("Fee type") },
            { value: "BU", description: "BU - " + __("Recall items") },
            { value: "BV", description: "BV - " + __("Fee amount") },
            { value: "BW", description: "BW - " + __("Expiration date") },
            { value: "BX", description: "BX - " + __("Supported messages") },
            { value: "BY", description: "BY - " + __("Hold type") },
            { value: "BZ", description: "BZ - " + __("Hold items limit") },
            { value: "CA", description: "CA - " + __("Overdue items limit") },
            { value: "CB", description: "CB - " + __("Charged items limit") },
            { value: "CC", description: "CC - " + __("Fee limit") },
            {
                value: "CD",
                description: "CD - " + __("Unavailable hold items"),
            },
            { value: "CE", description: "CE - " + __("Unused") },
            { value: "CF", description: "CF - " + __("Hold queue length") },
            { value: "CG", description: "CG - " + __("Fee ID") },
            { value: "CH", description: "CH - " + __("Item properties") },
            { value: "CI", description: "CI - " + __("Security inhibit") },
            { value: "CJ", description: "CJ - " + __("Recall date") },
            { value: "CK", description: "CK - " + __("Media type") },
            { value: "CL", description: "CL - " + __("Sort bin") },
            { value: "CM", description: "CM - " + __("Hold pickup date") },
            { value: "CN", description: "CN - " + __("Login user ID") },
            { value: "CO", description: "CO - " + __("Login password") },
            { value: "CP", description: "CP - " + __("Location code") },
            { value: "CQ", description: "CQ - " + __("Valid patron password") },
            { value: "CR", description: "CR - " + __("Collection code") },
            { value: "CS", description: "CS - " + __("Call number") },
            { value: "CT", description: "CT - " + __("Destination location") },
            { value: "CV", description: "CV - " + __("Alert type") },
            { value: "CY", description: "CY - " + __("Hold patron ID") },
            { value: "DA", description: "DA - " + __("Hold patron name") },
            { value: "PB", description: "PB - " + __("Patron birth date") },
            { value: "PC", description: "PC - " + __("Patron class") },
            {
                value: "PI",
                description: "PI - " + __("Patron internet profile"),
            },
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
                    "CR (Collection Code) is a 3M extension field that communicates an item's shelving category to SIP2 clients. Selects which Koha item field to use as the CR value. Defaults to 'collection_code'."
                ),
            },
            {
                name: "ct_always_send",
                type: "boolean",
                label: __("CT always send"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "CT (Destination Location) tells the SIP2 client where to route an item, for example to a holds shelf or to another branch for transfer. When enabled, this field is always sent in checkin responses even when the item has no routing destination."
                ),
            },
            {
                name: "cv_send_00_on_success",
                type: "boolean",
                label: __("CV always send 00 on success"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    'CV (Alert Type) classifies the reason for a checkin alert, for example: 01 = hold at same branch, 02 = hold for another branch, 04 = item needs transfer. Some SIP2 clients require CV to be present in every checkin response; when enabled, sends CV with value "00" (no alert) on successful checkins instead of omitting the field entirely.'
                ),
            },
            {
                name: "cv_triggers_alert",
                type: "boolean",
                label: __("CV triggers alert"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "When enabled, the SIP2 alert flag is only raised if a CV (Alert Type) value is present. When disabled (the default), the alert flag is raised if the checkin failed or if any CV value is sent."
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
                toolTip: __(
                    "If enabled, items are automatically assigned to holds at SIP check-in; The alerts messages will continue to show, however, to allow items to be put to one side and then captured by a subsequent staff check-in."
                ),
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
                label: __("Block previous checkouts"),
                hideIn: ["List"],
                group: "Details",
                toolTip: __(
                    "Block checkout of items previously or currently checked out by a patron"
                ),
            },
            {
                name: "register_id",
                type: "relationshipSelect",
                label: __("Cash register"),
                relationshipAPIClient: APIClient.cash.cash_registers,
                relationshipOptionLabelAttr: "name", // attr of the related resource used for display
                relationshipRequiredKey: "cash_register_id",
                hideIn: () =>
                    sysprefs.value.UseCashRegisters !== "0"
                        ? ["List"]
                        : ["Form", "Show", "List"],
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
                defaultValue: "CRLF",
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
                    relationshipI18n: {
                        nameUpperCase: __("Custom patron field"),
                        removeThisMessage: __(
                            "Remove this custom patron field"
                        ),
                        addNewMessage: __("Add new custom patron field"),
                        noneCreatedYetMessage: __(
                            "There are no custom patron fields created yet"
                        ),
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
                    relationshipI18n: {
                        nameUpperCase: __("Patron attribute"),
                        removeThisMessage: __("Remove this patron attribute"),
                        addNewMessage: __("Add new patron attribute"),
                        noneCreatedYetMessage: __(
                            "There are no patron attributes created yet"
                        ),
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
                        toolTip: __(
                            "Must match an existing patron attribute type code"
                        ),
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
                    relationshipI18n: {
                        nameUpperCase: __("Custom item field"),
                        removeThisMessage: __("Remove this custom item field"),
                        addNewMessage: __("Add new custom item field"),
                        noneCreatedYetMessage: __(
                            "There are no custom item fields created yet"
                        ),
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
                    relationshipI18n: {
                        nameUpperCase: __("Item field"),
                        removeThisMessage: __("Remove this item field"),
                        addNewMessage: __("Add new item field"),
                        noneCreatedYetMessage: __(
                            "There are no item fields created yet"
                        ),
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
                    relationshipI18n: {
                        nameUpperCase: __("Sort bin mapping"),
                        removeThisMessage: __("Remove this sort bin mapping"),
                        addNewMessage: __("Add new sort bin mapping"),
                        noneCreatedYetMessage: __(
                            "There are no sort bin mappings created yet"
                        ),
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
                    relationshipI18n: {
                        nameUpperCase: __("Screen msg regex"),
                        removeThisMessage: __("Remove this screen msg regex"),
                        addNewMessage: __("Add new screen msg regex"),
                        noneCreatedYetMessage: __(
                            "There are no screen msg regexs created yet"
                        ),
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
                group: __("System preference overrides"),
                componentProps: {
                    resourceRelationships: {
                        resourceProperty: "system_preference_overrides",
                    },
                    relationshipI18n: {
                        nameUpperCase: __("System preference override"),
                        removeThisMessage: __(
                            "Remove this system preference override"
                        ),
                        addNewMessage: __("Add new system preference override"),
                        noneCreatedYetMessage: __(
                            "There are no system preference overrides created yet"
                        ),
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
                label: "AE " + __("field template"),
                placeholder:
                    "[% patron.surname %][% IF patron.firstname %], [% patron.firstname %][% END %]",
                hideIn: ["List"],
                group: "Templates",
                toolTip:
                    "AE " +
                    __(
                        "(Personal name) is the patron's name as sent to the SIP2 client. Use Template Toolkit syntax - the patron fields (Koha::Patron) are available."
                    ),
            },
            {
                name: "av_field_template",
                type: "textarea",
                label: "AV " + __("field template"),
                placeholder:
                    "[% accountline.description %] [% accountline.amountoutstanding | format('%.2f') %]",
                hideIn: ["List"],
                group: "Templates",
                toolTip:
                    "AV " +
                    __(
                        "(Fine items) passes fee and fine details to the SIP2 client. Use Template Toolkit syntax - the accountline fields (Koha::Account::Line) and patron fields are available."
                    ),
            },
            {
                name: "da_field_template",
                type: "textarea",
                label: "DA " + __("field template"),
                placeholder:
                    "[% patron.surname %][% IF patron.firstname %], [% patron.firstname %][% END %]",
                hideIn: ["List"],
                group: "Templates",
                toolTip:
                    "DA " +
                    __(
                        "(Hold patron name) is the name of the patron who has placed a hold on the item being checked in. Use Template Toolkit syntax - the patron fields (Koha::Patron) for the hold patron and item fields are available."
                    ),
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
