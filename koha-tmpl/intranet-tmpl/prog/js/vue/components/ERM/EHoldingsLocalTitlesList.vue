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
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"
import { fetchLocalTitles } from "../../fetch"

export default {
    setup() {
        const AVStore = useAVStore()
        const { av_title_publication_types } = storeToRefs(AVStore)
        const { get_lib_from_av } = AVStore

        return {
            av_title_publication_types,
            get_lib_from_av,
        }
    },
    data: function () {
        return {
            titles: [],
            initialized: false,
            filters: {
                publication_title: this.$route.query.publication_title || "",
                publication_type: this.$route.query.publication_type || "",
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
                autoWidth: false,
                searchCols: [
                    { search: filters.publication_title },
                    null,
                    { search: filters.publication_type },
                    null,
                ],
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
                        title: __("Contributors"),
                        data: "first_author:first_editor",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(row.first_author) + (row.first_author && row.first_editor ? "<br/>" : "") + escape_str(row.first_editor)
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
                    $("#" + table_id).find("thead th").eq(2).attr('data-filter', 'av_title_publication_types')
                }
            }, eholdings_titles_table_settings, 1)
        },
    },
    beforeUnmount() {
        if ($.fn.DataTable.isDataTable('#title_list')) {
            $('#title_list')
                .DataTable()
                .destroy(true)
        }
    },
    components: { Toolbar },
    name: "EHoldingsLocalTitlesList",
}
</script>
