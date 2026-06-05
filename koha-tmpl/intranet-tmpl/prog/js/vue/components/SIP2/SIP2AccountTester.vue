<template>
    <div v-if="account" id="sip2_account_tester">
        <h1>
            {{
                $__("Test SIP2 messages for account %s").format(
                    account.login_id
                )
            }}
        </h1>

        <p>
            {{
                $__(
                    "Build a SIP2 request below and see the response this account would generate. Nothing is saved: the message is run inside a transaction that is always rolled back, so even a checkout or checkin leaves the database untouched."
                )
            }}
        </p>

        <div class="row">
            <div class="col-md-6">
                <form @submit.prevent="runTest">
                    <fieldset class="rows">
                        <legend>{{ $__("Message") }}</legend>
                        <ol>
                            <li>
                                <label for="message">{{
                                    $__("Message type")
                                }}</label>
                                <select id="message" v-model="form.message">
                                    <option
                                        v-for="option in messageOptions"
                                        :key="option.value"
                                        :value="option.value"
                                    >
                                        {{ option.label }}
                                    </option>
                                </select>
                            </li>
                            <li v-if="needsPatron">
                                <label for="patron_id">{{
                                    $__("Patron barcode")
                                }}</label>
                                <input
                                    id="patron_id"
                                    v-model="form.patron_id"
                                    type="text"
                                />
                            </li>
                            <li v-if="needsItem">
                                <label for="item_id">{{
                                    $__("Item barcode")
                                }}</label>
                                <input
                                    id="item_id"
                                    v-model="form.item_id"
                                    type="text"
                                />
                            </li>
                            <li v-if="needsPatron">
                                <label for="patron_password">{{
                                    $__("Patron password")
                                }}</label>
                                <input
                                    id="patron_password"
                                    v-model="form.patron_password"
                                    type="text"
                                />
                            </li>
                        </ol>
                    </fieldset>

                    <fieldset class="rows">
                        <legend>{{ $__("Request message") }}</legend>
                        <ol>
                            <li>
                                <label for="raw_request">{{
                                    $__("Raw request")
                                }}</label>
                                <textarea
                                    id="raw_request"
                                    v-model="rawRequest"
                                    rows="3"
                                    class="sip-message"
                                    @input="rawEdited = true"
                                ></textarea>
                            </li>
                            <li v-if="rawEdited">
                                <span class="hint"
                                    >{{
                                        $__(
                                            "You have edited the request by hand. The form fields above no longer update it."
                                        )
                                    }}
                                    <a href="#" @click.prevent="resetRequest">{{
                                        $__("Reset to the generated request")
                                    }}</a></span
                                >
                            </li>
                        </ol>
                    </fieldset>

                    <fieldset class="action">
                        <input
                            type="submit"
                            class="btn btn-primary"
                            :value="$__('Run test')"
                            :disabled="running"
                        />
                        <router-link
                            :to="{
                                name: 'SIP2AccountsShow',
                                params: {
                                    sip_account_id: account.sip_account_id,
                                },
                            }"
                            class="cancel"
                            >{{ $__("Back to account") }}</router-link
                        >
                    </fieldset>
                </form>
            </div>

            <div class="col-md-6">
                <fieldset class="rows" v-if="error">
                    <legend>{{ $__("Error") }}</legend>
                    <p class="error">{{ error }}</p>
                </fieldset>

                <fieldset class="rows" v-if="result">
                    <legend>{{ $__("Response") }}</legend>
                    <ol>
                        <li>
                            <span class="label">{{ $__("Raw response") }}</span>
                            <pre class="sip-message">{{ result.response }}</pre>
                        </li>
                        <li v-if="result.fixed">
                            <span class="label">{{ $__("Fixed fields") }}</span>
                            <pre class="sip-message">{{ result.fixed }}</pre>
                        </li>
                    </ol>

                    <table v-if="result.fields.length" class="sip-fields">
                        <thead>
                            <tr>
                                <th>{{ $__("Field") }}</th>
                                <th>{{ $__("Value") }}</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="(field, i) in result.fields"
                                :key="`field-${i}`"
                            >
                                <td>{{ fieldLabel(field.field) }}</td>
                                <td>{{ field.value }}</td>
                            </tr>
                        </tbody>
                    </table>
                </fieldset>
            </div>
        </div>
    </div>
</template>

