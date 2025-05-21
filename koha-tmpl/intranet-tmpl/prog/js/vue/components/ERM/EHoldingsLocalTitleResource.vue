<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    props: {
        routeAction: String,
        embedded: { type: Boolean, default: false },
    },
    setup(props) {
        const AVStore = inject("AVStore");
        const { av_title_publication_types } = storeToRefs(AVStore);

        const vendorStore = inject("vendorStore");
        const { vendors } = storeToRefs(vendorStore);

        return {
            ...BaseResource.setup({
                resourceName: "title",
                nameAttr: "publication_title",
                idAttr: "title_id",
                showComponent: "EHoldingsLocalTitlesShow",
                listComponent: "EHoldingsLocalTitlesList",
                addComponent: "EHoldingsLocalTitlesFormAdd",
                editComponent: "EHoldingsLocalTitlesFormAddEdit",
                apiClient: APIClient.erm.localTitles,
                resourceTableUrl:
                    APIClient.erm.httpClient._baseURL +
                    "eholdings/local/titles",
                i18n: {
                    deleteConfirmationMessage: __(
                        "Are you sure you want to remove this title?"
                    ),
                    deleteSuccessMessage: __("Title %s deleted"),
                    displayName: __("Title"),
                    editLabel: __("Edit title #%s"),
                    emptyListMessage: __("There are no titles defined"),
                    newLabel: __("New title"),
                },
                av_title_publication_types,
                eholdings_titles_table_settings,
                vendors,
            }),
        };
    },
    data() {
        const tableFilters = this.getTableFilterFormElements();
        const defaults = this.getFilterValues(this.$route.query, tableFilters);

        return {
            resourceAttrs: [
                {
                    name: "publication_title",
                    required: true,
                    type: "text",
                    label: this.$__("Publication title"),
                    showInTable: {
                        title: this.$__("Publication title"),
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
                    label: this.$__("Print-format identifier"),
                    showInTable: {
                        title: this.$__("Identifier"),
                        data: "print_identifier:online_identifier",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            let print_identifier = row.print_identifier;
                            let online_identifier = row.online_identifier;
                            return [
                                print_identifier
                                    ? escape_str(
                                          __("ISBN (Print): %s").format(
                                              print_identifier
                                          )
                                      )
                                    : "",
                                online_identifier
                                    ? escape_str(
                                          __("ISBN (Online): %s").format(
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
                    label: this.$__("Online-format identifier"),
                },
                {
                    name: "date_first_issue_online",
                    type: "text",
                    label: this.$__(
                        "Date of first serial issue available online"
                    ),
                },
                {
                    name: "num_first_vol_online",
                    type: "text",
                    label: this.$__("Number of first volume available online"),
                },
                {
                    name: "num_first_issue_online",
                    type: "text",
                    label: this.$__("Number of first issue available online"),
                },
                {
                    name: "date_last_issue_online",
                    type: "text",
                    label: this.$__("Date of last issue available online"),
                },
                {
                    name: "num_last_vol_online",
                    type: "text",
                    label: this.$__("Number of last volume available online"),
                },
                {
                    name: "num_last_issue_online",
                    type: "text",
                    label: this.$__("Number of last issue available online"),
                },
                {
                    name: "title_url",
                    type: "text",
                    label: this.$__("Title-level URL"),
                },
                {
                    name: "first_author",
                    type: "text",
                    label: this.$__("First author"),
                    showInTable: {
                        title: __("Contributors"),
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
                    label: this.$__("Embargo information"),
                },
                {
                    name: "coverage_depth",
                    type: "text",
                    label: this.$__("Coverage depth"),
                },
                {
                    name: "notes",
                    type: "text",
                    label: this.$__("Notes"),
                },
                {
                    name: "publisher_name",
                    type: "text",
                    label: this.$__("Publisher name"),
                },
                {
                    name: "publication_type",
                    type: "select",
                    label: this.$__("Publication type"),
                    avCat: "av_title_publication_types",
                    showInTable: true,
                },
                {
                    name: "date_monograph_published_print",
                    type: "text",
                    label: this.$__(
                        "Date the monograph is first published in print"
                    ),
                },
                {
                    name: "date_monograph_published_online",
                    type: "text",
                    label: this.$__(
                        "Date the monograph is first published online"
                    ),
                },
                {
                    name: "monograph_volume",
                    type: "text",
                    label: this.$__("Number of volume for monograph"),
                },
                {
                    name: "monograph_edition",
                    type: "text",
                    label: this.$__("Edition of the monograph"),
                },
                {
                    name: "first_editor",
                    type: "text",
                    label: this.$__("First editor"),
                },
                {
                    name: "parent_publication_title_id",
                    type: "text",
                    label: this.$__(
                        "Title identifier of the parent publication"
                    ),
                },
                {
                    name: "preceding_publication_title_id",
                    type: "text",
                    label: this.$__(
                        "Title identifier of any preceding publication title"
                    ),
                },
                {
                    name: "access_type",
                    type: "text",
                    label: this.$__("Access type"),
                },
                {
                    name: "create_linked_biblio",
                    type: "checkbox",
                    group:
                        this.routeAction === "add"
                            ? this.$__("Create linked bibliographic record")
                            : this.$__("Update linked bibliographic record"),
                    label:
                        this.routeAction === "add"
                            ? this.$__("Create bibliographic record")
                            : this.$__("Update bibliographic record"),
                    value: false,
                },
                {
                    name: "resources",
                    type: "relationshipWidget",
                    group: this.$__("Packages"),
                    apiClient: APIClient.erm.localPackages,
                    showElement: {
                        type: "component",
                        hidden: title => title.resources.length > 0,
                        componentPath: "./RelationshipTableDisplay.vue",
                        componentProps: {
                            tableOptions: {
                                type: "object",
                                value: {
                                    columns: [
                                        {
                                            title: __("Name"),
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
                        relationshipStrings: {
                            nameLowerCase: this.$__("package"),
                            nameUpperCase: this.$__("Package"),
                            namePlural: this.$__("packages"),
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
                            label: this.$__("Package"),
                            requiredKey: "package_id",
                            selectLabel: "name",
                            required: true,
                            indexRequired: true,
                        },
                        {
                            name: "vendor_id",
                            type: "vendor",
                            label: this.$__("Vendor"),
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
                            label: this.$__("Start date"),
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
                            label: this.$__("End date"),
                        },
                        {
                            name: "proxy",
                            type: "text",
                            label: this.$__("Proxy"),
                        },
                    ],
                },
            ],
            tableOptions: {
                url: this.getResourceTableUrl(),
                options: {
                    embed: "resources.package",
                    searchCols: [
                        { search: defaults.publication_title },
                        null,
                        { search: defaults.publication_type },
                        null,
                    ],
                },
                table_settings: this.eholdings_titles_table_settings,
                add_filters: true,
                filters_options: {
                    3: () =>
                        this.map_av_dt_filter("av_title_publication_types"),
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
        checkForm(title) {
            let errors = [];

            let resources = title.resources;
            const package_ids = resources.map(al => al.package_id);
            const duplicate_package_ids = package_ids.filter(
                (id, i) => package_ids.indexOf(id) !== i
            );

            if (duplicate_package_ids.length) {
                errors.push(this.$__("A package is used several times"));
            }

            this.setWarning(errors.join("<br>"));
            return !errors.length;
        },
        onSubmit(e, titleToSave) {
            e.preventDefault();

            let title = JSON.parse(JSON.stringify(titleToSave)); // copy

            if (!this.checkForm(title)) {
                return false;
            }

            let title_id = title.title_id;
            delete title.title_id;
            delete title.biblio_id;

            // Cannot use the map/keepAttrs because of the reserved keywork 'package'
            title.resources.forEach(function (e) {
                delete e.package;
                delete e.resource_id;
            });

            if (title_id) {
                this.apiClient.update(title, title_id).then(
                    success => {
                        this.setMessage(this.$__("Title updated"));
                        this.$router.push({
                            name: "EHoldingsLocalTitlesList",
                        });
                    },
                    error => {}
                );
            } else {
                this.apiClient.create(title).then(
                    success => {
                        this.setMessage(this.$__("Title created"));
                        this.$router.push({
                            name: "EHoldingsLocalTitlesList",
                        });
                    },
                    error => {}
                );
            }
        },
        additionalToolbarButtons(resource) {
            return {
                list: [
                    {
                        to: { name: "EHoldingsLocalTitlesFormImport" },
                        icon: "plus",
                        title: this.$__("Import from list"),
                    },
                    {
                        to: { name: "EHoldingsLocalTitlesKBARTImport" },
                        icon: "plus",
                        title: this.$__("Import from KBART file"),
                    },
                ],
            };
        },
    },
    emits: ["select-resource"],
    name: "EHoldingsLocalTitlesResource",
};
</script>

<style scoped>
:deep(fieldset.rows ol table) {
    display: table;
}
:deep(fieldset.rows label) {
    width: 25rem;
}
</style>
