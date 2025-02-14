<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${resourceName}_relationship_list`">
        <div v-if="resourceCount > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="formattedTableOptions"
                :searchable_additional_fields="searchable_additional_fields"
                :searchable_av_options="searchable_av_options"
            ></KohaTable>
        </div>
    </div>
</template>

<script>
import Toolbar from "./Toolbar.vue";
import ToolbarButton from "./ToolbarButton.vue";
import { ref } from "vue";
import { APIClient } from "../fetch/api-client.js";
import KohaTable from "./KohaTable.vue";

export default {
    setup(props) {
        const table = ref();

        return {
            table,
        };
    },
    props: {
        apiClient: Object,
        i18n: Object,
        tableOptions: Object,
        filters: {
            type: Object,
            default: {},
        },
        resource: Object,
        resourceName: String,
        hasAdditionalFields: {
            type: Boolean,
            default: false,
        },
    },
    data() {
        return {
            resourceCount: 0,
            initialized: false,
            searchable_additional_fields: [],
            searchable_av_options: [],
        };
    },
    created() {
        this.getResourceCount().then(() => {
            if (this.hasAdditionalFields) {
                this.getSearchableAdditionalFields().then(() =>
                    this.getSearchableAVOptions().then(
                        () => (this.initialized = true)
                    )
                );
            } else {
                this.initialized = true;
            }
        });
    },
    methods: {
        async getResourceCount() {
            await this.apiClient.count().then(
                count => {
                    this.resourceCount = count;
                },
                error => {}
            );
        },
        async getSearchableAdditionalFields() {
            const client = APIClient.additional_fields;
            await client.additional_fields.getAll(this.resourceName).then(
                searchable_additional_fields => {
                    this.searchable_additional_fields =
                        searchable_additional_fields.filter(
                            field => field.searchable
                        );
                },
                error => {}
            );
        },
        async getSearchableAVOptions() {
            const client_av = APIClient.authorised_values;
            let av_cat_array = this.searchable_additional_fields
                .filter(field => field.authorised_value_category_name)
                .map(field => field.authorised_value_category_name);

            await client_av.values
                .getCategoriesWithValues([
                    ...new Set(av_cat_array.map(av_cat => '"' + av_cat + '"')),
                ]) // unique
                .then(av_categories => {
                    av_cat_array.forEach(av_cat => {
                        let av_match = av_categories.find(
                            element => element.category_name == av_cat
                        );
                        this.searchable_av_options[av_cat] =
                            av_match.authorised_values.map(av => ({
                                value: av.value,
                                label: av.description,
                            }));
                    });
                });
        },
    },
    computed: {
        formattedTableOptions() {
            if (this.filters) {
                this.tableOptions.url += "?q=" + JSON.stringify(this.filters);
            }
            return this.tableOptions;
        },
    },
    components: { Toolbar, ToolbarButton, KohaTable },
    name: "RelationshipTableDisplay",
};
</script>

<style scoped>
.filters > input[type="checkbox"],
.filters > input[type="button"] {
    margin-left: 1rem;
}
</style>
