<template>
    <div id="sip2_account_tester">
        <div v-if="!account">
            <p v-if="error" class="error" role="alert">{{ error }}</p>
            <p v-else>{{ $__("Loading...") }}</p>
        </div>
        <template v-else>
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
                        "Build a SIP2 request below and see the response this account would generate. The message is run inside a transaction that is always rolled back, so database changes, even from a checkout or checkin, are undone. Plugin hooks still run. Every test is logged."
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
                                    <FormElement
                                        :resource="form"
                                        :attr="attrs.message"
                                    />
                                </li>
                                <li v-if="needsPatron">
                                    <FormElement
                                        :resource="form"
                                        :attr="attrs.patron_id"
                                    />
                                </li>
                                <li v-if="needsItem">
                                    <FormElement
                                        :resource="form"
                                        :attr="attrs.item_id"
                                    />
                                </li>
                                <li v-if="needsPatron">
                                    <FormElement
                                        :resource="form"
                                        :attr="attrs.patron_password"
                                    />
                                </li>
                                <li v-if="needsSummary">
                                    <FormElement
                                        :resource="form"
                                        :attr="attrs.summary"
                                    />
                                </li>
                            </ol>
                            <p v-if="hasDelimiter" class="error" role="alert">
                                {{
                                    $__(
                                        "The | character cannot be used in a barcode."
                                    )
                                }}
                            </p>
                        </fieldset>

                        <fieldset class="rows">
                            <legend>{{ $__("Request message") }}</legend>
                            <ol>
                                <li class="stacked">
                                    <label for="raw_request"
                                        >{{ $__("Raw request") }}:</label
                                    >
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
                                        <a
                                            href="#"
                                            @click.prevent="resetRequest"
                                            >{{
                                                $__(
                                                    "Reset to the generated request"
                                                )
                                            }}</a
                                        ></span
                                    >
                                </li>
                            </ol>
                        </fieldset>

                        <fieldset class="action">
                            <input
                                type="submit"
                                class="btn btn-primary"
                                :value="$__('Run test')"
                                :disabled="running || hasDelimiter"
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

                <div class="col-md-6" aria-live="polite">
                    <fieldset v-if="error" class="rows">
                        <legend>{{ $__("Error") }}</legend>
                        <p class="error" role="alert">{{ error }}</p>
                    </fieldset>

                    <fieldset v-if="result" class="rows">
                        <legend>{{ $__("Response") }}</legend>
                        <ol>
                            <li class="stacked">
                                <span class="label">{{
                                    $__("Raw response")
                                }}</span>
                                <pre class="sip-message">{{
                                    result.response
                                }}</pre>
                            </li>
                            <li v-if="result.fixed" class="stacked">
                                <span class="label">{{
                                    $__("Fixed fields")
                                }}</span>
                                <pre class="sip-message">{{
                                    result.fixed
                                }}</pre>
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
        </template>
    </div>
</template>

