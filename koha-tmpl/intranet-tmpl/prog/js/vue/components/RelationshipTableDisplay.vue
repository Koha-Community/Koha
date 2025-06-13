<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${resourceNamePlural}_relationship_list`">
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
import { computed, onBeforeMount, ref } from "vue";
import { APIClient } from "../fetch/api-client.js";
import KohaTable from "./KohaTable.vue";

export default {
    setup(props) {
        const table = ref();
        const resourceCount = ref(0);
        const initialized = ref(false);
        const searchable_additional_fields = ref([]);
        const searchable_av_options = ref([]);

        const getResourceCount = async () => {
            await props.apiClient.count().then(
                count => {
                    resourceCount.value = count;
                },
                error => {}
            );
        };
        const getSearchableAdditionalFields = async () => {
            const client = APIClient.additional_fields;
            await client.additional_fields.getAll(props.resourceName).then(
                response => {
                    searchable_additional_fields.value = response.filter(
                        field => field.searchable
                    );
                },
                error => {}
            );
        };
        const getSearchableAVOptions = async () => {
            const client_av = APIClient.authorised_values;
            let av_cat_array = searchable_additional_fields.value
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
                        searchable_av_options.value[av_cat] =
                            av_match.authorised_values.map(av => ({
                                value: av.value,
                                label: av.description,
                            }));
                    });
                });
        };

        const formattedTableOptions = computed(() => {
            if (props.filters) {
                props.tableOptions.url += "?q=" + JSON.stringify(props.filters);
            }
            return props.tableOptions;
        });
        onBeforeMount(() => {
            getResourceCount().then(() => {
                if (props.hasAdditionalFields) {
                    getSearchableAdditionalFields().then(() =>
                        getSearchableAVOptions().then(
                            () => (initialized.value = true)
                        )
                    );
                } else {
                    initialized.value = true;
                }
            });
        });

        return {
            table,
            resourceCount,
            initialized,
            searchable_additional_fields,
            searchable_av_options,
            formattedTableOptions,
            getResourceCount,
            getSearchableAdditionalFields,
            getSearchableAVOptions,
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
        resourceNamePlural: String,
        hasAdditionalFields: {
            type: Boolean,
            default: false,
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
