<template>
    <div id="package_list_result">
        <div id="filters" v-if="erm_provider != 'manual'">
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
                            @keyup.enter="filter_table"
                        />
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
            display_filters: false,
        }
    },
    inject: ['erm_provider'],
    methods: {
        show_resource: function (resource_id) {
            this.$router.push("/cgi-bin/koha/erm/eholdings/resources/" + resource_id)
        },
        toggle_filters: function (e) {
            this.display_filters = !this.display_filters
        },
        filter_table: function () {
            $("#package_list").DataTable().draw()
        },
    },
    mounted() {
        let show_resource = this.show_resource
        let resources = this.resources

        let additional_filters = {}
        if (erm_provider != 'manual') {
            additional_filters = {
                name: function () {
                    let package_name_search = $("#package_name_filter").val()
                    if (!package_name_search) return ""
                    return package_name_search
                },
                selection_type: function () {
                    let selection_type_search = $("#selection_type_filter").val()
                    if (!selection_type_search) return ""
                    return selection_type_search
                },
            }
        }

        $('#package_list').dataTable($.extend(true, {}, dataTablesDefaults, {
            data: resources,
            ...(erm_provider != 'manual' ? { dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>' } : {}),
            ...(erm_provider != 'manual' ? { lengthMenu: [[10, 20, 50, 100], [10, 20, 50, 100]] } : {}),
            "embed": ['package.name'],
            "columnDefs": [{ "width": "20%", "targets": 0 }
            ],
            autoWidth: false,
            "columns": [
                {
                    "title": __("Name"),
                    "data": "package_name",
                    "searchable": true,
                    "orderable": true,
                    "render": function (data, type, row, meta) {
                        // Rendering done in drawCallback
                        return ""
                    },
                    width: '100%',
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
                        `${row.package.name}`
                    )
                    if (row.is_selected) {
                        n = createVNode('span', {}, [n, " ", createVNode("i", { class: "fa fa-check-square-o", style: { color: "green" }, title: __("Is selected") })])
                    }
                    render(n, e)
                })
            },
        }))

        $('#package_list_result').css('display', 'block')
        $("#package_list").DataTable().columns.adjust().draw()
    },
    beforeUnmount() {
        $('#package_list')
            .DataTable()
            .destroy(true)
    },
    props: {
        resources: Array,
    },
    name: 'EHoldingsTitlePackagesList',
}
</script>

<style scoped>
#package_list_result {
    width: 50%;
    padding-left: 26rem;
}
#package_list {
    display: table;
}
#filters fieldset {
    margin: 0;
}
</style>