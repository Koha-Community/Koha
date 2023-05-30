<template>
    <div id="report-builder">
        <h2>{{ $__("Build a custom report") }}</h2>
        <form @submit="buildCustomReport($event)" class="custom_usage_report">
            <fieldset class="rows custom_report_builder">
                <div class="">
                    <h3>{{ $__("Select report data") }}</h3>
                    <ol>
                        <li>
                            <label for="interval"
                                >{{ $__("Data display") }}:</label
                            >
                            <v-select
                                id="interval"
                                v-model="query.data_display"
                                label="description"
                                :reduce="interval => interval.value"
                                :options="[
                                    {
                                        value: 'monthly',
                                        description: 'By month',
                                    },
                                    {
                                        value: 'monthly_with_totals',
                                        description:
                                            'By month with period total',
                                    },
                                    { value: 'yearly', description: 'By year' },
                                    {
                                        value: 'metric_type',
                                        description: 'By metric type',
                                    },
                                ]"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider"
                                >{{ $__("Choose data provider") }}:</label
                            >
                            <v-select
                                id="usage_data_provider"
                                v-model="query.usage_data_providers"
                                label="name"
                                :reduce="
                                    provider =>
                                        provider.erm_usage_data_provider_id
                                "
                                :options="usage_data_providers"
                                @update:modelValue="setReportTypes($event)"
                                multiple
                            />
                        </li>
                        <li>
                            <label for="report_types"
                                >{{ $__("Choose report") }}:</label
                            >
                            <v-select
                                id="report_type"
                                v-model="query.report_type"
                                label="description"
                                :reduce="report => report.value"
                                :options="report_types_options"
                                @update:modelValue="setMetricTypes($event)"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="metric_types"
                                >{{ $__("Choose metric type") }}:</label
                            >
                            <v-select
                                id="metric_type"
                                v-model="query.metric_types"
                                label="description"
                                :reduce="report => report.value"
                                :options="metric_types_options"
                                multiple
                                :disabled="
                                    this.metric_types_options.length === 0
                                "
                            />
                        </li>
                        <li>
                            <label for="start_year"
                                >{{ $__("Start year") }}:</label
                            >
                            <input
                                id="start_year"
                                class="year_input"
                                v-model="query.start_year"
                                :placeholder="
                                    $__('Please enter year in format YYYY')
                                "
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="start_month"
                                >{{ $__("Start month") }}:</label
                            >
                            <v-select
                                id="start-month"
                                v-model="query.start_month"
                                label="description"
                                :reduce="month => month.value"
                                :options="months_data"
                                :disabled="
                                    query.data_display.includes('yearly')
                                "
                            />
                        </li>
                        <li>
                            <label for="end_year">{{ $__("End year") }}:</label>
                            <input
                                id="end_year"
                                class="year_input"
                                v-model="query.end_year"
                                :placeholder="
                                    $__('Please enter year in format YYYY')
                                "
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="end_month"
                                >{{ $__("End month") }}:</label
                            >
                            <v-select
                                id="end_month"
                                v-model="query.end_month"
                                label="description"
                                :reduce="month => month.value"
                                :options="months_data"
                                :disabled="
                                    query.data_display.includes('yearly')
                                "
                            />
                        </li>
                        <li>
                            <label for="title">{{ $__("Title") }}:</label>
                            <v-select
                                id="title"
                                v-model="query.titles"
                                label="title"
                                :options="titles"
                                multiple
                                @input="titlesSearchFilter($event)"
                                :placeholder="$__('Type to search')"
                            />
                        </li>
                    </ol>
                </div>
                <div class="">
                    <h3>{{ $__("Select report columns") }}</h3>
                    <ol class="checkbox_options">
                        <li
                            v-for="(
                                prop, key, index
                            ) in title_property_column_options"
                            v-bind:key="index"
                            class="checkbox_options"
                        >
                            <!-- TODO: Check translations -->
                            <label :for="prop.property" class="checkbox"
                                >{{ $__(prop.name) }}:</label
                            >
                            <input
                                type="checkbox"
                                :name="prop.property"
                                :id="prop.property"
                                :checked="true"
                                v-model="
                                    title_property_column_options[key].active
                                "
                            />
                        </li>
                    </ol>
                </div>
                <div v-if="query.data_display.includes('monthly')">
                    <h3>{{ $__("Select date display method") }}</h3>
                    <div class="date_display">
                        <label
                            for="yearly_filter_required"
                            class="date_display_title"
                            >{{ $__("Display data filtered by year") }}:</label
                        >
                        <label
                            for="yearly_filter_required_yes"
                            class="date_display_radio"
                        >
                            <input
                                type="radio"
                                name="yearly_or_monthly"
                                id="yearly_filter_required_yes"
                                @change="month_selector($event)"
                                :checked="yearly_filter_required ? true : false"
                            />
                            Yes - Table will be limited to 12 columns (Jan-Dec)
                            with the option to switch between years
                        </label>
                        <label
                            for="yearly_filter_required_no"
                            class="date_display_radio"
                        >
                            <input
                                type="radio"
                                name="yearly_or_monthly"
                                id="yearly_filter_required_no"
                                @change="month_selector($event)"
                                :checked="
                                    !yearly_filter_required ? true : false
                                "
                            />
                            No - Table will include one column for every month
                            of data selected
                        </label>
                    </div>
                </div>
                <div v-if="!yearly_filter_required">
                    <h3>{{ $__("Select which months to display") }}</h3>
                    <ol>
                        <li
                            v-for="(
                                year, key, index
                            ) in time_period_columns_builder"
                            v-bind:key="key + index"
                            class="checkbox_options"
                        >
                            <label :for="key">{{ $__(key) }}: </label>
                            <div
                                v-for="(month, i) in year"
                                v-bind:key="key + i"
                                class="month_selectors"
                            >
                                <label for="month" class="month_labels">
                                    {{ $__(month.short) }}
                                </label>
                                <input
                                    type="checkbox"
                                    :name="month.short"
                                    :id="month.short + key"
                                    :key="month + key + i"
                                    :checked="true"
                                    @change="
                                        update_months_required(
                                            $event,
                                            key,
                                            i,
                                            this.time_period_columns_builder
                                        )
                                    "
                                />
                            </div>
                        </li>
                    </ol>
                </div>
            </fieldset>
            <fieldset class="action">
                <ButtonSubmit />
                <button
                    @click="clearForm($event)"
                    style="padding: 0.5em 1em; margin-left: 0.5em"
                >
                    Clear
                </button>
            </fieldset>
        </form>
    </div>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue"
