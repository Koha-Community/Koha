<template>
    <div id="title_list_result">
        <div id="filters" v-if="erm_provider != 'manual'">
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
                            @keyup.enter="filter_table"
                        />
                    </li>
                    <li>
                        <label>{{ $t("Publication type") }}:</label>
                        <select id="publication_type_filter">
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
                        <select id="selection_type_filter">
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
        <table id="title_list"></table>
    </div>
</template>

<script>

import { createVNode, render } from 'vue'
import { useAVStore } from "../../stores/authorised_values"
import { storeToRefs } from "pinia"

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
    data() {
        return {
            display_filters: false,
        }
    },
    inject: ['erm_provider'],
    methods: {
        show_resource: function (resource_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/resources/" + resource_id)
        },
        filter_table: function () {
            $("#title_list").DataTable().draw()
        },
        toggle_filters: function (e) {
            this.display_filters = !this.display_filters
        },
    },
    mounted() {
        let show_resource = this.show_resource
        let package_id = this.package_id
        let get_lib_from_av = this.get_lib_from_av

        window['av_title_publication_types'] = this.av_title_publication_types.map(e => {
            e['_id'] = e['authorised_value']
            e['_str'] = e['lib']
            return e
        })

        let additional_filters = {}
        if (erm_provider != 'manual') {
            additional_filters = {
                publication_title: function () {
                    let publication_title_search = $("#publication_title_filter").val()
                    if (!publication_title_search) return ""
                    return publication_title_search
                },
                publication_type: function () {
                    let content_type_search = $("#publication_type_filter").val()
                    if (!content_type_search) return ""
                    return content_type_search
                },
                selection_type: function () {
                    let selection_type_search = $("#selection_type_filter").val()
                    if (!selection_type_search) return ""
                    return selection_type_search
                },
            }
        }

        $('#title_list').kohaTable({
            "ajax": {
                "url": "/api/v1/erm/eholdings/packages/" + package_id + "/resources",
            },
            ...(erm_provider != 'manual' ? { ordering: false } : {}),
            ...(erm_provider != 'manual' ? { dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>' } : {}),
            ...(erm_provider != 'manual' ? { lengthMenu: [[10, 20, 50, 100], [10, 20, 50, 100]] } : {}),
            "embed": ['title.publication_title'],
            autoWidth: false,
            "columns": [
                {
                    "title": __("Name"),
                    "data": "title.publication_title",
                    "searchable": (erm_provider == 'manual') ? 1 : 0,
                    "orderable": (erm_provider == 'manul') ? 1 : 0,
                    "render": function (data, type, row, meta) {
                        // Rendering done in drawCallback
                        return ""
                    }
                },
                {
                    "title": __("Publication type"),
                    "data": "title.publication_type",
                    "searchable": (erm_provider == 'manual') ? 1 : 0,
                    "orderable": (erm_provider == 'manul') ? 1 : 0,
                    "render": function (data, type, row, meta) {
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
                        href: "/cgi-bin/koha/erm/eholdings/resources/" + row.resource_id,
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
            ...(erm_provider == 'manual' ? {
                preDrawCallback: function (settings) {
                    var table_id = settings.nTable.id
                    if (erm_provider == 'manual') {
                        $("#" + table_id).find("thead th").eq(1).attr('data-filter', 'av_title_publication_types')
                    }
                }
            } : {}),
        }, null, erm_provider == 'manual' ? 1 : 0, additional_filters)
    },
    beforeUnmount() {
        $('#title_list')
            .DataTable()
            .destroy(true)
    },
    props: {
        package_id: String,
    },
    name: 'EHoldingsPackageTitlesList',
}
</script>

<style scoped>
#title_list_result {
    width: 50%;
    padding-left: 10rem;
}
#title_list {
    display: table;
}
#filters {
    margin: 0;
}
</style>