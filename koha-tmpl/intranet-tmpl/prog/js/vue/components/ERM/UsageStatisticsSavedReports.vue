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
                            :reduce="report => report"
                            :options="default_usage_reports"
                            :required="!default_usage_report"
                        >
                            <template #search="{ attributes, events }">
                                <input
                                    :required="!default_usage_report"
                                    class="vs__search"
                                    v-bind="attributes"
                                    v-on="events"
                                />
                            </template>
                        </v-select>
                        <span class="required">{{ $__("Required") }}</span>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <ButtonSubmit />
                <button
                    v-if="default_usage_report"
                    @click="deleteSavedReport($event)"
                    class="btn btn-default"
                >
                    {{ $__("Delete report") }}
                </button>
            </fieldset>
        </form>
    </div>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue";
import { APIClient } from "../../fetch/api-client.js";
import { inject } from "vue";

export default {
    setup() {
        const { setMessage, setError } = inject("mainStore");

        return {
            setMessage,
            setError,
        };
    },
    data() {
        return {
            initialized: false,
            default_usage_report: null,
            default_usage_reports: [],
        };
    },
    mounted() {
        this.getDefaultUsageReports();
    },
    methods: {
        async getDefaultUsageReports() {
            const client = APIClient.erm;
            await client.default_usage_reports.getAll().then(
                default_usage_reports => {
                    this.default_usage_reports = default_usage_reports;
                    this.initialized = true;
                },
                error => {}
            );
        },
        async deleteSavedReport(e) {
            e.preventDefault();
            const id = this.default_usage_report.erm_default_usage_report_id;
            if (id) {
                const client = APIClient.erm;
                await client.default_usage_reports.delete(id).then(
                    success => {
                        this.setMessage(
                            this.$__("Report deleted successfully")
                        );
                        this.default_usage_reports =
                            this.default_usage_reports.filter(
                                report =>
                                    report.erm_default_usage_report_id !== id
                            );
                        this.default_usage_report = null;
                    },
                    error => {}
                );
            } else {
                this.setError(
                    this.$__("No report was selected - could not delete")
                );
            }
        },
        displayDefaultReport(e) {
            e.preventDefault();
            this.$router.push({
                name: "UsageStatisticsReportsViewer",
                query: { data: this.default_usage_report.report_url_params },
            });
        },
    },
    components: {
        ButtonSubmit,
    },
    name: "UsageStatisticsSaveReports",
};
</script>
