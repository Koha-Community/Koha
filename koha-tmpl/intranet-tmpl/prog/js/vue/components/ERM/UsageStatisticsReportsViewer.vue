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
        <div class="page-section">
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

        const {
            getReportURL,
            getTimePeriodColumns,
            getReportType,
            getTableSettings,
            getColumns,
            getYearlyFilter,
            getMonthsData,
            getQuery,
            setColumns,
        } = inject("reportsStore")

        const report_type = getReportType()
        const embed =
            report_type === "yearly" ? ["erm_usage_yuses"] : ["erm_usage_muses"]

        const years = Object.keys(getTimePeriodColumns())
        const year = ref(years[years.length - 1])

        return {
            getReportURL,
            getTimePeriodColumns,
            getTableSettings,
            getColumns,
            getYearlyFilter,
            getMonthsData,
            getQuery,
            setColumns,
            table,
            report_type,
            embed,
            years,
            year,
        }
    },
    data() {
        return {
            building_table: false,
            initialized: false,
            tableOptions: {
                columns: this.buildColumnArray(this.report_type),
                options: { embed: this.embed },
                url: () => this.tableURL(this.year),
                table_settings: this.report_type.includes("monthly")
                    ? this.monthly_usage_table_settings
                    : this.yearly_usage_table_settings,
                add_filters: true,
            },
            yearly_filter: null,
        }
    },
    methods: {
        buildColumnArray(report_type) {
            const columns = this.getColumns()
            const months_data = this.getMonthsData()
            const time_period_columns = this.getTimePeriodColumns()
            const yearly_filter = this.getYearlyFilter()
            const query = this.getQuery()

            const column_set = [...columns]
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
            this.$refs.table.redraw(this.tableURL(this.year))
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
        tableURL(year) {
            const filter_required = this.getYearlyFilter()
            if (filter_required) {
                const query = this.getQuery()
                const time_period_columns = this.getTimePeriodColumns()

                const url = this.buildFilteredQuery(
                    query,
                    time_period_columns,
                    year
                )

                return url
            } else {
                const url = this.getReportURL()

                return url
            }
        },
    },
    mounted() {
        if (!this.building_table) {
            this.yearly_filter = this.getYearlyFilter()
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
</style>
