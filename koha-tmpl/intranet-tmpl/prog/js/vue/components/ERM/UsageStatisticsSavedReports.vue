<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else>
        <div v-if="!this.default_usage_reports.length">
            {{
                $__(
                    "You have not saved any reports yet, please create a report."
                )
            }}
        </div>
        <form
            v-else
            class="default-report"
            @submit="displayDefaultReport($event)"
        >
            <h2>{{ $__("Select saved report") }}</h2>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label for="default_usage_reports"
                            >{{ $__("Choose report") }}:</label
                        >
                        <v-select
                            id="default_usage_reports"
                            v-model="default_usage_report"
                            label="report_name"
                            :reduce="report => report.report_url_params"
                            :options="default_usage_reports"
                        />
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <ButtonSubmit />
            </fieldset>
        </form>
    </div>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue"
import { APIClient } from "../../fetch/api-client.js"

export default {
    data() {
        return {
            initialized: false,
            default_usage_report: null,
            default_usage_reports: [],
        }
    },
    mounted() {
        this.getDefaultUsageReports()
    },
    methods: {
        async getDefaultUsageReports() {
            const client = APIClient.erm
            await client.default_usage_reports.getAll().then(
                default_usage_reports => {
                    this.default_usage_reports = default_usage_reports
                    this.initialized = true
                },
                error => {}
            )
        },
        displayDefaultReport(e) {
            e.preventDefault()

            this.$router.push({
                name: "UsageStatisticsReportsViewer",
                query: { data: this.default_usage_report },
            })
        },
    },
    components: {
        ButtonSubmit,
    },
    name: "UsageStatisticsSaveReports",
}
</script>

<style></style>
