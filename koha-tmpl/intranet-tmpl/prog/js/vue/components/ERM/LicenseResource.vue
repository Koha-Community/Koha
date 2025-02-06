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
        routeAction: String,
    },
    setup(props) {
        const AVStore = inject("AVStore");
        const { av_license_types, av_license_statuses, av_user_roles } =
            storeToRefs(AVStore);

        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        return {
            ...BaseResource.setup({
                resourceName: "license",
                nameAttr: "name",
                idAttr: "license_id",
                showComponent: "LicensesShow",
                listComponent: "LicensesList",
                addComponent: "LicensesFormAdd",
                editComponent: "LicensesFormAddEdit",
                apiClient: APIClient.erm.licenses,
                resourceTableUrl: APIClient.erm._baseURL + "licenses",
                i18n: {
                    displayName: __("License"),
                    displayNameLowerCase: __("license"),
                    displayNamePlural: __("licenses"),
                },
                extendedAttributesResourceType: "license",
                av_license_types,
                av_license_statuses,
                av_user_roles,
                vendors,
            }),
        };
    },
    data() {
        const tableFilters = this.getTableFilters();
        const defaults = this.getFilters(this.$route.query, tableFilters);

        return {
            resourceAttrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("License name"),
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
                    componentProps: {
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
                    textAreaRows: 10,
                    textAreaCols: 50,
                    label: __("Description"),
                },
                {
                    name: "type",
                    required: true,
                    type: "select",
                    label: __("Type"),
                    avCat: "av_license_types",
                },
                {
                    name: "status",
                    required: true,
                    type: "select",
                    label: __("Status"),
                    avCat: "av_license_statuses",
                },
                {
                    name: "started_on",
                    type: "component",
                    label: __("Start date"),
                    componentPath: "./FlatPickrWrapper.vue",
                    showElement: {
                        type: "text",
                        value: "started_on",
                        format: this.format_date,
                    },
                    componentProps: {
                        id: {
                            type: "string",
                            value: "started_on",
                        },
                        date_to: {
                            type: "string",
                            value: "ended_on",
                        },
                    },
                },
                {
                    name: "ended_on",
                    type: "component",
                    label: __("End date"),
                    componentPath: "./FlatPickrWrapper.vue",
                    required: false,
                    showElement: {
                        type: "text",
                        value: "ended_on",
                        format: this.format_date,
                    },
                    componentProps: {
                        id: {
                            type: "string",
                            value: "ended_on",
                        },
                    },
                },
                {
                    name: "additional_fields",
                    extended_attributes_resource_type:
                        this.extendedAttributesResourceType,
                },
                {
                    name: "user_roles",
                    type: "relationshipWidget",
                    group: __("Users"),
                    showElement: {
                        type: "table",
                        columnData: "user_roles",
                        hidden: license => !!license.user_roles?.length,
                        label: __("License users"),
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
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "user_roles",
                        },
                        relationshipStrings: {
                            nameLowerCase: __("user"),
                            nameUpperCase: __("License user"),
                            namePlural: __("users"),
                        },
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                user_id: null,
                                role: null,
                                patron_str: "",
                            },
                        },
                    },
                    relationshipFields: [
                        {
                            name: "user_id",
                            type: "component",
                            label: __("User"),
                            componentPath: "./PatronSearch.vue",
                            required: true,
                            componentProps: {
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
                            avCat: "av_user_roles",
                            required: true,
                        },
                    ],
                },
                {
                    name: "documents",
                    type: "relationshipWidget",
                    group: __("Documents"),
                    showElement: {
                        type: "component",
                        hidden: license => !!license.documents?.length,
                        componentPath: "./DocumentDisplay.vue",
                        componentProps: {
                            resource: {
                                type: "resource",
                                value: null,
                            },
                        },
                    },
                    componentProps: {
                        resourceRelationships: {
                            resourceProperty: "documents",
                        },
                        relationshipStrings: {
                            nameLowerCase: __("document"),
                            nameUpperCase: __("Document"),
                            namePlural: __("documents"),
                        },
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                file_name: null,
                                file_type: null,
                                file_description: null,
                                file_content: null,
                                physical_location: null,
                                uri: null,
                                notes: null,
                            },
                        },
                    },
                    relationshipFields: [
                        {
                            name: "document",
                            type: "component",
                            componentPath: "./DocumentSelect.vue",
                            label: __("File"),
                            componentProps: {
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
            tableOptions: {
                columns: this.getTableColumns(),
                url: this.getResourceTableUrl(),
                options: { embed: "vendor,extended_attributes,+strings" },
                table_settings: this.license_table_settings,
                add_filters: true,
                filters_options: {
                    1: () =>
                        this.vendors.map(e => {
                            e["_id"] = e["id"];
                            e["_str"] = e["name"];
                            return e;
                        }),
                    3: () => this.map_av_dt_filter("av_license_types"),
                    4: () => this.map_av_dt_filter("av_license_statuses"),
                },
                actions: {
                    0: ["show"],
                    1: ["show"],
                    "-1": ["edit", "delete"],
                },
            },
            tableFilters,
        };
    },
    methods: {
        tableUrl() {
            return this.getResourceTableUrl();
        },
        checkForm(license) {
            let errors = [];

            let documents_with_uploaded_files = license.documents.filter(
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
            license.user_roles.forEach((user, i) => {
                if (user.patron_str === "") {
                    errors.push(
                        this.$__("License user %s is missing a user").format(
                            i + 1
                        )
                    );
                }
            });
            this.setWarning(errors.join("<br>"));
            return !errors.length;
        },
        onSubmit(e, licenseToSave) {
            e.preventDefault();

            let license = JSON.parse(JSON.stringify(licenseToSave)); // copy
            let license_id = license.license_id;

            if (!this.checkForm(license)) {
                return false;
            }

            delete license.license_id;
            delete license.vendor;
            delete license._strings;

            if (license.vendor_id == "") {
                license.vendor_id = null;
            }

            license.user_roles = license.user_roles.map(
                ({ patron, patron_str, ...keepAttrs }) => keepAttrs
            );

            license.documents = license.documents.map(
                ({ file_type, uploaded_on, ...keepAttrs }) => keepAttrs
            );

            if (license_id) {
                this.apiClient.update(license, license_id).then(
                    success => {
                        this.setMessage(this.$__("License updated"));
                        this.$router.push({ name: "LicensesList" });
                    },
                    error => {}
                );
            } else {
                this.apiClient.create(license).then(
                    success => {
                        this.setMessage(this.$__("License created"));
                        this.$router.push({ name: "LicensesList" });
                    },
                    error => {}
                );
            }
        },
        getTableColumns() {
            let get_lib_from_av = this.get_lib_from_av;

            return [
                {
                    title: __("ID"),
                    data: "me.license_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(`${row.license_id}`) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Name"),
                    data: "me.name:me.license_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(row.name) +
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
                    title: __("Type"),
                    data: "type",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av("av_license_types", row.type)
                        );
                    },
                },
                {
                    title: __("Status"),
                    data: "status",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av("av_license_statuses", row.status)
                        );
                    },
                },
                {
                    title: __("Started on"),
                    data: "started_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.started_on);
                    },
                },
                {
                    title: __("Ended on"),
                    data: "ended_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.ended_on);
                    },
                },
            ];
        },
        getTableFilters() {
            return [];
        },
        async filterTable(filters, table, embedded = false) {},
    },
    name: "LicenseResource",
};
</script>
