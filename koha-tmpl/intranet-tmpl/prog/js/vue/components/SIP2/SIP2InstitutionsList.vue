<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="sip2_institutions_list">
        <Toolbar>
            <ToolbarButton
                action="add"
                @go-to-add-resource="goToResourceAdd"
                :title="$__('New institution')"
            />
        </Toolbar>
        <div v-if="institutions_count > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @show="goToResourceShow"
                @edit="goToResourceEdit"
                @delete="doResourceDelete"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{ $__("There are no institutions defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { APIClient } from "../../fetch/api-client.js";
import { ref } from "vue";
import KohaTable from "../KohaTable.vue";
import SIP2InstitutionResource from "./SIP2InstitutionResource.vue";

export default {
    extends: SIP2InstitutionResource,
    setup() {
        const table = ref();

        return {
            ...SIP2InstitutionResource.setup(),
            table,
            institutions_table_settings,
        };
    },
    data: function () {
        return {
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                url: () => this.table_url(),
                table_settings: this.institutions_table_settings,
                actions: {
                    0: ["show"],
                    "-1": this.embedded
                        ? [
                              {
                                  select: {
                                      text: this.$__("Select"),
                                      icon: "fa fa-check",
                                  },
                              },
                          ]
                        : ["edit", "delete"],
                },
            },
            before_route_entered: false,
            building_table: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getInstitutionsCount().then(() => (vm.initialized = true));
        });
    },
    methods: {
        async getInstitutionsCount() {
            const client = APIClient.sip2;
            await client.institutions.count().then(
                count => {
                    this.institutions_count = count;
                },
                error => {}
            );
        },
        getTableColumns: function () {
            return [
                {
                    title: __("Name"),
                    data: "name:sip_institution_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a role="button" class="show">' +
                            escape_str(
                                `${row.name} (#${row.sip_institution_id})`
                            ) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Name"),
                    data: "name",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Implementation"),
                    data: "implementation",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Checkin"),
                    data: "checkin",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(row.checkin ? __("Yes") : __("No"));
                    },
                },
                {
                    title: __("Checkout"),
                    data: "checkout",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(row.checkout ? __("Yes") : __("No"));
                    },
                },
                {
                    title: __("Renewal"),
                    data: "renewal",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(row.renewal ? __("Yes") : __("No"));
                    },
                },
                {
                    title: __("Retries"),
                    data: "retries",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Status update"),
                    data: "status_update",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            row.status_update ? __("Yes") : __("No")
                        );
                    },
                },
                {
                    title: __("Timeout"),
                    data: "timeout",
                    searchable: true,
                    orderable: true,
                },
            ];
        },
        table_url: function () {
            return "/api/v1/sip2/institutions";
        },
    },
    components: { Toolbar, ToolbarButton, KohaTable },
    name: "SIP2InstitutionsList",
};
</script>