import { inject } from "vue"
import { storeToRefs } from "pinia"
import { APIClient } from "../../fetch/api-client.js"

export default {
    setup() {
        const AVStore = inject("AVStore")
        const {
            av_report_types,
            av_platform_reports_metrics,
            av_database_reports_metrics,
            av_title_reports_metrics,
            av_item_reports_metrics,
        } = storeToRefs(AVStore)

        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore")

        const {
            setReportURL,
            setTimePeriodColumns,
            setReportType,
            setQuery,
            setColumns,
            setYearlyFilter,
            getMonthsData,
        } = inject("reportsStore")

        const months_data = getMonthsData()

        return {
            av_report_types,
            av_platform_reports_metrics,
            av_database_reports_metrics,
            av_title_reports_metrics,
            av_item_reports_metrics,
            setConfirmationDialog,
            setMessage,
            setError,
            setReportURL,
            setTimePeriodColumns,
            setReportType,
            setColumns,
            setYearlyFilter,
            setQuery,
            months_data,
        }
    },
    data() {
        return {
            title_property_column_options: {
                provider_name: {
                    name: "Provider name",
                    active: true,
                    column: {
                        title: __("Data provider"),
                        data: "provider_name",
                        searchable: true,
                        orderable: true,
                    },
                },
                online_issn: {
                    name: "Online ISSN",
                    active: false,
                    column: {
                        title: __("Online ISSN"),
                        data: "online_issn",
                        searchable: true,
                        orderable: true,
                    },
                },
                print_issn: {
                    name: "Print ISSN",
                    active: false,
                    column: {
                        title: __("Print ISSN"),
                        data: "print_issn",
                        searchable: true,
                        orderable: true,
                    },
                },
                title_doi: {
                    name: "DOI",
                    active: false,
                    column: {
                        title: __("DOI"),
                        data: "title_doi",
                        searchable: true,
                        orderable: true,
                    },
                },
                title_uri: {
                    name: "URI",
                    active: false,
                    column: {
                        title: __("URI"),
                        data: "title_uri",
                        searchable: true,
                        orderable: true,
                    },
                },
            },
            query: {
                data_display: "monthly",
                report_type: null,
                metric_types: null,
                usage_data_providers: null,
                titles: null,
                start_month: null,
                start_year: null,
                end_month: null,
                end_year: null,
            },
            yearly_filter_required: true,
            metric_types_matrix: {
                Searches_Platform: ["PR", "PR_P1"],
                Searches_Automated: ["DR", "DR_D1"],
                Searches_Federated: ["DR", "DR_D1"],
                Searches_Regular: ["DR", "DR_D1"],
                Total_Item_Investigations: [
                    "PR",
                    "DR",
                    "DR_D1",
                    "TR",
                    "TR_B3",
                    "TR_J3",
                    "IR",
                ],
                Total_Item_Requests: [
                    "PR",
                    "PR_P1",
                    "DR",
                    "DR_D1",
                    "TR",
                    "TR_B1",
                    "TR_B3",
                    "TR_J1",
                    "TR_J3",
                    "TR_J4",
                    "IR",
                    "IR_A1",
                    "IR_M1",
                ],
                Unique_Item_Investigations: [
                    "PR",
                    "DR",
                    "TR",
                    "TR_B3",
                    "TR_J3",
                    "IR",
                ],
                Unique_Item_Requests: [
                    "PR",
                    "PR_P1",
                    "DR",
                    "TR",
                    "TR_B3",
                    "TR_J1",
                    "TR_J3",
                    "TR_J4",
                    "IR",
                    "IR_A1",
                ],
                Unique_Title_Investigations: ["PR", "DR", "TR", "TR_B3"],
                Unique_Title_Requests: [
                    "PR",
                    "PR_P1",
                    "DR",
                    "TR",
                    "TR_B1",
                    "TR_B3",
                ],
                Limit_Exceeded: ["DR", "DR_D2", "TR", "TR_B2", "TR_J2", "IR"],
                No_License: ["DR", "DR_D2", "TR", "TR_B2", "TR_J2", "IR"],
            },
            metric_types_options: [],
            report_types_options: [...this.av_report_types],
            titles: [],
            time_period_columns_builder: null,
            request_url: null,
        }
    },
    methods: {
        async getTitles(query) {
            const client = APIClient.erm
            await client.titles.getAll(query).then(
                titles => {
                    // If multiple searches are done we need to keep the results of the
                    // earlier searches but not allow for duplicate titles in the option array
                    const addNewTitles = [...this.titles, ...titles]
                    const removedDuplicates = [
                        ...new Map(
                            addNewTitles.map(title => [title.title_id, title])
                        ).values(),
                    ]
                    this.titles = removedDuplicates
                },
                error => {}
            )
        },
        change_custom_or_default(e) {
            this.initialized = false
            this.custom_or_default = e.target.getAttribute("data-content")
        },
        titlesSearchFilter(e) {
            const queryString = `title=${e.target.value}`
            this.getTitles(queryString)
        },
        validateYear(year) {
            const validYearCheck = /^\d{4}$/.test(year) ? true : false
            return validYearCheck
        },
        clearForm(e) {
            e.preventDefault()

            this.query = {
                data_display: "monthly",
                report_type: null,
                metric_types: null,
                usage_data_providers: null,
                titles: null,
                start_month: null,
                start_year: null,
                end_month: null,
                end_year: null,
            }
            this.yearly_filter_required = true
        },
        buildCustomReport(e) {
            e.preventDefault()

            const queryObject = this.query
            const {
                start_year,
                end_year,
                data_display,
                report_type,
                metric_types,
            } = queryObject

            if (!report_type || !start_year || !end_year) {
                alert(
                    "You have not filled in all the required fields, please try again"
                )
                return
            }

            // validate if the year is a valid string
            const valid_start_year = this.validateYear(start_year)
            const valid_end_year = this.validateYear(end_year)

            if (!valid_start_year || !valid_end_year) {
                this.setError(
                    this.$__("Please enter a year with the format YYYY")
                )
                return
            }

            // If no metric types are selected then all possible values should be included for backend data filtering
            if (!metric_types || (metric_types && metric_types.length === 0)) {
                const final_metric_types = this.metric_types_options.map(
                    metric => {
                        return metric.value
                    }
                )
                queryObject.metric_types = final_metric_types
            }

            const metric_report_type =
                data_display === "metric_type" ? true : false
            const url = !data_display.includes("yearly")
                ? this.build_monthly_url_query(
                      queryObject,
                      this.time_period_columns_builder,
                      metric_report_type
                  )
                : this.build_yearly_url_query(queryObject)
            const type = data_display
            const columns = this.defineColumns(
                this.title_property_column_options
            )
            // Set state to be accessed by reports viewer component
            this.setReportURL(url)
            this.setQuery(queryObject)
            this.setTimePeriodColumns(this.time_period_columns_builder)
            if (data_display.includes("monthly")) {
                this.setYearlyFilter(this.yearly_filter_required)
            } else {
                this.setYearlyFilter(false)
            }
            this.setReportType(type)
            this.setColumns(columns)

            this.$router.push({
                name: "UsageStatisticsReportsViewer",
            })
        },
        month_selector(e) {
            if (!this.query.start_year || !this.query.end_year) {
                alert(
                    "Please select a start and end year before choosing this option"
                )
                return
            }
            if (e.target.id === "yearly_filter_required_no") {
                const years = []
                for (
                    let i = parseInt(this.query.start_year);
                    i <= parseInt(this.query.end_year);
                    i++
                ) {
                    years.push(i)
                }

                const months = this.determine_months(
                    this.query,
                    years,
                    this.months_data
                )

                this.time_period_columns_builder = months
                this.yearly_filter_required = false
            } else {
                this.time_period_columns_builder = null
                this.yearly_filter_required = true
            }
        },
        determine_months(query, years, months_data) {
            const { start_month, end_month } = query
            const months_per_year = {}
            const numberOfYears = years.length

            years.forEach((year, index) => {
                // No month parameters selected - return all months
                if (!start_month && !end_month) {
                    const copied_months = months_data.map(month => {
                        return { ...month }
                    })
                    months_per_year[year] = copied_months
                    return
                }
                // If a report of 3+ years is chosen, "middle" years will return all months
                if (index > 0 && index + 1 < numberOfYears) {
                    const copied_months = months_data.map(month => {
                        return { ...month }
                    })
                    months_per_year[year] = copied_months
                    return
                }
                // If a single year report is chosen, return the correct number of months
                if (index === 0 && numberOfYears === 1) {
                    const months = []
                    const first_month = start_month ? parseInt(start_month) : 1
                    const last_month = end_month ? parseInt(end_month) : 12
                    for (let i = first_month; i <= last_month; i++) {
                        months.push(months_data[i - 1])
                    }
                    months_per_year[year] = months
                    return
                }
                // If a multiple year report is chosen, ensure the first year has the correct months
                if (index === 0 && numberOfYears > 1) {
                    const months = []
                    const first_month = start_month ? parseInt(start_month) : 1
                    for (let i = first_month; i <= 12; i++) {
                        months.push(months_data[i - 1])
                    }
                    months_per_year[year] = months
                    return
                }
                // If a multiple year report is chosen, ensure the final year has the correct months
                if (index + 1 === numberOfYears && numberOfYears > 1) {
                    const months = []
                    const last_month = end_month ? parseInt(end_month) : 12
                    for (let i = 1; i <= last_month; i++) {
                        months.push(months_data[i - 1])
                    }
                    months_per_year[year] = months
                    return
                }
            })
            return months_per_year
        },
        update_months_required($event, key, index, time_period_columns) {
            const value = $event.target.checked

            time_period_columns[key][index].active = value

            this.time_period_columns_builder = time_period_columns
        },
        build_monthly_url_query(
            query,
            time_period_columns,
            metric_type_report
        ) {
            let url = metric_type_report
                ? "/api/v1/erm/usage_titles/metric_types_report"
                : "/api/v1/erm/usage_titles/monthly_report"
            // Work out which years are included in the query
            const years = []
            const {
                start_year,
                end_year,
                metric_types,
                usage_data_providers,
                titles,
                report_type,
            } = query

            for (let i = parseInt(start_year); i <= parseInt(end_year); i++) {
                years.push(i)
            }

            const months = time_period_columns
                ? time_period_columns
                : this.determine_months(query, years, this.months_data)
            this.time_period_columns_builder = months

            // Build a query array by year - [{ year1 }, {year2} ...etc]
            const queryArray = years.map(year => {
                const queryByYear = {}

                queryByYear[`erm_usage_muses.year`] = year
                queryByYear[`erm_usage_muses.report_type`] = report_type

                // Find the months applicable to each year, ignoring months that have been de-selected
                const queryMonths = months[year]
                    .filter(month => month.active)
                    .map(month => {
                        return month.value
                    })
                queryByYear[`erm_usage_muses.month`] = queryMonths
                // Add any title query
                if (titles) {
                    const title_ids = titles.map(title => {
                        return title.title_id
                    })
                    queryByYear[`erm_usage_muses.title_id`] = title_ids
                }
                // Add any metric types query
                if (metric_types) {
                    queryByYear[`erm_usage_muses.metric_type`] = metric_types
                }
                // Add any data provider query
                if (usage_data_providers) {
                    queryByYear[`erm_usage_muses.usage_data_provider_id`] =
                        usage_data_providers
                }

                return queryByYear
            })

            url += `?q=${JSON.stringify(queryArray)}`

            return url
        },
        build_yearly_url_query(query) {
            let url = "/api/v1/erm/usage_titles/yearly_report"
            const {
                start_year,
                end_year,
                metric_types,
                usage_data_providers,
                titles,
                report_type,
            } = query
            const queryObject = {}
            // Work out which years are included in the query
            const years = []

            for (let i = parseInt(start_year); i <= parseInt(end_year); i++) {
                years.push(i)
            }
            queryObject["erm_usage_yuses.year"] = years
            this.time_period_columns_builder = years
            queryObject[`erm_usage_yuses.report_type`] = report_type

            // Add any metric types query
            if (metric_types) {
                queryObject[`erm_usage_yuses.metric_type`] = metric_types
            }
            // Add any title query
            if (titles) {
                const title_ids = titles.map(title => {
                    return title.title_id
                })
                queryObject[`erm_usage_yuses.title_id`] = title_ids
            }
            // Add any data provider query
            if (usage_data_providers) {
                queryObject[`erm_usage_yuses.usage_data_provider_id`] =
                    usage_data_providers
            }
            url += `?q=${JSON.stringify(queryObject)}`

            return url
        },
        setMetricTypes(e) {
            const report_type = e
            const possible_metric_types = []
            let av_type

            if (report_type) {
                switch (report_type.substring(0, 1)) {
                    case "P":
                        av_type = this.av_platform_reports_metrics
                        break
                    case "T":
                        av_type = this.av_title_reports_metrics
                        break
                    case "I":
                        av_type = this.av_item_reports_metrics
                        break
                    case "D":
                        av_type = this.av_database_reports_metrics
                        break
                }

                for (const metric in this.metric_types_matrix) {
                    if (
                        this.metric_types_matrix[metric].includes(
                            report_type,
                            false
                        )
                    ) {
                        const av_metric_type = av_type.find(
                            type => metric === type.value
                        )
                        possible_metric_types.push(av_metric_type)
                    }
                }
                this.metric_types_options = possible_metric_types
            } else {
                this.metric_types_options = []
                this.query.metric_types = null
            }
        },
        setReportTypes(report_types) {
            const permittedReportTypes = []
            if (report_types.length === 0) {
                this.report_types_options = this.av_report_types
                return
            }

            report_types.forEach(id => {
                const data_provider = this.usage_data_providers.find(
                    item => item.erm_usage_data_provider_id === id
                )
                const report_types = data_provider.report_types
                const single_report_types = report_types.split(";")
                single_report_types.pop() // remove trailing "" from array

                single_report_types.forEach(type => {
                    const report_type = this.av_report_types.find(
                        rt => rt.value === type
                    )
                    permittedReportTypes.push(report_type)
                })
            })
            this.report_types_options = permittedReportTypes
        },
        defineColumns(title_props) {
            const columns = [
                {
                    title: __("Title"),
                    data: "title",
                    searchable: true,
                    orderable: true,
                },
            ]
            // Add user selected columns
            const title_properties = Object.keys(title_props)
            title_properties.forEach(prop => {
                if (title_props[prop].active) {
                    columns.push(title_props[prop].column)
                }
            })

            return columns
        },
    },
    props: ["usage_data_providers"],
    components: {
        ButtonSubmit,
    },
}
</script>

<style scoped>
h2 {
    margin-bottom: 0em;
}
.custom_usage_report h3 {
    margin-top: 1em;
}
.custom_report_builder {
    display: flex;
    flex-direction: column;
}
.checkbox_options {
    display: flex;
    justify-content: flex-start;
    gap: 0px;
}
.checkbox {
    display: inline-block;
    float: none;
    margin: 0;
    padding: 0;
    width: auto;
}
.date_display {
    display: flex;
    flex-direction: column;
    justify-content: left;
    text-align: left;
    width: 100%;
    gap: 0.5em;
}
.date_display_title {
    text-align: left;
    width: 100%;
}
.date_display_radio {
    width: 100%;
    text-align: left;
}
input:not([type="submit"]):not([type="search"]):not([type="button"]):not([type="checkbox"]) {
    min-width: 5%;
}
.month_selectors {
    margin-right: 1em;
}
.month_labels {
    width: 2em;
    text-align: right;
    margin: 0em;
}
.year_input {
    width: 30%;
}
</style>
