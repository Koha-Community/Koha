<template>
    <div>
        <fieldset>
            {{ $__("Publication title") }}:
            <input
                type="text"
                id="publication_title_filter"
                v-model="filters.publication_title"
                @keyup.enter="filter_table"
            />
            {{ $__("Publication type") }}:
            <select
                id="publication_type_filter"
                v-model="filters.publication_type"
            >
                <option value="">{{ $__("All") }}</option>
                <option
                    v-for="type in av_title_publication_types"
                    :key="type.value"
                    :value="type.value"
                >
                    {{ type.description }}
                </option>
            </select>
            {{ $__("Selection status") }}:
            <select id="selection_type_filter" v-model="filters.selection_type">
                <option value="0">{{ $__("All") }}</option>
                <option value="1">{{ $__("Selected") }}</option>
                <option value="2">{{ $__("Not selected") }}</option>
            </select>
            <input
                @click="filter_table"
                id="filter_table"
                type="button"
                :value="$__('Submit')"
            />
            <span v-if="cannot_search">{{
                $__("Please enter a search term")
            }}</span>
        </fieldset>

        <!-- We need to display the table element to initiate DataTable -->
        <div
            id="title_list_result"
            :style="show_table ? 'display: block' : 'display: none'"
        >
            <div
                v-if="
                    local_title_count !== undefined &&
                    local_title_count !== null
                "
            >
                <router-link :to="local_titles_url">
                    {{
                        $__("%s titles found locally").format(local_title_count)
                    }}</router-link
                >
            </div>
            <div id="title_list_result" class="page-section">
                <KohaTable
                    v-if="show_table"
                    ref="table"
                    v-bind="tableOptions"
                    @show="doShow"
                ></KohaTable>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref, reactive } from "vue"
import { storeToRefs } from "pinia"
import { APIClient } from "../../fetch/api-client.js"
import { build_url_params, build_url } from "../../composables/datatables"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const vendorStore = inject("vendorStore")
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = inject("AVStore")
        const { av_title_publication_types } = storeToRefs(AVStore)
        const { get_lib_from_av } = AVStore

        const ERMStore = inject("ERMStore")
        const { sysprefs } = ERMStore

        const table = ref()
        const filters = reactive({
            publication_title: "",
            publication_type: "",
            selection_type: "",
        })

        return {
            vendors,
            av_title_publication_types,
            get_lib_from_av,
            escape_str,
            sysprefs,
            table,
        }
    },
    data: function () {
        this.filters = {
            publication_title: this.$route.query.publication_title || "",
            publication_type: this.$route.query.publication_type || "",
            selection_type: this.$route.query.selection_type || "",
        }
        let filters = this.filters

        return {
            titles: [],
            initialized: true,
            tableOptions: {
                columns: this.getTableColumns(),
                url: "/api/v1/erm/eholdings/ebsco/titles",
                options: {
                    ordering: false,
                    dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                    aLengthMenu: [
                        [10, 20, 50, 100],
                        [10, 20, 50, 100],
                    ],
                },
                filters_options: {
                    1: () =>
                        this.map_av_dt_filter("av_title_publication_types"),
                },
                actions: { 0: ["show"] },
                default_filters: {
                    publication_title: function () {
                        return filters.publication_title || ""
                    },
                    publication_type: function () {
                        return filters.publication_type || ""
                    },
                    selection_type: function () {
                        return filters.selection_type || ""
                    },
                },
            },
            cannot_search: false,
            show_table: build_url_params(filters).length ? true : false,
            local_title_count: null,
        }
    },
    computed: {
        local_titles_url() {
            let { href } = this.$router.resolve({
                name: "EHoldingsLocalTitlesList",
            })
            return build_url(href, this.filters)
        },
    },
    methods: {
        doShow: function ({ title_id }, dt, event) {
            event.preventDefault()
            this.$router.push({
                name: "EHoldingsEBSCOTitlesShow",
                params: { title_id },
            })
        },
        filter_table: async function () {
            if (this.filters.publication_title.length) {
                this.cannot_search = false
                let { href } = this.$router.resolve({
                    name: "EHoldingsEBSCOTitlesList",
                })
                let new_route = build_url(href, this.filters)
                this.$router.push(new_route)
                this.show_table = true
                this.local_title_count = null

                if (this.$refs.table) {
                    this.$refs.table.redraw(
                        "/api/v1/erm/eholdings/ebsco/titles"
                    )
                }
                if (this.sysprefs.ERMProviders.includes("local")) {
                    const client = APIClient.erm

                    const q = this.filters
                        ? {
                              ...(this.filters.publication_title
                                  ? {
                                        "me.publication_title": {
                                            like:
                                                "%" +
                                                this.filters.publication_title +
                                                "%",
                                        },
                                    }
                                  : {}),
                              ...(this.filters.publication_type
                                  ? {
                                        "me.publication_type":
                                            this.filters.publication_type,
                                    }
                                  : {}),
                          }
                        : undefined

                    client.localTitles.count(q).then(
                        count => (this.local_title_count = count),
                        error => {}
                    )
                }
            } else {
                this.cannot_search = true
            }
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av
            let escape_str = this.escape_str
            return [
                {
                    title: __("Title"),
                    data: "me.publication_title",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        let node =
                            '<a href="/cgi-bin/koha/erm/eholdings/ebsco/titles/' +
                            row.title_id +
                            '" class="show">' +
                            escape_str(
                                `${row.publication_title} (#${row.title_id})`
                            ) +
                            "</a>"
                        if (row.is_selected) {
                            node +=
                                " " +
                                '<i class="fa fa-check-square-o" style="color: green; float: right;" title="' +
                                __("Is selected") +
                                '" />'
                        }
                        return node
                    },
                },
                {
                    title: __("Publisher name"),
                    data: "me.publisher_name",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return escape_str(row.publisher_name)
                    },
                },
                {
                    title: __("Publication type"),
                    data: "publication_type",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_title_publication_types",
                                row.publication_type
                            )
                        )
                    },
                },
                {
                    title: __("Identifier"),
                    data: "print_identifier:online_identifier",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        let print_identifier = row.print_identifier
                        let online_identifier = row.online_identifier
                        return (
                            (print_identifier
                                ? escape_str(
                                      __("ISBN (Print): %s").format(
                                          print_identifier
                                      )
                                  )
                                : "") +
                            (online_identifier
                                ? escape_str(
                                      __("ISBN (Online): %s").format(
                                          online_identifier
                                      )
                                  )
                                : "")
                        )
                    },
                },
            ]
        },
    },
    components: { KohaTable },
    name: "EHoldingsEBSCOTitlesList",
}
</script>
