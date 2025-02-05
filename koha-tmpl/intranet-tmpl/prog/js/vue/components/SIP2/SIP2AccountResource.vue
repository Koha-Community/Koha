<script>
import { inject } from "vue";
import BaseResource from "./../BaseResource.vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    props: {
        routeAction: String,
    },
    setup(props) {
        const AVStore = inject("AVStore");
        const { av_lost } = storeToRefs(AVStore);

        return {
            ...BaseResource.setup({
                resourceName: "account",
                nameAttr: "login_id",
                idAttr: "sip_account_id",
                showComponent: "SIP2AccountsShow",
                listComponent: "SIP2AccountsList",
                addComponent: "SIP2AccountsFormAdd",
                editComponent: "SIP2AccountsFormAddEdit",
                apiClient: APIClient.sip2.accounts,
                resourceTableUrl: APIClient.sip2._baseURL + "accounts",
                formGroupsDisplayMode: "accordion", // or default 'groups'
                i18n: {
                    displayName: __("Account"),
                    displayNameLowerCase: __("account"),
                    displayNamePlural: __("accounts"),
                },
                av_lost,
            }),
        };
    },
    data() {
        return {
            resourceAttrs: [
                {
                    name: "login_id",
                    required: true,
                    type: "text",
                    label: __("Account login id"),
                    group: "Details",
                },
                {
                    name: "login_password",
                    required: true,
                    type: "text",
                    label: __("Account login password"),
                    group: "Details",
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
                            href: "/cgi-bin/koha/sip2/institutions/1",
                            // params: {
                            //     bookseller_id: "vendor_id",
                            // },
                        },
                    },
                    relationshipAPIClient: APIClient.sip2.institutions,
                    relationshipOptionLabelAttr: "name", // attr of the related resource used for display
                    relationshipRequiredKey: "sip_institution_id",
                    group: "Details",
                },
                {
                    name: "allow_additional_materials_checkout",
                    type: "boolean",
                    label: __("Allow additional materials checkout"),
                    group: "Details",
                    toolTip: __(
                        "If enabled, allows patrons to check out items via SIP even if the item has additional materials"
                    ),
                },
                {
                    name: "allow_empty_passwords",
                    type: "boolean",
                    label: __("Allow empty passwords"),
                    group: "Details",
                },
                {
                    name: "allow_fields",
                    type: "select",
                    allowMultipleChoices: true,
                    defaultValue: null,
                    formatForForm: value => this.explodeValues(value, ","),
                    options: this.getSIPFields(),
                    requiredKey: "value",
                    selectLabel: "description",
                    label: __("Allow fields"),
                    group: "Details",
                    toolTip: __(
                        "Hides all fields not in the list, it is the inverse of hide_fields ( hide_fields takes precedence )"
                    ),
                },
                {
                    name: "blocked_item_types",
                    type: "relationshipSelect",
                    allowMultipleChoices: true,
                    formatForForm: value => this.explodeValues(value, "|"),
                    defaultValue: null,
                    relationshipAPIClient: APIClient.item.item_types,
                    relationshipOptionLabelAttr: "description",
                    relationshipRequiredKey: "item_type_id",
                    label: __("Blocked item types"),
                    group: "Details",
                    toolTip: __(
                        "List of item types that are blocked from being issued at this SIP account"
                    ),
                },
                {
                    name: "checked_in_ok",
                    type: "boolean",
                    label: __("Checked in OK"),
                    group: "Details",
                },
                {
                    name: "convert_nonprinting_characters",
                    type: "text",
                    label: __("Convert nonprinting characters"),
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
                    group: "Details",
                    toolTip: __(
                        "Always send the CT field, even if it is empty"
                    ),
                },
                {
                    name: "cv_send_00_on_success",
                    type: "boolean",
                    label: __("CV always send 00 on success"),
                    group: "Details",
                    toolTip: __(
                        'Checkin success message to return a CV field of value "00" rather than no CV field at all'
                    ),
                },
                {
                    name: "cv_triggers_alert",
                    type: "boolean",
                    label: __("CV triggers alert"),
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
                    group: "Details",
                },
                {
                    name: "hide_fields",
                    type: "select",
                    allowMultipleChoices: true,
                    defaultValue: null,
                    formatForForm: value => this.explodeValues(value, ","),
                    options: this.getSIPFields(),
                    requiredKey: "value",
                    selectLabel: "description",
                    label: __("Hide fields"),
                    group: "Details",
                    toolTip: __(
                        "Hides all fields in the list, it is the inverse of allow_fields ( hide_fields takes precedence )"
                    ),
                },
                {
                    name: "holds_block_checkin",
                    type: "boolean",
                    label: __("Holds block checkin"),
                    group: "Details",
                },
                {
                    name: "holds_get_captured",
                    type: "boolean",
                    label: __("Holds get captured"),
                    group: "Details",
                },
                {
                    name: "inhouse_item_types",
                    type: "relationshipSelect",
                    allowMultipleChoices: true,
                    defaultValue: null,
                    formatForForm: value => this.explodeValues(value, ","),
                    relationshipAPIClient: APIClient.item.item_types,
                    relationshipOptionLabelAttr: "description",
                    relationshipRequiredKey: "item_type_id",
                    label: __("Inhouse item types"),
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
                    formatForForm: value => this.explodeValues(value, ","),
                    relationshipAPIClient: APIClient.patron.patron_categories,
                    relationshipOptionLabelAttr: "name",
                    relationshipRequiredKey: "patron_category_id",
                    label: __("Inhouse patron categories"),
                    group: "Details",
                    toolTip: __(
                        "Patron categories that can only do in house checkouts via SIP self check machines"
                    ),
                },
                {
                    name: "lost_block_checkout",
                    type: "number",
                    label: __("Lost block checkout"),
                    group: "Details",
                    toolTip: __(
                        "If a patron has more than a certain number of lost items (default is 1), a flag is set"
                    ),
                    placeholder: 1,
                },
                {
                    name: "lost_block_checkout_value",
                    type: "number",
                    label: __("Lost block checkout value"),
                    group: "Details",
                    toolTip: __(
                        "Specifies the minimum value of a lost item to be counted towards the lost_block_checkout threshold."
                    ),
                    placeholder: 1,
                },
                {
                    name: "lost_status_for_missing",
                    type: "select",
                    label: __("Lost status for missing"),
                    formatForForm: value => (value ? value.toString() : null),
                    avCat: "av_lost",
                    defaultValue: null,
                    group: "Details",
                },
                {
                    name: "overdues_block_checkout",
                    type: "boolean",
                    label: __("Overdues block checkout"),
                    group: "Details",
                },
                {
                    name: "payment_type_writeoff",
                    type: "text",
                    label: __("Payment type writeoff"),
                    group: "Details",
                    placeholder: "06",
                },
                {
                    name: "prevcheckout_block_checkout",
                    type: "boolean",
                    label: __("Previous checkout block checkout"),
                    group: "Details",
                },
                {
                    name: "register_id",
                    type: "relationshipSelect",
                    label: __("Cash register"),
                    relationshipAPIClient: APIClient.cash.cash_registers,
                    relationshipOptionLabelAttr: "name", // attr of the related resource used for display
                    relationshipRequiredKey: "cash_register_id",
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
                    group: "Details",
                    toolTip: __(
                        "If set, the item information SIP message will update the datelastseen field for items. For lost items, will either keep them as'lost' or mark them as 'found' depending on the setting"
                    ),
                },
                {
                    name: "send_patron_home_library_in_af",
                    type: "boolean",
                    label: __("Send patron home library in AF"),
                    group: "Details",
                },
                {
                    name: "show_checkin_message",
                    type: "boolean",
                    label: __("Show checkin message"),
                    group: "Details",
                    toolTip: __(
                        "If enabled, successful checking responses will contain an AF screen message"
                    ),
                },
                {
                    name: "show_outstanding_amount",
                    type: "boolean",
                    label: __("Show outstanding amount"),
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
                        hidden: account =>
                            !!account.custom_patron_fields?.length,
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
                            type: "text",
                            placeholder: "XY",
                            label: __("Field"),
                        },
                        {
                            name: "template",
                            required: true,
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
                            type: "text",
                            placeholder: "XY",
                            label: __("Field"),
                        },
                        {
                            name: "code",
                            required: true,
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
                            type: "text",
                            placeholder: "IN",
                            label: __("Field"),
                        },
                        {
                            name: "template",
                            required: true,
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
                            type: "text",
                            placeholder: "XY",
                            label: __("Field"),
                        },
                        {
                            name: "code",
                            required: true,
                            type: "text",
                            placeholder: "permanent_location",
                            label: __("Code"),
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
                            type: "text",
                            placeholder: "AllFinesNeedOverride",
                            label: __("Variable"),
                        },
                        {
                            name: "value",
                            required: true,
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
                    group: "Templates",
                },
                {
                    name: "av_field_template",
                    type: "textarea",
                    label: __("AV field template"),
                    placeholder:
                        "[% accountline.description %] [% accountline.amountoutstanding | format('%.2f') %]",
                    group: "Templates",
                },
                {
                    name: "da_field_template",
                    type: "textarea",
                    label: __("DA field template"),
                    placeholder:
                        "[% patron.surname %][% IF patron.firstname %], [% patron.firstname %][% END %]",
                    group: "Templates",
                },
            ],
            tableOptions: {
                columns: this.getTableColumns(),
                url: () => this.resourceTableUrl,
                options: { embed: "institution" },
                table_settings: this.accounts_table_settings,
                actions: {
                    0: ["show"],
                    "-1": this.embedded
                        ? [
                              {
                                  select: {
                                      text: this.$__("Select"),
                                      icon: "fa fa-check",
                                  },
                              },
                          ]
                        : ["edit", "delete"],
                },
            },
        };
    },
    methods: {
        getSIPFields: function () {
            return [
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
        },
        explodeValues: function (value, delimiter) {
            if (!value) {
                return null;
            }
            return Array.isArray(value) ? value : value.split(delimiter);
        },
        getTableColumns: function () {
            return [
                {
                    title: __("Login"),
                    data: "login_id:sip_account_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(
                                `${row.login_id} (#${row.sip_account_id})`
                            ) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Institution"),
                    data: "sip_institution_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.sip_institution_id != undefined
                            ? '<a href="/cgi-bin/koha/sip2/institutions/' +
                                  row.sip_institution_id +
                                  '">' +
                                  escape_str(row.institution.name) +
                                  "</a>"
                            : "";
                    },
                },
                {
                    title: __("Delimiter"),
                    data: "delimiter",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Encoding"),
                    data: "encoding",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Error detect"),
                    data: "error_detect",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            row.error_detect ? __("Yes") : __("No")
                        );
                    },
                },
                {
                    title: __("Terminator"),
                    data: "terminator",
                    searchable: true,
                    orderable: true,
                },
            ];
        },
        onSubmit(e, accountToSave) {
            e.preventDefault();

            let account = JSON.parse(JSON.stringify(accountToSave)); // copy
            let sip_account_id = account.sip_account_id;

            delete account.sip_account_id;

            account.allow_fields = account.allow_fields?.join(",");
            account.hide_fields = account.hide_fields?.join(",");
            account.inhouse_item_types = account.inhouse_item_types?.join(",");
            account.inhouse_patron_categories =
                account.inhouse_patron_categories?.join(",");
            account.blocked_item_types = account.blocked_item_types?.join("|");

            if (!account.terminator) {
                account.terminator = null;
            }

            account.item_fields = account.item_fields.map(
                ({ account_id, account_item_field_id, ...keepAttrs }) =>
                    keepAttrs
            );

            account.patron_attributes = account.patron_attributes.map(
                ({ account_id, account_patron_attribute_id, ...keepAttrs }) =>
                    keepAttrs
            );

            const client = APIClient.sip2;
            if (sip_account_id) {
                client.accounts.update(account, sip_account_id).then(
                    success => {
                        this.setMessage(this.$__("Account updated"));
                        this.$router.push({ name: "SIP2AccountsList" });
                    },
                    error => {}
                );
            } else {
                client.accounts.create(account).then(
                    success => {
                        this.setMessage(this.$__("Account created"));
                        this.$router.push({ name: "SIP2AccountsList" });
                    },
                    error => {}
                );
            }
        },
    },
    name: "SIP2AccountResource",
};
</script>
