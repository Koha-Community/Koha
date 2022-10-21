<template>
    <div id="package_list_result">
        <table :id="table_id"></table>
    </div>
</template>

<script>

import { createVNode, render } from 'vue'
import { useDataTable } from "../../composables/datatables"

export default {
    setup() {
        const table_id = "package_list"
        useDataTable(table_id)

        return {
            table_id,
        }
    },
    data() {
        return {
        }
    },
    methods: {
        show_resource: function (resource_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/local/resources/" + resource_id)
        },
        build_datatable: function () {
            let show_resource = this.show_resource
            let resources = this.resources
            let table_id = this.table_id

            $('#' + table_id).dataTable($.extend(true, {}, dataTablesDefaults, {
                data: resources,
                embed: ['package.name'],
                order: [[0, "asc"]],
                autoWidth: false,
                columns: [
                    {
                        title: __("Name"),
                        data: "package.name",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        },
                        width: '100%',
                    },
                ],
                drawCallback: function (settings) {

                    var api = new $.fn.dataTable.Api(settings)

                    $.each($(this).find("tbody tr td:first-child"), function (index, e) {
                        let tr = $(this).parent()
                        let row = api.row(tr).data()
                        if (!row) return // Happen if the table is empty
                        let n = createVNode("a", {
                            role: "button",
                            href: "/cgi-bin/koha/erm/eholdings/local/resources/" + row.resource_id,
                            onClick: (e) => {
                                e.preventDefault()
                                show_resource(row.resource_id)
                            }
                        },
                            `${row.package.name}`
                        )
                        render(n, e)
                    })
                },
            }))
        },
    },
    mounted() {
        this.build_datatable()
    },
    props: {
        resources: Array,
    },
    name: 'EHoldingsLocalTitlePackagesList',
}
</script>

<style scoped>
#package_list {
    display: table;
}
</style>
