<template>
    <div id="title_list_result">
        <div id="filters">
            <a href="#" @click.prevent="toggle_filters($event)"
                ><i class="fa fa-search"></i>
                {{ display_filters ? $t("Hide filters") : $t("Show filters") }}
            </a>
            <fieldset v-if="display_filters">
                <ol>
                    <li>
                        <label>{{ $t("Title") }}:</label>
                        <input
                            type="text"
                            id="publication_title_filter"
                            v-model="filters.publication_title"
                            @keyup.enter="filter_table"
                        />
                    </li>
                    <li>
                        <label>{{ $t("Publication type") }}:</label>
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
                    </li>
                    <li>
                        <label>{{ $t("Selection status") }}:</label>
                        <select
                            id="selection_type_filter"
                            v-model="filters.selection_type"
                        >
                            <option value="0">{{ $t("All") }}</option>
                            <option value="1">{{ $t("Selected") }}</option>
                            <option value="2">{{ $t("Not selected") }}</option>
                        </select>
                    </li>
                </ol>

                <input
                    @click="filter_table"
                    id="filter_table"
                    type="button"
                    :value="$t('Filter')"
                />
            </fieldset>
        </div>
        <table :id="table_id"></table>
    </div>
</template>

<script>

import { inject, createVNode, render } from 'vue'
import { storeToRefs } from "pinia"
import { useDataTable } from "../../composables/datatables"

export default {
    setup() {
        const AVStore = inject('AVStore')
        const { av_title_publication_types } = storeToRefs(AVStore)
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const table_id = "title_list"
        useDataTable(table_id)

        return {
            av_title_publication_types,
            get_lib_from_av,
            map_av_dt_filter,
            table_id,
        }
    },
    data() {
        return {
            filters: {
                publication_title: "",
                publication_type: "",
                selection_type: "",
            },
            display_filters: false,
        }
    },
    methods: {
        show_resource: function (resource_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/ebsco/resources/" + resource_id)
        },
        filter_table: function () {
            $('#' + this.table_id).DataTable().draw()
        },
        toggle_filters: function (e) {
            this.display_filters = !this.display_filters
        },
        build_datatable: function () {
            let show_resource = this.show_resource
            let package_id = this.package_id
            let get_lib_from_av = this.get_lib_from_av
            let map_av_dt_filter = this.map_av_dt_filter
            let filters = this.filters
            let table_id = this.table_id

            window['av_title_publication_types'] = map_av_dt_filter('av_title_publication_types')

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

            $('#' + table_id).kohaTable({
                ajax: {
                    url: "/api/v1/erm/eholdings/ebsco/packages/" + package_id + "/resources",
                },
                ordering: false,
                dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                aLengthMenu: [[10, 20, 50, 100], [10, 20, 50, 100]],
                embed: ['title'],
                autoWidth: false,
                columns: [
                    {
                        title: __("Name"),
                        data: "title.publication_title",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        }
                    },
                    {
                        title: __("Publication type"),
                        data: "title.publication_type",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            return escape_str(get_lib_from_av("av_title_publication_types", row.title.publication_type))
                        }
                    },
                ],
                drawCallback: function (settings) {

                    var api = new $.fn.dataTable.Api(settings)

                    $.each($(this).find("tbody tr td:first-child"), function (index, e) {
                        let tr = $(this).parent()
                        let row = api.row(tr).data()
                        if (!row) return // Happen if the table is empty
                        let n = createVNode("a", {
                            role: "button",
                            href: "/cgi-bin/koha/erm/eholdings/ebsco/resources/" + row.resource_id,
                            onClick: (e) => {
                                e.preventDefault()
                                show_resource(row.resource_id)
                            }
                        },
                            `${row.title.publication_title}`
                        )
                        if (row.is_selected) {
                            n = createVNode('span', {}, [n, " ", createVNode("i", { class: "fa fa-check-square-o", style: { color: "green" }, title: __("Is selected") })])
                        }
                        render(n, e)
                    })
                },
            }, null, 0, additional_filters)
        },
    },
    mounted() {
        this.build_datatable()
    },
    props: {
        package_id: String,
    },
    name: 'EHoldingsEBSCOPackageTitlesList',
}
</script>

<style scoped>
#title_list_result {
    width: 60%;
}
#title_list {
    display: table;
}
#filters {
    margin: 0;
}
</style>
