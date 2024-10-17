<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="trains_list">
        <Toolbar>
            <ToolbarButton
                action="add"
                @go-to-add-resource="goToResourceAdd"
                :title="$__('New train')"
            />
        </Toolbar>
        <fieldset v-if="count_trains > 0" class="filters">
            <label>{{ $__("Filter by") }}:</label>
            <input
                type="radio"
                id="all_status_filter"
                v-model="filters.status"
                value=""
            /><label for="all_status_filter">{{ $__("All") }}</label>
            <input
                type="radio"
                id="closed_status_filter"
                v-model="filters.status"
                value="closed"
            /><label for="closed_status_filter">{{ $__("Closed") }}</label>
            <input
                type="radio"
                id="sent_status_filter"
                v-model="filters.status"
                value="sent"
            /><label for="sent_status_filter">{{ $__("Sent") }}</label>
            <input
                type="radio"
                id="received_status_filter"
                v-model="filters.status"
                value="received"
            /><label for="received_status_filter">{{ $__("Received") }}</label>
            <input
                @click="filter_table"
                id="filter_table"
                type="button"
                :value="$__('Filter')"
            />
        </fieldset>
        <div v-if="count_trains > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @show="goToResourceShow"
                @edit="goToResourceEdit"
                @delete="doResourceDelete"
                @addItems="doAddItems"
            ></KohaTable>
        </div>

        <div v-else class="alert alert-info">
            {{ $__("There are no trains defined") }}
        </div>
    </div>
</template>

<script>
import flatPickr from "vue-flatpickr-component";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { inject, ref, reactive } from "vue";
import { APIClient } from "../../fetch/api-client";
import { build_url } from "../../composables/datatables";
import KohaTable from "../KohaTable.vue";
import TrainResource from "./TrainResource.vue";

export default {
    extends: TrainResource,
    setup() {
        const PreservationStore = inject("PreservationStore");
        const { get_lib_from_av, map_av_dt_filter } = PreservationStore;

        const table = ref();
        const filters = reactive({ status: "" });
        return {
            ...TrainResource.setup(),
            get_lib_from_av,
            map_av_dt_filter,
            escape_str,
            table,
            filters,
        };
    },
    data: function () {
        this.filters.status = this.$route.query.status || "";
        return {
            fp_config: flatpickr_defaults,
            count_trains: 0,
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                options: {
                    order: [
                        [1, "desc"],
                        [2, "asc"],
                        [3, "asc"],
                        [4, "asc"],
                    ],
                },
                url: this.table_url,
                add_filters: true,
                actions: {
                    0: ["show"],
                    "-1": [
                        "edit",
                        "delete",
                        {
                            addItems: {
                                text: this.$__("Add items"),
                                icon: "fa fa-plus",
                            },
                        },
                    ],
                },
            },
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getCountTrains();
        });
    },
    computed: {},
    methods: {
        async getCountTrains() {
            const client = APIClient.preservation;
            client.trains.count().then(
                count => {
                    this.count_trains = count;
                    this.initialized = true;
                },
                error => {}
            );
        },
        doAddItems: function (train, dt, event) {
            if (train.closed_on != null) {
                this.setWarning(this.$__("Cannot add items to a closed train"));
            } else {
                this.$router.push({
                    name: "TrainsFormAddItem",
                    params: { train_id: train.train_id },
                });
            }
        },
        table_url() {
            let url = this.getResourceTableUrl();
            let q;
            if (this.filters.status == "closed") {
                q = {
                    "me.closed_on": { "!=": null },
                    "me.sent_on": null,
                    "me.received_on": null,
                };
            } else if (this.filters.status == "sent") {
                q = {
                    "me.closed_on": { "!=": null },
                    "me.sent_on": { "!=": null },
                    "me.received_on": null,
                };
            } else if (this.filters.status == "received") {
                q = {
                    "me.closed_on": { "!=": null },
                    "me.sent_on": { "!=": null },
                    "me.received_on": { "!=": null },
                };
            }
            if (q) {
                url += "?" + new URLSearchParams({ q: JSON.stringify(q) });
            }

            return url;
        },
        filter_table: async function () {
            let new_route = build_url(
                "/cgi-bin/koha/preservation/trains",
                this.filters
            );
            this.$router.push(new_route);
            if (this.$refs.table) {
                this.$refs.table.redraw(this.table_url());
            }
        },
        getTableColumns: function () {
            let escape_str = this.escape_str;
            return [
                {
                    title: __("Name"),
                    data: "me.train_id:me.name",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(`${row.name} (#${row.train_id})`)
                        );
                    },
                },
                {
                    title: __("Created on"),
                    data: "created_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.created_on);
                    },
                },
                {
                    title: __("Closed on"),
                    data: "closed_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.closed_on);
                    },
                },
                {
                    title: __("Sent on"),
                    data: "sent_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.sent_on);
                    },
                },
                {
                    title: __("Received on"),
                    data: "received_on",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return $date(row.received_on);
                    },
                },
            ];
        },
    },
    components: { flatPickr, Toolbar, ToolbarButton, KohaTable },
    name: "TrainsList",
    emits: ["select-train", "close"],
};
</script>

<style scoped>
#train_list {
    display: table;
}
.filters > input[type="radio"] {
    min-width: 0 !important;
}
.filters > input[type="button"] {
    margin-left: 1rem;
}
</style>
