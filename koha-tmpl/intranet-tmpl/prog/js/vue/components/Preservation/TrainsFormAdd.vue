<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="trains_add">
        <h2 v-if="train.train_id">
            {{ $__("Edit train #%s").format(train.train_id) }}
        </h2>
        <h2 v-else>{{ $__("New train") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label class="required" for="train_name"
                                >{{ $__("Name") }}:</label
                            >
                            <input
                                id="train_name"
                                v-model="train.name"
                                :placeholder="$__('Name')"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label class="required" for="train_description"
                                >{{ $__("Description") }}:
                            </label>
                            <textarea
                                id="train_description"
                                v-model="train.description"
                                :placeholder="$__('Description')"
                                required
                                rows="10"
                                cols="50"
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="not_for_loan_waiting_list_in"
                                >{{
                                    $__("Status for item added to this train")
                                }}:</label
                            >
                            <v-select
                                :disabled="train.train_id ? true : false"
                                id="not_for_loan"
                                v-model="train.not_for_loan"
                                label="description"
                                :reduce="av => av.value"
                                :options="authorisedValues.av_notforloan"
                            />
                        </li>
                        <li>
                            <label
                                class="required"
                                for="train_default_processing"
                                >{{ $__("Default processing") }}:
                            </label>
                            <v-select
                                id="train_default_processing"
                                label="name"
                                v-model="train.default_processing_id"
                                :reduce="p => p.processing_id"
                                :options="processings"
                                :required="!train.default_processing_id"
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="!train.default_processing_id"
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
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
                        :to="{ name: 'TrainsList' }"
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
import { inject } from "vue";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    setup() {
        const PreservationStore = inject("PreservationStore");
        const { authorisedValues } = storeToRefs(PreservationStore);
        const { config } = PreservationStore;

        const { setMessage, setWarning } = inject("mainStore");

        return { authorisedValues, setMessage, setWarning, config };
    },
    data() {
        return {
            train: {
                train_id: null,
                name: "",
                description: "",
                not_for_loan:
                    this.config.settings.not_for_loan_default_train_in,
                default_processing_id: null,
                created_on: null,
                closed_on: null,
                sent_on: null,
                received_on: null,
            },
            processings: [],
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.train_id) {
                vm.train = vm.getTrain(to.params.train_id);
            } else {
                vm.initialized = true;
            }
        });
    },
    beforeCreate() {
        const client = APIClient.preservation;
        client.processings.getAll().then(
            processings => {
                this.processings = processings;
            },
            error => {}
        );
    },
    methods: {
        async getTrain(train_id) {
            const client = APIClient.preservation;
            client.trains.get(train_id).then(train => {
                this.train = train;
                this.initialized = true;
            });
        },
        checkForm(train) {
            let errors = [];

            errors.forEach(function (e) {
                setWarning(e);
            });
            return !errors.length;
        },
        onSubmit(e) {
            e.preventDefault();

            let train = JSON.parse(JSON.stringify(this.train)); // copy
            let train_id = train.train_id;
            if (!this.checkForm(train)) {
                return false;
            }

            delete train.train_id;
            delete train.default_processing;
            delete train.items;

            const client = APIClient.preservation;
            if (train_id) {
                client.trains.update(train, train_id).then(
                    success => {
                        this.setMessage(this.$__("Train updated"));
                        this.$router.push({ name: "TrainsList" });
                    },
                    error => {}
                );
            } else {
                client.trains.create(train).then(
                    success => {
                        this.setMessage(this.$__("Train created"));
                        this.$router.push({ name: "TrainsList" });
                    },
                    error => {}
                );
            }
        },
    },
    components: {},
    name: "TrainsFormAdd",
};
</script>
