<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="usage_data_providers_list">
        <template class="toolbar_options">
            <Toolbar />
            <div
                v-if="usage_data_provider_count > 0"
                id="toolbar"
                class="btn-toolbar"
            >
                <router-link
                    :to="{ name: 'UsageStatisticsDataProvidersSummary' }"
                    class="btn btn-default"
                >
                    <i class="fa fa-list"></i>
                    {{ $__("Data providers summary") }}</router-link
                >
            </div>
        </template>
        <div v-if="usage_data_provider_count > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @show="show_usage_data_provider"
                @edit="edit_usage_data_provider"
                @delete="delete_usage_data_provider"
                @run_now="run_harvester_now"
                @test_connection="test_harvester_connection"
            ></KohaTable>
        </div>
        <div v-else-if="initialized" class="alert alert-info">
            {{ $__("There are no usage data providers defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./UsageStatisticsDataProvidersToolbar.vue";
import { inject, ref } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import KohaTable from "../KohaTable.vue";

export default {
    setup() {
        const ERMStore = inject("ERMStore"); // Left in for future permissions fixes
        const { get_lib_from_av, map_av_dt_filter } = ERMStore;

        const { setConfirmationDialog, setMessage, setWarning } =
            inject("mainStore");

        const table = ref();

        return {
            get_lib_from_av,
            map_av_dt_filter,
            setConfirmationDialog,
            setMessage,
            setWarning,
            table,
        };
    },
    data: function () {
        return {
            usage_data_provider_count: 0,
            initialized: false,
            building_table: false,
            tableOptions: {
                columns: this.getTableColumns(),
                options: {},
                url: () => this.table_url(),
                table_settings: this.usage_data_provider_table_settings,
                add_filters: true,
                actions: {
                    0: ["show"],
                    "-1": [
                        {
                            run_now: {
                                text: this.$__("Run now"),
                                icon: "fa fa-play",
                            },
                        },
                        {
                            test_connection: {
                                text: this.$__("Test"),
                                icon: "fa fa-check",
                            },
                        },
                        "edit",
                        "delete",
                    ],
                },
            },
        };
    },
    methods: {
        async getUsageDataProviderCount() {
            const client = APIClient.erm;
            await client.usage_data_providers.count().then(
                count => {
                    this.usage_data_provider_count = count;
                    this.initialized = true;
                },
                error => {}
            );
        },
        table_url() {
            let url = "/api/v1/erm/usage_data_providers";
            return url;
        },
        show_usage_data_provider(usage_data_provider, dt, event) {
            event.preventDefault();

            this.$router.push({
                name: "UsageStatisticsDataProvidersShow",
                params: {
                    usage_data_provider_id:
                        usage_data_provider.erm_usage_data_provider_id,
                },
            });
        },
        edit_usage_data_provider(usage_data_provider, dt, event) {
            this.$router.push({
                name: "UsageStatisticsDataProvidersFormAddEdit",
                params: {
                    usage_data_provider_id:
                        usage_data_provider.erm_usage_data_provider_id,
                },
            });
        },
        delete_usage_data_provider(usage_data_provider, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this data provider?"
                    ),
                    message: usage_data_provider.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm;
                    client.usage_data_providers
                        .delete(usage_data_provider.erm_usage_data_provider_id)
                        .then(
                            success => {
                                this.setMessage(
                                    this.$__("Data provider %s deleted").format(
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
        },
        run_harvester_now(usage_data_provider, dt, event) {
            const { erm_usage_data_provider_id: id, name } =
                usage_data_provider;

            if (!usage_data_provider.active) {
                this.setConfirmationDialog(
                    {
                        title: this.$__(
                            "This data provider is set to 'Inactive', do you wish to update the status to 'Active'?"
                        ),
                        message: name,
                        accept_label: this.$__("Yes, update status"),
                        cancel_label: this.$__("No, do not update status"),
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
                                    this.setMessage(
                                        this.$__(
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
                this.setConfirmationDialog(
                    {
                        title: this.$__(
                            "Are you sure you want to run the harvester for this data provider?"
                        ),
                        message: name,
                        accept_label: this.$__("Yes, run"),
                        cancel_label: this.$__("No, do not run"),
                        inputs: [
                            {
                                id: "begin_date",
                                type: "Date",
                                value: null,
                                required: true,
                                label: this.$__("Begin date"),
                            },
                            {
                                id: "end_date",
                                type: "Date",
                                value: $date_to_rfc3339($date(date.toString())),
                                required: true,
                                label: this.$__("End date"),
                            },
                        ],
                    },
                    callback_result => {
                        const client = APIClient.erm;
                        client.usage_data_providers
                            .process_SUSHI_response(id, {
                                begin_date: callback_result.inputs.find(
                                    input => {
                                        return input.id == "begin_date";
                                    }
                                ).value,
                                end_date: callback_result.inputs.find(input => {
                                    return input.id == "end_date";
                                }).value,
                            })
                            .then(
                                success => {
                                    let message = "";
                                    success.jobs.forEach((job, i) => {
                                        message +=
                                            "<li>" +
                                            this.$__(
                                                "Job for report type <strong>%s</strong> has been queued"
                                            ).format(job.report_type) +
                                            '. <a href="/cgi-bin/koha/admin/background_jobs.pl?op=view&id=' +
                                            job.job_id +
                                            '" target="_blank">' +
                                            this.$__("Check job progress") +
                                            ".</a></li>";
                                    });
                                    this.setMessage(message, true);
                                },
                                error => {}
                            );
                    }
                );
            }
        },
        test_harvester_connection(usage_data_provider, dt, event) {
            const { erm_usage_data_provider_id: id, name } =
                usage_data_provider;

            if (usage_data_provider.active) {
                const client = APIClient.erm;
                client.usage_data_providers.test(id).then(
                    success => {
                        if (success) {
                            this.setMessage(
                                this.$__(
                                    "Harvester connection was successful for usage data provider %s"
                                ).format(name),
                                true
                            );
                        } else {
                            this.setMessage(
                                this.$__(
                                    "No connection for usage data provider %s, please check your credentials and try again."
                                ).format(name),
                                true
                            );
                        }
                    },
                    error => {}
                );
            } else {
                this.setWarning(
                    this.$__(
                        "This data provider is inactive - connection testing is not possible"
                    ),
                    true
                );
            }
        },
        getTableColumns() {
            return [
                {
                    title: __("Name"),
                    data: "me.erm_usage_data_provider_id:me.name",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/eusage/usage_data_providers/' +
                            row.erm_usage_data_provider_id +
                            '" class="show">' +
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
                    render: function (data, type, row, meta) {
                        const status = row.active ? "Active" : "Inactive";
                        return status;
                    },
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Last run"),
                    data: "last_run",
                    searchable: true,
                    orderable: true,
                },
            ];
        },
    },
    mounted() {
        if (!this.building_table) {
            this.building_table = true;
            this.getUsageDataProviderCount();
        }
    },
    components: { Toolbar, KohaTable },
    name: "DataProvidersList",
};
</script>

<style scoped>
#usage_data_provider_list {
    display: table;
}
.toolbar_options {
    display: flex;
}
</style>
