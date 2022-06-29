<template>
    <div>
        <div v-if="!this.initialized">{{ $t("Loading") }}</div>
        <div v-else-if="this.titles" id="titles_list">
            <Toolbar />
            <div v-if="this.titles.length" id="title_list_result">
                <table v-if="this.titles.length" id="title_list"></table>
            </div>
            <div v-else-if="this.initialized" class="dialog message">
                {{ $t("There are no titles defined") }}
            </div>
        </div>
    </div>
</template>

<script>
import Toolbar from "./EHoldingsLocalTitlesToolbar.vue"
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"
import { fetchLocalTitles } from "../../fetch"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = useAVStore()
        const { av_title_publication_types } = storeToRefs(AVStore)
        const { get_lib_from_av } = AVStore

        return {
            vendors,
            av_title_publication_types,
            get_lib_from_av,
        }
    },
    data: function () {
        return {
            titles: [],
            initialized: false,
            filters: {
                publication_title: this.$route.query.q || "",
            },
            cannot_search: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getTitles().then(() => vm.build_datatable())
        })
    },
    methods: {
        async getTitles() {
            const titles = await fetchLocalTitles()
            this.titles = titles
            this.initialized = true
        },
        show_title: function (title_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/local/titles/" + title_id)
        },
        edit_title: function (title_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/local/titles/edit/" + title_id)
        },
        delete_title: function (title_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/local/titles/delete/" + title_id)
        },
        build_datatable: function () {
            let show_title = this.show_title
            let edit_title = this.edit_title
            let delete_title = this.delete_title
            let get_lib_from_av = this.get_lib_from_av
            let filters = this.filters

            window['vendors'] = this.vendors.map(e => {
                e['_id'] = e['id']
                e['_str'] = e['name']
                return e
            })
            let vendors_map = this.vendors.reduce((map, e) => {
                map[e.id] = e
                return map
            }, {})
            window['av_title_publication_types'] = this.av_title_publication_types.map(e => {
                e['_id'] = e['authorised_value']
                e['_str'] = e['lib']
                return e
            })

            $('#title_list').kohaTable({
                ajax: {
                    url: "/api/v1/erm/eholdings/local/titles",
                },
                embed: ["resources.package"],
                order: [[0, "asc"]],
                search: { search: filters.publication_title },
                autoWidth: false,
                columns: [
                    {
                        title: __("Title"),
                        data: "me.publication_title",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        }
                    },
                    {
                        title: __("Vendor"),
                        data: "vendor_id",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return row.vendor_id != undefined ? escape_str(vendors_map[row.vendor_id].name) : ""
                        }
                    },
                    {
                        title: __("Publication type"),
                        data: "publication_type",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(get_lib_from_av("av_title_publication_types", row.publication_type))
                        }
                    },
                    {
                        title: __("Identifier"),
                        data: "print_identifier:online_identifier",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            let print_identifier = row.print_identifier
                            let online_identifier = row.online_identifier
                            return (print_identifier ? escape_str(_("ISBN (Print): %s").format(print_identifier)) : "") +
                                (online_identifier ? escape_str(_("ISBN (Online): %s").format(online_identifier)) : "")
                        }
                    },
                    {
                        title: __("Actions"),
                        data: function (row, type, val, meta) {
                            return '<div class="actions"></div>'
                        },
                        className: "actions noExport",
                        searchable: false,
                        orderable: false
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
                            href: "/cgi-bin/koha/erm/eholdings/local/titles/" + row.title_id,
                            onClick: (e) => {
                                e.preventDefault()
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
    },
    components: { Toolbar },
    name: "EHoldingsLocalTitlesList",
}
</script>
