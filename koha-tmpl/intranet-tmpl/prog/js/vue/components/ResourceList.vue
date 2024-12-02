<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="resource_list">
        <Toolbar v-if="!embedded">
            <ToolbarButton
                action="add"
                @go-to-add-resource="goToResourceAdd"
                :title="$__('New %s').format(i18n.display_name_lc)"
            />
        </Toolbar>
        <fieldset
            v-if="tableFilters?.length > 0 && resource_count > 0"
            class="filters"
        >
            <template
                v-for="(filter, index) in tableFilters"
                v-bind:key="index"
            >
                <FormElement
                    :resource="filters"
                    :attr="filter"
                    :index="index"
                />
            </template>
            <input
                @click="filterTable(filters, table, embedded)"
                id="filterTable"
                type="button"
                :value="$__('Filter')"
            />
        </fieldset>
        <div v-if="resource_count > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                :searchable_additional_fields="searchable_additional_fields"
                :searchable_av_options="searchable_av_options"
                @show="goToResourceShow"
                @edit="goToResourceEdit"
                @delete="doResourceDelete"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{
                $__("There are no %s defined").format(i18n.display_name_plural)
            }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./Toolbar.vue";
import ToolbarButton from "./ToolbarButton.vue";
import { ref } from "vue";
import { APIClient } from "../fetch/api-client.js";
import KohaTable from "./KohaTable.vue";
import FormElement from "./FormElement.vue";

export default {
    setup() {
        const table = ref();

        return {
            table,
            license_table_settings,
        };
    },
    props: {
        embedded: { type: Boolean, default: false },
        api_client: Object,
        i18n: Object,
        tableOptions: Object,
        resource_name: String,
        goToResourceShow: Function,
        goToResourceEdit: Function,
        doResourceDelete: Function,
        goToResourceAdd: Function,
        tableFilters: Array,
        getFilters: Function,
        filterTable: Function,
        tableUrl: Function,
    },
    data: function () {
        return {
            resource_count: 0,
            initialized: false,
            searchable_additional_fields: [],
            searchable_av_options: [],
            filters: this.getFilters(this.$route.query),
            router: this.$router,
        };
    },
    created() {
        if (this.embedded) {
            this.getResourceCount().then(() => (this.initialized = true));
        } else {
            this.getResourceCount().then(() =>
                this.getSearchableAdditionalFields().then(() =>
                    this.getSearchableAVOptions().then(
                        () => (this.initialized = true)
                    )
                )
            );
        }
    },
    methods: {
        async getResourceCount() {
            await this.api_client.count().then(
                count => {
                    this.resource_count = count;
                },
                error => {}
            );
        },
        async getSearchableAdditionalFields() {
            const client = APIClient.additional_fields;
            await client.additional_fields.getAll(this.resource_name).then(
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
        redrawTable() {
            if (this.filterTable) {
                this.filterTable();
            } else {
                this.table.redraw(this.tableUrl(this.filters));
            }
        },
    },
    components: { Toolbar, ToolbarButton, KohaTable, FormElement },
    name: "ResourcesList",
};
</script>

<style scoped>
.filters > input[type="checkbox"],
.filters > input[type="button"] {
    margin-left: 1rem;
}
</style>
