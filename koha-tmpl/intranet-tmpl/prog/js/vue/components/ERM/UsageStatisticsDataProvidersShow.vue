<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="usage_data_providers_show">
        <Toolbar>
            <ToolbarButton
                :to="{
                    name: 'UsageStatisticsDataProvidersFormAddEdit',
                    params: {
                        usage_data_provider_id:
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
import { $__ } from "@k/i18n/";

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
