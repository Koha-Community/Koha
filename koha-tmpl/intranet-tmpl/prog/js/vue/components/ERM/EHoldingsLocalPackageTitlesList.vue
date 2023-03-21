<template>
    <div id="title_list_result">
        <KohaTable ref="table" v-bind="tableOptions" @show="doShow"></KohaTable>
    </div>
</template>

<script>
import { inject, ref } from "vue"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const AVStore = inject("AVStore")
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const table = ref()
        return {
            get_lib_from_av,
            map_av_dt_filter,
            escape_str,
            table,
        }
    },
    data() {
        return {
            tableOptions: {
                columns: this.getTableColumns(),
                url:
                    "/api/v1/erm/eholdings/local/packages/" +
                    this.package_id +
                    "/resources",
                options: { embed: "title" },
                add_filters: true,
                filters_options: {
                    1: () =>
                        this.map_av_dt_filter("av_title_publication_types"),
                },
                actions: {
                    0: ["show"],
                },
            },
        }
    },
    methods: {
        doShow: function ({ resource_id }, dt, event) {
            event.preventDefault()
            this.$router.push({
                name: "EHoldingsLocalResourcesShow",
                params: { resource_id },
            })
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av
            let escape_str = this.escape_str

            return [
                {
                    title: __("Name"),
                    data: "title.publication_title",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/eholdings/local/resources/' +
                            row.resource_id +
                            '" class="show">' +
                            escape_str(row.title.publication_title) +
                            "</a>"
                        )
                    },
                },
                {
                    title: __("Publication type"),
                    data: "title.publication_type",
                    searchable: true,
                    orderable: true,
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
    name: "EHoldingsLocalPackageTitlesList",
}
</script>
