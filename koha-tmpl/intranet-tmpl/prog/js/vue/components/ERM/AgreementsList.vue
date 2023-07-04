<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="agreements_list">
        <Toolbar v-if="!embedded" :options="this.toolbar_options" />
        <fieldset v-if="agreement_count > 0" class="filters">
            <label for="expired_filter">{{ $__("Filter by expired") }}:</label>
            <input
                type="checkbox"
                id="expired_filter"
                v-model="filters.by_expired"
                @keyup.enter="filter_table"
            />
            {{ $__("on") }}
            <flat-pickr
                id="max_expiration_date_filter"
                v-model="filters.max_expiration_date"
                :config="fp_config"
                :disabled="!filters.by_expired"
            />

            <label for="by_mine_filter">{{ $__("Show mine only") }}:</label>
            <input
                type="checkbox"
                id="by_mine_filter"
                v-model="filters.by_mine"
                @keyup.enter="filter_table"
            />

            <input
                @click="filter_table"
                id="filter_table"
                type="button"
                :value="$__('Filter')"
            />
        </fieldset>
        <div v-if="agreement_count > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @show="doShow"
                @edit="doEdit"
                @delete="doDelete"
                @select="doSelect"
            ></KohaTable>
        </div>
        <div v-else class="dialog message">
            {{ $__("There are no agreements defined") }}
        </div>
    </div>
</template>

<script>
import flatPickr from "vue-flatpickr-component"
import Toolbar from "../Toolbar.vue"
import { inject, ref, reactive } from "vue"
import { APIClient } from "../../fetch/api-client.js"
import { storeToRefs } from "pinia"
import { build_url } from "../../composables/datatables"
import KohaTable from "../KohaTable.vue"

