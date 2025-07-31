<template>
    <BaseResource
        :routeAction="routeAction"
        :instancedResource="this"
    ></BaseResource>
</template>
<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        routeAction: String,
        embedded: { type: Boolean, default: false },
    },
    setup(props) {
        const format_date = $date;

        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        const baseResource = useBaseResource({
            resourceName: "package",
            nameAttr: "name",
            idAttr: "package_id",
            components: {
                show: "EHoldingsLocalPackagesShow",
                list: "EHoldingsLocalPackagesList",
                add: "EHoldingsLocalPackagesFormAdd",
                edit: "EHoldingsLocalPackagesFormAddEdit",
            },
            apiClient: APIClient.erm.localPackages,
            table: {
                resourceTableUrl:
                    APIClient.erm.httpClient._baseURL +
                    "eholdings/local/packages",
            },
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this local package?"
                ),
                deleteSuccessMessage: $__("Local package %s deleted"),
                displayName: $__("Local package"),
                editLabel: $__("Edit package #%s"),
                emptyListMessage: $__("There are no packages defined"),
                newLabel: $__("New package"),
            },
            extendedAttributesResourceType: "package",
            vendors,
            props,
            moduleStore: "ERMStore",
            resourceAttrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: $__("Package name"),
                    tableColumnDefinition: {
                        title: $__("Package name"),
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
                    label: $__("Vendor"),
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
                    label: $__("Type"),
                    avCat: "av_package_types",
                },
                {
                    name: "content_type",
                    type: "select",
                    label: $__("Content type"),
                    avCat: "av_package_content_types",
                },
                {
                    name: "created_on",
                    type: "date",
                    label: $__("Created on"),
                    showElement: {
                        type: "text",
                        value: "created_on",
                        format: format_date,
                    },
                    hideIn: ["Form"],
                },
                {
                    name: "notes",
                    required: false,
                    type: "text",
                    label: $__("Notes"),
                },
                {
                    name: "package_agreements",
                    type: "relationshipWidget",
                    group: $__("Agreements"),
                    showElement: {
                        type: "table",
                        columnData: "package_agreements",
                        hidden: erm_package =>
                            !!erm_package.package_agreements?.length,
                        columns: [
                            {
                                name: $__("Agreement name"),
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
                        relationshipI18n: {
                            nameUpperCase: $__("Agreement"),
                            removeThisMessage: $__("Remove this agreement"),
                            addNewMessage: $__("Add new agreement"),
                            noneCreatedYetMessage: $__(
                                "There are no agreements created yet"
                            ),
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
                            label: $__("Agreement"),
                            requiredKey: "agreement_id",
                            selectLabel: "name",
                            required: true,
                            indexRequired: true,
                        },
                    ],
                    hideIn: ["List"],
                },
            ],
        });

        const defaults = baseResource.getFilterValues(baseResource.route.query);
        const tableOptions = {
            url: baseResource.getResourceTableUrl(),
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
            table_settings: eholdings_packages_table_settings,
            add_filters: true,
            filters_options: {
                vendor_id: [
                    ...vendors.value.map(e => {
                        e["_id"] = e["id"];
                        e["_str"] = e["name"];
                        return e;
                    }),
                ],
                package_type: () =>
                    baseResource.map_av_dt_filter("av_package_types"),
                content_type: () =>
                    baseResource.map_av_dt_filter("av_package_content_types"),
            },
            actions: {
                0: ["show"],
                "-1": ["edit", "delete"],
            },
        };

        const checkForm = erm_package => {
            let errors = [];
            let package_agreements = erm_package.package_agreements;
            const agreement_ids = package_agreements.map(pa => pa.agreement_id);
            const duplicate_agreement_ids = agreement_ids.filter(
                (id, i) => agreement_ids.indexOf(id) !== i
            );

            if (duplicate_agreement_ids.length) {
                errors.push($__("An agreement is used several times"));
            }

            baseResource.setWarning(errors.join("<br>"));
            return !errors.length;
        };
        const onFormSave = (e, packageToSave) => {
            e.preventDefault();

            let erm_package = JSON.parse(JSON.stringify(packageToSave)); // copy

            if (!checkForm(erm_package)) {
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
                baseResource.apiClient.update(erm_package, package_id).then(
                    success => {
                        baseResource.setMessage($__("Package updated"));
                        baseResource.router.push({
                            name: "EHoldingsLocalPackagesList",
                        });
                    },
                    error => {}
                );
            } else {
                baseResource.apiClient.create(erm_package).then(
                    success => {
                        baseResource.setMessage($__("Package created"));
                        baseResource.router.push({
                            name: "EHoldingsLocalPackagesList",
                        });
                    },
                    error => {}
                );
            }
        };
        const appendToShow = () => {
            let get_lib_from_av = baseResource.get_lib_from_av;
            return [
                {
                    type: "component",
                    name: $__("Titles"),
                    hidden: erm_package => erm_package,
                    componentPath:
                        "@koha-vue/components/RelationshipTableDisplay.vue",
                    componentProps: {
                        tableOptions: {
                            type: "object",
                            value: {
                                columns: [
                                    {
                                        title: $__("Name"),
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
                                        title: $__("Publication type"),
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
        };

        return {
            ...baseResource,
            tableOptions,
            checkForm,
            onFormSave,
            appendToShow,
        };
    },
    emits: ["select-resource"],
    name: "EHoldingsLocalPackagesResource",
    components: {
        BaseResource,
    },
};
</script>
