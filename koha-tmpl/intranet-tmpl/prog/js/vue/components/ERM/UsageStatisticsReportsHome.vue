<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="report_builder">
        <h2>{{ $__("Usage statistics reports") }}</h2>
        <div id="usage_data_providerstabs" class="toptabs numbered">
            <ul class="nav nav-tabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <a
                        href="#"
                        class="nav-link"
                        data-content="default"
                        @click="changeCustomOrDefault"
                        v-bind:class="
                            custom_or_default === 'default' ? 'active' : ''
                        "
                        >{{ $__("Saved reports") }}</a
                    >
                </li>
                <li class="nav-item" role="presentation">
                    <a
                        href="#"
                        class="nav-link"
                        data-content="custom"
                        @click="changeCustomOrDefault"
                        v-bind:class="
                            custom_or_default === 'custom' ? 'active' : ''
                        "
                        >{{ $__("Create report") }}</a
                    >
                </li>
            </ul>
        </div>
        <div class="tab-content">
            <div v-if="custom_or_default === 'default'">
                <UsageStatisticsSavedReports />
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
import { inject, onBeforeMount, ref } from "vue";
import ButtonSubmit from "../ButtonSubmit.vue";
import { APIClient } from "../../fetch/api-client.js";
import UsageStatisticsReportBuilder from "./UsageStatisticsReportBuilder.vue";
import UsageStatisticsSavedReports from "./UsageStatisticsSavedReports.vue";
import { $__ } from "@k/i18n/";

export default {
    setup(props) {
        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore");

        const initialized = ref(false);
        const custom_or_default = ref("default");
        const default_usage_report = ref(null);
        const default_usage_reports = ref([]);
        const usage_data_providers = ref([]);

        const getUsageDataProviders = async () => {
            const client = APIClient.erm;
            await client.usage_data_providers.getAll().then(
                result => {
                    if (result.length === 0) {
                        setError(
                            $__(
                                "No data providers have been created -  no report data will be available"
                            )
                        );
                    }
                    usage_data_providers.value = result;
                    initialized.value = true;
                },
                error => {}
            );
        };
        const changeCustomOrDefault = e => {
            custom_or_default.value = e.target.getAttribute("data-content");
        };

        onBeforeMount(() => {
            getUsageDataProviders();
        });
        return {
            setConfirmationDialog,
            setMessage,
            setError,
            initialized,
            custom_or_default,
            default_usage_report,
            default_usage_reports,
            usage_data_providers,
            changeCustomOrDefault,
        };
    },
    components: {
        ButtonSubmit,
        UsageStatisticsReportBuilder,
        UsageStatisticsSavedReports,
    },
    name: "UsageStatisticsReportsHome",
};
</script>

<style scoped>
.rows {
    float: none;
}
.toptabs {
    margin-bottom: 0;
}
</style>
