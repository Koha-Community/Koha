<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="titles_list">
        <div v-if="titles_count > 0" class="page-section">
            <KohaTable ref="table" v-bind="tableOptions"></KohaTable>
        </div>
        <div v-else-if="initialized" class="dialog message">
            {{ $__("No title data has been harvested for this provider") }}
        </div>
    </div>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js"
import { ref } from "vue"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const table = ref()

        return {
            table,
        }
    },
    data: function () {
        return {
            titles_count: 0,
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
        }
    },
    methods: {
        async getTitles() {
            const client = APIClient.erm
            await client.usage_titles
                .count({
                    usage_data_provider_id:
                        this.$route.params.usage_data_provider_id,
                })
                .then(
                    count => {
                        this.titles_count = count
                        this.initialized = true
                    },
                    error => {}
                )
        },
        table_url() {
            let url = `/api/v1/erm/usage_titles?usage_data_provider_id=${this.$route.params.usage_data_provider_id}`
            return url
        },
        getTableColumns() {
            return [
                {
                    title: __("Title"),
                    data: "title",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Publisher"),
                    data: "publisher",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Publisher ID"),
                    data: "publisher_id",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("DOI"),
                    data: "title_doi",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Print ISSN"),
                    data: "print_issn",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Online ISSN"),
                    data: "online_issn",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("URI"),
                    data: "title_uri",
                    searchable: true,
                    orderable: true,
                },
            ]
        },
    },
    mounted() {
        if (!this.building_table) {
            this.building_table = true
            this.getTitles()
        }
    },
    components: { KohaTable },
    name: "UsageStatisticsTitlesList",
}
</script>

<style scoped>
#title_list {
    display: table;
}
</style>
