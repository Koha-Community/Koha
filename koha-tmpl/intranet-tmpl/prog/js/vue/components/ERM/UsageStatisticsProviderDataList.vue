<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="data_list">
        <div v-if="data_count > 0" class="page-section">
            <KohaTable ref="table" v-bind="tableOptions"></KohaTable>
        </div>
        <div v-else-if="initialized" class="alert alert-info">
            {{
                $__("No %s data has been harvested for this provider").format(
                    data_type
                )
            }}
        </div>
    </div>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js";
import { ref } from "vue";
import KohaTable from "../KohaTable.vue";

export default {
    setup() {
        const table = ref();

        return {
            table,
        };
    },
    data() {
        return {
            data_count: 0,
            initialized: false,
            before_route_entered: false,
            building_table: false,
            tableOptions: {
                columns: this.getTableColumns(),
                options: {},
                url: () => this.table_url(),
                table_settings: this.title_table_settings,
                add_filters: true,
            },
        };
    },
    methods: {
        async getData() {
            const client = APIClient.erm;
            await client[`usage_${this.data_type}s`]
                .count({
                    usage_data_provider_id:
                        this.$route.params.usage_data_provider_id,
                })
                .then(
                    count => {
                        this.data_count = count;
                        this.initialized = true;
                    },
                    error => {}
                );
        },
        table_url() {
            let url = "/api/v1/erm/usage_%ss?usage_data_provider_id=%s".format(
                this.data_type,
                this.$route.params.usage_data_provider_id
            );
            return url;
        },
        getTableColumns() {
            const column_options = [
                {
                    used_by: ["title", "platform", "item", "database"],
                    column: {
                        title:
                            this.data_type.charAt(0).toUpperCase() +
                            this.data_type.slice(1),
                        data: this.data_type,
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["item", "database", "platforms"],
                    column: {
                        title: __("Platform"),
                        data: "platform",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title", "item", "database"],
                    column: {
                        title: __("Publisher"),
                        data: "publisher",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title", "database"],
                    column: {
                        title: __("Publisher ID"),
                        data: "publisher_id",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title"],
                    column: {
                        title: __("DOI"),
                        data: "title_doi",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title"],
                    column: {
                        title: __("Print ISSN"),
                        data: "print_issn",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title"],
                    column: {
                        title: __("Online ISSN"),
                        data: "online_issn",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title"],
                    column: {
                        title: __("URI"),
                        data: "title_uri",
                        searchable: true,
                        orderable: true,
                    },
                },
            ];
            const columns = column_options
                .filter(column => column.used_by.includes(this.data_type))
                .map(result => result.column);
            return columns;
        },
    },
    mounted() {
        if (!this.building_table) {
            this.building_table = true;
            this.getData();
        }
    },
    props: ["data_type"],
    components: { KohaTable },
    name: "UsageStatisticsProviderDataList",
};
</script>

<style scoped>
#title_list {
    display: table;
}
</style>
