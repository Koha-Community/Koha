<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="usage_data_providers_show">
        <Toolbar>
            <ToolbarButton
                :to="{
                    name: 'UsageStatisticsDataProvidersFormAddEdit',
                    params: {
                        erm_usage_data_provider_id:
                            usage_data_provider.erm_usage_data_provider_id,
                    },
                }"
                icon="pencil"
                :title="$__('Edit')"
            />
            <a
                @click="
                    delete_usage_data_provider(
                        usage_data_provider.erm_usage_data_provider_id,
                        usage_data_provider.name
                    )
                "
                class="btn btn-default"
                ><font-awesome-icon icon="trash" /> {{ $__("Delete") }}</a
            >
            <button
                @click="
                    test_usage_data_provider(
                        usage_data_provider.erm_usage_data_provider_id,
                        usage_data_provider.name
                    )
                "
                class="btn btn-default"
                :disabled="!usage_data_provider.active"
            >
                <i class="fa fa-check"></i> {{ $__("Test") }}
            </button>
            <button
                @click="
                    run_harvester(
                        usage_data_provider.erm_usage_data_provider_id
                    )
                "
                class="btn btn-default"
                :disabled="!usage_data_provider.active"
            >
                <i class="fa fa-play"></i> {{ $__("Run now") }}
            </button>
        </Toolbar>

        <h2>
            {{
                $__("Data provider #%s").format(
                    usage_data_provider.erm_usage_data_provider_id
                )
            }}
        </h2>
        <div id="usage_data_providerstabs" class="toptabs numbered">
            <ul class="nav nav-tabs">
                <li class="nav-item">
                    <a
                        href="#"
                        class="nav-link"
                        data-content="detail"
                        @click="change_tab_content"
                        v-bind:class="tab_content === 'detail' ? 'active' : ''"
                        >{{ $__("Detail") }}</a
                    >
                </li>
                <li
                    v-for="(item, i) in available_data_types"
                    class="nav-item"
                    :key="i"
                >
                    <a
                        href="#"
                        class="nav-link"
                        :data-content="item.data_type"
                        @click="change_tab_content"
                        v-bind:class="
                            tab_content === item.data_type ? 'active' : ''
                        "
                        >{{ item.tab_name }}</a
                    >
                </li>
                <li class="nav-item">
                    <a
                        href="#"
                        class="nav-link"
                        data-content="upload"
                        @click="change_tab_content"
                        v-bind:class="tab_content === 'upload' ? 'active' : ''"
                        >{{ $__("Manual upload") }}</a
                    >
                </li>
                <li class="nav-item">
                    <a
                        href="#"
                        class="nav-link"
                        data-content="imports"
                        @click="change_tab_content"
                        v-bind:class="tab_content === 'imports' ? 'active' : ''"
                        >{{ $__("Import logs") }}</a
                    >
                </li>
            </ul>
        </div>
        <div class="tab-content">
            <div
                v-if="tab_content === 'detail'"
                class="usage_data_provider_detail"
            >
                <UsageStatisticsDataProviderDetails
                    :usage_data_provider="usage_data_provider"
                />
            </div>
            <template v-for="(item, i) in available_data_types">
                <div v-if="tab_content === item.data_type" :key="i">
                    <UsageStatisticsProviderDataList
                        :data_type="item.data_type"
                    />
                </div>
            </template>
            <div v-if="tab_content === 'upload'">
                <UsageStatisticsDataProvidersFileImport />
            </div>
            <div v-if="tab_content === 'imports'">
                <UsageStatisticsDataProvidersCounterLogs />
            </div>
        </div>
        <fieldset class="action">
            <router-link
                :to="{ name: 'UsageStatisticsDataProvidersList' }"
                role="button"
                class="cancel"
                >{{ $__("Close") }}</router-link
            >
        </fieldset>
    </div>
</template>

<script>
import { inject, onBeforeMount, ref } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import UsageStatisticsDataProvidersFileImport from "./UsageStatisticsDataProvidersFileImport.vue";
import UsageStatisticsDataProvidersCounterLogs from "./UsageStatisticsDataProvidersCounterLogs.vue";
import UsageStatisticsDataProviderDetails from "./UsageStatisticsDataProviderDetails.vue";
import UsageStatisticsProviderDataList from "./UsageStatisticsProviderDataList.vue";
import { useRoute, useRouter } from "vue-router";
import { $__ } from "@koha-vue/i18n/";

