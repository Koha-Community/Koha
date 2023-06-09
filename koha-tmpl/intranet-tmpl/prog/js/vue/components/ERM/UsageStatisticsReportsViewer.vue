<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-if="initialized" id="usage_list">
        <fieldset v-if="yearly_filter" class="yearly_filter">
            <label for="year_filter">{{ $__("Display by year") }}:</label>
            <v-select
                id="year_select"
                v-model="year"
                :reduce="year => year"
                label="description"
                :options="years"
            />
            <input
                @click="update_table()"
                id="filter_table"
                type="button"
                :value="$__('Update table')"
            />
        </fieldset>
        <div class="page-section hide-table" ref="table_div">
            <KohaTable ref="table" v-bind="tableOptions"></KohaTable>
        </div>
    </div>
</template>

<script>
import { inject, ref } from "vue"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const table = ref()

        const { getMonthsData } = inject("reportsStore")

        return {
            getMonthsData,
            table,
        }
    },
    beforeCreate() {
        const urlParams = JSON.parse(this.$route.query.data)
        this.params = urlParams

        this.report_type = this.params.type
        this.embed =
            this.report_type === "yearly"
                ? ["erm_usage_yuses"]
                : ["erm_usage_muses"]

        this.years = Object.keys(this.params.tp_columns)
        this.year = this.years[this.years.length - 1]
    },
    data() {
        return {
            building_table: false,
            initialized: false,
            tableOptions: {
                columns: this.buildColumnArray(this.report_type, this.params),
                options: { embed: this.embed },
                url: () => this.tableURL(this.year, this.params),
                table_settings: this.report_type.includes("monthly")
                    ? this.monthly_usage_table_settings
                    : this.yearly_usage_table_settings,
                add_filters: true,
            },
            yearly_filter: null,
            params: this.params,
            year: this.year,
            years: this.years,
        }
    },
    methods: {
        buildColumnArray(report_type, params) {
            const columns = params.columns
            const months_data = this.getMonthsData() //
            const time_period_columns = params.tp_columns
            const yearly_filter = params.yearly_filter
            const query = params.queryObject

            const column_set = [
                {
                    title: __("Title"),
                    data: "title",
                    searchable: true,
                    orderable: true,
                },
                ...columns,
            ]
            // Add metric type to each row
            if (report_type !== "metric_type") {
                column_set.push({
                    title: __("Metric"),
                    render: function (data, type, row, meta) {
                        return row.metric_type
                    },
                    searchable: true,
                    orderable: true,
                })
            }

            // Add monthly columns
            if (yearly_filter) {
                months_data.forEach(month => {
                    column_set.push({
                        title: __(month.short),
                        render: function (data, type, row, meta) {
                            const find_correct_month =
                                row.erm_usage_muses.filter(
                                    item => item.month === month.value
                                )
                            const usage_record = find_correct_month.length
                            const usage = usage_record
                                ? find_correct_month[0].usage_count
                                : "-"
                            return usage
                        },
                        searchable: true,
                        orderable: true,
                    })
                })
            } else {
                if (report_type.includes("monthly")) {
                    const years = Object.keys(time_period_columns)

                    years.forEach(year => {
                        const abbreviated_year = year.substring(2)
                        const selected_months = time_period_columns[year]

                        selected_months.forEach(month => {
                            if (month.active) {
                                const column_title = `${month.short}${abbreviated_year}`
                                column_set.push({
                                    title: __(column_title),
                                    render: function (data, type, row, meta) {
                                        const filtered_by_year =
                                            row.erm_usage_muses.filter(
                                                item =>
                                                    item.year === parseInt(year)
                                            )
                                        const find_correct_month =
                                            filtered_by_year.filter(
                                                item =>
                                                    item.month === month.value
                                            )
                                        const data_available =
                                            find_correct_month.length

                                        const usage = data_available
                                            ? find_correct_month[0].usage_count
                                            : "-"
                                        return usage
                                    },
                                    searchable: true,
                                    orderable: true,
                                })
                            }
                        })
                    })
                }
                if (report_type === "yearly") {
                    const years = time_period_columns

                    years.forEach(year => {
                        const title = String(year)
                        column_set.push({
                            title: __(title),
                            render: function (data, type, row, meta) {
                                const find_usage = row.erm_usage_yuses.find(
                                    item => item.year === year
                                )
                                const usage = find_usage
                                    ? find_usage.totalcount
                                    : "-"
                                return usage
                            },
                            searchable: true,
                            orderable: true,
                        })
                    })
                }
                if (report_type === "metric_type") {
                    const metric_types = query.metric_types
                    metric_types.forEach(metric => {
                        column_set.push({
                            title: __(metric),
                            render: function (data, type, row, meta) {
                                const filterByMetric =
                                    row.erm_usage_muses.filter(
                                        item => item.metric_type === metric
                                    )
                                const period_total = filterByMetric.reduce(
                                    (acc, item) => {
                                        return acc + item.usage_count
                                    },
                                    0
                                )
                                return period_total
                            },
                            searchable: true,
                            orderable: true,
                        })
                    })
                }
            }
            // Add totals column if required
            if (report_type === "monthly_with_totals") {
                column_set.push({
                    title: __("Period total"),
                    render: function (data, type, row, meta) {
                        const sum = row.erm_usage_muses.reduce((acc, item) => {
                            return acc + item.usage_count
                        }, 0)
                        return sum
                    },
                    searchable: true,
                    orderable: true,
                })
            }
            return column_set
        },
        async update_table() {
            this.$refs.table.redraw(this.tableURL(this.year, this.params))
        },
        buildFilteredQuery(query, time_period_columns, year) {
            let url = "/api/v1/erm/usage_titles/monthly_report"
            const queryObject = {}
            const { metric_types, usage_data_providers, titles, report_type } =
                query

            // Identify the year
            queryObject[`erm_usage_muses.year`] = year
            queryObject[`erm_usage_muses.report_type`] = report_type
            // Add months to query
            const months = time_period_columns[year].map(month => {
                return month.value
            })
            queryObject[`erm_usage_muses.month`] = months
            // Add any title query
            if (titles) {
                const title_ids = titles.map(title => {
                    return title.title_id
                })
                queryObject[`erm_usage_muses.title_id`] = title_ids
            }
            // Add any metric types query
            if (metric_types) {
                queryObject[`erm_usage_muses.metric_type`] = metric_types
            }
            // Add any data provider query
            if (usage_data_providers) {
                queryObject[`erm_usage_muses.usage_data_provider_id`] =
                    usage_data_providers
            }

            url += `?q=[${JSON.stringify(queryObject)}]`

            return url
        },
        tableURL(year, params) {
            const filter_required = params.yearly_filter
            if (filter_required) {
                const query = params.queryObject
                const time_period_columns = params.tp_columns

                const url = this.buildFilteredQuery(
                    query,
                    time_period_columns,
                    year
                )

                return url
            } else {
                const url = params.url

                return url
            }
        },
        mergeTitleDataIntoOneLine(numberOfMetricTypes) {
            let dt = this.$refs.table.useTableObject()
            dt.on("draw", () => {
                const rows = dt.rows().nodes().to$()

                const data_rows = []
                for (let i = 0; i < rows.length; i = i + numberOfMetricTypes) {
                    data_rows.push([rows.slice(i, i + numberOfMetricTypes)])
                }

                data_rows
                    .map(item => item[0])
                    .forEach(titleRows => {
                        Array.from(titleRows).forEach((row, i) => {
                            const cells = row.cells
                            if (i === 0) {
                                cells[0].rowSpan = numberOfMetricTypes
                                cells[0].style.textAlign = "center"
                                cells[0].style.verticalAlign = "middle"
                                cells[0].style.borderRight = "1px solid #BCBCBC"
                            } else {
                                cells[0].remove()
                            }
                        })
                    })
            })
            this.$refs.table_div.classList.remove("hide-table")
        },
    },
    watch: {
        table() {
            // table needs to be rendered before header can be created and
            // table is hidden by .hide-table until table header is created
            if (this.report_type !== "metric_type") {
                this.mergeTitleDataIntoOneLine(
                    this.params.queryObject.metric_types.length
                )
            } else {
                this.$refs.table_div.classList.remove("hide-table")
            }
        },
    },
    mounted() {
        if (!this.building_table) {
            this.yearly_filter = this.params.yearly_filter
            this.building_table = true
            this.initialized = true
        }
    },
    components: {
        KohaTable,
    },
    name: "UsageStatisticsReportsViewer",
}
</script>

<style scoped>
.title_property_options {
    display: flex;
}
.checkbox {
    display: inline-block;
    float: none;
    margin: 0;
    padding: 0;
    width: auto;
}
.yearly_filter {
    display: flex;
    align-items: center;
    gap: 1em;
}
.v-select {
    max-width: 30%;
}
.hide-table {
    display: none;
}
</style>
