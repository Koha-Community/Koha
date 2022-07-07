<template>
    <div>
        <fieldset>
            {{ $t("Publication title") }}:
            <input
                type="text"
                id="publication_title_filter"
                v-model="filters.publication_title"
                @keyup.enter="filter_table"
            />
            {{ $t("Publication type") }}:
            <select
                id="publication_type_filter"
                v-model="filters.publication_type"
            >
                <option value="">{{ $t("All") }}</option>
                <option
                    v-for="type in av_title_publication_types"
                    :key="type.authorised_values"
                    :value="type.authorised_value"
                >
                    {{ type.lib }}
                </option>
            </select>
            {{ $t("Selection status") }}:
            <select id="selection_type_filter" v-model="filters.selection_type">
                <option value="0">{{ $t("All") }}</option>
                <option value="1">{{ $t("Selected") }}</option>
                <option value="2">{{ $t("Not selected") }}</option>
            </select>
            <input
                @click="filter_table"
                id="filter_table"
                type="button"
                :value="$t('Submit')"
            />
            <span v-if="cannot_search">{{
                $t("Please enter a search term")
            }}</span>
        </fieldset>

        <!-- We need to display the table element to initiate DataTable -->
        <div
            id="title_list_result"
            :style="show_table ? 'display: block' : 'display: none'"
        >
            <div
                v-if="
                    local_count_titles !== undefined &&
                    local_count_titles !== null
                "
            >
                <router-link :to="local_titles_url">
                    {{
                        $t("{count} titles found locally", {
                            count: local_count_titles,
                        })
                    }}</router-link
                >
            </div>
            <div id="title_list_result">
                <table id="title_list"></table>
            </div>
        </div>
    </div>
</template>

<script>
import { createVNode, render } from 'vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"
import { fetchCountLocalTitles } from "./../../fetch"

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
            erm_providers,
        }
    },
    data: function () {
        return {
            titles: [],
            initialized: true,
            filters: {
                publication_title: this.$route.query.publication_title || "",
                publication_type: this.$route.query.publication_type || "",
                selection_type: this.$route.query.selection_type || "",
            },
            cannot_search: false,
            show_table: false,
            local_count_titles: null,
        }
    },
    computed: {
        local_titles_url() { return this.build_url("/cgi-bin/koha/erm/eholdings/local/titles") },
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.build_datatable()
        })
    },
    methods: {
        show_title: function (title_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/ebsco/titles/" + title_id)
        },
        build_url_params: function () {
            return Object.entries(this.filters)
                .map(([k, v]) => v ? k + "=" + v : undefined)
                .filter(e => e !== undefined)
                .join('&')
        },
        build_url: function (base_url) {
            let params = this.build_url_params()
            return base_url + (params.length ? '?' + params : '')
        },
        filter_table: async function () {
            if (this.filters.publication_title.length) {
                this.cannot_search = false
                let new_route = this.build_url("/cgi-bin/koha/erm/eholdings/ebsco/titles")
                this.$router.push(new_route)
                this.show_table = true
                this.local_count_titles = null
                $("#title_list").DataTable().draw()
                if (this.erm_providers.includes('local')) {
                    this.local_count_titles = await fetchCountLocalTitles(this.filters)
                }
            } else {
                this.cannot_search = true
            }
        },
        build_datatable: function () {
            let show_title = this.show_title
            let get_lib_from_av = this.get_lib_from_av
            if (!this.show_table) {
                this.show_table = this.build_url_params().length ? true : false
            }
            let filters = this.filters
            let show_table = this.show_table

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

            let additional_filters = {
                publication_title: function () {
                    return filters.publication_title || ""
                },
                publication_type: function () {
                    return filters.publication_type || ""
                },
                selection_type: function () {
                    return filters.selection_type || ""
                },
            }
            $('#title_list').kohaTable({
                ajax: {
                    url: "/api/v1/erm/eholdings/ebsco/titles",
                },
                embed: ["resources.package"],
                ordering: false,
                dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                aLengthMenu: [[10, 20, 50, 100], [10, 20, 50, 100]],
                deferLoading: true,
                autoWidth: false,
                columns: [
                    {
                        title: __("Title"),
                        data: "me.publication_title",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        }
                    },
                    {
                        title: __("Vendor"),
                        data: "vendor_id",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            return row.vendor_id != undefined ? escape_str(vendors_map[row.vendor_id].name) : ""
                        }
                    },
                    {
                        title: __("Publication type"),
                        data: "publication_type",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            return escape_str(get_lib_from_av("av_title_publication_types", row.publication_type))
                        }
                    },
                    {
                        title: __("Identifier"),
                        data: "print_identifier:online_identifier",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            let print_identifier = row.print_identifier
                            let online_identifier = row.online_identifier
                            return (print_identifier ? escape_str(_("ISBN (Print): %s").format(print_identifier)) : "") +
                                (online_identifier ? escape_str(_("ISBN (Online): %s").format(online_identifier)) : "")
                        }
                    },
                ],
                drawCallback: function (settings) {

                    var api = new $.fn.dataTable.Api(settings)

                    if (!api.rows({ search: 'applied' }).count()) return

                    $.each($(this).find("tbody tr td:first-child"), function (index, e) {
                        let row = api.row(index).data()
                        if (!row) return // Happen if the table is empty
                        let n = createVNode("a", {
                            role: "button",
                            onClick: (e) => {
                                e.preventDefault()
                                show_title(row.title_id)
                            }
                        },
                            `${row.publication_title} (#${row.title_id})`
                        )
                        // TODO? We don't have is_selected at title level
                        //if (row.is_selected) {
                        //    n = createVNode('span', {}, [n, " ", createVNode("i", { class: "fa fa-check-square-o", style: { color: "green" }, title: __("Is selected") })])
                        //}
                        render(n, e)
                    })
                },
            }, eholdings_titles_table_settings, 0, additional_filters)

            if (filters.publication_title.length) {
                this.filter_table()
            }
        },
    },
    beforeUnmount() {
        if ( ! $.fn.DataTable.isDataTable( '#title_list' ) ) {
            $('#title_list')
                .DataTable()
                .destroy(true)
        }
    },
    name: "EHoldingsEBSCOTitlesList",
}
</script>
