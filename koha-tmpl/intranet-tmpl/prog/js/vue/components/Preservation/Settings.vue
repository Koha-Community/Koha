<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="settings">
        <h2>
            {{ $__("Edit preservation settings") }}
        </h2>
        <div>
            <form @submit="onSubmit($event)">
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
                                v-model="settings.not_for_loan_waiting_list_in"
                                label="description"
                                :reduce="av => av.value"
                                :options="av_notforloan"
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="
                                            !settings.not_for_loan_waiting_list_in
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
                                v-model="settings.not_for_loan_default_train_in"
                                label="description"
                                :reduce="av => av.value"
                                :options="av_notforloan"
                            />
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input type="submit" value="Submit" />
                    <router-link
                        :to="{ name: 'Home' }"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
            <SettingsProcessings />
        </div>
    </div>
</template>

<script>
import { inject } from "vue"
import { APIClient } from "../../fetch/api-client.js"
import { storeToRefs } from "pinia"
import SettingsProcessings from "./SettingsProcessings.vue"

export default {
    setup() {
        const AVStore = inject("AVStore")
        const { av_notforloan } = storeToRefs(AVStore)

        const { setMessage, setWarning } = inject("mainStore")
        const PreservationStore = inject("PreservationStore")
        const { settings } = storeToRefs(PreservationStore)

        return { av_notforloan, setMessage, setWarning, settings }
    },
    data() {
        return {
            initialized: true,
        }
    },
    methods: {
        checkForm(train) {
            let errors = []

            errors.forEach(function (e) {
                setWarning(e)
            })
            return !errors.length
        },
        onSubmit(e) {
            e.preventDefault()
            const client = APIClient.sysprefs
            client.sysprefs
                .update(
                    "PreservationNotForLoanWaitingListIn",
                    this.settings.not_for_loan_waiting_list_in
                )
                .then(
                    client.sysprefs.update(
                        "PreservationNotForLoanDefaultTrainIn",
                        this.settings.not_for_loan_default_train_in || 0
                    )
                )
                .then(
                    success => {
                        this.setMessage(this.$__("Settings updated"), true)
                    },
                    error => {}
                )
        },
    },
    components: { SettingsProcessings },
    name: "Settings",
}
</script>
