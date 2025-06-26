<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="usage_data_providers_list">
        <template class="toolbar_options">
            <Toolbar>
                <ToolbarButton
                    :to="{ name: 'UsageStatisticsDataProvidersFormAdd' }"
                    icon="plus"
                    :title="$__('New data provider')"
                />
                <ToolbarButton
                    v-if="usageDataProviderCount > 0"
                    :to="{ name: 'UsageStatisticsDataProvidersSummary' }"
                    icon="list"
                    :title="$__('Data providers summary')"
                />
            </Toolbar>
        </template>
        <div v-if="usageDataProviderCount > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @show="showUsageDataProvider"
                @edit="editUsageDataProvider"
                @delete="deleteUsageDataProvider"
                @run_now="runHarvesterNow"
                @test_connection="testHarvesterConnection"
            ></KohaTable>
        </div>
        <div v-else-if="initialized" class="alert alert-info">
            {{ $__("There are no usage data providers defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { inject, ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { APIClient } from "../../fetch/api-client.js";
import KohaTable from "../KohaTable.vue";
import { $__ } from "../../i18n/";

export default {
    setup() {
        const router = useRouter();

        const ERMStore = inject("ERMStore"); // Left in for future permissions fixes
        const { get_lib_from_av, map_av_dt_filter } = ERMStore;

        const { setConfirmationDialog, setMessage, setWarning } =
            inject("mainStore");

        const getTableColumns = () => {
            return [
                {
                    title: __("Name"),
                    data: "me.erm_usage_data_provider_id:me.name",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(
                                `${row.name} (#${row.erm_usage_data_provider_id})`
                            ) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Description"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Status"),
                    data: "active",
                    render: function (data, type, row, meta) {
                        const status = row.active
                            ? __("Active")
                            : __("Inactive");
                        return status;
                    },
                    searchable: false,
                    orderable: true,
                },
                {
                    title: __("Last run"),
                    data: "last_run",
                    searchable: false,
                    orderable: false,
                },
            ];
        };

        const table = ref();
        const buildingTable = ref(false);
        const usageDataProviderCount = ref(0);
        const initialized = ref(false);
        const tableOptions = ref({
            columns: getTableColumns(),
            options: {},
            url: () => tableUrl(),
            table_settings: usage_data_provider_table_settings,
            add_filters: true,
            actions: {
                0: ["show"],
                "-1": [
                    {
                        run_now: {
                            text: $__("Run now"),
                            icon: "fa fa-play",
                        },
                    },
                    {
                        test_connection: {
                            text: $__("Test"),
                            icon: "fa fa-check",
                        },
                    },
                    "edit",
                    "delete",
                ],
            },
        });

        const tableUrl = () => {
            let url = "/api/v1/erm/usage_data_providers";
            return url;
        };
        const showUsageDataProvider = (usage_data_provider, dt, event) => {
            router.push({
                name: "UsageStatisticsDataProvidersShow",
                params: {
                    erm_usage_data_provider_id:
                        usage_data_provider.erm_usage_data_provider_id,
                },
            });
        };
        const editUsageDataProvider = (usage_data_provider, dt, event) => {
            router.push({
                name: "UsageStatisticsDataProvidersFormAddEdit",
                params: {
                    erm_usage_data_provider_id:
                        usage_data_provider.erm_usage_data_provider_id,
                },
            });
        };
        const deleteUsageDataProvider = (usage_data_provider, dt, event) => {
            setConfirmationDialog(
                {
                    title: $__(
                        "Are you sure you want to remove this data provider?"
                    ),
                    message: usage_data_provider.name,
                    accept_label: $__("Yes, delete"),
                    cancel_label: $__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm;
                    client.usage_data_providers
                        .delete(usage_data_provider.erm_usage_data_provider_id)
                        .then(
                            success => {
                                setMessage(
                                    $__("Data provider %s deleted").format(
                                        usage_data_provider.name
                                    ),
                                    true
                                );
                                dt.draw();
                            },
                            error => {}
                        );
                }
            );
        };
        const runHarvesterNow = (usage_data_provider, dt, event) => {
            const { erm_usage_data_provider_id: id, name } =
                usage_data_provider;

            if (!usage_data_provider.active) {
                setConfirmationDialog(
                    {
                        title: $__(
                            "This data provider is set to 'Inactive', do you wish to update the status to 'Active'?"
                        ),
                        message: name,
                        accept_label: $__("Yes, update status"),
                        cancel_label: $__("No, do not update status"),
                    },
                    () => {
                        usage_data_provider.active = 1;
                        delete usage_data_provider.erm_usage_data_provider_id;
                        // const counter_files = usage_data_provider.counter_files
                        // delete usage_data_provider.counter_files
                        delete usage_data_provider.earliest_platform;
                        delete usage_data_provider.latest_platform;
                        delete usage_data_provider.earliest_title;
                        delete usage_data_provider.latest_title;
                        delete usage_data_provider.earliest_database;
                        delete usage_data_provider.latest_database;
                        delete usage_data_provider.earliest_item;
                        delete usage_data_provider.latest_item;
                        const client = APIClient.erm;
                        client.usage_data_providers
                            .update(usage_data_provider, id)
                            .then(
                                success => {
                                    setMessage(
                                        $__(
                                            "Updated status for usage data provider %s"
                                        ).format(name),
                                        true
                                    );
                                    // usage_data_provider.counter_files =
                                    // counter_files
                                    dt.draw();
                                },
                                error => {}
                            );
                    }
                );
            } else {
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
                            .process_SUSHI_response(id, inputFields)
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
            }
        };
        const testHarvesterConnection = (usage_data_provider, dt, event) => {
            const { erm_usage_data_provider_id: id, name } =
                usage_data_provider;

            if (usage_data_provider.active) {
                const client = APIClient.erm;
                client.usage_data_providers.test(id).then(
                    success => {
                        if (success) {
                            setMessage(
                                $__(
                                    "Harvester connection was successful for usage data provider %s"
                                ).format(name),
                                true
                            );
                        } else {
                            setMessage(
                                $__(
                                    "No connection for usage data provider %s, please check your credentials and try again."
                                ).format(name),
                                true
                            );
                        }
                    },
                    error => {}
                );
            } else {
                setWarning(
                    $__(
                        "This data provider is inactive - connection testing is not possible"
                    ),
                    true
                );
            }
        };
        const getUsageDataProviderCount = async () => {
            const client = APIClient.erm;
            await client.usage_data_providers.count().then(
                count => {
                    usageDataProviderCount.value = count;
                    initialized.value = true;
                },
                error => {}
            );
        };

        onMounted(() => {
            if (!buildingTable.value) {
                buildingTable.value = true;
                getUsageDataProviderCount();
            }
        });
        return {
            get_lib_from_av,
            map_av_dt_filter,
            setConfirmationDialog,
            setMessage,
            setWarning,
            usage_data_provider_table_settings,
            table,
            initialized,
            usageDataProviderCount,
            tableOptions,
            getTableColumns,
            showUsageDataProvider,
            editUsageDataProvider,
            deleteUsageDataProvider,
            runHarvesterNow,
            testHarvesterConnection,
            getUsageDataProviderCount,
        };
    },
    components: { Toolbar, ToolbarButton, KohaTable },
    name: "UsageStatisticsDataProvidersList",
};
</script>

<style scoped>
.toolbar_options {
    display: flex;
}
</style>
