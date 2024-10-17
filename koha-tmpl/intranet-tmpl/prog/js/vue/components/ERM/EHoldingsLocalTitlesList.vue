<template>
    <div>
        <div v-if="!initialized">{{ $__("Loading") }}</div>
        <div v-else id="titles_list">
            <Toolbar>
                <ToolbarButton
                    action="add"
                    @go-to-add-resource="goToResourceAdd"
                    :title="$__('New title')"
                />
                <ToolbarButton
                    :to="{ name: 'EHoldingsLocalTitlesFormImport' }"
                    icon="plus"
                    :title="$__('Import from list')"
                />
                <ToolbarButton
                    :to="{ name: 'EHoldingsLocalTitlesKBARTImport' }"
                    icon="plus"
                    :title="$__('Import from KBART file')"
                />
            </Toolbar>
            <div
                v-if="title_count > 0"
                id="title_list_result"
                class="page-section"
            >
                <KohaTable
                    ref="table"
                    v-bind="tableOptions"
                    @show="goToResourceShow"
                    @edit="goToResourceEdit"
                    @delete="doResourceDelete"
                ></KohaTable>
            </div>
            <div v-else class="alert alert-info">
                {{ $__("There are no titles defined") }}
            </div>
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { inject, ref, reactive } from "vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";
import KohaTable from "../KohaTable.vue";
import EHoldingsLocalTitleResource from "./EHoldingsLocalTitleResource.vue";

export default {
    extends: EHoldingsLocalTitleResource,
    setup() {
        const ERMStore = inject("ERMStore");
        const { get_lib_from_av, map_av_dt_filter } = ERMStore;


        const table = ref();
        const filters = reactive({
            publication_title: "",
            publication_type: "",
        });

        return {
            ...EHoldingsLocalTitleResource.setup(),
            get_lib_from_av,
            map_av_dt_filter,
            escape_str,
            table,
            filters,
            eholdings_titles_table_settings,
        };
    },
    data: function () {
        this.filters = {
            publication_title: this.$route.query.publication_title || "",
            publication_type: this.$route.query.publication_type || "",
        };
        let filters = this.filters;

        return {
            title_count: 0,
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                url: this.getResourceTableUrl(),
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
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getTitleCount().then(() => (vm.initialized = true));
        });
    },
    methods: {
        async getTitleCount() {
            const client = APIClient.erm;
            await client.localTitles.count().then(
                count => {
                    this.title_count = count;
                },
                error => {}
            );
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av;
            let escape_str = this.escape_str;

            return [
                {
                    title: __("Title"),
                    data: "me.publication_title:me.title_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(
                                `${row.publication_title} (#${row.title_id})`
                            ) +
                            "</a>"
                        );
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
                        );
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
                        );
                    },
                },
                {
                    title: __("Identifier"),
                    data: "print_identifier:online_identifier",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        let print_identifier = row.print_identifier;
                        let online_identifier = row.online_identifier;
                        return [
                            print_identifier
                                ? escape_str(
                                      __("ISBN (Print): %s").format(
                                          print_identifier
                                      )
                                  )
                                : "",
                            online_identifier
                                ? escape_str(
                                      __("ISBN (Online): %s").format(
                                          online_identifier
                                      )
                                  )
                                : "",
                        ].join("<br/>");
                    },
                },
            ];
        },
    },
    components: { Toolbar, ToolbarButton, KohaTable },
    name: "EHoldingsLocalTitlesList",
};
</script>
