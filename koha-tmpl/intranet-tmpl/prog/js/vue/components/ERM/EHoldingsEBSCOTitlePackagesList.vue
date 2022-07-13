<template>
    <div id="package_list_result">
        <div id="filters">
            <a href="#" @click.prevent="toggle_filters($event)"
                ><i class="fa fa-search"></i>
                {{ display_filters ? $t("Hide filters") : $t("Show filters") }}
            </a>
            <fieldset v-if="display_filters" id="filters">
                <ol>
                    <li>
                        <label>{{ $t("Package name") }}:</label>
                        <input
                            type="text"
                            id="package_name_filter"
                            v-model="this.filters.package_name"
                            @keyup.enter="filter_table"
                        />
                    </li>
                    <li>
                        <label>{{ $t("Selection status") }}:</label>
                        <select
                            id="selection_type_filter"
                            v-model="this.filters.selection_type"
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
        <table id="package_list"></table>
    </div>
</template>

<script>

import { createVNode, render } from 'vue'

export default {
    setup() {
        return {
        }
    },
    data() {
        return {
            filters: {
                package_name: "",
                selection_type: 0,
            },
            display_filters: false,
        }
    },
    methods: {
        show_resource: function (resource_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/ebsco/resources/" + resource_id)
        },
        toggle_filters: function (e) {
            this.display_filters = !this.display_filters
        },
        filter_table: function () {
            $("#package_list").DataTable().draw()
        },
        build_datatable: function () {
            let show_resource = this.show_resource
            let resources = this.resources
            let filters = this.filters

            $.fn.dataTable.ext.search = $.fn.dataTable.ext.search.filter((search) => search.name != 'apply_filter')
            $('#package_list').dataTable($.extend(true, {}, dataTablesDefaults, {
                data: resources,
                embed: ['package.name'],
                ordering: false,
                dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                aLengthMenu: [[10, 20, 50, 100], [10, 20, 50, 100]],
                autoWidth: false,
                columns: [
                    {
                        title: __("Name"),
                        data: "package.name",
                        searchable: false,
                        orderable: false,
                        render: function (data, type, row, meta) {
                            // Rendering done in drawCallback
                            return ""
                        },
                        width: '100%',
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
                            href: "/cgi-bin/koha/erm/eholdings/ebsco/resources/" + row.resource_id,
                            onClick: (e) => {
                                e.preventDefault()
                                show_resource(row.resource_id)
                            }
                        },
                            `${row.package.name}`
                        )
                        if (row.is_selected) {
                            n = createVNode('span', {}, [n, " ", createVNode("i", { class: "fa fa-check-square-o", style: { color: "green" }, title: __("Is selected") })])
                        }
                        render(n, e)
                    })
                },
                initComplete: function () {
                    $.fn.dataTable.ext.search.push(
                        function apply_filter(settings, data, dataIndex, row) {
                            return row.package.name.match(new RegExp(filters.package_name, "i"))
                                && (filters.selection_type == 0
                                    || filters.selection_type == 1 && row.is_selected
                                    || filters.selection_type == 2 && !row.is_selected)
                        }
                    )
                }
            }))
        }
    },
    mounted() {
        this.build_datatable()
    },
    beforeUnmount() {
        if ($.fn.DataTable.isDataTable('#package_list')) {
            $('#package_list')
                .DataTable()
                .destroy(true)
        }
    },
    props: {
        resources: Array,
    },
    name: 'EHoldingsEBSCOTitlePackagesList',
}
</script>

<style scoped>
#package_list_result {
    width: 60%;
    padding-left: 26rem;
}
#package_list {
    display: table;
}
#filters fieldset {
    margin: 0;
}
</style>
