<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="report_builder">
        <h2>Usage Statistics Reports</h2>
        <div id="usage_data_providerstabs" class="toptabs numbered">
            <ul class="nav nav-tabs" role="tablist">
                <li
                    role="presentation"
                    v-bind:class="
                        custom_or_default === 'default' ? 'active' : ''
                    "
                >
                    <a
                        href="#"
                        role="tab"
                        data-content="default"
                        @click="change_custom_or_default"
                        >Default</a
                    >
                </li>
                <li
                    role="presentation"
                    v-bind:class="
                        custom_or_default === 'custom' ? 'active' : ''
                    "
                >
                    <a
                        href="#"
                        role="tab"
                        data-content="custom"
                        @click="change_custom_or_default"
                        >Custom</a
                    >
                </li>
            </ul>
        </div>
        <div class="tab-content">
            <div v-if="custom_or_default === 'default'">
                <form
                    class="default-report"
                    @submit="displayDefaultReport($event)"
                >
                    <h2>{{ $__("Select default report") }}</h2>
                    <fieldset class="rows">
                        <ol>
                            <li>
                                <label for="default_reports"
                                    >{{ $__("Choose report") }}:</label
                                >
                                <v-select
                                    id="default_report"
                                    v-model="query.default_report"
                                    label="description"
                                    :reduce="report => report"
                                    :options="default_reports"
                                />
                            </li>
                        </ol>
                    </fieldset>
                    <fieldset class="action">
                        <ButtonSubmit />
                    </fieldset>
                </form>
            </div>
            <div v-if="custom_or_default === 'custom'">
                <UsageStatisticsReportBuilder
                    :usage_data_providers="usage_data_providers"
                />
            </div>
        </div>
    </div>
</template>

<script>
import { inject } from "vue"
import { storeToRefs } from "pinia"
import ButtonSubmit from "../ButtonSubmit.vue"
import { APIClient } from "../../fetch/api-client.js"
import UsageStatisticsReportBuilder from "./UsageStatisticsReportBuilder.vue"

export default {
    setup() {
        // const AVStore = inject("AVStore")
        // const {
        //     av_report_types,
        //     av_platform_reports_metrics,
        //     av_database_reports_metrics,
        //     av_title_reports_metrics,
        //     av_item_reports_metrics,
        // } = storeToRefs(AVStore)

        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore")

        return {
            // av_report_types,
            // av_platform_reports_metrics,
            // av_database_reports_metrics,
            // av_title_reports_metrics,
            // av_item_reports_metrics,
            setConfirmationDialog,
            setMessage,
            setError,
        }
    },
    data() {
        return {
            initialized: false,
            custom_or_default: "default",
            query: {
                interval: "monthly",
                report_type: null,
                metric_types: null,
                usage_data_providers: null,
                titles: null,
                start_month: null,
                start_year: null,
                end_month: null,
                end_year: null,
            },
            default_reports: [
                "Top resource requests",
                "Publisher rollup",
                "Provider rollup",
                "Yearly usage requests",
                "Titles",
                // etc etc
            ],
            // metric_types_matrix: {
            //     Searches_Platform: ["PR", "PR_P1"],
            //     Searches_Automated: ["DR", "DR_D1"],
            //     Searches_Federated: ["DR", "DR_D1"],
            //     Searches_Regular: ["DR", "DR_D1"],
            //     Total_Item_Investigations: [
            //         "PR",
            //         "DR",
            //         "DR_D1",
            //         "TR",
            //         "TR_B3",
            //         "TR_J3",
            //         "IR",
            //     ],
            //     Total_Item_Requests: [
            //         "PR",
            //         "PR_P1",
            //         "DR",
            //         "DR_D1",
            //         "TR",
            //         "TR_B1",
            //         "TR_B3",
            //         "TR_J1",
            //         "TR_J3",
            //         "TR_J4",
            //         "IR",
            //         "IR_A1",
            //         "IR_M1",
            //     ],
            //     Unique_Item_Investigations: [
            //         "PR",
            //         "DR",
            //         "TR",
            //         "TR_B3",
            //         "TR_J3",
            //         "IR",
            //     ],
            //     Unique_Item_Requests: [
            //         "PR",
            //         "PR_P1",
            //         "DR",
            //         "TR",
            //         "TR_B1",
            //         "TR_B3",
            //         "TR_J1",
            //         "TR_J3",
            //         "TR_J4",
            //         "IR",
            //         "IR_A1",
            //     ],
            //     Unique_Title_Investigations: ["PR", "DR", "TR", "TR_B3"],
            //     Unique_Title_Requests: ["PR", "PR_P1", "DR", "TR", "TR_B3"],
            //     Limit_Exceeded: ["DR", "DR_D2", "TR", "TR_B2", "TR_J2", "IR"],
            //     No_License: ["DR", "DR_D2", "TR", "TR_B2", "TR_J2", "IR"],
            // },
            // metric_types_options: null,
            // months: [
            //     { short: "Jan", description: "January", value: 1 },
            //     { short: "Feb", description: "February", value: 2 },
            //     { short: "Mar", description: "March", value: 3 },
            //     { short: "Apr", description: "April", value: 4 },
            //     { short: "May", description: "May", value: 5 },
            //     { short: "Jun", description: "June", value: 6 },
            //     { short: "Jul", description: "July", value: 7 },
            //     { short: "Aug", description: "August", value: 8 },
            //     { short: "Sep", description: "September", value: 9 },
            //     { short: "Oct", description: "October", value: 10 },
            //     { short: "Nov", description: "November", value: 11 },
            //     { short: "Dec", description: "December", value: 12 },
            // ],
            // years: ["2022", "2023"],
            // titles: [],
            // usage_data_providers: [],
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getUsageDataProviders()
        })
    },
    beforeRouteUpdate(to, from) {
        this.usage_data_provider = this.getUsageDataProviders()
    },
    methods: {
        async getUsageDataProviders() {
            const client = APIClient.erm
            await client.usage_data_providers.getAll().then(
                usage_data_providers => {
                    if (usage_data_providers.length === 0) {
                        this.setError(
                            this.$__(
                                "No data providers have been created -  no report data will be available"
                            )
                        )
                    }
                    this.usage_data_providers = usage_data_providers
                    this.initialized = true
                },
                error => {}
            )
        },
        change_custom_or_default(e) {
            this.initialized = false
            this.custom_or_default = e.target.getAttribute("data-content")
        },
        displayDefaultReport(e) {
            e.preventDefault()
        },
    },
    components: {
        ButtonSubmit,
        UsageStatisticsReportBuilder,
    },
    name: "UsageStatisticsReportsHome",
}
</script>

<style scoped>
.rows {
    float: none;
}
/* .report-builder {
    display: flex;
}
.custom-report {
    width: 50%;
    align-items: left;
}
.custom-report .v-select,
input {
    width: 50%;
    min-width: 50%;
}
.default-report {
    width: 50%;
} */
</style>
