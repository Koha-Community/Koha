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
import { inject, onMounted, ref, useTemplateRef } from "vue";
import KohaTable from "../KohaTable.vue";
import { useRoute } from "vue-router";
import { $__ } from "@koha-vue/i18n";

export default {
    setup() {
        const route = useRoute();
        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const table = useTemplateRef("table");
        const counter_files_count = ref(0);
        const initialized = ref(false);
        const building_table = ref(false);

        const table_url = () => {
            let url = `/api/v1/erm/counter_logs?usage_data_provider_id=${route.params.erm_usage_data_provider_id}`;
            return url;
        };
        const download_counter_file = (counter_log, dt, event) => {
            window.location.href =
                "/api/v1/erm/counter_files/" +
                counter_log.counter_files_id +
                "/file/content";
        };
        const delete_counter_file = (counter_log, dt, event) => {
            setConfirmationDialog(
                {
                    title: $__("Are you sure you want to remove this file?"),
                    message: counter_log.filename,
                    accept_label: $__("Yes, delete"),
                    cancel_label: $__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm;
                    client.counter_files
                        .delete(counter_log.counter_files_id)
                        .then(
                            success => {
                                setMessage(
                                    $__("File %s deleted").format(
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
        };
        const getTableColumns = () => {
            return [
                {
                    title: $__("Filename"),
                    data: "filename",
                    searchable: true,
                    orderable: true,
                },
                {
                    data: "importdate",
                    title: $__("Import date"),
                    render: function (data, type, row, meta) {
                        const date = row.importdate.substr(0, 10);
                        const time = row.importdate.substr(11, 8);
                        return `${date} ${time}`;
                    },
                    searchable: true,
                    orderable: true,
                },
                {
                    title: $__("Imported by"),
                    render: function (data, type, row, meta) {
                        const { patron } = row;
                        const importer = patron
                            ? '<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=' +
                              patron.patron_id +
                              '">' +
                              $patron_to_html(patron) +
                              "</a>"
                            : $__("Cronjob");
                        return importer;
                    },
                    searchable: true,
                    orderable: true,
                },
            ];
        };

        const getCounterFiles = async () => {
            const client = APIClient.erm;
            await client.counter_files
                .count({
                    usage_data_provider_id:
                        route.params.erm_usage_data_provider_id,
                })
                .then(
                    count => {
                        counter_files_count.value = count;
                        initialized.value = true;
                    },
                    error => {}
                );
        };

        const tableOptions = ref({
            columns: getTableColumns(),
            options: {
                embed: "patron",
            },
            url: () => table_url(),
            table_settings: counter_log_table_settings,
            add_filters: true,
            filters_options: {},
            actions: {
                0: ["show"],
                "-1": [
                    {
                        download: {
                            text: $__("Download"),
                            icon: "fa fa-download",
                        },
                    },
                    "delete",
                ],
            },
        });

        onMounted(() => {
            if (!building_table.value) {
                building_table.value = true;
                getCounterFiles();
            }
        });
        return {
            table,
            setConfirmationDialog,
            setMessage,
            counter_files_count,
            initialized,
            building_table,
            tableOptions,
            download_counter_file,
            delete_counter_file,
        };
    },
    components: { KohaTable },
    name: "UsageStatisticsTitlesList",
};
</script>
