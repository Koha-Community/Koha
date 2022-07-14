<template>
    <div id="title_list_result">
        <table :id="table_id"></table>
    </div>
</template>

<script>

import { createVNode, render } from 'vue'
import { useAVStore } from "../../stores/authorised_values"
import { useDataTable } from "../../composables/datatables"

export default {
    setup() {
        const AVStore = useAVStore()
        const { av_title_publication_types } = storeToRefs(AVStore)
        const { get_lib_from_av } = AVStore

        const table_id = "title_list"
        useDataTable(table_id)

        return {
            av_title_publication_types,
            get_lib_from_av,
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
            let package_id = this.package_id
            let get_lib_from_av = this.get_lib_from_av
            let table_id = this.table_id

            window['av_title_publication_types'] = this.av_title_publication_types.map(e => {
                e['_id'] = e['authorised_value']
                e['_str'] = e['lib']
                return e
            })

            $('#' + table_id).kohaTable({
                ajax: {
                    url: "/api/v1/erm/eholdings/local/packages/" + package_id + "/resources",
                },
                embed: ['title'],
                autoWidth: false,
                columns: [
                    {
                        title: __("Name"),
                        data: "title.publication_title",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        }
                    },
                    {
                        title: __("Publication type"),
                        data: "title.publication_type",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(get_lib_from_av("av_title_publication_types", row.title.publication_type))
                        }
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
                            `${row.title.publication_title}`
                        )
                        render(n, e)
                    })
                },
                preDrawCallback: function (settings) {
                    $("#" + table_id).find("thead th").eq(1).attr('data-filter', 'av_title_publication_types')
                }
            }, null, 1)
        },
    },
    mounted() {
        this.build_datatable()
    },
    props: {
        package_id: String,
    },
    name: 'EHoldingsLocalPackageTitlesList',
}
</script>

<style scoped>
#title_list_result {
    width: 60%;
    padding-left: 10rem;
}
#title_list {
    display: table;
}
</style>
