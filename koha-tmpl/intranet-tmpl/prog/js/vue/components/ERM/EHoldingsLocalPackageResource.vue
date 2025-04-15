<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";
import { inject } from "vue";
import { storeToRefs } from "pinia";

export default {
    extends: BaseResource,
    props: {
        routeAction: String,
        embedded: { type: Boolean, default: false },
    },
    setup(props) {
        const AVStore = inject("AVStore");
        const { av_package_types, av_package_content_types } =
            storeToRefs(AVStore);
        const { get_lib_from_av } = AVStore;

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
                    APIClient.erm.httpClient._baseURL +
                    "eholdings/local/packages",
                i18n: {
                    deleteConfirmationMessage: __(
                        "Are you sure you want to remove this local package?"
                    ),
                    deleteSuccessMessage: __("Local package %s deleted"),
                    displayName: __("Local package"),
                    editLabel: __("Edit package #%s"),
                    emptyListMessage: __("There are no packages defined"),
                    newLabel: __("New package"),
                },
                extendedAttributesResourceType: "package",
                av_package_types,
                av_package_content_types,
                eholdings_packages_table_settings,
                vendors,
                get_lib_from_av,
            }),
        };
    },
    data() {
        const tableFilters = this.getTableFilterFormElements();
        const defaults = this.getFilterValues(this.$route.query, tableFilters);

        return {
            resourceAttrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("Package name"),
                    showInTable: {
                        title: __("Package name"),
                        data: "name:package_id",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return (
                                '<a role="button" class="show">' +
                                escape_str(
                                    `${row["name"]} (#${row["package_id"]})`
                                ) +
                                "</a>"
                            );
                        },
                    },
                },
                {
                    name: "vendor_id",
                    type: "vendor",
                    label: __("Vendor"),
                    showInTable: true,
                    showElement: {
                        type: "text",
                        value: "vendor.name",
                        link: {
                            href: "/cgi-bin/koha/acquisition/vendors",
                            slug: "vendor_id",
                        },
                    },
                },
                {
                    name: "package_type",
                    type: "select",
                    label: __("Type"),
                    showInTable: true,
                    avCat: "av_package_types",
                },
                {
                    name: "content_type",
                    type: "select",
                    label: __("Content type"),
                    showInTable: true,
                    avCat: "av_package_content_types",
                },
                {
                    name: "created_on",
                    type: "date",
                    label: __("Created on"),
                    showInTable: true,
                    hideInForm: true,
                    showElement: {
                        type: "text",
                        value: "created_on",
                        format: this.format_date,
                    },
                },
                {
                    name: "notes",
                    required: false,
                    type: "text",
                    label: __("Notes"),
                    showInTable: true,
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
                            indexRequired: true,
                        },
                    ],
                },
            ],
            tableOptions: {
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

            this.setWarning(errors.join("<br>"));
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
            delete erm_package.created_on;

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
        appendToShow() {
            let get_lib_from_av = this.get_lib_from_av;
            return [
                {
                    type: "component",
                    name: __("Titles"),
                    hidden: erm_package => erm_package,
                    componentPath: "./RelationshipTableDisplay.vue",
                    componentProps: {
                        tableOptions: {
                            type: "object",
                            value: {
                                columns: [
                                    {
                                        title: __("Name"),
                                        data: "title.publication_title",
                                        searchable: true,
                                        orderable: true,
                                        render: function (
                                            data,
                                            type,
                                            row,
                                            meta
                                        ) {
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
                                        render: function (
                                            data,
                                            type,
                                            row,
                                            meta
                                        ) {
                                            return escape_str(
                                                get_lib_from_av(
                                                    "av_title_publication_types",
                                                    row.title.publication_type
                                                )
                                            );
                                        },
                                    },
                                ],
                                options: {
                                    embed: "title",
                                },
                                url:
                                    APIClient.erm.httpClient._baseURL +
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
                        resourceNamePlural: {
                            type: "string",
                            value: "titles",
                        },
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
