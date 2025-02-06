<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";
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
        embedded: { type: Boolean, default: false },
    },
    setup(props) {
        const AVStore = inject("AVStore");
        const { av_package_types, av_package_content_types } =
            storeToRefs(AVStore);

        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        return {
            ...BaseResource.setup({
                resourceName: "package",
                nameAttr: "name",
                idAttr: "package_id",
                showComponent: "EHoldingsLocalPackagesShow",
                listComponent: "EHoldingsLocalPackagesList",
                addComponent: "EHoldingsLocalPackagesFormAdd",
                editComponent: "EHoldingsLocalPackagesFormAddEdit",
                apiClient: APIClient.erm.localPackages,
                resourceTableUrl:
                    APIClient.erm._baseURL + "eholdings/local/packages",
                i18n: {
                    displayName: __("Local package"),
                    displayNameLowerCase: __("package"),
                    displayNamePlural: __("packages"),
                },
                extendedAttributesResourceType: "package",
                av_package_types,
                av_package_content_types,
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
                    label: __("Package name"),
                },
                {
                    name: "vendor_id",
                    type: "component",
                    label: __("Vendor"),
                    showElement: {
                        type: "text",
                        value: "vendor.name",
                        link: {
                            href: "/cgi-bin/koha/acquisition/vendors",
                            slug: "vendor_id",
                        },
                    },
                    componentPath: "./FormSelectVendors.vue",
                    componentProps: {
                        id: {
                            type: "string",
                            value: "package_id_",
                            indexRequired: true,
                        },
                    },
                },
                {
                    name: "package_type",
                    type: "select",
                    label: __("Type"),
                    avCat: "av_package_types",
                },
                {
                    name: "content_type",
                    type: "select",
                    label: __("Content type"),
                    avCat: "av_package_content_types",
                },
                {
                    name: "notes",
                    required: false,
                    type: "text",
                    label: __("Notes"),
                },
                {
                    name: "additional_fields",
                    extended_attributes_resource_type:
                        this.extendedAttributesResourceType,
                },
                {
                    name: "package_agreements",
                    type: "relationshipWidget",
                    group: __("Agreements"),
                    showElement: {
                        type: "table",
                        columnData: "package_agreements",
                        hidden: erm_package =>
                            !!erm_package.package_agreements?.length,
                        columns: [
                            {
                                name: __("Agreement name"),
                                value: "agreement.name",
                                link: {
                                    name: "AgreementsShow",
                                    params: {
                                        agreement_id: "agreement_id",
                                    },
                                },
                            },
                        ],
                    },
                    apiClient: APIClient.erm.agreements,
                    componentProps: {
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                agreement_id: null,
                            },
                        },
                        resourceRelationships: {
                            resourceProperty: "package_agreements",
                        },
                        relationshipStrings: {
                            nameLowerCase: __("agreement"),
                            nameUpperCase: __("Agreement"),
                            namePlural: __("agreements"),
                        },
                        fetchOptions: {
                            type: "boolean",
                            value: true,
                        },
                    },
                    relationshipFields: [
                        {
                            name: "agreement_id",
                            type: "select",
                            label: __("Agreement"),
                            requiredKey: "agreement_id",
                            selectLabel: "name",
                            required: true,
                        },
                    ],
                },
                {
                    name: "resources",
                    type: "relationshipWidget",
                    group: __("Titles"),
                    apiClient: APIClient.erm.localResources,
                    hideInForm: true,
                    showElement: {
                        type: "component",
                        hidden: erm_package => erm_package,
                        componentPath: "./RelationshipTableDisplay.vue",
                        componentProps: {
                            tableOptions: {
                                type: "object",
                                value: {
                                    columns: this.getRelationshipTableColumns(),
                                    options: {
                                        embed: "title",
                                    },
                                    url:
                                        APIClient.erm._baseURL +
                                        "eholdings/local/resources",
                                },
                            },
                            apiClient: {
                                type: "object",
                                value: APIClient.erm.localPackages,
                            },
                            filters: {
                                type: "filter",
                                keys: {
                                    package_id: { property: "package_id" },
                                },
                            },
                            resource: {
                                type: "resource",
                            },
                            resourceName: {
                                type: "string",
                                value: "title",
                            },
                        },
                    },
                },
            ],
            tableOptions: {
                columns: this.getTableColumns(),
                url: this.getResourceTableUrl(),
                options: {
                    embed: "resources+count,vendor.name,extended_attributes,+strings",
                    searchCols: [
                        { search: defaults.package_name },
                        null,
                        null,
                        { search: defaults.content_type },
                        null,
                        null,
                    ],
                },
                table_settings: this.eholdings_packages_table_settings,
                add_filters: true,
                filters_options: {
                    1: () =>
                        this.vendors.map(e => {
                            e["_id"] = e["id"];
                            e["_str"] = e["name"];
                            return e;
                        }),
                    2: () => this.map_av_dt_filter("av_package_types"),
                    3: () => this.map_av_dt_filter("av_package_content_types"),
                },
                actions: {
                    0: ["show"],
                    "-1": ["edit", "delete"],
                },
            },
            tableFilters,
        };
    },
    methods: {
        checkForm(erm_package) {
            let errors = [];
            let package_agreements = erm_package.package_agreements;
            const agreement_ids = package_agreements.map(pa => pa.agreement_id);
            const duplicate_agreement_ids = agreement_ids.filter(
                (id, i) => agreement_ids.indexOf(id) !== i
            );

            if (duplicate_agreement_ids.length) {
                errors.push(this.$__("An agreement is used several times"));
            }

            errors.forEach(function (e) {
                this.setWarning(e);
            });
            return !errors.length;
        },
        onSubmit(e, packageToSave) {
            e.preventDefault();

            let erm_package = JSON.parse(JSON.stringify(packageToSave)); // copy

            if (!this.checkForm(erm_package)) {
                return false;
            }

            let package_id = erm_package.package_id;
            delete erm_package.package_id;
            delete erm_package.resources;
            delete erm_package.vendor;
            delete erm_package.resources_count;
            delete erm_package.is_selected;
            delete erm_package._strings;

            erm_package.package_agreements = erm_package.package_agreements.map(
                ({ package_id, agreement, ...keepAttrs }) => keepAttrs
            );

            if (package_id) {
                this.apiClient.update(erm_package, package_id).then(
                    success => {
                        this.setMessage(this.$__("Package updated"));
                        this.$router.push({
                            name: "EHoldingsLocalPackagesList",
                        });
                    },
                    error => {}
                );
            } else {
                this.apiClient.create(erm_package).then(
                    success => {
                        this.setMessage(this.$__("Package created"));
                        this.$router.push({
                            name: "EHoldingsLocalPackagesList",
                        });
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
                    data: "me.name:me.package_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(`${row.name} (#${row.package_id})`) +
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
                            ? '<a href="/cgi-bin/koha/acquisition/vendors/' +
                                  row.vendor_id +
                                  '">' +
                                  escape_str(row.vendor.name) +
                                  "</a>"
                            : "";
                    },
                },
                {
                    title: __("Type"),
                    data: "package_type",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_package_types",
                                row.package_type
                            )
                        );
                    },
                },
                {
                    title: __("Content type"),
                    data: "content_type",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_package_content_types",
                                row.content_type
                            )
                        );
                    },
                },
                {
                    title: __("Created on"),
                    data: "created_on",
                    searchable: false,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.created_on);
                    },
                },
                {
                    title: __("Notes"),
                    data: "notes",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.notes;
                    },
                },
            ];
        },
        getTableFilters() {
            return [];
        },
        tableUrl(filters) {
            let url = this.getResourceTableUrl();
            return url;
        },
        async filterTable(filters, table, embedded = false) {},
        getToolbarButtons() {
            return [];
        },
        getRelationshipTableColumns() {
            const get_lib_from_av = this.get_lib_from_av;

            return [
                {
                    title: __("Name"),
                    data: "title.publication_title",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/eholdings/local/resources/' +
                            row.resource_id +
                            '" class="show">' +
                            escape_str(
                                `${row.title.publication_title} (#${row.title.title_id})`
                            ) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Publication type"),
                    data: "title.publication_type",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_title_publication_types",
                                row.title.publication_type
                            )
                        );
                    },
                },
            ];
        },
    },
    name: "EHoldingsLocalPackageResource",
};
</script>

<style scoped>
:deep(fieldset.rows ol table) {
    display: table;
}
</style>