<script>
import { computed, reactive, ref, watch } from "vue";
import { useRoute } from "vue-router";
import { APIClient } from "../../fetch/api-client.js";
import { getSIPFields } from "../../composables/sip2-fields.js";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "SIP2AccountTester",
    setup() {
        const route = useRoute();
        const sip_account_id = route.params.sip_account_id;

        const account = ref(null);
        const result = ref(null);
        const error = ref(null);
        const running = ref(false);

        const form = reactive({
            message: "patron_information",
            patron_id: "",
            item_id: "",
            patron_password: "",
        });

        const messageOptions = [
            { value: "patron_status", label: $__("Patron status") },
            { value: "patron_information", label: $__("Patron information") },
            { value: "item_information", label: $__("Item information") },
            { value: "checkout", label: $__("Checkout") },
            { value: "checkin", label: $__("Check-in") },
        ];

        const needsPatron = computed(() =>
            ["patron_status", "patron_information", "checkout"].includes(
                form.message
            )
        );
        const needsItem = computed(() =>
            ["item_information", "checkout", "checkin"].includes(form.message)
        );

        // A code => "AA - Patron identifier" lookup for the response breakdown.
        const fieldLabels = Object.fromEntries(
            getSIPFields().map(field => [field.value, field.description])
        );
        const fieldLabel = code => fieldLabels[code] || code;

        // Mirrors C4::SIP::Sip::timestamp: YYYYMMDD, four spaces for the zone,
        // then HHMMSS.
        const sipTimestamp = () => {
            const now = new Date();
            const pad = n => String(n).padStart(2, "0");
            return (
                now.getFullYear() +
                pad(now.getMonth() + 1) +
                pad(now.getDate()) +
                "    " +
                pad(now.getHours()) +
                pad(now.getMinutes()) +
                pad(now.getSeconds())
            );
        };

        // Builds a single variable length field. An optional field with no
        // value is omitted entirely, matching Koha::SIP2::MessageTester.
        const sipField = (id, value, optional) => {
            if (optional && !value) return "";
            return id + (value ?? "") + "|";
        };

        // Builds the raw request string for the chosen message, the same way
        // Koha::SIP2::MessageTester::_build_request does on the backend.
        const buildRequest = () => {
            const institution_id = account.value?.institution?.name ?? "";
            const date = sipTimestamp();
            const patron_id = form.patron_id || "";
            const item_id = form.item_id || "";
            const patron_password = form.patron_password || "";
            const language = "001";

            switch (form.message) {
                case "patron_status":
                    return (
                        "23" +
                        language +
                        date +
                        sipField("AO", institution_id) +
                        sipField("AA", patron_id) +
                        sipField("AC", "") +
                        sipField("AD", patron_password, true)
                    );
                case "patron_information":
                    return (
                        "63" +
                        language +
                        date +
                        "          " +
                        sipField("AO", institution_id) +
                        sipField("AA", patron_id) +
                        sipField("AC", "") +
                        sipField("AD", patron_password, true)
                    );
                case "item_information":
                    return (
                        "17" +
                        date +
                        sipField("AO", institution_id) +
                        sipField("AB", item_id) +
                        sipField("AC", "")
                    );
                case "checkout":
                    return (
                        "11" +
                        "N" +
                        "N" +
                        date +
                        date +
                        sipField("AO", institution_id) +
                        sipField("AA", patron_id) +
                        sipField("AB", item_id) +
                        sipField("AC", "") +
                        sipField("AD", patron_password, true)
                    );
                case "checkin":
                    return (
                        "09" +
                        "N" +
                        date +
                        date +
                        sipField("AP", institution_id) +
                        sipField("AO", institution_id) +
                        sipField("AB", item_id) +
                        sipField("AC", "")
                    );
                default:
                    return "";
            }
        };

        const generatedRequest = computed(() => buildRequest());

        const rawRequest = ref("");
        const rawEdited = ref(false);

        // Keep the editable raw request in sync with the form until the
        // librarian starts editing it by hand.
        watch(
            generatedRequest,
            value => {
                if (!rawEdited.value) rawRequest.value = value;
            },
            { immediate: true }
        );

        const resetRequest = () => {
            rawEdited.value = false;
            rawRequest.value = generatedRequest.value;
        };

        const client = APIClient.sip2.accounts;

        client
            .get(sip_account_id)
            .then(fetched => {
                account.value = fetched;
                if (!rawEdited.value) rawRequest.value = generatedRequest.value;
            })
            .catch(e => {
                error.value = e.toString();
            });

        const runTest = async () => {
            running.value = true;
            error.value = null;
            result.value = null;

            try {
                result.value = await client.testMessage(sip_account_id, {
                    request: rawRequest.value,
                });
            } catch (e) {
                error.value = e?.message || e.toString();
            } finally {
                running.value = false;
            }
        };

        return {
            account,
            form,
            messageOptions,
            needsPatron,
            needsItem,
            rawRequest,
            rawEdited,
            resetRequest,
            runTest,
            running,
            result,
            error,
            fieldLabel,
        };
    },
};
</script>

<style scoped>
.sip-message {
    font-family: monospace;
    white-space: pre-wrap;
    word-break: break-all;
    width: 100%;
}

table.sip-fields {
    width: 100%;
    margin-top: 1em;
}

p.error {
    color: #c00;
}
</style>
