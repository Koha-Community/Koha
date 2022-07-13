<template>
    <div id="package_list_result">
        <table id="package_list"></table>
    </div>
</template>

<script>

import { createVNode, render } from 'vue'

export default {
    setup() {
        return {
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

            $('#package_list').dataTable($.extend(true, {}, dataTablesDefaults, {
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
                        let row = api.row(index).data()
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
    beforeUnmount() {
        if ($.fn.DataTable.isDataTable('#package_list')) {
            $('#package_list')
                .DataTable()
                .destroy(true)
        }
    },
    props: {
        resources: Array,
    },
    name: 'EHoldingsLocalTitlePackagesList',
}
</script>

<style scoped>
#package_list_result {
    width: 60%;
    padding-left: 26rem;
}
#package_list {
    display: table;
}
</style>
