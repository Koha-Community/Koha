<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div
        v-else-if="usage_data_providers.length"
        id="usage_data_providers_summary"
    >
        <div id="toolbar" class="btn-toolbar">
            <router-link
                :to="{ name: 'UsageStatisticsDataProvidersList' }"
                class="btn btn-default"
            >
                <i class="fa fa-list"></i>
                {{ $__("Data providers list") }}</router-link
            >
        </div>
        <div
            v-if="usage_data_providers.length"
            class="page-section hide-table"
            ref="table_div"
        >
            <KohaTable ref="table" v-bind="tableOptions"></KohaTable>
        </div>
    </div>
</template>

<script>
import { inject, onMounted, ref, useTemplateRef, watch } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import KohaTable from "../KohaTable.vue";
import { $__ } from "../../i18n";

export default {
    setup() {
        const ERMStore = inject("ERMStore"); // Left in for future permissions fixes
        const { get_lib_from_av, map_av_dt_filter } = ERMStore;

        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const table = useTemplateRef("table");

        const usage_data_providers = ref([]);
        const initialized = ref(false);
        const building_table = ref(false);

        const table_url = () => {
            let url = "/api/v1/erm/usage_data_providers";
            return url;
        };
        const getTableColumns = () => {
            const columns = [
                {
                    title: __("Provider"),
                    data: "me.erm_usage_data_provider_id:me.name",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.name;
                    },
                },
            ];

            const data_types = ["title", "platform", "database", "item"];
            data_types.forEach(data_type => {
                columns.push(
                    {
                        title: __("Start"),
                        data: "description",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            const date = row[`earliest_${data_type}`]
                                ? row[`earliest_${data_type}`]
                                : __("N/A");
                            return date;
                        },
                    },
                    {
                        title: __("End"),
                        data: "description",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            const date = row[`latest_${data_type}`]
                                ? row[`latest_${data_type}`]
                                : __("N/A");
                            return date;
                        },
                    }
                );
            });

            return columns;
        };
        const createTableHeader = () => {
            const tableEl = table.$el.getElementsByTagName("table")[0];

            const row = tableEl.insertRow(0);
            const [cellOne, cellTwo, cellThree, cellFour, cellFive] =
                Array.from("1".repeat(5)).map(item => {
                    const cell = document.createElement("th");
                    row.appendChild(cell);
                    return cell;
                });
            cellTwo.colSpan = 2;
            cellTwo.innerHTML = $__("Title reports");
            cellThree.colSpan = 2;
            cellThree.innerHTML = $__("Platform reports");
            cellFour.colSpan = 2;
            cellFour.innerHTML = $__("Database reports");
            cellFive.colSpan = 2;
            cellFive.innerHTML = $__("Item reports");

            table_div.classList.remove("hide-table");
        };

        const tableOptions = ref({
            columns: getTableColumns(),
            options: { embed: "counter_files" },
            url: () => table_url(),
            table_settings: usage_data_provider_table_settings,
            // add_filters: true,
            actions: {},
        });

        const getUsageDataProviders = async () => {
            const client = APIClient.erm;
            await client.usage_data_providers.getAll().then(
                result => {
                    usage_data_providers.value = result;
                    initialized.value = true;
                },
                error => {}
            );
        };

        watch(table, () => {
            createTableHeader();
        });

        onMounted(() => {
            if (!building_table.value) {
                building_table.value = true;
                getUsageDataProviders();
            }
        });

        return {
            get_lib_from_av,
            map_av_dt_filter,
            setConfirmationDialog,
            setMessage,
            table,
            usage_data_providers,
            initialized,
            building_table,
            tableOptions,
            createTableHeader,
        };
    },
    components: { KohaTable },
    name: "UsageStatisticsDataProvidersSummary",
};
</script>

<style scoped>
#usage_data_provider_summary {
    display: table;
}
.hide-table {
    display: none;
}
</style>
