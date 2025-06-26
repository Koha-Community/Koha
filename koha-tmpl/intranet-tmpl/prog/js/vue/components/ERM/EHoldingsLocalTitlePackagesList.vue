<template>
    <div id="package_list_result">
        <table :id="tableId"></table>
    </div>
</template>

<script>
import { createVNode, onMounted, render } from "vue";
import { useDataTable } from "../../composables/datatables";
import { useRouter } from "vue-router";
import { $__ } from "@k/i18n";

export default {
    setup(props) {
        const router = useRouter();
        const tableId = "package_list";
        useDataTable(tableId);

        const showResource = resource_id => {
            router.push({
                name: "EHoldingsLocalResourcesShow",
                params: { resource_id },
            });
        };
        const buildDatatable = () => {
            let show_resource = showResource;
            let appRouter = router;
            let resources = props.resources;
            let table_id = tableId;

            $("#" + table_id).kohaTable({
                data: resources,
                embed: ["package.name"],
                order: [[0, "asc"]],
                columns: [
                    {
                        title: $__("Name"),
                        data: "package.name",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return "";
                        },
                        width: "100%",
                    },
                ],
                drawCallback: function (settings) {
                    var api = new $.fn.dataTable.Api(settings);

                    $.each(
                        $(this).find("tbody tr td:first-child"),
                        function (index, e) {
                            let tr = $(this).parent();
                            let row = api.row(tr).data();
                            if (!row) return; // Happen if the table is empty
                            let { href } = appRouter.resolve({
                                name: "EHoldingsLocalResourcesShow",
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
                            render(n, e);
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
        };
    },
    props: {
        resources: Array,
    },
    name: "EHoldingsLocalTitlePackagesList",
};
</script>
