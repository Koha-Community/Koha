<template>
    <ResourceList
        v-if="action === 'list'"
        v-bind="{
            api_client,
            i18n,
            tableOptions,
            resource_name,
            goToResourceShow,
            goToResourceEdit,
            doResourceDelete,
            goToResourceAdd,
            tableFilters,
            getFilters,
            filterTable,
            tableUrl,
        }"
    />
    <ResourceShow
        v-if="action === 'show'"
        v-bind="{
            id_attr,
            api_client,
            i18n,
            resource_attrs,
            list_component,
            goToResourceEdit,
            doResourceDelete,
        }"
    />
    <ResourceFormAdd
        v-if="['add', 'edit'].includes(action)"
        v-bind="{
            id_attr,
            api_client,
            i18n,
            resource_attrs,
            list_component,
            resource: newResource,
            onSubmit,
        }"
    />
</template>

<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";
import ResourceShow from "../ResourceShow.vue";
import ResourceFormAdd from "../ResourceFormAdd.vue";
import ResourceList from "../ResourceList.vue";

export default {
    components: { ResourceShow, ResourceFormAdd, ResourceList },
    extends: BaseResource,
    props: {
        action: String,
    },
    setup(props) {
        const AVStore = inject("AVStore");
        const {
            av_agreement_statuses,
            av_agreement_closure_reasons,
            av_agreement_renewal_priorities,
            av_user_roles,
            av_agreement_license_statuses,
            av_agreement_license_location,
            av_agreement_relationships,
        } = storeToRefs(AVStore);

        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        return {
            ...BaseResource.setup({
                resource_name: "agreement",
                name_attr: "name",
                id_attr: "agreement_id",
                show_component: "AgreementsShow",
                list_component: "AgreementsList",
                add_component: "AgreementsFormAdd",
                edit_component: "AgreementsFormAddEdit",
                api_client: APIClient.erm.agreements,
                resource_table_url: APIClient.erm._baseURL + "agreements",
                i18n: {
                    display_name: __("Agreement"),
                    display_name_lc: __("agreement"),
                    display_name_plural: __("agreements"),
                },
                av_agreement_statuses,
                av_agreement_closure_reasons,
                av_agreement_renewal_priorities,
                av_user_roles,
                av_agreement_license_statuses,
                av_agreement_license_location,
                av_agreement_relationships,
                agreement_table_settings,
                vendors,
            }),
        };
    },
    data() {
        const tableFilters = this.getTableFilters();
        const defaults = this.getFilters(this.$route.query, tableFilters);

        return {
            resource_attrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("Agreement name"),
                    show_in_table: true,
                },
                {
                    name: "vendor_id",
                    type: "component",
                    label: __("Vendor"),
                    showElement: {
                        type: "text",
                        value: "vendor.name",
                        link: {
                            href: "/cgi-bin/koha/acqui/supplier.pl",
                            params: {
                                bookseller_id: "vendor_id",
                            },
                        },
                    },
                    componentPath: "./FormSelectVendors.vue",
                    props: {
                        id: {
                            type: "string",
                            value: "license_id_",
                            indexRequired: true,
                        },
                    },
                },
                {
                    name: "description",
                    type: "textarea",
                    text_area_rows: 10,
                    text_area_cols: 50,
                    label: __("Description"),
                    show_in_table: true,
                },
                {
                    name: "status",
                    required: true,
                    type: "select",
                    label: __("Status"),
                    av_cat: "av_agreement_statuses",
                    show_in_table: true,
                    onSelected: resource => {
                        if (resource.status !== "closed") {
                            resource.closure_reason = null;
                        }
                        return resource;
                    },
                },
                {
                    name: "closure_reason",
                    type: "select",
                    label: __("Closure reason"),
                    av_cat: "av_agreement_closure_reasons",
                    show_in_table: true,
                    disabled: agreement => agreement.status !== "closed",
                },
                {
                    name: "is_perpetual",
                    type: "boolean",
                    label: __("Is perpetual"),
                    show_in_table: true,
                },
                {
                    name: "renewal_priority",
                    type: "select",
                    label: __("Renewal priority"),
                    av_cat: "av_agreement_renewal_priorities",
                    show_in_table: true,
                },
                {
                    name: "license_info",
                    type: "textarea",
                    text_area_rows: 2,
                    text_area_cols: 50,
                    label: __("License info"),
                },
                {
                    name: "additional_fields",
                    type: "relationship",
                    showElement: {
                        type: "relationship",
                        hidden: agreement =>
                            !!agreement._strings?.additional_field_values
                                ?.length,
                        componentPath: "./AdditionalFieldsDisplay.vue",
                        props: {
                            resource_type: {
                                type: "string",
                                value: "agreement",
                            },
                            additional_field_values: {
                                type: "resourceProperty",
                                resourceProperty:
                                    "_strings.additional_field_values",
                            },
                        },
                    },
                    componentPath: "./AdditionalFieldsEntry.vue",
                    props: {
                        resource_type: {
                            type: "string",
                            value: "agreement",
                        },
                        additional_field_values: {
                            type: "resourceProperty",
                            resourceProperty: "extended_attributes",
                        },
                        resource: {
                            type: "resource",
                            value: "agreement",
                        },
                    },
                    events: [
                        {
                            name: "additional-fields-changed",
                            callback: this.additionalFieldsChanged,
                        },
                    ],
                },
                {
                    name: "periods",
                    type: "relationship",
                    showElement: {
                        type: "table",
                        columnData: "periods",
                        hidden: agreement => !!agreement.periods?.length,
                        columns: [
                            {
                                name: __("Period start"),
                                value: "started_on",
                                format: this.format_date,
                            },
                            {
                                name: __("Period end"),
                                value: "ended_on",
                                format: this.format_date,
                            },
                            {
                                name: __("Cancellation deadline"),
                                value: "cancellation_deadline",
                                format: this.format_date,
                            },
                            {
                                name: __("Notes"),
                                value: "notes",
                            },
                        ],
                    },
                    label: __("Periods"),
                    componentPath: "./ERM/AgreementPeriods.vue",
                    props: {
                        periods: {
                            type: "resourceProperty",
                            resourceProperty: "periods",
                        },
                    },
                    subFields: [
                        {
                            name: "started_on",
                            type: "component",
                            label: __("Start date"),
                            componentPath: "./FlatPickrWrapper.vue",
                            required: true,
                            props: {
                                id: {
                                    type: "string",
                                    value: "started_on_",
                                    indexRequired: true,
                                },
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                                date_to: {
                                    type: "string",
                                    value: "ended_on_",
                                    indexRequired: true,
                                },
                            },
                        },
                        {
                            name: "ended_on",
                            type: "component",
                            label: __("End date"),
                            componentPath: "./FlatPickrWrapper.vue",
                            required: false,
                            props: {
                                id: {
                                    type: "string",
                                    value: "ended_on_",
                                    indexRequired: true,
                                },
                            },
                        },
                        {
                            name: "cancellation_deadline",
                            type: "component",
                            label: __("Cancellation deadline"),
                            componentPath: "./FlatPickrWrapper.vue",
                            required: false,
                            props: {
                                id: {
                                    type: "string",
                                    value: "cancellation_deadline_",
                                    indexRequired: true,
                                },
                            },
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: __("Notes"),
                        },
                    ],
                },
                {
                    name: "user_roles",
                    type: "relationship",
                    label: __("Users"),
                    componentPath: "./ERM/UserRoles.vue",
                    showElement: {
                        type: "table",
                        columnData: "user_roles",
                        hidden: agreement => !!agreement.user_roles?.length,
                        columns: [
                            {
                                name: __("Name"),
                                value: "patron",
                                format: this.patron_to_html,
                            },
                            {
                                name: __("Role"),
                                value: "role",
                                av: "av_user_roles",
                            },
                        ],
                    },
                    props: {
                        user_roles: {
                            type: "resourceProperty",
                            resourceProperty: "user_roles",
                        },
                        av_user_roles: {
                            type: "av",
                            av: null,
                        },
                        user_type: {
                            type: "string",
                            value: __("Agreement user %s"),
                        },
                    },
                    subFields: [
                        {
                            name: "user_id",
                            type: "component",
                            label: __("User"),
                            componentPath: "./PatronSearch.vue",
                            required: true,
                            props: {
                                name: {
                                    type: "string",
                                    value: "user_id",
                                },
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                                resource: {
                                    type: "resource",
                                    value: null,
                                },
                                counter: {
                                    type: "string",
                                    value: "",
                                    indexRequired: true,
                                },
                                label: {
                                    type: "string",
                                    value: __("User"),
                                },
                            },
                        },
                        {
                            name: "role",
                            type: "select",
                            label: __("Role"),
                            av_cat: "av_user_roles",
                            required: true,
                        },
                    ],
                },
                {
                    name: "licenses",
                    type: "relationship",
                    label: __("Licenses"),
                    componentPath: "./ERM/AgreementLicenses.vue",
                    showElement: {
                        type: "table",
                        columnData: "agreement_licenses",
                        hidden: agreement =>
                            !!agreement.agreement_licenses?.length,
                        columns: [
                            {
                                name: __("Name"),
                                value: "license.name",
                                link: {
                                    name: "LicensesShow",
                                    params: {
                                        license_id: "license_id",
                                    },
                                },
                            },
                            {
                                name: __("Status"),
                                value: "status",
                                av: "av_agreement_license_statuses",
                            },
                            {
                                name: __("Physical location"),
                                value: "physical_location",
                                av: "av_agreement_license_location",
                            },
                            {
                                name: __("Notes"),
                                value: "notes",
                            },
                            {
                                name: __("URI"),
                                value: "uri",
                            },
                        ],
                    },
                    props: {
                        agreement_licenses: {
                            type: "resourceProperty",
                            resourceProperty: "agreement_licenses",
                        },
                        av_agreement_license_statuses: {
                            type: "av",
                            av: null,
                        },
                        av_agreement_license_location: {
                            type: "av",
                            av: null,
                        },
                    },
                    subFields: [
                        {
                            name: "license_id",
                            type: "component",
                            label: __("License"),
                            componentPath: "./InfiniteScrollSelect.vue",
                            required: true,
                            props: {
                                id: {
                                    type: "string",
                                    value: "license_id_",
                                    indexRequired: true,
                                },
                                selectedData: {
                                    type: "resourceProperty",
                                    resourceProperty: "license",
                                },
                                dataType: {
                                    type: "string",
                                    value: "licenses",
                                },
                                dataIdentifier: {
                                    type: "string",
                                    value: "license_id",
                                },
                                label: {
                                    type: "string",
                                    value: "name",
                                },
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                            },
                        },
                        {
                            name: "status",
                            type: "select",
                            label: __("Status"),
                            av_cat: "av_agreement_license_statuses",
                        },
                        {
                            name: "physical_location",
                            type: "select",
                            label: __("Physical location"),
                            av_cat: "av_agreement_license_location",
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: __("Notes"),
                        },
                        {
                            name: "uri",
                            required: false,
                            type: "text",
                            label: __("URI"),
                        },
                    ],
                },
                {
                    name: "relationships",
                    type: "relationship",
                    componentPath: "./ERM/AgreementRelationships.vue",
                    showElement: {
                        type: "component",
                        hidden: agreement =>
                            !!agreement.agreement_relationships?.length,
                        componentPath:
                            "./ERM/AgreementRelationshipsDisplay.vue",
                        props: {
                            agreement: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                    props: {
                        agreement_id: {
                            type: "resourceProperty",
                            resourceProperty: "agreement_id",
                        },
                        av_agreement_relationships: {
                            type: "av",
                            av: null,
                        },
                        relationships: {
                            type: "resourceProperty",
                            resourceProperty: "agreement_relationships",
                        },
                    },
                    subFields: [
                        {
                            name: "related_agreement_id",
                            type: "select",
                            label: __("Related agreement"),
                            requiredKey: "agreement_id",
                            selectLabel: "name",
                        },
                        {
                            name: "relationship",
                            type: "select",
                            label: __("Relationship"),
                            av_cat: "av_agreement_relationships",
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: __("Notes"),
                        },
                    ],
                },
                {
                    name: "packages",
                    type: "relationship",
                    componentPath: null,
                    showElement: {
                        type: "component",
                        hidden: agreement =>
                            !!agreement.agreement_packages?.length,
                        componentPath: "./ERM/AgreementPackagesDisplay.vue",
                        props: {
                            agreement: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                },
                {
                    name: "documents",
                    type: "relationship",
                    componentPath: "./ERM/Documents.vue",
                    showElement: {
                        type: "component",
                        hidden: agreement => !!agreement.documents?.length,
                        componentPath: "./DocumentDisplay.vue",
                        props: {
                            resource: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                    props: {
                        documents: {
                            type: "resourceProperty",
                            resourceProperty: "documents",
                        },
                    },
                    subFields: [
                        {
                            name: "document",
                            type: "component",
                            componentPath: "./DocumentSelect.vue",
                            label: __("File"),
                            props: {
                                counter: {
                                    type: "string",
                                    value: "",
                                    indexRequired: true,
                                },
                                document: {
                                    type: "resource",
                                    value: null,
                                },
                            },
                        },
                        {
                            name: "uri",
                            required: false,
                            type: "text",
                            label: __("URI"),
                        },
                        {
                            name: "notes",
                            required: false,
                            type: "text",
                            label: __("Notes"),
                        },
                    ],
                },
            ],
            agreement: {
                agreement_id: null,
                name: "",
                vendor_id: null,
                description: "",
                status: "",
                closure_reason: "",
                is_perpetual: false,
                renewal_priority: "",
                license_info: "",
                periods: [],
                user_roles: [],
                agreement_licenses: [],
                agreement_relationships: [],
                documents: [],
                extended_attributes: [],
            },
            tableOptions: {
                columns: this.getTableColumns(),
                options: {
                    embed: "user_roles,vendor,extended_attributes,+strings",
                },
                url: () => this.tableUrl(defaults),
                table_settings: this.agreement_table_settings,
                add_filters: true,
                filters_options: {
                    1: () =>
                        this.vendors.map(e => {
                            e["_id"] = e["id"];
                            e["_str"] = e["name"];
                            return e;
                        }),
                    3: () => this.map_av_dt_filter("av_agreement_statuses"),
                    4: () =>
                        this.map_av_dt_filter("av_agreement_closure_reasons"),
                    5: [
                        { _id: 0, _str: this.$__("No") },
                        { _id: 1, _str: this.$__("Yes") },
                    ],
                    6: () =>
                        this.map_av_dt_filter(
                            "av_agreement_renewal_priorities"
                        ),
                },
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
                default_filters: {
                    "user_roles.user_id": function () {
                        return defaults.by_mine
                            ? logged_in_user.borrowernumber
                            : "";
                    },
                },
            },
            tableFilters,
        };
    },
    methods: {
        checkForm(agreement) {
            let errors = [];

            let agreement_licenses = agreement.agreement_licenses;
            // Do not use al.license.name here! Its name is not the one linked with al.license_id
            // At this point al.license is meaningless, form/template only modified al.license_id
            const license_ids = agreement_licenses.map(al => al.license_id);
            const duplicate_license_ids = license_ids.filter(
                (id, i) => license_ids.indexOf(id) !== i
            );

            if (duplicate_license_ids.length) {
                errors.push(this.$__("A license is used several times"));
            }

            const related_agreement_ids = agreement.agreement_relationships.map(
                rs => rs.related_agreement_id
            );
            const duplicate_related_agreement_ids =
                related_agreement_ids.filter(
                    (id, i) => related_agreement_ids.indexOf(id) !== i
                );

            if (duplicate_related_agreement_ids.length) {
                errors.push(
                    this.$__(
                        "An agreement is used as relationship several times"
                    )
                );
            }

            if (
                agreement_licenses.filter(al => al.status == "controlling")
                    .length > 1
            ) {
                errors.push(
                    this.$__("Only one controlling license is allowed")
                );
            }

            if (
                agreement_licenses.filter(al => al.status == "controlling")
                    .length > 1
            ) {
                errors.push(
                    this.$__("Only one controlling license is allowed")
                );
            }

            let documents_with_uploaded_files = agreement.documents.filter(
                doc => typeof doc.file_content !== "undefined"
            );
            if (
                documents_with_uploaded_files.filter(
                    doc => atob(doc.file_content).length >= max_allowed_packet
                ).length >= 1
            ) {
                errors.push(
                    this.$__("File size exceeds maximum allowed: %s MB").format(
                        (max_allowed_packet / (1024 * 1024)).toFixed(2)
                    )
                );
            }
            agreement.user_roles.forEach((user, i) => {
                if (user.patron_str === "") {
                    errors.push(
                        this.$__("Agreement user %s is missing a user").format(
                            i + 1
                        )
                    );
                }
            });
            this.setWarning(errors.join("<br>"));
            return !errors.length;
        },
        onSubmit(e, agreementToSave) {
            e.preventDefault();

            //let agreement= Object.assign( {} ,this.agreement); // copy
            let agreement = JSON.parse(JSON.stringify(agreementToSave)); // copy
            let agreement_id = agreement.agreement_id;

            if (!this.checkForm(agreement)) {
                return false;
            }

            delete agreement.agreement_id;
            delete agreement.vendor;
            delete agreement._strings;
            agreement.is_perpetual = agreement.is_perpetual ? true : false;

            if (agreement.vendor_id == "") {
                agreement.vendor_id = null;
            }

            agreement.periods = agreement.periods.map(
                ({ agreement_id, agreement_period_id, ...keepAttrs }) =>
                    keepAttrs
            );

            agreement.user_roles = agreement.user_roles.map(
                ({ patron, patron_str, ...keepAttrs }) => keepAttrs
            );

            agreement.agreement_licenses = agreement.agreement_licenses.map(
                ({
                    license,
                    agreement_id,
                    agreement_license_id,
                    ...keepAttrs
                }) => keepAttrs
            );

            agreement.agreement_relationships =
                agreement.agreement_relationships.map(
                    ({ related_agreement, ...keepAttrs }) => keepAttrs
                );

            agreement.documents = agreement.documents.map(
                ({ file_type, uploaded_on, ...keepAttrs }) => keepAttrs
            );

            delete agreement.agreement_packages;

            if (agreement_id) {
                this.api_client.update(agreement, agreement_id).then(
                    success => {
                        this.setMessage(this.$__("Agreement updated"));
                        this.$router.push({ name: "AgreementsList" });
                    },
                    error => {}
                );
            } else {
                this.api_client.create(agreement).then(
                    success => {
                        this.setMessage(this.$__("Agreement created"));
                        this.$router.push({ name: "AgreementsList" });
                    },
                    error => {}
                );
            }
        },
        getTableColumns() {
            let get_lib_from_av = this.get_lib_from_av;
            let escape_str = this.escape_str;

            return [
                {
                    title: __("Name"),
                    data: "me.name:me.agreement_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(`${row.name} (#${row.agreement_id})`) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Vendor"),
                    data: "vendor_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.vendor_id != undefined
                            ? '<a href="/cgi-bin/koha/acqui/supplier.pl?booksellerid=' +
                                  row.vendor_id +
                                  '">' +
                                  escape_str(row.vendor.name) +
                                  "</a>"
                            : "";
                    },
                },
                {
                    title: __("Description"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Status"),
                    data: "status",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av("av_agreement_statuses", row.status)
                        );
                    },
                },
                {
                    title: __("Closure reason"),
                    data: "closure_reason",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_agreement_closure_reasons",
                                row.closure_reason
                            )
                        );
                    },
                },
                {
                    title: __("Is perpetual"),
                    data: "is_perpetual",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            row.is_perpetual ? __("Yes") : __("No")
                        );
                    },
                },
                {
                    title: __("Renewal priority"),
                    data: "renewal_priority",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_agreement_renewal_priorities",
                                row.renewal_priority
                            )
                        );
                    },
                },
            ];
        },
        getTableFilters() {
            return [
                {
                    name: "by_expired",
                    type: "checkbox",
                    label: __("Filter by expired"),
                    value: false,
                    onChange: function (filters) {
                        if (filters.by_expired) {
                            filters.max_expiration_date = new Date()
                                .toISOString()
                                .substring(0, 10);
                        } else {
                            filters.max_expiration_date = "";
                        }
                        return filters;
                    },
                },
                {
                    name: "max_expiration_date",
                    type: "component",
                    label: __("on"),
                    componentPath: "./FlatPickrWrapper.vue",
                    props: {
                        id: {
                            type: "string",
                            value: "max_expiration_date_filter",
                        },
                        disabled: {
                            type: "resourceProperty",
                            resourceProperty: "by_expired",
                        },
                    },
                    value: "",
                },
                {
                    name: "by_mine",
                    type: "checkbox",
                    label: __("Show mine only"),
                    value: false,
                },
            ];
        },
        tableUrl(filters) {
            let url = this.getResourceTableUrl();
            if (filters?.by_expired)
                url += "?max_expiration_date=" + filters.max_expiration_date;
            return url;
        },
        async filterTable(filters, table, embedded = false) {
            if (!embedded) {
                if (filters.by_expired && !filters.max_expiration_date) {
                    filters.max_expiration_date = new Date()
                        .toISOString()
                        .substring(0, 10);
                }
                if (!filters.by_expired) {
                    filters.max_expiration_date = "";
                }
                let { href } = this.$router.resolve({ name: "AgreementsList" });
                let new_route = this.build_url(href, filters);
                this.$router.push(new_route);
            }
            table.redraw(this.tableUrl(filters));
        },
    },
    computed: {
        newResource() {
            return this[this.resource_name];
        },
    },
    created() {
        //IMPROVEME: We need this for now to assign the correct av array from setup to the attr options in data
        this.assignAVs(this.resource_attrs);
        this.getResourceTableColumns();
    },
    name: "AgreementResource",
};
</script>
