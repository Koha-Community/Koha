<template>
    <h2>{{ $__("Import from a list") }}</h2>
    <div v-if="job_id" class="alert alert-info">
        {{ $__("Import in progress,") }}
        <a
            :href="`/cgi-bin/koha/admin/background_jobs.pl?op=view&id=${job_id}`"
            target="_blank"
        >
            {{ $__("see job #%s").format(job_id) }}
        </a>
    </div>
    <fieldset id="package_list" class="rows">
        {{ $__("To the following local package") }}:
        <v-select
            v-model="package_id"
            label="name"
            :reduce="p => p.package_id"
            :options="packages"
            :clearable="false"
        >
        </v-select>
    </fieldset>
    <div id="import_list_result" class="page-section">
        <table :id="tableId"></table>
    </div>
</template>

<script>
import { setError } from "../../messages";
import { createVNode, onBeforeMount, onMounted, ref, render } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import { useDataTable } from "../../composables/datatables";
import { $__ } from "@k/i18n";

export default {
    setup() {
        const tableId = "list_list";
        useDataTable(tableId);

        const job_id = ref(null);
        const package_id = ref(null);
        const packages = ref([]);
        const initialized = ref(false);

        const importTitleFromList = async list_id => {
            if (!package_id.value) {
                setError($__("Cannot import, no package selected"));
                return;
            }
            if (!list_id) return;
            const client = APIClient.erm;
            client.localTitles
                .import({ list_id, package_id: package_id.value })
                .then(
                    result => {
                        job_id.value = result.job_id;
                    },
                    error => {}
                );
        };
        const buildDatatable = () => {
            let lists = logged_in_user_lists;
            let table_id = tableId;
            let importFromList = importTitleFromList;
            $("#" + table_id).kohaTable({
                data: lists,
                order: [[0, "asc"]],
                columns: [
                    {
                        title: $__("Name"),
                        data: "shelfname",
                        searchable: true,
                        orderable: true,
                        width: "100%",
                        render: function (data, type, row, meta) {
                            return (
                                row.shelfname + " (#" + row.shelfnumber + ")"
                            );
                        },
                    },
                    {
                        title: $__("Actions"),
                        data: function (row, type, val, meta) {
                            return '<div class="actions"></div>';
                        },
                        className: "actions noExport",
                        searchable: false,
                        orderable: false,
                    },
                ],
                drawCallback: function (settings) {
                    var api = new $.fn.dataTable.Api(settings);

                    $.each($(this).find("td .actions"), function (index, e) {
                        let tr = $(this).parent().parent();
                        let list_id = api.row(tr).data().shelfnumber;
                        let importButton = createVNode(
                            "a",
                            {
                                class: "btn btn-default btn-xs",
                                role: "button",
                                onClick: () => {
                                    importFromList(list_id);
                                },
                            },
                            [
                                createVNode("i", {
                                    class: "fa fa-download",
                                    "aria-hidden": "true",
                                }),
                                $__("Import"),
                            ]
                        );

                        let n = createVNode("span", {}, [importButton]);
                        render(n, e);
                    });
                },
            });
        };

        onBeforeMount(() => {
            const client = APIClient.erm;
            client.localPackages.getAll().then(
                result => {
                    packages.value = result;
                    if (packages.value.length) {
                        package_id.value = result[0].package_id;
                    }
                    initialized.value = true;
                },
                error => {}
            );
        });
        onMounted(() => {
            buildDatatable();
        });
        return {
            tableId,
            logged_in_user_lists,
            job_id,
            package_id,
            packages,
            initialized,
            importTitleFromList,
            buildDatatable,
        };
    },
    name: "EHoldingsLocalTitlesFormImport",
};
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
