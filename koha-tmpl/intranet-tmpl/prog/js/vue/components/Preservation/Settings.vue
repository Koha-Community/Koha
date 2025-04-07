<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="settings">
        <h2>
            {{ $__("Edit preservation settings") }}
        </h2>
        <div>
            <form
                v-if="config.permissions.manage_sysprefs"
                @submit="onSubmit($event)"
            >
                <fieldset class="rows">
                    <legend>{{ $__("General settings") }}</legend>
                    <ol>
                        <li>
                            <label
                                class="required"
                                for="not_for_loan_waiting_list_in"
                                >{{
                                    $__(
                                        "Status for item added to waiting list"
                                    )
                                }}:</label
                            >
                            <v-select
                                id="not_for_loan_waiting_list_in"
                                v-model="
                                    config.settings.not_for_loan_waiting_list_in
                                "
                                label="description"
                                :reduce="av => av.value"
                                :options="authorisedValues.av_notforloan"
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="
                                            !config.settings
                                                .not_for_loan_waiting_list_in
                                        "
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                        </li>
                        <li>
                            <label for="not_for_loan_default_train_in"
                                >{{
                                    $__(
                                        "Default status for item added to train"
                                    )
                                }}:</label
                            >
                            <v-select
                                id="not_for_loan_default_train_in"
                                v-model="
                                    config.settings
                                        .not_for_loan_default_train_in
                                "
                                label="description"
                                :reduce="av => av.value"
                                :options="authorisedValues.av_notforloan"
                            />
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input
                        type="submit"
                        class="btn btn-primary"
                        :value="$__('Submit')"
                    />
                    <router-link
                        :to="{ name: 'Home' }"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
            <fieldset v-else class="rows">
                <legend>{{ $__("General settings") }}</legend>
                <ol>
                    <li>
                        <label for="not_for_loan_waiting_list_in"
                            >{{
                                $__("Status for item added to waiting list")
                            }}:</label
                        >
                        <span>{{
                            get_lib_from_av(
                                "av_notforloan",
                                config.settings.not_for_loan_waiting_list_in
                            )
                        }}</span>
                    </li>
                    <li>
                        <label for="not_for_loan_default_train_in"
                            >{{
                                $__("Default status for item added to train")
                            }}:</label
                        >
                        <span>{{
                            get_lib_from_av(
                                "av_notforloan",
                                config.settings.not_for_loan_default_train_in
                            )
                        }}</span>
                    </li>
                </ol>
            </fieldset>

            <SettingsProcessings />
        </div>
    </div>
</template>

<script>
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import { storeToRefs } from "pinia";
import SettingsProcessings from "./SettingsProcessings.vue";

export default {
    setup() {
        const PreservationStore = inject("PreservationStore");
        const { authorisedValues } = storeToRefs(PreservationStore);
        const { get_lib_from_av, config } = PreservationStore;

        const { setMessage, setWarning } = inject("mainStore");

        return {
            authorisedValues,
            get_lib_from_av,
            setMessage,
            setWarning,
            config,
        };
    },
    data() {
        return {
            initialized: true,
        };
    },
    methods: {
        checkForm(train) {
            let errors = [];

            errors.forEach(function (e) {
                setWarning(e);
            });
            return !errors.length;
        },
        onSubmit(e) {
            e.preventDefault();
            const client = APIClient.sysprefs;
            client.sysprefs
                .update(
                    "PreservationNotForLoanWaitingListIn",
                    this.config.settings.not_for_loan_waiting_list_in
                )
                .then(
                    client.sysprefs.update(
                        "PreservationNotForLoanDefaultTrainIn",
                        this.config.settings.not_for_loan_default_train_in || 0
                    )
                )
                .then(
                    success => {
                        this.setMessage(this.$__("Settings updated"), true);
                    },
                    error => {}
                );
        },
    },
    components: { SettingsProcessings },
    name: "Settings",
};
</script>
