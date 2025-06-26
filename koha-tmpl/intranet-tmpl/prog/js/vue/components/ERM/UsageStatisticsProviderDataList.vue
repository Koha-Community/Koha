<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="data_list">
        <div v-if="data_count > 0" class="page-section">
            <KohaTable ref="table" v-bind="tableOptions"></KohaTable>
        </div>
        <div v-else-if="initialized" class="alert alert-info">
            {{
                $__("No %s data has been harvested for this provider").format(
                    data_type
                )
            }}
        </div>
    </div>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js";
import { onMounted, ref } from "vue";
import KohaTable from "../KohaTable.vue";
import { useRoute } from "vue-router";

export default {
    setup(props) {
        const route = useRoute();
        const table = ref();

        const tableUrl = () => {
            let url = "/api/v1/erm/usage_%ss?usage_data_provider_id=%s".format(
                props.data_type,
                route.params.erm_usage_data_provider_id
            );
            return url;
        };
        const getTableColumns = () => {
            const column_options = [
                {
                    used_by: ["title", "platform", "item", "database"],
                    column: {
                        title:
                            props.data_type.charAt(0).toUpperCase() +
                            props.data_type.slice(1),
                        data: props.data_type,
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["item", "database", "platforms"],
                    column: {
                        title: __("Platform"),
                        data: "platform",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title", "item", "database"],
                    column: {
                        title: __("Publisher"),
                        data: "publisher",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title", "database"],
                    column: {
                        title: __("Publisher ID"),
                        data: "publisher_id",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title"],
                    column: {
                        title: __("DOI"),
                        data: "title_doi",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title"],
                    column: {
                        title: __("Print ISSN"),
                        data: "print_issn",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title"],
                    column: {
                        title: __("Online ISSN"),
                        data: "online_issn",
                        searchable: true,
                        orderable: true,
                    },
                },
                {
                    used_by: ["title"],
                    column: {
                        title: __("URI"),
                        data: "title_uri",
                        searchable: true,
                        orderable: true,
                    },
                },
            ];
            const columns = column_options
                .filter(column => column.used_by.includes(props.data_type))
                .map(result => result.column);
            return columns;
        };

        const getData = async () => {
            const client = APIClient.erm;
            await client[`usage_${props.data_type}s`]
                .count({
                    usage_data_provider_id:
                        route.params.erm_usage_data_provider_id,
                })
                .then(
                    count => {
                        data_count.value = count;
                        initialized.value = true;
                    },
                    error => {}
                );
        };

        const data_count = ref(0);
        const initialized = ref(false);
        const building_table = ref(false);
        const tableOptions = ref({
            columns: getTableColumns(),
            options: {},
            url: () => tableUrl(),
            table_settings: title_table_settings,
            add_filters: true,
        });

        onMounted(() => {
            if (!building_table.value) {
                building_table.value = true;
                getData();
            }
        });
        return {
            table,
            data_count,
            initialized,
            building_table,
            tableOptions,
        };
    },
    props: ["data_type"],
    components: { KohaTable },
    name: "UsageStatisticsProviderDataList",
};
</script>