<script>
import { computed, reactive, ref, watch } from "vue";
import { useRoute } from "vue-router";
import { APIClient } from "../../fetch/api-client.js";
import FormElement from "../FormElement.vue";
import { getSIPFields } from "../../composables/sip2-fields.js";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "SIP2AccountTester",
    components: { FormElement },
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
            summary: "",
        });

        const messageOptions = [
            { value: "patron_status", description: $__("Patron status") },
            {
                value: "patron_information",
                description: $__("Patron information"),
            },
            { value: "item_information", description: $__("Item information") },
            { value: "checkout", description: $__("Checkout") },
            { value: "checkin", description: $__("Check-in") },
        ];

        // A delimiter in a value would add fields to the generated request
        const hasDelimiter = computed(() =>
            [form.patron_id, form.item_id].some(value => value?.includes("|"))
        );

        // The message of an error without the "Error: " the http client adds
        const errorMessage = e =>
            (e?.message || String(e)).replace(/^Error: /, "");

        // The detail a patron information request can ask for. The order is the
        // order of the positions of the summary field of the request, the server
        // reads the first Y only.
        const summaryOptions = [
            { value: "", description: $__("None") },
            { value: "hold_items", description: $__("Hold items") },
            { value: "overdue_items", description: $__("Overdue items") },
            { value: "charged_items", description: $__("Charged items") },
            { value: "fine_items", description: $__("Fine items") },
            { value: "recall_items", description: $__("Recall items") },
            {
                value: "unavailable_holds",
                description: $__("Unavailable holds"),
            },
        ];

        // The ten character summary field: spaces, or a Y at the position of the
        // detail that is asked for
        const sipSummary = () => {
            const position = summaryOptions.findIndex(
                option => option.value && option.value === form.summary
            );
            return Array.from({ length: 10 }, (_, i) =>
                i === position - 1 ? "Y" : " "
            ).join("");
        };

        const needsSummary = computed(
            () => form.message === "patron_information"
        );

        const needsPatron = computed(() =>
            ["patron_status", "patron_information", "checkout"].includes(
                form.message
            )
        );
        const needsItem = computed(() =>
            ["item_information", "checkout", "checkin"].includes(form.message)
        );

        const passwordOptions = [
            { value: "", description: $__("Not sent") },
            { value: "GOOD", description: $__("Valid password") },
            { value: "BAD", description: $__("Invalid password") },
        ];

        const attrs = {
            message: {
                name: "message",
                type: "select",
                label: $__("Message type"),
                options: messageOptions,
                requiredKey: "value",
                selectLabel: "description",
                required: true,
            },
            patron_id: {
                name: "patron_id",
                type: "text",
                label: $__("Patron barcode"),
            },
            item_id: {
                name: "item_id",
                type: "text",
                label: $__("Item barcode"),
            },
            patron_password: {
                name: "patron_password",
                type: "select",
                label: $__("Patron password"),
                options: passwordOptions,
                requiredKey: "value",
                selectLabel: "description",
                toolTip: $__(
                    "The patron's password is never checked, this chooses the outcome."
                ),
            },
            summary: {
                name: "summary",
                type: "select",
                label: $__("Detail"),
                options: summaryOptions,
                requiredKey: "value",
                selectLabel: "description",
                toolTip: $__("The list of items to include in the response."),
            },
        };

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
                        sipSummary() +
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
            rawRequest.value = buildRequest();
        };

        const client = APIClient.sip2.accounts;

        client
            .get(sip_account_id)
            .then(fetched => {
                account.value = fetched;
                if (!rawEdited.value) rawRequest.value = generatedRequest.value;
            })
            .catch(e => {
                error.value = errorMessage(e);
            });

        const runTest = async () => {
            running.value = true;
            error.value = null;
            result.value = null;

            try {
                const response = await client.testMessage(sip_account_id, {
                    request: rawRequest.value,
                });

                // The http client hands back a response that is not JSON as it
                // is, even when it is an error page from a proxy
                if (!Array.isArray(response?.fields)) {
                    throw new Error($__("Unexpected response from the server"));
                }
                result.value = response;
            } catch (e) {
                error.value = errorMessage(e);
            } finally {
                running.value = false;
            }
        };

        return {
            account,
            form,
            attrs,
            needsPatron,
            needsItem,
            needsSummary,
            hasDelimiter,
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

/* A label above content that is as wide as the form, left aligned with it,
   instead of the narrow right aligned label next to short inputs */
li.stacked > label,
li.stacked > span.label {
    display: block;
    float: none;
    margin: 0 0 0.25em;
    padding: 0;
    text-align: left;
    width: auto;
}

li.stacked > textarea,
li.stacked > pre {
    box-sizing: border-box;
    display: block;
    margin: 0;
    width: 100%;
}

/* The form sits in a half width column, where the 30% the SIP2 module gives a
   select is too narrow for its choices */
form :deep(.v-select) {
    min-width: 14em;
    width: 50%;
}

table.sip-fields {
    width: 100%;
    margin-top: 1em;
}

p.error {
    color: #c00;
}
</style>
