<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else-if="this.packages" id="packages_list">
        <Toolbar />
        <table v-if="this.packages.length" id="package_list"></table>
        <div v-else-if="this.initialized" class="dialog message">
            {{ $t("There are no packages defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./EHoldingsPackagesToolbar.vue"
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"
import { fetchPackages } from "../../fetch"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = useAVStore()
        const { av_package_types, av_package_content_types } = storeToRefs(AVStore)

        return {
            vendors,
            av_package_types,
            av_package_content_types,
        }
    },
    data: function () {
        return {
            packages: [],
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getPackages()
        })
    },
    methods: {
        async getPackages() {
            const packages = await fetchPackages()
            this.packages = packages
            this.initialized = true
        },
        show_package: function (package_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/packages/" + package_id)
        },
        edit_package: function (package_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/packages/edit/" + package_id)
        },
        delete_package: function (package_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/packages/delete/" + package_id)
        },
    },
    updated() {
        let show_package = this.show_package
        let edit_package = this.edit_package
        let delete_package = this.delete_package
        window['vendors'] = this.vendors.map(e => {
            e['_id'] = e['id']
            e['_str'] = e['name']
            return e
        })
        let vendors_map = this.vendors.reduce((map, e) => {
            map[e.id] = e
            return map
        }, {})
        window['av_package_types'] = this.av_package_types.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let av_package_types_map = this.av_package_types.reduce((map, e) => {
            map[e.authorised_value] = e
            return map
        }, {})
        window['av_package_content_types'] = this.av_package_content_types.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })
        let av_package_content_types_map = this.av_package_content_types.reduce((map, e) => {
            map[e.authorised_value] = e
            return map
        }, {})

        $('#package_list').kohaTable({
            "ajax": {
                "url": eholdings_packages_table_url,
            },
            "order": [[0, "asc"]],
            "columnDefs": [{
                "targets": [0],
                "render": function (data, type, row, meta) {
                    if (type == 'display') {
                        return escape_str(data)
                    }
                    return data
                }
            }],
            "columns": [
                {
                    "title": __("Name"),
                    "data": ["me.package_id", "me.name"],
                    "searchable": true,
                    "orderable": true,
                    // Rendering done in drawCallback
                },
                {
                    "title": __("Vendor"),
                    "data": "vendor_id",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return row.vendor_id != undefined ? escape_str(vendors_map[row.vendor_id].name) : ""
                    }
                },
                {
                    "title": __("Type"),
                    "data": "package_type",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return row.package_type != undefined && row.package_type != "" ? escape_str(av_package_types_map[row.package_type].lib) : ""
                    }
                },
                {
                    "title": __("Content type"),
                    "data": "package_type",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return row.content_type != undefined && row.content_type != "" ? escape_str(av_package_content_types_map[row.content_type].lib) : ""
                    }
                },
                {
                    "title": __("Created on"),
                    "data": "created_on",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        return $date(row.created_on)
                    }
                },
                {
                    "title": __("Actions"),
                    "data": function (row, type, val, meta) {
                        return '<div class="actions"></div>'
                    },
                    "className": "actions noExport",
                    "searchable": false,
                    "orderable": false
                }
            ],
            drawCallback: function (settings) {

                var api = new $.fn.dataTable.Api(settings)

                $.each($(this).find("td .actions"), function (index, e) {
                    let package_id = api.row(index).data().package_id
                    let editButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            edit_package(package_id)
                        }
                    },
                        [createVNode("i", { class: "fa fa-pencil", 'aria-hidden': "true" }), __("Edit")])

                    let deleteButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            delete_package(package_id)
                        }
                    },
                        [createVNode("i", { class: "fa fa-trash", 'aria-hidden': "true" }), __("Delete")])

                    let n = createVNode('span', {}, [editButton, " ", deleteButton])
                    render(n, e)
                })

                $.each($(this).find("tbody tr td:first-child"), function (index, e) {
                    let row = api.row(index).data()
                    if (!row) return // Happen if the table is empty
                    let n = createVNode("a", {
                        role: "button",
                        onClick: () => {
                            show_package(row.package_id)
                        }
                    },
                       `${row.name} (#${row.package_id})`
                    )
                    render(n, e)
                })
            },
            preDrawCallback: function (settings) {
                var table_id = settings.nTable.id
                $("#" + table_id).find("thead th").eq(1).attr('data-filter', 'vendors')
                $("#" + table_id).find("thead th").eq(2).attr('data-filter', 'av_package_types')
                $("#" + table_id).find("thead th").eq(3).attr('data-filter', 'av_package_content_types')
            }

        }, eholdings_packages_table_settings, 1)
    },
    beforeUnmount() {
        $('#package_list')
            .DataTable()
            .destroy(true)
    },
    components: { Toolbar },
    name: "EHoldingsPackagesList",
}
</script>
