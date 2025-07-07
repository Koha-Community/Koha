<template>
    <div id="package_list_result">
        <div id="filters">
            <a href="#" @click.prevent="toggleFilters($event)"
                ><i class="fa fa-search"></i>
                {{ displayFilters ? $__("Hide filters") : $__("Show filters") }}
            </a>
            <fieldset v-if="displayFilters" id="filters">
                <ol>
                    <li>
                        <label>{{ $__("Package name") }}:</label>
                        <input
                            type="text"
                            id="package_name_filter"
                            v-model="filters.package_name"
                            @keyup.enter="filterTable"
                        />
                    </li>
                    <li>
                        <label>{{ $__("Selection status") }}:</label>
                        <select
                            id="selection_type_filter"
                            v-model="filters.selection_type"
                        >
                            <option value="0">{{ $__("All") }}</option>
                            <option value="1">{{ $__("Selected") }}</option>
                            <option value="2">{{ $__("Not selected") }}</option>
                        </select>
                    </li>
                </ol>
                <input
                    @click="filterTable"
                    id="filterTable"
                    type="button"
                    :value="$__('Filter')"
                />
            </fieldset>
        </div>
        <table :id="tableId"></table>
    </div>
</template>

<script>
import { createVNode, onMounted, ref, render } from "vue";
import { useDataTable } from "../../composables/datatables";
import { useRouter } from "vue-router";
import { $__ } from "@koha-vue/i18n";

export default {
    setup(props) {
        const router = useRouter();
        const tableId = "package_list";
        useDataTable(tableId);

        const filters = ref({
            package_name: "",
            selection_type: 0,
        });
        const displayFilters = ref(false);

        const showResource = resource_id => {
            router.push({
                name: "EHoldingsEBSCOResourcesShow",
                params: { resource_id },
            });
        };
        const toggleFilters = e => {
            displayFilters.value = !displayFilters.value;
        };
        const filterTable = () => {
            $("#" + tableId)
                .DataTable()
                .draw();
        };
        const buildDatatable = () => {
            let show_resource = showResource;
            let resources = props.resources;
            let tableFilters = filters.value;
            let appRouter = router;

            $.fn.dataTable.ext.search = $.fn.dataTable.ext.search.filter(
                search => search.name != "apply_filter"
            );
            $("#" + tableId).kohaTable({
                data: resources,
                embed: ["package.name"],
                ordering: false,
                dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                lengthMenu: [
                    [10, 20, 50, 100],
                    [10, 20, 50, 100],
                ],
                columns: [
                    {
                        title: $__("Name"),
                        data: "package.name",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return "";
                        },
                        width: "100%",
                    },
                ],
                drawCallback: function (settings) {
                    var api = new $.fn.dataTable.Api(settings);

                    if (!api.rows({ search: "applied" }).count()) return;

                    $.each(
                        $(this).find("tbody tr td:first-child"),
                        function (index, e) {
                            let tr = $(this).parent();
                            let row = api.row(tr).data();
                            if (!row) return; // Happen if the table is empty
                            let { href } = appRouter.resolve({
                                name: "EHoldingsEBSCOResourcesShow",
                                params: { resource_id: row.resource_id },
                            });
                            let n = createVNode(
                                "a",
                                {
                                    role: "button",
                                    href,
                                    onClick: e => {
                                        e.preventDefault();
                                        show_resource(row.resource_id);
                                    },
                                },
                                `${row.package.name}`
                            );
                            if (row.is_selected) {
                                n = createVNode("span", {}, [
                                    n,
                                    " ",
                                    createVNode("i", {
                                        class: "fa fa-check-square",
                                        style: {
                                            color: "green",
                                            float: "right",
                                        },
                                        title: $__("Is selected"),
                                    }),
                                ]);
                            }
                            render(n, e);
                        }
                    );
                },
                initComplete: function () {
                    $.fn.dataTable.ext.search.push(
                        function apply_filter(settings, data, dataIndex, row) {
                            return (
                                row.package.name.match(
                                    new RegExp(tableFilters.package_name, "i")
                                ) &&
                                (tableFilters.selection_type == 0 ||
                                    (tableFilters.selection_type == 1 &&
                                        row.is_selected) ||
                                    (tableFilters.selection_type == 2 &&
                                        !row.is_selected))
                            );
                        }
                    );
                },
            });
        };

        onMounted(() => {
            buildDatatable();
        });
        return {
            tableId,
            filters,
            displayFilters,
            toggleFilters,
            filterTable,
        };
    },
    props: {
        resources: Array,
    },
    name: "EHoldingsEBSCOTitlePackagesList",
};
</script>

<style scoped>
#filters fieldset {
    margin: 0;
}
</style>
