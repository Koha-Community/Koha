<template>
    <div>
        <div v-if="!initialized">{{ $__("Loading") }}</div>
        <div v-else id="titles_list">
            <Toolbar :options="this.toolbar_options" />
            <div
                v-if="title_count > 0"
                id="title_list_result"
                class="page-section"
            >
                <KohaTable
                    ref="table"
                    v-bind="tableOptions"
                    @show="doShow"
                    @edit="doEdit"
                    @delete="doDelete"
                ></KohaTable>
            </div>
            <div v-else class="dialog message">
                {{ $__("There are no titles defined") }}
            </div>
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue"
import { inject, ref, reactive } from "vue"
import { storeToRefs } from "pinia"
import { APIClient } from "../../fetch/api-client.js"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const AVStore = inject("AVStore")
        const { av_title_publication_types } = storeToRefs(AVStore)
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const { setConfirmationDialog, setMessage } = inject("mainStore")

        const table = ref()
        const filters = reactive({
            publication_title: "",
            publication_type: "",
        })

        return {
            av_title_publication_types,
            get_lib_from_av,
            map_av_dt_filter,
            escape_str,
            table,
            filters,
            setConfirmationDialog,
            setMessage,
            eholdings_titles_table_settings,
        }
    },
    data: function () {
        this.filters = {
            publication_title: this.$route.query.publication_title || "",
            publication_type: this.$route.query.publication_type || "",
        }
        let filters = this.filters

        return {
            title_count: 0,
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                url: "/api/v1/erm/eholdings/local/titles",
                options: {
                    embed: "resources.package",
                    searchCols: [
                        { search: filters.publication_title },
                        null,
                        { search: filters.publication_type },
                        null,
                    ],
                },
                table_settings: this.eholdings_titles_table_settings,
                add_filters: true,
                filters_options: {
                    2: () =>
                        this.map_av_dt_filter("av_title_publication_types"),
                },
                actions: {
                    0: ["show"],
                    "-1": ["edit", "delete"],
                },
            },
            cannot_search: false,
            toolbar_options: [
                {
                    to: "EHoldingsLocalTitlesFormAdd",
                    button_title: this.$__("New title"),
                },
                {
                    to: "EHoldingsLocalTitlesFormImport",
                    button_title: this.$__("Import from list"),
                },
            ],
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getTitleCount().then(() => (vm.initialized = true))
        })
    },
    methods: {
        async getTitleCount() {
            const client = APIClient.erm
            await client.localTitles.count().then(
                count => {
                    this.title_count = count
                },
                error => {}
            )
        },
        doShow: function ({ title_id }, dt, event) {
            event.preventDefault()
            this.$router.push({
                name: "EHoldingsLocalTitlesShow",
                params: { title_id },
            })
        },
        doEdit: function ({ title_id }, dt, event) {
            this.$router.push({
                name: "EHoldingsLocalTitlesFormAddEdit",
                params: { title_id },
            })
        },
        doDelete: function (title, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this title?"
                    ),
                    message: title.publication_title,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm
                    client.localTitles.delete(title.title_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Local title %s deleted").format(
                                    title.publication_title
                                ),
                                true
                            )
                            dt.draw()
                        },
                        error => {}
                    )
                }
            )
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av
            let escape_str = this.escape_str

            return [
                {
                    title: __("Title"),
                    data: "me.publication_title:me.title_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/eholdings/local/titles/' +
                            row.title_id +
                            '" class="show">' +
                            escape_str(
                                `${row.publication_title} (#${row.title_id})`
                            ) +
                            "</a>"
                        )
                    },
                },
                {
                    title: __("Contributors"),
                    data: "first_author:first_editor",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            escape_str(row.first_author) +
                            (row.first_author && row.first_editor
                                ? "<br/>"
                                : "") +
                            escape_str(row.first_editor)
                        )
                    },
                },
                {
                    title: __("Publication type"),
                    data: "publication_type",
                    searchable: true,
                    orderable: true,
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
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        let print_identifier = row.print_identifier
                        let online_identifier = row.online_identifier
                        return (
                            (print_identifier
                                ? escape_str(
                                      _("ISBN (Print): %s").format(
                                          print_identifier
                                      )
                                  )
                                : "") +
                            (online_identifier
                                ? escape_str(
                                      _("ISBN (Online): %s").format(
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
    components: { Toolbar, KohaTable },
    name: "EHoldingsLocalTitlesList",
}
</script>
