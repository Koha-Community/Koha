<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else-if="this.eholdings" id="eholdings_list">
        <Toolbar />
        <table v-if="this.eholdings.length" id="eholding_list"></table>
        <div v-else-if="this.initialized" class="dialog message">
            {{ $t("There are no eHoldings defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./EHoldingsToolbar.vue"
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { storeToRefs } from "pinia"
import { fetchEHoldings } from "../../fetch"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        return {
            vendors,
        }
    },
    data: function () {
        return {
            eholdings: [],
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getEHoldings()
        })
    },
    methods: {
        async getEHoldings() {
            const eholdings = await fetchEHoldings()
            this.eholdings = eholdings
            console.log(this.eholdings)
            this.initialized = true
        },
        show_eholding: function (eholding_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/" + eholding_id)
        },
        edit_eholding: function (eholding_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/edit/" + eholding_id)
        },
        delete_eholding: function (eholding_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/delete/" + eholding_id)
        },
    },
    updated() {
        let show_eholding = this.show_eholding
        let edit_eholding = this.edit_eholding
        let delete_eholding = this.delete_eholding

        window['vendors'] = this.vendors.map(e => {
            e['_id'] = e['id']
            e['_str'] = e['name']
            return e
        })
        let vendors_map = this.vendors.reduce((map, e) => {
            map[e.id] = e
            return map
        }, {})

        $('#eholding_list').kohaTable({
            "ajax": {
                "url": eholdings_table_url,
            },
            "order": [[0, "asc"]],
            "columnDefs": [{
                "targets": [1],
                "render": function (data, type, row, meta) {
                    if (type == 'display') {
                        return escape_str(data)
                    }
                    return data
                }
            }],
            "columns": [
                {
                    "title": __("Title"),
                    "data": ["me.eholding_id", "me.publication_title"],
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
                    "title": __("Publication type"),
                    "data": "publication_type",
                    "searchable": true,
                    "orderable": true,
                },
                {
                    "title": __("Identifier"),
                    "data": ["print_identifier", "online_identifier"],
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        let print_identifier = row.print_identifier
                        let online_identifier = row.online_identifier
                        return (print_identifier ? escape_str(_("ISBN (Print): %s").format(print_identifier)) : "") +
                            (online_identifier ? escape_str(_("ISBN (Online): %s").format(online_identifier)) : "")
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
                    let eholding_id = api.row(index).data().eholding_id
                    let editButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            edit_eholding(eholding_id)
                        }
                    },
                        [createVNode("i", { class: "fa fa-pencil", 'aria-hidden': "true" }), __("Edit")])

                    let deleteButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            delete_eholding(eholding_id)
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
                            show_eholding(row.eholding_id)
                        }
                    },
                        `${row.publication_title} (#${row.eholding_id})`
                    )
                    render(n, e)
                })
            },
            preDrawCallback: function (settings) {
                var table_id = settings.nTable.id
                $("#" + table_id).find("thead th").eq(2).attr('data-filter', 'vendors')
            }
        }, eholding_table_settings, 1)
    },
    beforeUnmount() {
        $('#eholding_list')
            .DataTable()
            .destroy(true)
    },
    components: { Toolbar },
    name: "EHoldingsList",
}
</script>
