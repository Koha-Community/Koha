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
                                        description: $__('By month'),
                                    },
                                    {
                                        value: 'monthly_with_totals',
                                        description: $__(
                                            'By month with period total'
                                        ),
                                    },
                                    {
                                        value: 'yearly',
                                        description: $__('By year'),
                                    },
                                    {
                                        value: 'metric_type',
                                        description: $__('By metric type'),
                                    },
                                    {
                                        value: 'usage_data_provider',
                                        description: $__(
                                            'By data provider totals'
                                        ),
                                    },
                                ]"
                                :required="!query.data_display"
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="!query.data_display"
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                            <span class="required">{{ $__("Required") }}</span>
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
                                :options="usage_data_provider_list"
                                @update:modelValue="
                                    setReportTypesAndResetFilterData($event)
                                "
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
                                @update:modelValue="
                                    setMetricTypesAndProviderList($event)
                                "
                                :required="!query.report_type"
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="!query.report_type"
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="metric_types"
                                >{{ $__("Choose metric type") }}:</label
                            >
                            <v-select
                                id="metric_types"
                                v-model="query.metric_types"
                                label="description"
                                :reduce="metric => metric.value"
                                :options="metric_types_options"
                                multiple
                                :disabled="
                                    this.metric_types_options.length === 0
                                "
                            />
                        </li>
                        <li>
                            <label for="access_types"
                                >{{ $__("Choose access type") }}:</label
                            >
                            <v-select
                                id="access_types"
                                v-model="query.access_types"
                                label="description"
                                :options="access_types_options"
                                multiple
                                :disabled="
                                    this.access_types_options.length === 0
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
                                    (query.data_display &&
                                        query.data_display.includes(
                                            'yearly'
                                        )) ||
                                    !query.data_display
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
                                    (query.data_display &&
                                        query.data_display.includes(
                                            'yearly'
                                        )) ||
                                    !query.data_display
                                "
                            />
                        </li>
                        <li>
                            <label for="keyword">{{ $__("Keyword") }}:</label>
                            <v-select
                                id="keyword"
                                v-model="query.keywords"
                                :label="data_type"
                                :options="filter_data"
                                multiple
                                @input="dataSearchFilter($event)"
                                :placeholder="
                                    $__(
                                        'Type at least two characters to search'
                                    )
                                "
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
                            <label :for="prop.name" class="checkbox"
                                >{{ prop.name }}:</label
                            >
                            <input
                                type="checkbox"
                                :name="prop.name"
                                :id="prop.name"
                                :checked="true"
                                v-model="
                                    title_property_column_options[key].active
                                "
                                :disabled="
                                    !prop.used_by.includes(this.data_type)
                                "
                            />
                        </li>
                    </ol>
                </div>
                <div
                    v-if="
                        query.data_display &&
                        query.data_display.includes('monthly')
                    "
                >
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
                                @change="monthSelector($event)"
                                :checked="yearly_filter_required ? true : false"
                            />
                            {{
                                $__(
                                    "Yes - Table will be limited to 12 columns (Jan-Dec) with the option to switch between years"
                                )
                            }}
                        </label>
                        <label
                            for="yearly_filter_required_no"
                            class="date_display_radio"
                        >
                            <input
                                type="radio"
                                name="yearly_or_monthly"
                                id="yearly_filter_required_no"
                                @change="monthSelector($event)"
                                :checked="
                                    !yearly_filter_required ? true : false
                                "
                            />
                            {{
                                $__(
                                    "No - Table will include one column for every month of data selected"
                                )
                            }}
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
                                    {{ month.short }}
                                </label>
                                <input
                                    type="checkbox"
                                    :name="month.short"
                                    :id="month.short + key"
                                    :key="month + key + i"
                                    :checked="true"
                                    @change="
                                        updateMonthsRequired(
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
                <button @click="clearForm($event)" class="btn btn-default">
                    {{ $__("Clear") }}
                </button>
            </fieldset>
            <div class="save_report">
                <input
                    id="report_name"
                    v-model="report_name"
                    :placeholder="$__('Enter report name')"
                    class="year_input"
                />
                <button
                    @click="saveToDefaultReports($event)"
                    class="btn btn-default"
                >
                    {{ $__("Save report") }}
                </button>
            </div>
        </form>
    </div>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue";
import { inject } from "vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    setup() {
        const ERMStore = inject("ERMStore");
        const { authorisedValues } = storeToRefs(ERMStore);

        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore");

        const { getMonthsData, getColumnOptions } = inject("reportsStore");

        const months_data = getMonthsData();
        const title_property_column_options = getColumnOptions();

        return {
            authorisedValues,
            setConfirmationDialog,
            setMessage,
            setError,
            months_data,
            title_property_column_options,
        };
    },
    data() {
        return {
            query: {
                data_display: "monthly",
                report_type: null,
                metric_types: null,
                access_types: null,
                usage_data_providers: null,
                keywords: null,
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
            access_types_options: [],
            report_types_options: [...this.authorisedValues.av_report_types],
            filter_data: [],
            usage_data_provider_list: [...this.usage_data_providers],
            time_period_columns_builder: null,
            request_url: null,
            report_name: "",
            data_type: null,
        };
    },
    methods: {
        async getData(query, report_type) {
            const client = APIClient.erm;
            await client[`usage_${report_type}s`].getAll(query).then(
                response => {
                    // If multiple searches are done we need to keep the results of the
                    // earlier searches but not allow for duplicate objects in the option array
                    const addNewData = [...this.filter_data, ...response];
                    const removedDuplicates = [
                        ...new Map(
                            addNewData.map(object => [
                                object[`${report_type}_id`],
                                object,
                            ])
                        ).values(),
                    ];
                    this.filter_data = removedDuplicates;
                },
                error => {}
            );
        },
        dataSearchFilter(e) {
            const report_type = this.query.report_type;
            const data_type = this.data_type;
            if (!report_type) {
                alert("Please select a report type");
            }
            if (e.target.value.length > 1) {
                const providers = this.query.usage_data_providers
                    ? this.query.usage_data_providers
                    : [];
                const dataQueryObject = {};
                dataQueryObject[data_type] = { "-like": `${e.target.value}%` };
                if (providers.length) {
                    dataQueryObject.usage_data_provider_id = providers;
                }
                this.getData(dataQueryObject, this.data_type);
            }
        },
        validateYear(year) {
            const validYearCheck = /^\d{4}$/.test(year) ? true : false;
            return validYearCheck;
        },
        clearForm(e) {
            e.preventDefault();

            this.query = {
                data_display: "monthly",
                report_type: null,
                metric_types: null,
                access_types: null,
                usage_data_providers: null,
                keywords: null,
                start_month: null,
                start_year: null,
                end_month: null,
                end_year: null,
            };
            this.yearly_filter_required = true;
        },
        buildCustomReport(e) {
            e.preventDefault();

            const urlParams = this.validateFormAndCreateUrlParams();

            this.$router.push({
                name: "UsageStatisticsReportsViewer",
                query: { data: JSON.stringify(urlParams) },
            });
        },
        monthSelector(e) {
            if (!this.query.start_year || !this.query.end_year) {
                alert(
                    "Please select a start and end year before choosing this option"
                );
                return;
            }
            if (e.target.id === "yearly_filter_required_no") {
                const years = [];
                for (
                    let i = parseInt(this.query.start_year);
                    i <= parseInt(this.query.end_year);
                    i++
                ) {
                    years.push(i);
                }

                const months = this.determineMonths(
                    this.query,
                    years,
                    this.months_data
                );

                this.time_period_columns_builder = months;
                this.yearly_filter_required = false;
            } else {
                this.time_period_columns_builder = null;
                this.yearly_filter_required = true;
            }
        },
        determineMonths(query, years, months_data) {
            const { start_month, end_month } = query;
            const months_per_year = {};
            const numberOfYears = years.length;

            years.forEach((year, index) => {
                // No month parameters selected - return all months
                if (!start_month && !end_month) {
                    const copied_months = months_data.map(month => {
                        return { ...month };
                    });
                    months_per_year[year] = copied_months;
                    return;
                }
                // If a report of 3+ years is chosen, "middle" years will return all months
                if (index > 0 && index + 1 < numberOfYears) {
                    const copied_months = months_data.map(month => {
                        return { ...month };
                    });
                    months_per_year[year] = copied_months;
                    return;
                }
                // If a single year report is chosen, return the correct number of months
                if (index === 0 && numberOfYears === 1) {
                    const months = [];
                    const first_month = start_month ? parseInt(start_month) : 1;
                    const last_month = end_month ? parseInt(end_month) : 12;
                    for (let i = first_month; i <= last_month; i++) {
                        months.push(months_data[i - 1]);
                    }
                    months_per_year[year] = months;
                    return;
                }
                // If a multiple year report is chosen, ensure the first year has the correct months
                if (index === 0 && numberOfYears > 1) {
                    const months = [];
                    const first_month = start_month ? parseInt(start_month) : 1;
                    for (let i = first_month; i <= 12; i++) {
                        months.push(months_data[i - 1]);
                    }
                    months_per_year[year] = months;
                    return;
                }
                // If a multiple year report is chosen, ensure the final year has the correct months
                if (index + 1 === numberOfYears && numberOfYears > 1) {
                    const months = [];
                    const last_month = end_month ? parseInt(end_month) : 12;
                    for (let i = 1; i <= last_month; i++) {
                        months.push(months_data[i - 1]);
                    }
                    months_per_year[year] = months;
                    return;
                }
            });
            return months_per_year;
        },
        updateMonthsRequired($event, key, index, time_period_columns) {
            const value = $event.target.checked;

            time_period_columns[key][index].active = value;

            this.time_period_columns_builder = time_period_columns;
        },
        buildMonthlyUrlQuery(
            query,
            time_period_columns,
            data_display,
            db_table
        ) {
            let url;
            let prefix;
            switch (data_display) {
                case "monthly":
                case "monthly_with_totals":
                    url = `/api/v1/erm/eUsage/monthly_report/${db_table}`;
                    prefix = "erm_usage_muses";
                    break;
                case "metric_type":
                    url = `/api/v1/erm/eUsage/metric_types_report/${db_table}`;
                    prefix = "erm_usage_muses";
                    break;
                case "usage_data_provider":
                    url = `/api/v1/erm/eUsage/provider_rollup_report/${db_table}`;
                    prefix = `erm_usage_${db_table}s.erm_usage_muses`;
                    break;
            }

            // Work out which years are included in the query
            const years = [];
            const {
                start_year,
                end_year,
                metric_types,
                access_types,
                usage_data_providers,
                keywords,
                report_type,
            } = query;

            for (let i = parseInt(start_year); i <= parseInt(end_year); i++) {
                years.push(i);
            }

            const months = time_period_columns
                ? time_period_columns
                : this.determineMonths(query, years, this.months_data);
            this.time_period_columns_builder = months;

            // Build a query array by year - [{ year1 }, {year2} ...etc]
            const queryArray = years.map(year => {
                const queryByYear = {};

                queryByYear[`${prefix}.year`] = year;
                queryByYear[`${prefix}.report_type`] = report_type;

                // Find the months applicable to each year, ignoring months that have been de-selected
                const queryMonths = months[year]
                    .filter(month => month.active)
                    .map(month => {
                        return month.value;
                    });
                queryByYear[`${prefix}.month`] = queryMonths;
                // Add any keyword query
                if (keywords) {
                    const object_ids = keywords.map(object => {
                        return object[`${db_table}_id`];
                    });
                    queryByYear[`${prefix}.${db_table}_id`] = object_ids;
                }
                // Add any metric types query
                if (metric_types) {
                    queryByYear[`${prefix}.metric_type`] = metric_types;
                }
                // Add any access types query
                if (access_types) {
                    queryByYear[`${prefix}.access_type`] = access_types;
                }
                // Add any data provider query
                if (usage_data_providers) {
                    queryByYear[`${prefix}.usage_data_provider_id`] =
                        usage_data_providers;
                }

                return queryByYear;
            });

            url += `?q=${JSON.stringify(queryArray)}`;

            return url;
        },
        buildYearlyUrlQuery(query, db_table) {
            let url = `/api/v1/erm/eUsage/yearly_report/${db_table}`;
            const {
                start_year,
                end_year,
                metric_types,
                access_types,
                usage_data_providers,
                keywords,
                report_type,
            } = query;
            const queryObject = {};
            // Work out which years are included in the query
            const years = [];

            for (let i = parseInt(start_year); i <= parseInt(end_year); i++) {
                years.push(i);
            }
            queryObject["erm_usage_yuses.year"] = years;
            this.time_period_columns_builder = years;
            queryObject[`erm_usage_yuses.report_type`] = report_type;

            // Add any metric types query
            if (metric_types) {
                queryObject[`erm_usage_yuses.metric_type`] = metric_types;
            }
            // Add any access types query
            if (access_types) {
                queryObject[`erm_usage_yuses.access_type`] = access_types;
            }
            // Add any keyword query
            if (keywords) {
                const object_ids = keywords.map(object => {
                    return object[`${db_table}_id`];
                });
                queryObject[`erm_usage_yuses.${db_table}_id`] = object_ids;
            }
            // Add any data provider query
            if (usage_data_providers) {
                queryObject[`erm_usage_yuses.usage_data_provider_id`] =
                    usage_data_providers;
            }
            url += `?q=${JSON.stringify(queryObject)}`;

            return url;
        },
        setMetricTypesAndProviderList(e) {
            const report_type = e;
            const possible_metric_types = [];
            let av_type;

            this.filter_data.length = 0;
            this.query.keywords = null;

            if (report_type) {
                switch (report_type.substring(0, 1)) {
                    case "P":
                        av_type =
                            this.authorisedValues.av_platform_reports_metrics;
                        this.data_type = "platform";
                        break;
                    case "T":
                        av_type =
                            this.authorisedValues.av_title_reports_metrics;
                        this.data_type = "title";
                        break;
                    case "I":
                        av_type = this.authorisedValues.av_item_reports_metrics;
                        this.data_type = "item";
                        break;
                    case "D":
                        av_type =
                            this.authorisedValues.av_database_reports_metrics;
                        this.data_type = "database";
                        break;
                }

                if (report_type === "TR_J3" || report_type === "TR_B3") {
                    this.access_types_options = ["Controlled", "OA_Gold"];
                } else {
                    this.access_types_options = [];
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
                        );
                        possible_metric_types.push(av_metric_type);
                    }
                }
                this.metric_types_options = possible_metric_types;

                // Limit usage data providers to those with the applicable report type
                this.usage_data_provider_list =
                    this.usage_data_providers.filter(provider => {
                        const report_types = provider.report_types;
                        const single_report_types = report_types.split(";");
                        single_report_types.pop();

                        return single_report_types.includes(report_type);
                    });
                // Unselect any additional columns that aren't applicable to this data_type
                const title_properties = Object.keys(
                    this.title_property_column_options
                );
                title_properties.shift(); // Remove the first column as this is a default
                title_properties.forEach(prop => {
                    if (
                        !this.title_property_column_options[
                            prop
                        ].used_by.includes(this.data_type)
                    ) {
                        this.title_property_column_options[prop].active = false;
                    }
                });
            } else {
                this.metric_types_options = [];
                this.query.metric_types = null;
                // Reset data providers to include all providers
                this.usage_data_provider_list = [...this.usage_data_providers];
            }
        },
        setReportTypesAndResetFilterData(providers) {
            const permittedReportTypes = [];
            if (providers.length === 0) {
                this.report_types_options =
                    this.authorisedValues.av_report_types;
                this.query.keywords = null;
                this.filter_data.length = 0;
                return;
            }

            providers.forEach(id => {
                const data_provider = this.usage_data_providers.find(
                    item => item.erm_usage_data_provider_id === id
                );
                const report_types = data_provider.report_types;
                const single_report_types = report_types.split(";");
                single_report_types.pop(); // remove trailing "" from array

                single_report_types.forEach(type => {
                    const report_type =
                        this.authorisedValues.av_report_types.find(
                            rt => rt.value === type
                        );
                    permittedReportTypes.push(report_type);
                });
                // If we change/remove a data provider then we don't want data being displayed from that provider in the dropdown
                const removeProviderData = this.filter_data.filter(
                    obj => obj.erm_usage_data_provider_id !== id
                );
                this.filter_data = removeProviderData;
            });
            this.report_types_options = permittedReportTypes;
        },
        defineColumns(title_props) {
            const columns = [];
            // Add user selected columns
            const title_properties = Object.keys(title_props);
            title_properties.forEach(prop => {
                if (title_props[prop].active) {
                    columns.push(title_props[prop].id);
                }
            });

            return columns;
        },
        async saveToDefaultReports(e) {
            e.preventDefault();

            if (!this.report_name) {
                alert("Please provide a report name");
                return;
            }
            const params = this.validateFormAndCreateUrlParams();
            const report = {
                report_name: this.report_name,
                report_url_params: JSON.stringify(params),
            };

            const client = APIClient.erm;
            await client.default_usage_reports.create(report).then(
                success => {
                    this.setMessage(this.$__("Report saved successfully"));
                },
                error => {}
            );
        },
        validateFormAndCreateUrlParams() {
            const queryObject = { ...this.query };
            const {
                start_year,
                end_year,
                data_display,
                report_type,
                metric_types,
                access_types,
            } = queryObject;

            if (!report_type || !start_year || !end_year) {
                alert(
                    "You have not filled in all the required fields, please try again"
                );
                return;
            }

            // validate if the year is a valid string
            const valid_start_year = this.validateYear(start_year);
            const valid_end_year = this.validateYear(end_year);

            if (!valid_start_year || !valid_end_year) {
                this.setError(
                    this.$__("Please enter a year with the format YYYY")
                );
                return;
            }

            // If no metric types are selected then all possible values should be included for backend data filtering
            if (!metric_types || (metric_types && metric_types.length === 0)) {
                const final_metric_types = this.metric_types_options.map(
                    metric => {
                        return metric.value;
                    }
                );
                queryObject.metric_types = final_metric_types;
            }
            // If no access types are selected then all possible values should be included for backend data filtering ( but only for TR_J3 and TR_B3 reports)
            if (
                (report_type === "TR_J3" || report_type === "TR_B3") &&
                (!access_types || (access_types && access_types.length === 0))
            ) {
                const final_access_types = this.access_types_options.map(
                    access => {
                        return access;
                    }
                );
                queryObject.access_types = final_access_types;
            }

            // Determine which database table should be queried
            const url = !data_display.includes("yearly")
                ? this.buildMonthlyUrlQuery(
                      queryObject,
                      this.time_period_columns_builder,
                      data_display,
                      this.data_type
                  )
                : this.buildYearlyUrlQuery(queryObject, this.data_type);
            const type = data_display;
            const columns =
                data_display === "usage_data_provider"
                    ? []
                    : this.defineColumns(this.title_property_column_options);
            const yearly_filter = data_display.includes("monthly")
                ? this.yearly_filter_required
                : false;

            const urlParams = {
                url,
                columns,
                queryObject,
                yearly_filter,
                type,
                tp_columns: this.time_period_columns_builder,
            };

            return urlParams;
        },
    },
    props: ["usage_data_providers"],
    components: {
        ButtonSubmit,
    },
};
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
input:not([type="submit"]):not([type="search"]):not([type="button"]):not(
        [type="checkbox"]
    ) {
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
    min-height: 2em;
}
.button_format {
    padding: 0.5em 1em;
    margin-left: 0.5em;
}
.save_report {
    display: flex;
    gap: 0.5em;
    margin-top: 1em;
}
</style>
