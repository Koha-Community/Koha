<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div
        v-else-if="usage_data_providers.length"
        id="usage_data_providers_summary"
    >
        <div id="toolbar" class="btn-toolbar">
            <router-link
                :to="{ name: 'UsageStatisticsDataProvidersList' }"
                class="btn btn-default"
            >
                <i class="fa fa-list"></i>
                {{ $__("Data providers list") }}</router-link
            >
        </div>
        <div
            v-if="usage_data_providers.length"
            class="page-section hide-table"
            ref="table_div"
        >
            <KohaTable ref="table" v-bind="tableOptions"></KohaTable>
        </div>
    </div>
</template>

<script>
import Toolbar from "./UsageStatisticsDataProvidersToolbar.vue"
import { inject, ref } from "vue"
import { APIClient } from "../../fetch/api-client.js"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const AVStore = inject("AVStore") // Left in for future permissions fixes
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const { setConfirmationDialog, setMessage } = inject("mainStore")

        const table = ref()

        return {
            get_lib_from_av,
            map_av_dt_filter,
            setConfirmationDialog,
            setMessage,
            table,
        }
    },
    data: function () {
        return {
            usage_data_providers: [],
            initialized: false,
            building_table: false,
            tableOptions: {
                columns: this.getTableColumns(),
                options: { embed: "counter_files" },
                url: () => this.table_url(),
                table_settings: this.usage_data_provider_table_settings,
                // add_filters: true,
                actions: {},
            },
        }
    },
    methods: {
        async getUsageDataProviders() {
            const client = APIClient.erm
            await client.usage_data_providers.getAll().then(
                usage_data_providers => {
                    this.usage_data_providers = usage_data_providers
                    this.initialized = true
                },
                error => {}
            )
        },
        table_url() {
            let url = "/api/v1/erm/usage_data_providers"
            return url
        },
        getEarliestDate(row, identifier) {
            const counter_files = row.counter_files.filter(file =>
                file.type.includes(identifier)
            )
            if (counter_files.length === 0) {
                return "Not run"
            }
            const findData = counter_files.sort(
                (a, b) => new Date(a.date_uploaded) - new Date(b.date_uploaded)
            )
            const date = findData[0].date_uploaded.substr(0, 10)
            return `${date}`
        },
        getLatestDate(row, identifier) {
            const counter_files = row.counter_files.filter(file =>
                file.type.includes(identifier)
            )
            if (counter_files.length === 0) {
                return "Not run"
            }
            const findData = counter_files.sort(
                (a, b) => new Date(b.date_uploaded) - new Date(a.date_uploaded)
            )
            const date = findData[0].date_uploaded.substr(0, 10)
            return `${date}`
        },
        getTableColumns() {
            const getEarliestDate = this.getEarliestDate
            const getLatestDate = this.getLatestDate

            return [
                {
                    title: __("Provider"),
                    data: "me.erm_usage_data_provider_id:me.name",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.name
                    },
                },
                {
                    title: __("Start"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        const date = getEarliestDate(row, "TR")
                        return date
                    },
                },
                {
                    title: __("End"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        const date = getLatestDate(row, "TR")
                        return date
                    },
                },
                {
                    title: __("Start"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        const date = getEarliestDate(row, "PR")
                        return date
                    },
                },
                {
                    title: __("End"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        const date = getLatestDate(row, "PR")
                        return date
                    },
                },
                {
                    title: __("Start"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        const date = getEarliestDate(row, "DR")
                        return date
                    },
                },
                {
                    title: __("End"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        const date = getLatestDate(row, "DR")
                        return date
                    },
                },
                {
                    title: __("Start"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        const date = getEarliestDate(row, "IR")
                        return date
                    },
                },
                {
                    title: __("End"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        const date = getLatestDate(row, "IR")
                        return date
                    },
                },
            ]
        },
        createTableHeader() {
            const table = this.$refs.table.$el.getElementsByTagName("table")[0]

            const row = table.insertRow(0)
            const [cellOne, cellTwo, cellThree, cellFour, cellFive] = [
                ...Array(5).keys(),
            ].map(item => {
                const cell = document.createElement("th")
                row.appendChild(cell)
                return cell
            })
            cellTwo.colSpan = 2
            cellTwo.innerHTML = "Title reports"
            cellThree.colSpan = 2
            cellThree.innerHTML = "Platform reports"
            cellFour.colSpan = 2
            cellFour.innerHTML = "Database reports"
            cellFive.colSpan = 2
            cellFive.innerHTML = "Item reports"

            this.$refs.table_div.classList.remove("hide-table")
        },
    },
    watch: {
        table() {
            // table needs to be rendered before header can be created and
            // table is hidden by .hide-table until table header is created
            this.createTableHeader()
        },
    },
    mounted() {
        if (!this.building_table) {
            this.building_table = true
            this.getUsageDataProviders()
        }
    },
    components: { Toolbar, KohaTable },
    name: "UsageStatisticsDataProvidersSummary",
}
</script>

<style scoped>
#usage_data_provider_summary {
    display: table;
}
.hide-table {
    display: none;
}
</style>
