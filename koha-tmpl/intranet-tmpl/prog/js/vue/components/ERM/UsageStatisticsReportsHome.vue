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
import { inject } from "vue";
import ButtonSubmit from "../ButtonSubmit.vue";
import { APIClient } from "../../fetch/api-client.js";
import UsageStatisticsReportBuilder from "./UsageStatisticsReportBuilder.vue";
import UsageStatisticsSavedReports from "./UsageStatisticsSavedReports.vue";

export default {
    setup() {
        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore");

        return {
            setConfirmationDialog,
            setMessage,
            setError,
        };
    },
    data() {
        return {
            initialized: false,
            custom_or_default: "default",
            default_usage_report: null,
            default_usage_reports: [],
            usage_data_providers: [],
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getUsageDataProviders();
        });
    },
    methods: {
        async getUsageDataProviders() {
            const client = APIClient.erm;
            await client.usage_data_providers.getAll().then(
                usage_data_providers => {
                    if (usage_data_providers.length === 0) {
                        this.setError(
                            this.$__(
                                "No data providers have been created -  no report data will be available"
                            )
                        );
                    }
                    this.usage_data_providers = usage_data_providers;
                    this.initialized = true;
                },
                error => {}
            );
        },
        changeCustomOrDefault(e) {
            this.custom_or_default = e.target.getAttribute("data-content");
        },
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
