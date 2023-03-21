<template>
    <div id="title_list_result">
        <div id="filters">
            <a href="#" @click.prevent="toggle_filters($event)"
                ><i class="fa fa-search"></i>
                {{
                    display_filters ? $__("Hide filters") : $__("Show filters")
                }}
            </a>
            <fieldset v-if="display_filters">
                <ol>
                    <li>
                        <label>{{ $__("Title") }}:</label>
                        <input
                            type="text"
                            id="publication_title_filter"
                            v-model="filters.publication_title"
                            @keyup.enter="filter_table"
                        />
                    </li>
                    <li>
                        <label>{{ $__("Publication type") }}:</label>
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
                    </li>
                    <li>
                        <label>{{ $__("Selection status") }}:</label>
                        <select
                            id="selection_type_filter"
                            v-model="filters.selection_type"
                        >
                            <option value="0">{{ $__("All") }}</option>
                            <option value="1">{{ $__("Selected") }}</option>
                            <option value="2">{{ $__("Not selected") }}</option>
                        </select>
                    </li>
                </ol>

                <input
                    @click="filter_table"
                    id="filter_table"
                    type="button"
                    :value="$__('Filter')"
                />
            </fieldset>
        </div>
        <KohaTable ref="table" v-bind="tableOptions" @show="doShow"></KohaTable>
    </div>
</template>

<script>
import { inject, ref, reactive } from "vue"
import { storeToRefs } from "pinia"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const AVStore = inject("AVStore")
        const { av_title_publication_types } = storeToRefs(AVStore)
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const table = ref()
        const filters = reactive({
            publication_title: "",
            publication_type: "",
            selection_type: "",
        })

        return {
            av_title_publication_types,
            get_lib_from_av,
            escape_str,
            map_av_dt_filter,
            table,
        }
    },
    data() {
        this.filters = {
            publication_title: this.$route.query.publication_title || "",
            publication_type: this.$route.query.publication_type || "",
            selection_type: this.$route.query.selection_type || "",
        }
        let filters = this.filters
        return {
            tableOptions: {
                columns: this.getTableColumns(),
                url:
                    "/api/v1/erm/eholdings/ebsco/packages/" +
                    this.package_id +
                    "/resources",
                options: {
                    embed: "title",
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
            display_filters: false,
        }
    },
    methods: {
        doShow: function ({ resource_id }, dt, event) {
            event.preventDefault()
            this.$router.push({
                name: "EHoldingsEBSCOResourcesShow",
                params: { resource_id },
            })
        },
        filter_table: function () {
            this.$refs.table.redraw(
                "/api/v1/erm/eholdings/ebsco/packages/" +
                    this.package_id +
                    "/resources"
            )
        },
        toggle_filters: function (e) {
            this.display_filters = !this.display_filters
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av
            let map_av_dt_filter = this.map_av_dt_filter

            return [
                {
                    title: __("Name"),
                    data: "title.publication_title",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        let node =
                            '<a href="/cgi-bin/koha/erm/eholdings/ebsco/resources/' +
                            row.resource_id +
                            '" class="show">' +
                            escape_str(`${row.title.publication_title}`) +
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
                    title: __("Publication type"),
                    data: "title.publication_type",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_title_publication_types",
                                row.title.publication_type
                            )
                        )
                    },
                },
            ]
        },
    },
    props: {
        package_id: String,
    },
    components: { KohaTable },
    name: "EHoldingsEBSCOPackageTitlesList",
}
</script>

<style scoped>
#filters {
    margin: 0;
}
</style>
