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
                    APIClient.erm._baseURL + "eholdings/local/titles",
                i18n: {
                    displayName: __("Title"),
                    displayNameLowerCase: __("title"),
                    displayNamePlural: __("titles"),
                },
                av_title_publication_types,
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
                    name: "publication_title",
                    required: true,
                    type: "text",
                    label: __("Publication title"),
                },
                {
                    name: "print_identifier",
                    type: "text",
                    label: __("Print-format identifier"),
                },
                {
                    name: "online_identifier",
                    type: "text",
                    label: __("Online-format identifier"),
                },
                {
                    name: "date_first_issue_online",
                    type: "text",
                    label: __("Date of first serial issue available online"),
                },
                {
                    name: "num_first_vol_online",
                    type: "text",
                    label: __("Number of first volume available online"),
                },
                {
                    name: "num_first_issue_online",
                    type: "text",
                    label: __("Number of first issue available online"),
                },
                {
                    name: "date_last_issue_online",
                    type: "text",
                    label: __("Date of last issue available online"),
                },
                {
                    name: "num_last_vol_online",
                    type: "text",
                    label: __("Number of last volume available online"),
                },
                {
                    name: "num_last_issue_online",
                    type: "text",
                    label: __("Number of last issue available online"),
                },
                {
                    name: "title_url",
                    type: "text",
                    label: __("Title-level URL"),
                },
                {
                    name: "first_author",
                    type: "text",
                    label: __("First author"),
                },
                {
                    name: "embargo_info",
                    type: "text",
                    label: __("Embargo information"),
                },
                {
                    name: "coverage_depth",
                    type: "text",
                    label: __("Coverage depth"),
                },
                {
                    name: "notes",
                    type: "text",
                    label: __("Notes"),
                },
                {
                    name: "publisher_name",
                    type: "text",
                    label: __("Publisher name"),
                },
                {
                    name: "publication_type",
                    type: "select",
                    label: __("Publication type"),
                    avCat: "av_title_publication_types",
                },
                {
                    name: "date_monograph_published_print",
                    type: "text",
                    label: __("Date the monograph is first published in print"),
                },
                {
                    name: "date_monograph_published_online",
                    type: "text",
                    label: __("Date the monograph is first published online"),
                },
                {
                    name: "monograph_volume",
                    type: "text",
                    label: __("Number of volume for monograph"),
                },
                {
                    name: "monograph_edition",
                    type: "text",
                    label: __("Edition of the monograph"),
                },
                {
                    name: "first_editor",
                    type: "text",
                    label: __("First editor"),
                },
                {
                    name: "parent_publication_title_id",
                    type: "text",
                    label: __("Title identifier of the parent publication"),
                },
                {
                    name: "preceding_publication_title_id",
                    type: "text",
                    label: __(
                        "Title identifier of any preceding publication title"
                    ),
                },
                {
                    name: "access_type",
                    type: "text",
                    label: __("Access type"),
                },
                {
                    name: "create_linked_biblio",
                    type: "checkbox",
                    group:
                        this.routeAction === "add"
                            ? __("Create linked bibliographic record")
                            : __("Update linked bibliographic record"),
                    label:
                        this.routeAction === "add"
                            ? __("Create bibliographic record")
                            : __("Update bibliographic record"),
                    value: false,
                },
                {
                    name: "resources",
                    type: "relationshipWidget",
                    group: __("Packages"),
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
                            nameLowerCase: __("package"),
                            nameUpperCase: __("Package"),
                            namePlural: __("packages"),
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
                            label: __("Package"),
                            requiredKey: "package_id",
                            selectLabel: "name",
                            required: true,
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
                                    value: "resource_vendor_id_",
                                    indexRequired: true,
                                },
                            },
                        },
                        {
                            name: "started_on",
                            type: "component",
                            label: __("Start date"),
                            componentPath: "./FlatPickrWrapper.vue",
                            componentProps: {
                                id: {
                                    type: "string",
                                    value: "started_on_",
                                    indexRequired: true,
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
                            componentProps: {
                                id: {
                                    type: "string",
                                    value: "ended_on_",
                                    indexRequired: true,
                                },
                            },
                        },
                        {
                            name: "proxy",
                            type: "text",
                            label: __("Proxy"),
                        },
                    ],
                },
            ],
            tableOptions: {
                columns: this.getTableColumns(),
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
                    2: () =>
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

            errors.forEach(function (e) {
                this.setWarning(e);
            });
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
        getTableColumns() {
            let get_lib_from_av = this.get_lib_from_av;
            let escape_str = this.escape_str;

            return [
                {
                    title: __("Title"),
                    data: "me.publication_title:me.title_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(
                                `${row.publication_title} (#${row.title_id})`
                            ) +
                            "</a>"
                        );
                    },
                },
                {
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
                {
                    title: __("Publication type"),
                    data: "publication_type",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_title_publication_types",
                                row.publication_type
                            )
                        );
                    },
                },
                {
                    title: __("Identifier"),
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
            return [
                {
                    to: { name: "EHoldingsLocalTitlesFormImport" },
                    icon: "plus",
                    title: __("Import from list"),
                },
                {
                    to: { name: "EHoldingsLocalTitlesKBARTImport" },
                    icon: "plus",
                    title: __("Import from KBART file"),
                },
            ];
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
