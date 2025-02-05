<script>
import BaseResource from "../../BaseResource.vue";
import { APIClient } from "../../../fetch/api-client.js";
import ResourceShow from "../../ResourceShow.vue";
import ResourceFormAdd from "../../ResourceFormAdd.vue";
import ResourceList from "../../ResourceList.vue";

export default {
    components: { ResourceShow, ResourceFormAdd, ResourceList },
    extends: BaseResource,
    props: {
        routeAction: String,
    },
    setup(props) {
        return {
            ...BaseResource.setup({
                resourceName: "record_source",
                nameAttr: "name",
                idAttr: "record_source_id",
                showComponent: null,
                listComponent: "RecordSourcesList",
                addComponent: "RecordSourcesFormAdd",
                editComponent: "RecordSourcesFormAddEdit",
                apiClient: APIClient.record_sources.record_sources,
                resourceTableUrl: APIClient.record_sources._baseURL,
                i18n: {
                    displayName: __("Record source"),
                    displayNameLowerCase: __("record source"),
                    displayNamePlural: __("record sources"),
                },
            }),
        };
    },
    data() {
        const tableFilters = this.getTableFilters();
        const defaults = this.getFilters(this.$route.query, tableFilters);

        return {
            record_source: {
                record_source_id: null,
                name: "",
                can_be_edited: false,
            },
            resourceAttrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("Name"),
                },
                {
                    name: "can_be_edited",
                    type: "checkbox",
                    label: __("Can be edited"),
                    value: false,
                },
            ],
            tableOptions: {
                options: { embed: "usage_count" },
                columns: this.getTableColumns(),
                url: this.getResourceTableUrl(),
                actions: {
                    "-1": [
                        "edit",
                        {
                            delete: {
                                text: __("Delete"),
                                icon: "fa fa-trash",
                                should_display: row => row.usage_count == 0,
                            },
                        },
                    ],
                },
            },
            tableFilters,
        };
    },
    methods: {
        tableUrl() {
            return this.getResourceTableUrl();
        },
        onSubmit(e, recordSourceToSave) {
            e.preventDefault();
            let response;
            // RO attribute
            const recordSource = JSON.parse(JSON.stringify(recordSourceToSave)); // copy
            const recordSourceId = recordSource.record_source_id;

            delete recordSource.record_source_id;

            if (recordSourceId) {
                // update
                response = this.apiClient
                    .update(recordSource, recordSourceId)
                    .then(
                        success => {
                            this.setMessage(this.$__("Record source updated!"));
                            this.$router.push({ name: "RecordSourcesList" });
                        },
                        error => {}
                    );
            } else {
                response = this.apiClient.create(recordSource).then(
                    success => {
                        this.setMessage(this.$__("Record source created!"));
                        this.$router.push({ name: "RecordSourcesList" });
                    },
                    error => {}
                );
            }
        },
        getTableColumns() {
            let escape_str = this.escape_str;

            return [
                {
                    title: __("ID"),
                    data: "record_source_id",
                    searchable: true,
                },
                {
                    title: __("Name"),
                    data: "name",
                    searchable: true,
                },
                {
                    title: __("Can be edited"),
                    data: "can_be_edited",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            row.can_be_edited ? __("Yes") : __("No")
                        );
                    },
                },
            ];
        },
        getTableFilters() {
            return [];
        },
        async filterTable(filters, table, embedded = false) {},
    },
    name: "RecordSourcesResource",
};
</script>
