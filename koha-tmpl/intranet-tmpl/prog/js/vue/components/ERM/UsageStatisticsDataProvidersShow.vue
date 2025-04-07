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
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import UsageStatisticsDataProvidersFileImport from "./UsageStatisticsDataProvidersFileImport.vue";
import UsageStatisticsDataProvidersCounterLogs from "./UsageStatisticsDataProvidersCounterLogs.vue";
import UsageStatisticsDataProviderDetails from "./UsageStatisticsDataProviderDetails.vue";
import UsageStatisticsProviderDataList from "./UsageStatisticsProviderDataList.vue";

export default {
    setup() {
        const ERMStore = inject("ERMStore");
        const { get_lib_from_av } = ERMStore;

        const { setConfirmationDialog, setMessage } = inject("mainStore");

        return {
            get_lib_from_av,
            setConfirmationDialog,
            setMessage,
        };
    },
    data() {
        return {
            usage_data_provider: {
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
            },
            initialized: false,
            tab_content: "detail",
            available_data_types: [
                {
                    test: "TR",
                    data_type: "title",
                    tab_name: this.$__("Titles"),
                },
                {
                    test: "PR",
                    data_type: "platform",
                    tab_name: this.$__("Platforms"),
                },
                { test: "IR", data_type: "item", tab_name: this.$__("Items") },
                {
                    test: "DR",
                    data_type: "database",
                    tab_name: this.$__("Databases"),
                },
            ],
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getUsageDataProvider(to.params.usage_data_provider_id);
        });
    },
    methods: {
        async getUsageDataProvider(usage_data_provider_id) {
            const client = APIClient.erm;
            client.usage_data_providers.get(usage_data_provider_id).then(
                usage_data_provider => {
                    this.usage_data_provider = usage_data_provider;
                    this.initialized = true;
                },
                error => {}
            );
        },
        change_tab_content(e) {
            this.tab_content = e.target.getAttribute("data-content");
        },
        delete_usage_data_provider: function (
            usage_data_provider_id,
            usage_data_provider_name
        ) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this data provider?"
                    ),
                    message: usage_data_provider_name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm;
                    client.usage_data_providers
                        .delete(usage_data_provider_id)
                        .then(
                            success => {
                                this.setMessage(
                                    this.$__(
                                        "Usage data provider %s deleted"
                                    ).format(usage_data_provider_name),
                                    true
                                );
                                this.$router.push({
                                    name: "UsageStatisticsDataProvidersList",
                                });
                            },
                            error => {}
                        );
                }
            );
        },
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
