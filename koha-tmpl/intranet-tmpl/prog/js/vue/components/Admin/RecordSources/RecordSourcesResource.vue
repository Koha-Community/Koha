<script>
import BaseResource from "../../BaseResource.vue";
import { APIClient } from "../../../fetch/api-client.js";

export default {
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
            resourceAttrs: [
                {
                    name: "record_source_id",
                    required: true,
                    type: "text",
                    label: __("Id"),
                    hideInForm: true,
                    showInTable: {
                        title: __("ID"),
                        data: "record_source_id",
                        searchable: true,
                    },
                },
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("Name"),
                    showInTable: true,
                },
                {
                    name: "can_be_edited",
                    type: "checkbox",
                    label: __("Can be edited"),
                    value: false,
                    showInTable: true,
                },
            ],
            tableOptions: {
                options: { embed: "usage_count" },
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
    },
    name: "RecordSourcesResource",
};
</script>