export default {
    setup() {
        const route = useRoute();
        const router = useRouter();
        const ERMStore = inject("ERMStore");
        const { get_lib_from_av } = ERMStore;

        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const usage_data_provider = ref({
            erm_usage_data_provider_id: null,
            name: "",
            description: "",
            active: 1,
            method: "",
            aggregator: "",
            service_type: "",
            service_url: "",
            report_release: "",
            customer_id: "",
            requestor_id: "",
            api_key: "",
            requestor_name: "",
            requestor_email: "",
            report_types: [],
        });
        const initialized = ref(false);
        const tab_content = ref("detail");
        const available_data_types = ref([
            {
                test: "TR",
                data_type: "title",
                tab_name: $__("Titles"),
            },
            {
                test: "PR",
                data_type: "platform",
                tab_name: $__("Platforms"),
            },
            { test: "IR", data_type: "item", tab_name: $__("Items") },
            {
                test: "DR",
                data_type: "database",
                tab_name: $__("Databases"),
            },
        ]);

        const getUsageDataProvider = async usage_data_provider_id => {
            const client = APIClient.erm;
            client.usage_data_providers.get(usage_data_provider_id).then(
                result => {
                    usage_data_provider.value = result;
                    initialized.value = true;
                },
                error => {}
            );
        };

        const delete_usage_data_provider = (
            usage_data_provider_id,
            usage_data_provider_name
        ) => {
            setConfirmationDialog(
                {
                    title: $__(
                        "Are you sure you want to remove this data provider?"
                    ),
                    message: usage_data_provider_name,
                    accept_label: $__("Yes, delete"),
                    cancel_label: $__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm;
                    client.usage_data_providers
                        .delete(usage_data_provider_id)
                        .then(
                            success => {
                                setMessage(
                                    $__(
                                        "Usage data provider %s deleted"
                                    ).format(usage_data_provider_name),
                                    true
                                );
                                router.push({
                                    name: "UsageStatisticsDataProvidersList",
                                });
                            },
                            error => {}
                        );
                }
            );
        };

        const test_usage_data_provider = (
            usage_data_provider_id,
            usage_data_provider_name
        ) => {
            const client = APIClient.erm;
            client.usage_data_providers.test(usage_data_provider_id).then(
                success => {
                    if (success) {
                        setMessage(
                            $__(
                                "Harvester connection was successful for usage data provider %s"
                            ).format(usage_data_provider_name),
                            true
                        );
                    } else {
                        setMessage(
                            $__(
                                "No connection for usage data provider %s, please check your credentials and try again."
                            ).format(usage_data_provider_name),
                            true
                        );
                    }
                },
                error => {}
            );
        };

        const run_harvester = usage_data_provider_id => {
            let date = new Date();
            setConfirmationDialog(
                {
                    title: $__(
                        "Are you sure you want to run the harvester for this data provider?"
                    ),
                    message: name,
                    accept_label: $__("Yes, run"),
                    cancel_label: $__("No, do not run"),
                    inputs: [
                        {
                            name: "begin_date",
                            type: "date",
                            value: null,
                            label: $__("Begin date"),
                            required: true,
                            componentProps: {
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                            },
                        },
                        {
                            name: "end_date",
                            type: "date",
                            value: $date_to_rfc3339($date(date.toString())),
                            label: $__("End date"),
                            required: true,
                            componentProps: {
                                required: {
                                    type: "boolean",
                                    value: true,
                                },
                            },
                        },
                    ],
                },
                (callback_result, inputFields) => {
                    const client = APIClient.erm;
                    client.usage_data_providers
                        .process_SUSHI_response(
                            usage_data_provider_id,
                            inputFields
                        )
                        .then(
                            success => {
                                let message = "";
                                success.jobs.forEach((job, i) => {
                                    message +=
                                        "<li>" +
                                        $__(
                                            "Job for report type <strong>%s</strong> has been queued"
                                        ).format(job.report_type) +
                                        '. <a href="/cgi-bin/koha/admin/background_jobs.pl?op=view&id=' +
                                        job.job_id +
                                        '" target="_blank">' +
                                        $__("Check job progress") +
                                        ".</a></li>";
                                });
                                setMessage(message, true);
                            },
                            error => {}
                        );
                }
            );
        };

        const change_tab_content = e => {
            tab_content.value = e.target.getAttribute("data-content");
        };
        onBeforeMount(() => {
            getUsageDataProvider(route.params.erm_usage_data_provider_id);
        });
        return {
            get_lib_from_av,
            setConfirmationDialog,
            setMessage,
            usage_data_provider,
            initialized,
            tab_content,
            available_data_types,
            delete_usage_data_provider,
            test_usage_data_provider,
            run_harvester,
            change_tab_content,
        };
    },
    name: "UsageStatisticsDataProvidersShow",
    components: {
        UsageStatisticsDataProvidersFileImport,
        UsageStatisticsDataProvidersCounterLogs,
        UsageStatisticsDataProviderDetails,
        UsageStatisticsProviderDataList,
        Toolbar,
        ToolbarButton,
    },
};
</script>
<style scoped>
.active {
    cursor: pointer;
}
.toptabs {
    margin-bottom: 0;
}
</style>
