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
        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        const additionalToolbarButtons = resource => {
            return {
                list: [
                    {
                        to: { name: "EHoldingsLocalTitlesFormImport" },
                        icon: "plus",
                        title: $__("Import from list"),
                    },
                    {
                        to: { name: "EHoldingsLocalTitlesKBARTImport" },
                        icon: "plus",
                        title: $__("Import from KBART file"),
                    },
                ],
            };
        };

        const baseResource = useBaseResource({
            resourceName: "title",
            nameAttr: "publication_title",
            idAttr: "title_id",
            components: {
                show: "EHoldingsLocalTitlesShow",
                list: "EHoldingsLocalTitlesList",
                add: "EHoldingsLocalTitlesFormAdd",
                edit: "EHoldingsLocalTitlesFormAddEdit",
            },
            apiClient: APIClient.erm.localTitles,
            table: {
                resourceTableUrl:
                    APIClient.erm.httpClient._baseURL +
                    "eholdings/local/titles",
            },
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this title?"
                ),
                deleteSuccessMessage: $__("Title %s deleted"),
                displayName: $__("Title"),
                editLabel: $__("Edit title #%s"),
                emptyListMessage: $__("There are no titles defined"),
                newLabel: $__("New title"),
            },
            vendors,
            props,
            additionalToolbarButtons,
            moduleStore: "ERMStore",
            resourceAttrs: [
                {
                    name: "publication_title",
                    required: true,
                    type: "text",
                    label: $__("Publication title"),
                    tableColumnDefinition: {
                        title: $__("Publication title"),
                        data: "publication_title:title_id",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return (
                                '<a role="button" class="show">' +
                                escape_str(
                                    `${row["publication_title"]} (#${row["title_id"]})`
                                ) +
                                "</a>"
                            );
                        },
                    },
                },
                {
                    name: "print_identifier",
                    type: "text",
                    label: $__("Print-format identifier"),
                    tableColumnDefinition: {
                        title: $__("Identifier"),
                        data: "print_identifier:online_identifier",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            let print_identifier = row.print_identifier;
                            let online_identifier = row.online_identifier;
                            return [
                                print_identifier
                                    ? escape_str(
                                          $__("ISBN (Print): %s").format(
                                              print_identifier
                                          )
                                      )
                                    : "",
                                online_identifier
                                    ? escape_str(
                                          $__("ISBN (Online): %s").format(
                                              online_identifier
                                          )
                                      )
                                    : "",
                            ].join("<br/>");
                        },
                    },
                },
                {
                    name: "online_identifier",
                    type: "text",
                    label: $__("Online-format identifier"),
                    hideIn: ["List"],
                },
                {
                    name: "date_first_issue_online",
                    type: "text",
                    label: $__("Date of first serial issue available online"),
                    hideIn: ["List"],
                },
                {
                    name: "num_first_vol_online",
                    type: "text",
                    label: $__("Number of first volume available online"),
                    hideIn: ["List"],
                },
                {
                    name: "num_first_issue_online",
                    type: "text",
                    label: $__("Number of first issue available online"),
                    hideIn: ["List"],
                },
                {
                    name: "date_last_issue_online",
                    type: "text",
                    label: $__("Date of last issue available online"),
                    hideIn: ["List"],
                },
                {
                    name: "num_last_vol_online",
                    type: "text",
                    label: $__("Number of last volume available online"),
                    hideIn: ["List"],
                },
                {
                    name: "num_last_issue_online",
                    type: "text",
                    label: $__("Number of last issue available online"),
                    hideIn: ["List"],
                },
                {
                    name: "title_url",
                    type: "text",
                    label: $__("Title-level URL"),
                    hideIn: ["List"],
                },
                {
                    name: "first_author",
                    type: "text",
                    label: $__("First author"),
                    tableColumnDefinition: {
                        title: $__("Contributors"),
                        data: "first_author:first_editor",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return (
                                escape_str(row.first_author) +
                                (row.first_author && row.first_editor
                                    ? "<br/>"
                                    : "") +
                                escape_str(row.first_editor)
                            );
                        },
                    },
                },
                {
                    name: "embargo_info",
                    type: "text",
                    label: $__("Embargo information"),
                    hideIn: ["List"],
                },
                {
                    name: "coverage_depth",
                    type: "text",
                    label: $__("Coverage depth"),
                    hideIn: ["List"],
                },
                {
                    name: "notes",
                    type: "text",
                    label: $__("Notes"),
                    hideIn: ["List"],
                },
                {
                    name: "publisher_name",
                    type: "text",
                    label: $__("Publisher name"),
                    hideIn: ["List"],
                },
                {
                    name: "publication_type",
                    type: "select",
                    label: $__("Publication type"),
                    avCat: "av_title_publication_types",
                },
                {
                    name: "date_monograph_published_print",
                    type: "text",
                    label: $__(
                        "Date the monograph is first published in print"
                    ),
                    hideIn: ["List"],
                },
                {
                    name: "date_monograph_published_online",
                    type: "text",
                    label: $__("Date the monograph is first published online"),
                    hideIn: ["List"],
                },
                {
                    name: "monograph_volume",
                    type: "text",
                    label: $__("Number of volume for monograph"),
                    hideIn: ["List"],
                },
                {
                    name: "monograph_edition",
                    type: "text",
                    label: $__("Edition of the monograph"),
                    hideIn: ["List"],
                },
                {
                    name: "first_editor",
                    type: "text",
                    label: $__("First editor"),
                    hideIn: ["List"],
                },
                {
                    name: "parent_publication_title_id",
                    type: "text",
                    label: $__("Title identifier of the parent publication"),
                    hideIn: ["List"],
                },
                {
                    name: "preceding_publication_title_id",
                    type: "text",
                    label: $__(
                        "Title identifier of any preceding publication title"
                    ),
                    hideIn: ["List"],
                },
                {
                    name: "access_type",
                    type: "text",
                    label: $__("Access type"),
                    hideIn: ["List"],
                },
                {
                    name: "create_linked_biblio",
                    type: "checkbox",
                    group:
                        props.routeAction === "add"
                            ? $__("Create linked bibliographic record")
                            : $__("Update linked bibliographic record"),
                    label:
                        props.routeAction === "add"
                            ? $__("Create bibliographic record")
                            : $__("Update bibliographic record"),
                    value: false,
                    hideIn: ["List"],
                },
                {
                    name: "resources",
                    type: "relationshipWidget",
                    group: $__("Packages"),
                    apiClient: APIClient.erm.localPackages,
                    showElement: {
                        type: "component",
                        hidden: title => title.resources.length > 0,
                        componentPath:
                            "@koha-vue/components/RelationshipTableDisplay.vue",
                        componentProps: {
                            tableOptions: {
                                type: "object",
                                value: {
                                    columns: [
                                        {
                                            title: $__("Name"),
                                            data: "package.name",
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
                                                        `${row.package.name} (#${row.package.package_id})`
                                                    ) +
                                                    "</a>"
                                                );
                                            },
                                        },
                                    ],
                                    options: {
                                        embed: "package",
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
                                    title_id: { property: "title_id" },
                                },
                            },
                            resource: {
                                type: "resource",
                            },
                            resourceName: {
                                type: "string",
                                value: "package",
                            },
                            resourceNamePlural: {
                                type: "string",
                                value: "packages",
                            },
                            hasAdditionalFields: {
                                type: "boolean",
                                value: true,
                            },
                        },
                    },
                    componentProps: {
                        newRelationshipDefaultAttrs: {
                            type: "object",
                            value: {
                                package_id: null,
                                vendor_id: null,
                                started_on: null,
                                ended_on: null,
                                proxy: "",
                            },
                        },
                        resourceRelationships: {
                            resourceProperty: "resources",
                        },
                        relationshipI18n: {
                            nameUpperCase: $__("Package"),
                            removeThisMessage: $__("Remove this package"),
                            addNewMessage: $__("Add new package"),
                            noneCreatedYetMessage: $__(
                                "There are no packages created yet"
                            ),
                        },
                        fetchOptions: {
                            type: "boolean",
                            value: true,
                        },
                    },
                    relationshipFields: [
                        {
                            name: "package_id",
                            type: "select",
                            label: $__("Package"),
                            requiredKey: "package_id",
                            selectLabel: "name",
                            required: true,
                            indexRequired: true,
                        },
                        {
                            name: "vendor_id",
                            type: "vendor",
                            label: $__("Vendor"),
                            indexRequired: true,
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
                        },
                        {
                            name: "started_on",
                            type: "date",
                            label: $__("Start date"),
                            componentProps: {
                                date_to: {
                                    type: "string",
                                    value: "ended_on",
                                    indexRequired: true,
                                },
                            },
                        },
                        {
                            name: "ended_on",
                            type: "date",
                            label: $__("End date"),
                        },
                        {
                            name: "proxy",
                            type: "text",
                            label: $__("Proxy"),
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
                embed: "resources.package",
                searchCols: [
                    { search: defaults.publication_title },
                    null,
                    { search: defaults.publication_type },
                    null,
                ],
            },
            table_settings: eholdings_titles_table_settings,
            add_filters: true,
            filters_options: {
                3: () =>
                    baseResource.map_av_dt_filter("av_title_publication_types"),
            },
            actions: {
                0: ["show"],
                "-1": ["edit", "delete"],
            },
        };

        const checkForm = title => {
            let errors = [];

            let resources = title.resources;
            const package_ids = resources.map(al => al.package_id);
            const duplicate_package_ids = package_ids.filter(
                (id, i) => package_ids.indexOf(id) !== i
            );

            if (duplicate_package_ids.length) {
                errors.push($__("A package is used several times"));
            }

            baseResource.setWarning(errors.join("<br>"));
            return !errors.length;
        };
        const onFormSave = (e, titleToSave) => {
            e.preventDefault();

            let title = JSON.parse(JSON.stringify(titleToSave)); // copy

            if (!checkForm(title)) {
                return false;
            }

            let title_id = title.title_id;
            delete title.title_id;
            delete title.biblio_id;

            // Cannot use the map/keepAttrs because of the reserved keyword 'package'
            title.resources.forEach(function (e) {
                delete e.package;
                delete e.resource_id;
            });

            if (title_id) {
                baseResource.apiClient.update(title, title_id).then(
                    success => {
                        baseResource.setMessage($__("Title updated"));
                        baseResource.router.push({
                            name: "EHoldingsLocalTitlesList",
                        });
                    },
                    error => {}
                );
            } else {
                baseResource.apiClient.create(title).then(
                    success => {
                        baseResource.setMessage($__("Title created"));
                        baseResource.router.push({
                            name: "EHoldingsLocalTitlesList",
                        });
                    },
                    error => {}
                );
            }
        };

        return {
            ...baseResource,
            tableOptions,
            checkForm,
            onFormSave,
        };
    },
    emits: ["select-resource"],
    name: "EHoldingsLocalTitlesResource",
    components: {
        BaseResource,
    },
};
</script>

<style scoped>
:deep(fieldset.rows label) {
    width: 25rem;
}
</style>
