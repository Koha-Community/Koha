<template>
    <WidgetWrapper v-bind="widgetWrapperProps">
        <template #default>
            <div v-if="!default_usage_reports.length">
                <div class="d-flex align-items-center alert alert-info">
                    {{ noReportsText }}
                </div>
                <router-link :to="{ name: 'UsageStatisticsReportsHome' }">
                    {{ createReportText }}
                </router-link>
            </div>
            <div v-else class="d-flex align-items-center">
                <div class="flex-grow-1 me-2">
                    <label for="filter" class="visually-hidden">{{
                        pickReportText
                    }}</label>
                    <v-select
                        label="report_name"
                        :options="default_usage_reports"
                        style="min-width: 200px"
                        v-model="selected_report"
                    ></v-select>
                </div>
                <div>
                    <button
                        class="btn btn-primary"
                        type="button"
                        :disabled="!selected_report"
                        @click="runReport"
                    >
                        {{ runText }}
                    </button>
                </div>
            </div>
        </template>
    </WidgetWrapper>
</template>

<script>
import { ref } from "vue";
import { useRouter } from "vue-router";
import WidgetWrapper from "../WidgetWrapper.vue";
import { APIClient } from "../../../fetch/api-client.js";
import { useBaseWidget } from "../../../composables/base-widget.js";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "ERMRunUsageReport",
    components: { WidgetWrapper },
    props: {
        display: String,
    },
    emits: ["removed", "added", "moveWidget"],
    setup(props, { emit }) {
        const router = useRouter();
        const baseWidget = useBaseWidget(
            {
                id: "ERMRunUsageReport",
                name: $__("Run eUsage report"),
                icon: "fa-solid fa-file",
                description: $__("Select a saved eUsage report to run."),
                ...props,
            },
            emit
        );

        const default_usage_reports = ref([]);
        const selected_report = ref(null);

        const noReportsText = $__(
            "No saved eUsage reports are available to run."
        );
        const createReportText = $__("Create a report");
        const pickReportText = $__("Pick a report to run");
        const runText = $__("Run");

        async function getReports() {
            try {
                const response =
                    await APIClient.erm.default_usage_reports.getAll();
                default_usage_reports.value = response;
            } catch (error) {
                console.error("Error getting default usage reports", error);
            } finally {
                baseWidget.loading.value = false;
            }
        }

        baseWidget.onDashboardMounted(() => {
            getReports();
        });

        function runReport() {
            if (!selected_report.value) return;
            router.push({
                name: "UsageStatisticsReportsViewer",
                query: { data: selected_report.value.report_url_params },
            });
        }

        return {
            ...baseWidget,
            default_usage_reports,
            selected_report,
            runReport,
            noReportsText,
            createReportText,
            pickReportText,
            runText,
        };
    },
};
</script>
