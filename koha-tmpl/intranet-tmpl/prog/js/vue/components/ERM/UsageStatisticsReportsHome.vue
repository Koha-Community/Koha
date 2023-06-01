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
                        @click="changeCustomOrDefault"
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
                        @click="changeCustomOrDefault"
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
import ButtonSubmit from "../ButtonSubmit.vue"
import { APIClient } from "../../fetch/api-client.js"
import UsageStatisticsReportBuilder from "./UsageStatisticsReportBuilder.vue"

export default {
    setup() {
        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore")

        return {
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
        changeCustomOrDefault(e) {
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
</style>
