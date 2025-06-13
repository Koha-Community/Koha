<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else>
        <div v-if="!default_usage_reports.length">
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
import { inject, onMounted, ref } from "vue";
import { useRouter } from "vue-router";
import { $__ } from "../../i18n";

export default {
    setup() {
        const router = useRouter();
        const { setMessage, setError } = inject("mainStore");

        const initialized = ref(false);
        const default_usage_report = ref(null);
        const default_usage_reports = ref([]);

        const getDefaultUsageReports = async () => {
            const client = APIClient.erm;
            await client.default_usage_reports.getAll().then(
                result => {
                    default_usage_reports.value = result;
                    initialized.value = true;
                },
                error => {}
            );
        };
        const deleteSavedReport = async e => {
            e.preventDefault();
            const id = default_usage_report.value.erm_default_usage_report_id;
            if (id) {
                const client = APIClient.erm;
                await client.default_usage_reports.delete(id).then(
                    success => {
                        setMessage($__("Report deleted successfully"));
                        default_usage_reports.value =
                            default_usage_reports.value.filter(
                                report =>
                                    report.erm_default_usage_report_id !== id
                            );
                        default_usage_report.value = null;
                    },
                    error => {}
                );
            } else {
                setError($__("No report was selected - could not delete"));
            }
        };
        const displayDefaultReport = e => {
            e.preventDefault();
            router.push({
                name: "UsageStatisticsReportsViewer",
                query: { data: default_usage_report.value.report_url_params },
            });
        };
        onMounted(() => {
            getDefaultUsageReports();
        });
        return {
            setMessage,
            setError,
            initialized,
            default_usage_report,
            default_usage_reports,
            deleteSavedReport,
            displayDefaultReport,
        };
    },
    components: {
        ButtonSubmit,
    },
    name: "UsageStatisticsSaveReports",
};
</script>
