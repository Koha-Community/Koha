<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="usage_data_providers_show">
        <h2>
            {{
                $__("Data provider #%s").format(
                    usage_data_provider.erm_usage_data_provider_id
                )
            }}
            <span class="action_links">
                <router-link
                    :to="{
                        name: 'UsageStatisticsDataProvidersFormAddEdit',
                        params: {
                            usage_data_provider_id:
                                usage_data_provider.erm_usage_data_provider_id,
                        },
                    }"
                    :title="$__('Edit')"
                    ><i class="fa fa-pencil"></i
                ></router-link>
                <a
                    @click="
                        delete_usage_data_provider(
                            usage_data_provider.erm_usage_data_provider_id,
                            usage_data_provider.name
                        )
                    "
                    ><i class="fa fa-trash"></i
                ></a>
            </span>
        </h2>
        <div id="usage_data_providerstabs" class="toptabs numbered">
            <ul class="nav nav-tabs" role="tablist">
                <li
                    role="presentation"
                    v-bind:class="tab_content === 'detail' ? 'active' : ''"
                >
                    <a
                        href="#"
                        role="tab"
                        data-content="detail"
                        @click="change_tab_content"
                        >Detail</a
                    >
                </li>
                <li
                    v-for="(item, i) in available_data_types"
                    role="presentation"
                    v-bind:class="
                        tab_content === item.data_type ? 'active' : ''
                    "
                    :key="i"
                >
                    <a
                        href="#"
                        role="tab"
                        :data-content="item.data_type"
                        @click="change_tab_content"
                        >{{ $__(item.tab_name) }}</a
                    >
                </li>
                <li
                    role="presentation"
                    v-bind:class="tab_content === 'upload' ? 'active' : ''"
                >
                    <a
                        href="#"
                        role="tab"
                        data-content="upload"
                        @click="change_tab_content"
                        >Manual upload</a
                    >
                </li>
                <li
                    role="presentation"
                    v-bind:class="tab_content === 'imports' ? 'active' : ''"
                >
                    <a
                        href="#"
                        role="tab"
                        data-content="imports"
                        @click="change_tab_content"
                        >Import logs</a
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
import { inject } from "vue"
import { APIClient } from "../../fetch/api-client.js"
import UsageStatisticsDataProvidersFileImport from "./UsageStatisticsDataProvidersFileImport.vue"
import UsageStatisticsDataProvidersCounterLogs from "./UsageStatisticsDataProvidersCounterLogs.vue"
import UsageStatisticsDataProviderDetails from "./UsageStatisticsDataProviderDetails.vue"
import UsageStatisticsProviderDataList from "./UsageStatisticsProviderDataList.vue"

export default {
    setup() {
        const AVStore = inject("AVStore")
        const { get_lib_from_av } = AVStore

        const { setConfirmationDialog, setMessage } = inject("mainStore")

        return {
            get_lib_from_av,
            setConfirmationDialog,
            setMessage,
        }
    },
    data() {
        return {
            initialized: false,
            tab_content: "detail",
            available_data_types: [
                { test: "TR", data_type: "title", tab_name: "Titles" },
                { test: "PR", data_type: "platform", tab_name: "Platforms" },
                { test: "IR", data_type: "item", tab_name: "Items" },
                { test: "DR", data_type: "database", tab_name: "Databases" },
            ],
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getUsageDataProvider(to.params.usage_data_provider_id)
        })
    },
    methods: {
        async getUsageDataProvider(usage_data_provider_id) {
            const client = APIClient.erm
            client.usage_data_providers.get(usage_data_provider_id).then(
                usage_data_provider => {
                    this.usage_data_provider = usage_data_provider
                    this.initialized = true
                },
                error => {}
            )
        },
        change_tab_content(e) {
            this.tab_content = e.target.getAttribute("data-content")
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
                    const client = APIClient.erm
                    client.usage_data_providers
                        .delete(usage_data_provider_id)
                        .then(
                            success => {
                                this.setMessage(
                                    this.$__(
                                        "Usage data provider %s deleted"
                                    ).format(usage_data_provider_name),
                                    true
                                )
                                this.$router.push({
                                    name: "UsageStatisticsDataProvidersList",
                                })
                            },
                            error => {}
                        )
                }
            )
        },
    },
    name: "UsageStatisticsDataProvidersShow",
    components: {
        UsageStatisticsDataProvidersFileImport,
        UsageStatisticsDataProvidersCounterLogs,
        UsageStatisticsDataProviderDetails,
        UsageStatisticsProviderDataList,
    },
}
</script>
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
    cursor: pointer;
}
.active {
    cursor: pointer;
}
</style>
