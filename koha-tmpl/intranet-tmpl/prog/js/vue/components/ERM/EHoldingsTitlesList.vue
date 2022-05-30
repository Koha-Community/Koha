<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else-if="this.titles" id="titles_list">
        <Toolbar />
        <table v-if="this.titles.length" id="title_list"></table>
        <div v-else-if="this.initialized" class="dialog message">
            {{ $t("There are no titles defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./EHoldingsTitlesToolbar.vue"
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { storeToRefs } from "pinia"
import { fetchTitles } from "../../fetch"

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
            titles: [],
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getTitles()
        })
    },
    methods: {
        async getTitles() {
            const titles = await fetchTitles()
            this.titles = titles
            this.initialized = true
        },
        show_title: function (title_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/titles/" + title_id)
        },
        edit_title: function (title_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/titles/edit/" + title_id)
        },
        delete_title: function (title_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/titles/delete/" + title_id)
        },
    },
    updated() {
        let show_title= this.show_title
        let edit_title= this.edit_title
        let delete_title= this.delete_title

        window['vendors'] = this.vendors.map(e => {
            e['_id'] = e['id']
            e['_str'] = e['name']
            return e
        })
        let vendors_map = this.vendors.reduce((map, e) => {
            map[e.id] = e
            return map
        }, {})

        $('#title_list').kohaTable({
            "ajax": {
                "url": eholdings_titles_table_url,
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
                    "data": "me.title_id:me.publication_title",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        // Rendering done in drawCallback
                        return "";
                    }
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
                    "data": "print_identifier:online_identifier",
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
                    let title_id = api.row(index).data().title_id
                    let editButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            edit_title(title_id)
                        }
                    },
                        [createVNode("i", { class: "fa fa-pencil", 'aria-hidden': "true" }), __("Edit")])

                    let deleteButton = createVNode("a", {
                        class: "btn btn-default btn-xs", role: "button", onClick: () => {
                            delete_title(title_id)
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
                            show_title(row.title_id)
                        }
                    },
                        `${row.publication_title} (#${row.title_id})`
                    )
                    render(n, e)
                })
            },
            preDrawCallback: function (settings) {
                var table_id = settings.nTable.id
                $("#" + table_id).find("thead th").eq(1).attr('data-filter', 'vendors')
            }
        }, eholdings_titles_table_settings, 1)
    },
    beforeUnmount() {
        $('#title_list')
            .DataTable()
            .destroy(true)
    },
    components: { Toolbar },
    name: "EHoldingsTitlesList",
}
</script>
