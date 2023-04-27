<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="data_providers_add">
        <h2 v-if="usage_data_provider.erm_usage_data_provider_id">
            {{
                $__("Edit usage data provider #%s").format(
                    usage_data_provider.erm_usage_data_provider_id
                )
            }}
        </h2>
        <h2 v-else>{{ $__("New usage data provider") }}</h2>
        <div class="page-section">
            <form @submit="onSubmit($event)">
                <!-- <div class="page-section"> This is on other components such as AgreementsFormAdd.vue and just makes it look messy - what purpose is it serving?-->
                <legend>{{ $__("Data provider") }}</legend>
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label
                                class="required"
                                for="usage_data_provider_name"
                                >{{ $__("Data provider name") }}:</label
                            >
                            <input
                                id="usage_data_provider_name"
                                v-model="usage_data_provider.name"
                                :placeholder="$__('Data provider name')"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="usage_data_provider_description"
                                >{{ $__("Description") }}:
                            </label>
                            <textarea
                                id="usage_data_provider_description"
                                v-model="usage_data_provider.description"
                                :placeholder="$__('Description')"
                                rows="10"
                                cols="50"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_status"
                                >{{ $__("Harvester status") }}:</label
                            >
                            <v-select
                                id="harvester_status"
                                v-model="usage_data_provider.active"
                                label="description"
                                :reduce="status => status.value"
                                :options="statuses"
                            />
                        </li>
                        <!-- <li>
                            <label for="usage_data_provider_method"
                                >{{ $__("Method") }}:
                            </label>
                            <input
                                id="usage_data_provider_method"
                                v-model="usage_data_provider.method"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_aggregator"
                                >{{ $__("Aggregator") }}:
                            </label>
                            <input
                                id="usage_data_provider_aggregator"
                                v-model="usage_data_provider.aggregator"
                            />
                        </li> -->
                        <li>
                            <label for="usage_data_provider_service_type"
                                >{{ $__("Service type") }}:
                            </label>
                            <input
                                id="usage_data_provider_service_type"
                                v-model="usage_data_provider.service_type"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_begin_date"
                                >{{ $__("Harvest start date") }}:
                            </label>
                            <flat-pickr
                                id="usage_data_provider_begin_date"
                                v-model="usage_data_provider.begin_date"
                                :config="fp_config"
                                data-date_to="usage_data_provider_end_date"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_end_date"
                                >{{ $__("Harvest end date") }}:
                            </label>
                            <flat-pickr
                                id="usage_data_provider_end_date"
                                v-model="usage_data_provider.end_date"
                                :config="fp_config"
                            />
                        </li>
                        <li>
                            <label
                                class="required"
                                for="usage_data_provider_report_types"
                                >{{ $__("Report types") }}:
                            </label>
                            <v-select
                                id="report_type"
                                v-model="usage_data_provider.report_types"
                                label="description"
                                :reduce="av => av.value"
                                :options="av_report_types"
                                multiple
                                :required="
                                    !usage_data_provider.report_types.length
                                "
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="
                                            !usage_data_provider.report_types
                                                .length
                                        "
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                    </ol>
                </fieldset>
                <legend>{{ $__("Sushi credentials") }}</legend>
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label
                                class="required"
                                for="usage_data_provider_service_url"
                                >{{ $__("Service URL") }}:
                            </label>
                            <input
                                id="usage_data_provider_service_url"
                                v-model="usage_data_provider.service_url"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label
                                class="required"
                                for="usage_data_provider_report_release"
                                >{{ $__("Report release") }}:
                            </label>
                            <input
                                id="usage_data_provider_report_release"
                                v-model="usage_data_provider.report_release"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label
                                class="required"
                                for="usage_data_provider_customer_id"
                                >{{ $__("Customer Id") }}:
                            </label>
                            <input
                                id="usage_data_provider_customer_id"
                                v-model="usage_data_provider.customer_id"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label
                                class="required"
                                for="usage_data_provider_requestor_id"
                                >{{ $__("Requestor Id") }}:
                            </label>
                            <input
                                id="usage_data_provider_requestor_id"
                                v-model="usage_data_provider.requestor_id"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="usage_data_provider_api_key"
                                >{{ $__("API key") }}:
                            </label>
                            <input
                                id="usage_data_provider_api_key"
                                v-model="usage_data_provider.api_key"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_requestor_name"
                                >{{ $__("Requestor name") }}:
                            </label>
                            <input
                                id="usage_data_provider_requestor_name"
                                v-model="usage_data_provider.requestor_name"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_requestor_email"
                                >{{ $__("Requestor email") }}:
                            </label>
                            <input
                                id="usage_data_provider_requestor_email"
                                v-model="usage_data_provider.requestor_email"
                            />
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <ButtonSubmit />
                    <router-link
                        v-if="previous_route === 'data_provider_show'"
                        :to="{ name: 'UsageStatisticsDataProvidersShow' }"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                    <router-link
                        v-else
                        :to="{ name: 'UsageStatisticsDataProvidersList' }"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue"
