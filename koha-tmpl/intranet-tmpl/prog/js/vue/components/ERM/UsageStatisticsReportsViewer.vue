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
import { inject, ref } from "vue";
import KohaTable from "../KohaTable.vue";

export default {
    setup() {
        const table = ref();

        const { getMonthsData, getColumnOptions, checkReportColumns } =
            inject("reportsStore");

        return {
            getMonthsData,
            getColumnOptions,
            checkReportColumns,
            table,
        };
    },
    beforeCreate() {
        const urlParams = JSON.parse(this.$route.query.data);
        this.params = urlParams;
        this.report_type = this.params.type;
        let data_type;
        switch (this.params.queryObject.report_type.substring(0, 1)) {
            case "P":
                data_type = "platform";
                break;
            case "T":
                data_type = "title";
                break;
            case "I":
                data_type = "item";
                break;
            case "D":
                data_type = "database";
                break;
        }
        this.data_type = data_type;
        this.embed =
            this.report_type === "yearly"
                ? ["erm_usage_yuses"]
                : ["erm_usage_muses"];
        switch (this.report_type) {
            case "monthly":
            case "monthly_with_totals":
                this.embed = "erm_usage_muses";
                break;
            case "yearly":
                this.embed = "erm_usage_yuses";
                break;
            case "metric_type":
                this.embed = "erm_usage_muses";
                break;
            case "usage_data_provider":
                this.embed = `erm_usage_${data_type}s.erm_usage_muses`;
                break;
        }

        this.years = Object.keys(this.params.tp_columns);
        this.year = this.years[this.years.length - 1];
    },
    data() {
        return {
            building_table: false,
            initialized: false,
            tableOptions: {
                columns: this.buildColumnArray(
                    this.report_type,
                    this.params,
                    this.data_type
                ),
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
        };
    },
    methods: {
        buildColumnArray(report_display, params, data_type) {
            const columns = params.columns;
            const months_data = this.getMonthsData();
            const column_options = this.getColumnOptions();
            const time_period_columns = params.tp_columns;
            const yearly_filter = params.yearly_filter;
            const query = params.queryObject;
            const report_type = params.queryObject.report_type;
            const column_set = [];

            columns.forEach(column => {
                column_set.push(column_options[column].column);
                // Reset all columns except data providers to inactive
                if (column !== 1) column_options[column].active = false;
            });

            report_display !== "usage_data_provider" &&
                column_set.unshift({
                    title: __(
                        data_type.charAt(0).toUpperCase() + data_type.slice(1)
                    ),
                    data: data_type,
                    searchable: true,
                    orderable: true,
                });

            // Add metric type to each row
            if (report_display !== "metric_type") {
                // Add yop if it is required
                if (this.checkReportColumns(report_type, "YOP")) {
                    column_set.push({
                        title: __("YOP"),
                        data: "yop",
                        searchable: true,
                        orderable: true,
                    });
                }
                // Add access type if it is required
                if (this.checkReportColumns(report_type, "Access_Type")) {
                    column_set.push({
                        title: __("Access type"),
                        data: "access_type",
                        searchable: true,
                        orderable: true,
                    });
                }
                column_set.push({
                    title: __("Metric"),
                    render: function (data, type, row, meta) {
                        return row.metric_type;
                    },
                    searchable: true,
                    orderable: true,
                });
            }

            if (report_display === "usage_data_provider") {
                column_set.unshift({
                    title: __("Data provider"),
                    data: "name",
                    searchable: true,
                    orderable: true,
                });
                column_set.push({
                    title: __("Period total"),
                    data: "provider_rollup_total",
                    searchable: true,
                    orderable: true,
                });
                return column_set;
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
                                );
                            const usage_record = find_correct_month.length;
                            const usage = usage_record
                                ? find_correct_month[0].usage_count
                                : "-";
                            return usage;
                        },
                        searchable: true,
                        orderable: true,
                    });
                });
            } else {
                if (report_display.includes("monthly")) {
                    const years = Object.keys(time_period_columns);

                    years.forEach(year => {
                        const abbreviated_year = year.substring(2);
                        const selected_months = time_period_columns[year];

                        selected_months.forEach(month => {
                            if (month.active) {
                                const column_title = `${month.short}${abbreviated_year}`;
                                column_set.push({
                                    title: __(column_title),
                                    render: function (data, type, row, meta) {
                                        const filtered_by_year =
                                            row.erm_usage_muses.filter(
                                                item =>
                                                    item.year === parseInt(year)
                                            );
                                        const find_correct_month =
                                            filtered_by_year.filter(
                                                item =>
                                                    item.month === month.value
                                            );
                                        const data_available =
                                            find_correct_month.length;

                                        const usage = data_available
                                            ? find_correct_month[0].usage_count
                                            : "-";
                                        return usage;
                                    },
                                    searchable: true,
                                    orderable: true,
                                });
                            }
                        });
                    });
                }
                if (report_display === "yearly") {
                    const years = time_period_columns;

                    years.forEach(year => {
                        const title = String(year);
                        column_set.push({
                            title: __(title),
                            render: function (data, type, row, meta) {
                                const find_usage = row.erm_usage_yuses.find(
                                    item => item.year === year
                                );
                                const usage = find_usage
                                    ? find_usage.totalcount
                                    : "-";
                                return usage;
                            },
                            searchable: true,
                            orderable: true,
                        });
                    });
                }
                if (report_display === "metric_type") {
                    const metric_types = query.metric_types;
                    const access_types = query.access_types;
                    // Add yop if it is required
                    if (this.checkReportColumns(report_type, "YOP")) {
                        column_set.push({
                            title: __("YOP"),
                            data: "yop",
                            searchable: true,
                            orderable: true,
                        });
                    }
                    metric_types.forEach(metric => {
                        if (access_types && access_types.length > 0) {
                            access_types.forEach(access => {
                                column_set.push({
                                    title: __(access),
                                    render: function (data, type, row, meta) {
                                        const filterByType =
                                            row.erm_usage_muses.filter(
                                                item =>
                                                    item.access_type === access
                                            );
                                        const filterByMetric =
                                            filterByType.filter(
                                                item =>
                                                    item.metric_type === metric
                                            );
                                        const period_total =
                                            filterByMetric.reduce(
                                                (acc, item) => {
                                                    return (
                                                        acc + item.usage_count
                                                    );
                                                },
                                                0
                                            );
                                        return period_total;
                                    },
                                    searchable: false,
                                    orderable: false,
                                });
                            });
                        } else {
                            column_set.push({
                                title: __(metric),
                                render: function (data, type, row, meta) {
                                    const filterByMetric =
                                        row.erm_usage_muses.filter(
                                            item => item.metric_type === metric
                                        );
                                    const period_total = filterByMetric.reduce(
                                        (acc, item) => {
                                            return acc + item.usage_count;
                                        },
                                        0
                                    );
                                    return period_total;
                                },
                                searchable: false,
                                orderable: false,
                            });
                        }
                    });
                }
            }
            // Add totals column if required
            if (report_display === "monthly_with_totals") {
                column_set.push({
                    title: __("Period total"),
                    data: "usage_total",
                    searchable: true,
                    orderable: true,
                });
            }
            return column_set;
        },
        async update_table() {
            this.$refs.table.redraw(this.tableURL(this.year, this.params));
        },
        buildFilteredQuery(query, time_period_columns, year) {
            const queryObject = {};
            const {
                metric_types,
                access_types,
                usage_data_providers,
                keywords,
                report_type,
            } = query;
            let data_type;
            switch (report_type.substring(0, 1)) {
                case "P":
                    data_type = "platform";
                    break;
                case "T":
                    data_type = "title";
                    break;
                case "I":
                    data_type = "item";
                    break;
                case "D":
                    data_type = "database";
                    break;
            }
            let url = `/api/v1/erm/eUsage/monthly_report/${data_type}`;

            // Identify the year
            queryObject[`erm_usage_muses.year`] = year;
            queryObject[`erm_usage_muses.report_type`] = report_type;
            // Add months to query
            const months = time_period_columns[year].map(month => {
                return month.value;
            });
            queryObject[`erm_usage_muses.month`] = months;
            // Add any keyword query
            if (keywords) {
                const object_ids = keywords.map(object => {
                    return object[`${data_type}_id`];
                });
                queryObject[`erm_usage_muses.${data_type}_id`] = object_ids;
            }
            // Add any metric types query
            if (metric_types) {
                queryObject[`erm_usage_muses.metric_type`] = metric_types;
            }
            // Add any metric types query
            if (access_types) {
                queryObject[`erm_usage_muses.access_type`] = access_types;
            }
            // Add any data provider query
            if (usage_data_providers) {
                queryObject[`erm_usage_muses.usage_data_provider_id`] =
                    usage_data_providers;
            }

            url += `?q=[${JSON.stringify(queryObject)}]`;

            return url;
        },
        tableURL(year, params) {
            const filter_required = params.yearly_filter;
            if (filter_required) {
                const query = params.queryObject;
                const time_period_columns = params.tp_columns;

                const url = this.buildFilteredQuery(
                    query,
                    time_period_columns,
                    year
                );

                return url;
            } else {
                const url = params.url;

                return url;
            }
        },
        mergeTitleDataIntoOneLine(numberOfMetricTypes, numberOfAccessTypes) {
            let dt = this.$refs.table.useTableObject();
            dt.on("draw", () => {
                const rows = dt.rows().nodes().to$();
                const numberOfRows = numberOfAccessTypes
                    ? numberOfMetricTypes * numberOfAccessTypes
                    : numberOfMetricTypes;
                const data_rows = [];
                for (let i = 0; i < rows.length; i = i + numberOfRows) {
                    data_rows.push([rows.slice(i, i + numberOfRows)]);
                }

                data_rows
                    .map(item => item[0])
                    .forEach(titleRows => {
                        Array.from(titleRows).forEach((row, i) => {
                            const cells = row.cells;
                            if (i === 0) {
                                cells[0].rowSpan = numberOfRows;
                                cells[0].style.textAlign = "center";
                                cells[0].style.verticalAlign = "middle";
                                cells[0].style.borderRight =
                                    "1px solid #BCBCBC";
                            } else {
                                cells[0].remove();
                            }
                        });
                    });
            });
            this.$refs.table_div.classList.remove("hide-table");
        },
        createMetricReportTableHeader(metric_types, access_types) {
            const table = this.$refs.table.$el.getElementsByTagName("table")[0];
            const numberOfColumns = table.rows[0].cells.length;
            const dataColumns = metric_types.length * access_types;
            const numberOfNonStatisticColumns = numberOfColumns - dataColumns;
            const numberOfCellsToCreate =
                numberOfNonStatisticColumns + metric_types.length;

            const row = table.insertRow(0);
            const cellsToInsert = Array.from("1".repeat(numberOfCellsToCreate));
            const cells = cellsToInsert.map(item => {
                const cell = document.createElement("th");
                row.appendChild(cell);
                return cell;
            });

            const metricTypeColumns = cells.splice(numberOfNonStatisticColumns);
            metric_types.forEach((metric, i) => {
                const cell = metricTypeColumns[i];
                cell.colSpan = access_types;
                cell.innerHTML = metric;
            });
            this.$refs.table_div.classList.remove("hide-table");
        },
    },
    watch: {
        table() {
            const number_of_access_types = this.params.queryObject.access_types
                ? this.params.queryObject.access_types.length
                : 0;
            if (this.report_type === "metric_type") {
                if (number_of_access_types) {
                    this.createMetricReportTableHeader(
                        this.params.queryObject.metric_types,
                        number_of_access_types
                    );
                } else {
                    this.$refs.table_div.classList.remove("hide-table");
                }
            } else {
                this.mergeTitleDataIntoOneLine(
                    this.params.queryObject.metric_types.length,
                    number_of_access_types
                );
            }
        },
    },
    mounted() {
        if (!this.building_table) {
            this.yearly_filter = this.params.yearly_filter;
            this.building_table = true;
            this.initialized = true;
        }
    },
    components: {
        KohaTable,
    },
    name: "UsageStatisticsReportsViewer",
};
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
