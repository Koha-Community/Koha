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
                                v-if="manual_form"
                                id="usage_data_provider_name"
                                v-model="usage_data_provider.name"
                                :placeholder="$__('Data provider name')"
                                required
                            />
                            <v-select
                                v-else
                                id="usage_data_provider_name"
                                v-model="selected_provider"
                                label="name"
                                :options="registry_data"
                                @input="getPlatformData($event)"
                                @update:modelValue="setPlatformData($event)"
                                :required="!usage_data_provider.name"
                                :placeholder="
                                    $__(
                                        'Type at least two characters to search'
                                    )
                                "
                            >
                                <template v-if="searching" v-slot:no-options
                                    >{{ $__("Searching...") }}
                                </template>
                                <template v-else v-slot:no-options
                                    >{{ $__("No results found") }}
                                </template>
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="!usage_data_provider.name"
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                            <span class="required">{{ $__("Required") }}</span>
                            <button
                                v-if="
                                    !manual_form &&
                                    !usage_data_provider.erm_usage_data_provider_id
                                "
                                type="button"
                                class="btn btn-default"
                                style="margin-left: 1em"
                                @click="createManualProvider()"
                            >
                                {{ $__("Create manually") }}
                            </button>
                            <button
                                v-if="
                                    manual_form &&
                                    !usage_data_provider.erm_usage_data_provider_id
                                "
                                type="button"
                                style="margin-left: 1em"
                                @click="createFromRegistry()"
                            >
                                {{ $__("Create from registry") }}
                            </button>
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
                                :disabled="!selected_provider && !manual_form"
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
                                :disabled="!selected_provider && !manual_form"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_service_type"
                                >{{ $__("Service type") }}:
                            </label>
                            <input
                                id="usage_data_provider_service_type"
                                v-model="usage_data_provider.service_type"
                                :disabled="!selected_provider && !manual_form"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_service_platform"
                                >{{ $__("Service platform") }}:
                            </label>
                            <input
                                id="usage_data_provider_service_platform"
                                v-model="usage_data_provider.service_platform"
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
                                :options="valid_report_types"
                                multiple
                                :disabled="!selected_provider && !manual_form"
                                :required="
                                    !usage_data_provider.report_types.length
                                "
                            >
                                <template #list-header>
                                    <button
                                        type="button"
                                        @click="selectAll()"
                                        class="list-header-btns"
                                    >
                                        {{ $__("Select all") }}
                                    </button>
                                    <button
                                        class="list-header-btns"
                                        type="button"
                                        @click="unselectAll()"
                                    >
                                        {{ $__("Unselect all") }}
                                    </button>
                                </template>
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
                <legend>{{ $__("SUSHI credentials") }}</legend>
                <fieldset class="rows credentials">
                    <ol class="credentials_form">
                        <li>
                            <label
                                :class="
                                    required_fields.includes('URL')
                                        ? 'required'
                                        : ''
                                "
                                for="usage_data_provider_service_url"
                                >{{ $__("Service URL") }}:
                            </label>
                            <input
                                id="usage_data_provider_service_url"
                                style="min-width: 60%"
                                v-model="usage_data_provider.service_url"
                                :required="required_fields.includes('URL')"
                                :disabled="!selected_provider && !manual_form"
                            />
                            <span
                                class="required"
                                v-if="required_fields.includes('URL')"
                                >{{ $__("Required") }}
                            </span>
                        </li>
                        <li>
                            <label
                                :class="
                                    required_fields.includes('Release')
                                        ? 'required'
                                        : ''
                                "
                                for="usage_data_provider_report_release"
                                >{{ $__("Report release") }}:
                            </label>
                            <input
                                id="usage_data_provider_report_release"
                                style="min-width: 60%"
                                v-model="usage_data_provider.report_release"
                                :required="required_fields.includes('Release')"
                                :disabled="!selected_provider && !manual_form"
                            />
                            <span
                                class="required"
                                v-if="required_fields.includes('Release')"
                                >{{ $__("Required") }}
                            </span>
                        </li>
                        <li>
                            <label
                                :class="
                                    required_fields.includes('Customer')
                                        ? 'required'
                                        : ''
                                "
                                for="usage_data_provider_customer_id"
                                >{{ $__("Customer ID") }}:
                            </label>
                            <input
                                id="usage_data_provider_customer_id"
                                style="min-width: 60%"
                                v-model="usage_data_provider.customer_id"
                                :required="required_fields.includes('Customer')"
                                :disabled="!selected_provider && !manual_form"
                            />
                            <span
                                class="required"
                                v-if="required_fields.includes('Customer')"
                                >{{ $__("Required") }}
                            </span>
                        </li>
                        <li>
                            <label
                                :class="
                                    required_fields.includes('Requestor')
                                        ? 'required'
                                        : ''
                                "
                                for="usage_data_provider_requestor_id"
                                >{{ $__("Requestor ID") }}:
                            </label>
                            <input
                                id="usage_data_provider_requestor_id"
                                style="min-width: 60%"
                                v-model="usage_data_provider.requestor_id"
                                :required="
                                    required_fields.includes('Requestor')
                                "
                                :disabled="!selected_provider && !manual_form"
                            />
                            <span
                                class="required"
                                v-if="required_fields.includes('Requestor')"
                                >{{ $__("Required") }}
                            </span>
                        </li>
                        <li>
                            <label
                                for="usage_data_provider_api_key"
                                :class="
                                    required_fields.includes('API')
                                        ? 'required'
                                        : ''
                                "
                                >{{ $__("API key") }}:
                            </label>
                            <input
                                id="usage_data_provider_api_key"
                                style="min-width: 60%"
                                v-model="usage_data_provider.api_key"
                                :disabled="!selected_provider && !manual_form"
                                :required="required_fields.includes('API')"
                            />
                            <span
                                class="required"
                                v-if="required_fields.includes('API')"
                                >{{ $__("Required") }}
                            </span>
                        </li>
                        <li>
                            <label for="usage_data_provider_requestor_name"
                                >{{ $__("Requestor name") }}:
                            </label>
                            <input
                                id="usage_data_provider_requestor_name"
                                style="min-width: 60%"
                                v-model="usage_data_provider.requestor_name"
                                :disabled="!selected_provider && !manual_form"
                            />
                        </li>
                        <li>
                            <label for="usage_data_provider_requestor_email"
                                >{{ $__("Requestor email") }}:
                            </label>
                            <input
                                id="usage_data_provider_requestor_email"
                                style="min-width: 60%"
                                v-model="usage_data_provider.requestor_email"
                                :disabled="!selected_provider && !manual_form"
                            />
                        </li>
                    </ol>
                    <ol class="credentials_form" v-if="sushi_service">
                        <h3>{{ $__("Credentials information") }}</h3>
                        <li>
                            <label for="customer_id_info"
                                >{{ $__("Customer ID info") }}:
                            </label>
                            <span id="customer_id_info">{{
                                sushi_service.customer_id_info
                                    ? sushi_service.customer_id_info
                                    : $__("No information provided")
                            }}</span>
                        </li>
                        <li>
                            <label for="requestor_id_info"
                                >{{ $__("Requestor ID info") }}:
                            </label>
                            <span id="requestor_id_info">{{
                                sushi_service.requestor_id_info
                                    ? sushi_service.requestor_id_info
                                    : $__("No information provided")
                            }}</span>
                        </li>
                        <li>
                            <label for="api_key_info"
                                >{{ $__("API key info") }}:
                            </label>
                            <span id="api_key_info">{{
                                sushi_service.api_key_info
                                    ? sushi_service.api_key_info
                                    : $__("No information provided")
                            }}</span>
                        </li>
                        <span
                            >{{ $__("Please refer to the ") }}
                            <a href="https://registry.countermetrics.org/">{{
                                $__("COUNTER registry")
                            }}</a>
                            {{ $__("for more information.") }}</span
                        >
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
import ButtonSubmit from "../ButtonSubmit.vue";
import { setMessage, setWarning } from "../../messages";
import { APIClient } from "../../fetch/api-client.js";
import { inject } from "vue";
import { storeToRefs } from "pinia";

