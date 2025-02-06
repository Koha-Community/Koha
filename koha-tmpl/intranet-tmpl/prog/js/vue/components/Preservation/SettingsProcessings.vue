<template>
    <fieldset>
        <legend>{{ $__("Processings") }}</legend>
        <ol>
            <li
                :id="`processing_${counter}`"
                class="rows"
                v-for="(processing, counter) in processings"
                v-bind:key="counter"
            >
                <router-link
                    :to="{
                        name: 'SettingsProcessingsShow',
                        params: { processing_id: processing.processing_id },
                    }"
                >
                    {{ processing.name }}
                </router-link>

                <span class="action_links">
                    <a @click="deleteProcessing(processing)"
                        ><i class="fa fa-trash"></i>
                        {{ $__("Remove this processing") }}</a
                    >

                    <router-link
                        :to="{
                            name: 'SettingsProcessingsFormEdit',
                            params: { processing_id: processing.processing_id },
                        }"
                        ><i class="fa fa-pencil"></i>
                        {{ $__("Edit this processing") }}</router-link
                    >
                </span>
            </li>
        </ol>
        <router-link
            :to="{ name: 'SettingsProcessingsFormAdd' }"
            role="button"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("Add new processing") }}</router-link
        >
    </fieldset>
</template>

<script>
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    setup() {
        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore");
        return { setConfirmationDialog, setMessage, setError };
    },
    data() {
        return {
            processings: [],
        };
    },
    beforeCreate() {
        // FIXME Do we want that or a props passed from parent?
        const client = APIClient.preservation;
        client.processings.getAll().then(
            processings => {
                this.processings = processings;
            },
            error => {}
        );
    },
    methods: {
        deleteProcessing(processing) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this processing?"
                    ),
                    message: processing.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.preservation;
                    client.processings.delete(processing.processing_id).then(
                        success => {
                            this.setMessage(
                                this.$__("Processing %s deleted").format(
                                    processing.name
                                ),
                                true
                            );
                            client.processings.getAll().then(
                                processings => {
                                    this.processings = processings;
                                },
                                error => {}
                            );
                        },
                        error => {
                            // FIXME We need a better way to do that
                            if (error.toString().match(/409/)) {
                                this.setError(
                                    this.$__(
                                        "This processing cannot be deleted, it is already in used."
                                    )
                                );
                            }
                        }
                    );
                }
            );
        },
    },
    props: {},
    name: "SettingsProcessings",
};
</script>

<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
    cursor: pointer;
}
</style>