export default {
    setup() {
        const vendorStore = inject("vendorStore")
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = inject("AVStore")
        const { get_lib_from_av, map_av_dt_filter } = AVStore

        const { setConfirmationDialog, setMessage } = inject("mainStore")

        const table = ref()

        const filters = reactive({
            by_expired: false,
            max_expiration_date: "",
            by_mine: false,
        })
        return {
            vendors,
            get_lib_from_av,
            map_av_dt_filter,
            logged_in_user,
            table,
            setConfirmationDialog,
            setMessage,
            escape_str,
            agreement_table_settings,
            filters,
        }
    },
    data: function () {
        this.filters.by_expired =
            this.$route.query.by_expired === "true" || false
        this.filters.by_mine = this.$route.query.by_mine || false
        this.filters.max_expiration_date =
            this.$route.query.max_expiration_date || ""

        let filters = this.filters

        let logged_in_user = this.logged_in_user
        return {
            fp_config: flatpickr_defaults,
            agreement_count: 0,
            initialized: false,
            tableOptions: {
                columns: this.getTableColumns(),
                options: { embed: "user_roles,vendor" },
                url: () => this.table_url(),
                table_settings: this.agreement_table_settings,
                add_filters: true,
                filters_options: {
                    1: () =>
                        this.vendors.map(e => {
                            e["_id"] = e["id"]
                            e["_str"] = e["name"]
                            return e
                        }),
                    3: () => this.map_av_dt_filter("av_agreement_statuses"),
                    4: () =>
                        this.map_av_dt_filter("av_agreement_closure_reasons"),
                    5: [
                        { _id: 0, _str: _("No") },
                        { _id: 1, _str: _("Yes") },
                    ],
                    6: () =>
                        this.map_av_dt_filter(
                            "av_agreement_renewal_priorities"
                        ),
                },
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
                default_filters: {
                    "user_roles.user_id": function () {
                        return filters.by_mine
                            ? logged_in_user.borrowernumber
                            : ""
                    },
                },
            },
            before_route_entered: false,
            building_table: false,
            toolbar_options: [
                {
                    to: "AgreementsFormAdd",
                    button_title: this.$__("New agreement"),
                },
            ],
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getAgreementCount().then(() => (vm.initialized = true))
        })
    },
    methods: {
        async getAgreementCount() {
            const client = APIClient.erm
            await client.agreements.count().then(
                count => {
                    this.agreement_count = count
                },
                error => {}
            )
        },
        doShow: function ({ agreement_id }, dt, event) {
            event.preventDefault()
            this.$router.push({
                name: "AgreementsShow",
                params: { agreement_id },
            })
        },
        doEdit: function ({ agreement_id }, dt, event) {
            this.$router.push({
                name: "AgreementsFormAddEdit",
                params: { agreement_id },
            })
        },
        doDelete: function (agreement, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this agreement?"
                    ),
                    message: agreement.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm
                    client.agreements.delete(agreement.agreement_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Agreement %s deleted").format(
                                    agreement.name
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
        doSelect: function (agreement, dt, event) {
            this.$emit("select-agreement", agreement.agreement_id)
            this.$emit("close")
        },
        get_today_date: function () {
            return new Date().toISOString().substring(0, 10)
        },
        table_url: function () {
            let url = "/api/v1/erm/agreements"
            if (this.filters.by_expired)
                url +=
                    "?max_expiration_date=" + this.filters.max_expiration_date
            return url
        },
        filter_table: async function () {
            if (!this.embedded) {
                if (
                    this.filters.by_expired &&
                    !this.filters.max_expiration_date
                ) {
                    this.filters.max_expiration_date = this.get_today_date()
                }
                if (!this.filters.by_expired) {
                    this.filters.max_expiration_date = ""
                }
                let { href } = this.$router.resolve({ name: "AgreementsList" })
                let new_route = build_url(href, this.filters)
                this.$router.push(new_route)
            }
            this.$refs.table.redraw(this.table_url())
        },
        getTableColumns: function () {
            let get_lib_from_av = this.get_lib_from_av
            let escape_str = this.escape_str

            return [
                {
                    title: __("Name"),
                    data: "me.name:me.agreement_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a href="/cgi-bin/koha/erm/agreements/' +
                            row.agreement_id +
                            '" class="show">' +
                            escape_str(`${row.name} (#${row.agreement_id})`) +
                            "</a>"
                        )
                    },
                },
                {
                    title: __("Vendor"),
                    data: "vendor_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return row.vendor_id != undefined
                            ? '<a href="/cgi-bin/koha/acqui/supplier.pl?booksellerid=' +
                                  row.vendor_id +
                                  '">' +
                                  escape_str(row.vendor.name) +
                                  "</a>"
                            : ""
                    },
                },
                {
                    title: __("Description"),
                    data: "description",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Status"),
                    data: "status",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av("av_agreement_statuses", row.status)
                        )
                    },
                },
                {
                    title: __("Closure reason"),
                    data: "closure_reason",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_agreement_closure_reasons",
                                row.closure_reason
                            )
                        )
                    },
                },
                {
                    title: __("Is perpetual"),
                    data: "is_perpetual",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(row.is_perpetual ? _("Yes") : _("No"))
                    },
                },
                {
                    title: __("Renewal priority"),
                    data: "renewal_priority",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_agreement_renewal_priorities",
                                row.renewal_priority
                            )
                        )
                    },
                },
            ]
        },
    },
    mounted() {
        if (this.embedded) {
            this.getAgreementCount().then(() => (this.initialized = true))
        }
    },
    watch: {
        "filters.by_expired": function (newVal, oldVal) {
            if (newVal) {
                this.filters.max_expiration_date = this.get_today_date()
            } else {
                this.filters.max_expiration_date = ""
            }
        },
    },
    components: { flatPickr, Toolbar, KohaTable },
    props: {
        embedded: {
            type: Boolean,
            default: false,
        },
    },
    name: "AgreementsList",
    emits: ["select-agreement", "close"],
}
</script>

<style scoped>
.filters > label[for="by_mine_filter"],
.filters > input[type="checkbox"],
.filters > input[type="button"] {
    margin-left: 1rem;
}
</style>
