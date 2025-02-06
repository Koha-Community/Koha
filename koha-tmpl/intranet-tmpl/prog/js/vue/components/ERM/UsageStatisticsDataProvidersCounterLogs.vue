<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="counter_logs_list">
        <div v-if="counter_files_count > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @delete="delete_counter_file"
                @download="download_counter_file"
            ></KohaTable>
        </div>
        <div v-else-if="initialized" class="alert alert-info">
            {{ $__("There are no import logs defined") }}
        </div>
    </div>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js";
import { inject, ref } from "vue";
import KohaTable from "../KohaTable.vue";

export default {
    setup() {
        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const table = ref();

        return {
            table,
            setConfirmationDialog,
            setMessage,
        };
    },
    data: function () {
        return {
            counter_files_count: 0,
            initialized: false,
            before_route_entered: false,
            building_table: false,
            tableOptions: {
                columns: this.getTableColumns(),
                options: {
                    embed: "patron",
                },
                url: () => this.table_url(),
                table_settings: this.counter_log_table_settings,
                add_filters: true,
                filters_options: {},
                actions: {
                    0: ["show"],
                    "-1": [
                        {
                            download: {
                                text: this.$__("Download"),
                                icon: "fa fa-download",
                            },
                        },
                        "delete",
                    ],
                },
            },
        };
    },
    methods: {
        async getCounterFiles() {
            const client = APIClient.erm;
            await client.counter_files
                .count({
                    usage_data_provider_id:
                        this.$route.params.usage_data_provider_id,
                })
                .then(
                    count => {
                        this.counter_files_count = count;
                        this.initialized = true;
                    },
                    error => {}
                );
        },
        table_url() {
            let url = `/api/v1/erm/counter_logs?usage_data_provider_id=${this.$route.params.usage_data_provider_id}`;
            return url;
        },
        download_counter_file(counter_log, dt, event) {
            window.location.href =
                "/api/v1/erm/counter_files/" +
                counter_log.counter_files_id +
                "/file/content";
        },
        delete_counter_file(counter_log, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this file?"
                    ),
                    message: counter_log.filename,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm;
                    client.counter_files
                        .delete(counter_log.counter_files_id)
                        .then(
                            success => {
                                this.setMessage(
                                    this.$__("File %s deleted").format(
                                        counter_log.filename
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
        getTableColumns() {
            return [
                {
                    title: __("Filename"),
                    data: "filename",
                    searchable: true,
                    orderable: true,
                },
                {
                    data: "importdate",
                    title: __("Import date"),
                    render: function (data, type, row, meta) {
                        const date = row.importdate.substr(0, 10);
                        const time = row.importdate.substr(11, 8);
                        return `${date} ${time}`;
                    },
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Imported by"),
                    render: function (data, type, row, meta) {
                        const { patron } = row;
                        const importer = patron
                            ? '<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=' +
                              patron.patron_id +
                              '">' +
                              $patron_to_html(patron) +
                              "</a>"
                            : this.$__("Cronjob");
                        return importer;
                    },
                    searchable: true,
                    orderable: true,
                },
            ];
        },
    },
    mounted() {
        if (!this.building_table) {
            this.building_table = true;
            this.getCounterFiles();
        }
    },
    components: { KohaTable },
    name: "UsageStatisticsTitlesList",
};
</script>

<style scoped>
#title_list {
    display: table;
}
</style>