import { setMessage, setError, setWarning } from "../../messages"
import { APIClient } from "../../fetch/api-client.js"
import { inject } from "vue"
import { storeToRefs } from "pinia"
import flatPickr from "vue-flatpickr-component"

export default {
    setup() {
        const AVStore = inject("AVStore")
        const { av_report_types } = storeToRefs(AVStore)

        return {
            av_report_types,
        }
    },
    data() {
        return {
            usage_data_provider: {
                erm_usage_data_provider_id: null,
                name: "",
                description: "",
                active: 1,
                method: "",
                aggregator: "",
                service_type: "",
                service_url: "",
                report_release: "",
                begin_date: null,
                end_date: null,
                customer_id: "",
                requestor_id: "",
                api_key: "",
                requestor_name: "",
                requestor_email: "",
                report_types: [],
            },
            initialized: false,
            previous_route: "",
            statuses: [
                { description: "Active", value: 1 },
                { description: "Inactive", value: 0 },
            ],
            fp_config: flatpickr_defaults,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.usage_data_provider_id) {
                vm.getDataProvider(to.params.usage_data_provider_id)
            } else {
                vm.initialized = true
            }
            if (from.params.usage_data_provider_id) {
                vm.previous_route = "data_provider_show"
            } else {
                vm.previous_route = "data_provider_list"
            }
        })
    },
    methods: {
        async getDataProvider(erm_usage_data_provider_id) {
            const client = APIClient.erm
            client.usage_data_providers.get(erm_usage_data_provider_id).then(
                usage_data_provider => {
                    this.usage_data_provider = usage_data_provider
                    this.usage_data_provider.report_types =
                        this.formatReportTypes(usage_data_provider.report_types)
                    this.initialized = true
                },
                error => {}
            )
        },
        formatReportTypes(reportTypes) {
            const dataType =
                typeof reportTypes === "string" ? "string" : "array"

            if (dataType === "array") {
                let report_types_string = ""
                reportTypes.forEach(item => {
                    report_types_string += item
                    report_types_string += ";"
                })
                return report_types_string
            }
            if (dataType === "string") {
                const single_report_types = reportTypes.split(";")
                single_report_types.pop() // remove trailing "" from array
                return single_report_types
            }
        },
        onSubmit(e) {
            e.preventDefault()

            let usage_data_provider = JSON.parse(
                JSON.stringify(this.usage_data_provider)
            )
            let erm_usage_data_provider_id =
                usage_data_provider.erm_usage_data_provider_id
            usage_data_provider.report_types = this.formatReportTypes(
                usage_data_provider.report_types
            )

            delete usage_data_provider.erm_usage_data_provider_id

            const client = APIClient.erm
            if (erm_usage_data_provider_id) {
                client.usage_data_providers
                    .update(usage_data_provider, erm_usage_data_provider_id)
                    .then(
                        success => {
                            setMessage(this.$__("Data provider updated"))
                            this.$router.push({
                                name: "UsageStatisticsDataProvidersShow",
                                params: {
                                    usage_data_provider_id:
                                        erm_usage_data_provider_id,
                                },
                            })
                        },
                        error => {}
                    )
            } else {
                client.usage_data_providers.create(usage_data_provider).then(
                    success => {
                        erm_usage_data_provider_id =
                            success.erm_usage_data_provider_id
                        setMessage(this.$__("Data provider created"))
                        this.$router.push({
                            name: "UsageStatisticsDataProvidersShow",
                            params: {
                                usage_data_provider_id:
                                    erm_usage_data_provider_id,
                            },
                        })
                    },
                    error => {}
                )
            }
        },
    },
    components: {
        ButtonSubmit,
        flatPickr,
    },
    name: "UsageStatisticsDataProvidersFormAdd",
}
</script>