export default {
    setup() {
        const ERMStore = inject("ERMStore");
        const { authorisedValues } = storeToRefs(ERMStore);

        return {
            authorisedValues,
        };
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
                { description: this.$__("Active"), value: 1 },
                { description: this.$__("Inactive"), value: 0 },
            ],
            registry_data: [],
            valid_report_types: [...this.authorisedValues.av_report_types],
            selected_provider: null,
            manual_form: false,
            required_fields: [],
            sushi_service: null,
            searching: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.usage_data_provider_id) {
                vm.getDataProvider(to.params.usage_data_provider_id);
            } else {
                vm.initialized = true;
            }
            if (from.params.usage_data_provider_id) {
                vm.previous_route = "data_provider_show";
            } else {
                vm.previous_route = "data_provider_list";
            }
        });
    },
    methods: {
        async getDataProvider(erm_usage_data_provider_id) {
            const client = APIClient.erm;
            client.usage_data_providers.get(erm_usage_data_provider_id).then(
                usage_data_provider => {
                    this.usage_data_provider = usage_data_provider;
                    this.usage_data_provider.report_types =
                        this.formatReportTypes(
                            usage_data_provider.report_types
                        );
                    this.getCounterRegistry(usage_data_provider.name, "edit");
                },
                error => {}
            );
        },
        async getCounterRegistry(query, caller) {
            const client = APIClient.erm;
            client.counter_registry.getAll({ name: query }).then(
                registry_data => {
                    this.registry_data = registry_data;
                    if (caller === "edit" && registry_data.length > 0) {
                        this.selected_provider = registry_data.find(
                            platform =>
                                platform.name === this.usage_data_provider.name
                        );
                        this.valid_report_types =
                            this.valid_report_types.filter(report =>
                                this.selected_provider.reports.some(
                                    r => r.report_id === report.value
                                )
                            );
                    }
                    if (caller === "edit" && registry_data.length === 0) {
                        this.manual_form = true;
                    }
                    this.searching = false;
                    this.initialized = true;
                },
                error => {}
            );
        },
        async getSushiService(url) {
            const client = APIClient.erm;
            client.sushi_service.getAll({ url }).then(
                sushi_service => {
                    const { url, api_key_required, requestor_id_required } =
                        sushi_service;
                    this.usage_data_provider.service_url = url;
                    this.required_fields = ["URL", "Release", "Customer"];
                    api_key_required && this.required_fields.push("API");
                    requestor_id_required &&
                        this.required_fields.push("Requestor");
                    this.sushi_service = sushi_service || {};
                },
                error => {}
            );
        },
        getPlatformData(e) {
            if (e.target.value.length > 1) {
                this.searching = true;
                this.getCounterRegistry(e.target.value, "search");
            }
        },
        async setPlatformData(e) {
            const { sushi_services, reports, name } = e;
            this.valid_report_types = this.valid_report_types.filter(report =>
                reports.some(r => r.report_id === report.value)
            );
            if (this.valid_report_types.length === 0) {
                setWarning(
                    this.$__(
                        "This provider does not currently support any COUNTER 5 reports via SUSHI."
                    )
                );
            }

            this.selected_provider = e;
            this.usage_data_provider.name = name;
            await this.getSushiService(sushi_services[0].url);
            this.usage_data_provider.report_release =
                sushi_services[0].counter_release;
        },
        createManualProvider() {
            this.manual_form = true;
            this.selected_provider = null;
            this.sushi_service = null;
            this.required_fields = [];
        },
        createFromRegistry() {
            this.manual_form = false;
            this.selected_provider = null;
            this.sushi_service = null;
            this.required_fields = [];
            this.usage_data_provider.report_types = [];
        },
        selectAll() {
            this.usage_data_provider.report_types = this.valid_report_types.map(
                report => {
                    return report.value;
                }
            );
        },
        unselectAll() {
            this.usage_data_provider.report_types = [];
        },
        formatReportTypes(reportTypes) {
            const dataType =
                typeof reportTypes === "string" ? "string" : "array";

            if (dataType === "array") {
                let report_types_string = "";
                reportTypes.forEach(item => {
                    report_types_string += item;
                    report_types_string += ";";
                });
                return report_types_string;
            }
            if (dataType === "string") {
                const single_report_types = reportTypes.split(";");
                single_report_types.pop(); // remove trailing "" from array
                return single_report_types;
            }
        },
        onSubmit(e) {
            e.preventDefault();

            let usage_data_provider = JSON.parse(
                JSON.stringify(this.usage_data_provider)
            );
            let erm_usage_data_provider_id =
                usage_data_provider.erm_usage_data_provider_id;
            usage_data_provider.report_types = this.formatReportTypes(
                usage_data_provider.report_types
            );

            delete usage_data_provider.erm_usage_data_provider_id;

            const client = APIClient.erm;
            if (erm_usage_data_provider_id) {
                client.usage_data_providers
                    .update(usage_data_provider, erm_usage_data_provider_id)
                    .then(
                        success => {
                            setMessage(this.$__("Data provider updated"));
                            this.$router.push({
                                name: "UsageStatisticsDataProvidersShow",
                                params: {
                                    usage_data_provider_id:
                                        erm_usage_data_provider_id,
                                },
                            });
                        },
                        error => {}
                    );
            } else {
                client.usage_data_providers.create(usage_data_provider).then(
                    success => {
                        erm_usage_data_provider_id =
                            success.erm_usage_data_provider_id;
                        setMessage(this.$__("Data provider created"));
                        this.$router.push({
                            name: "UsageStatisticsDataProvidersShow",
                            params: {
                                usage_data_provider_id:
                                    erm_usage_data_provider_id,
                            },
                        });
                    },
                    error => {}
                );
            }
        },
    },
    components: {
        ButtonSubmit,
    },
    name: "UsageStatisticsDataProvidersFormAdd",
};
</script>

<style scoped>
.credentials {
    display: flex;
}
.credentials_form {
    width: 50%;
}
.list-header-btns {
    margin: 0.5em 0 0.5em 0.5em;
}
</style>
