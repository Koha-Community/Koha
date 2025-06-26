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
import { inject, onMounted, ref } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    setup() {
        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore");

        const processings = ref([]);

        const deleteProcessing = processing => {
            setConfirmationDialog(
                {
                    title: $__(
                        "Are you sure you want to remove this processing?"
                    ),
                    message: processing.name,
                    accept_label: $__("Yes, delete"),
                    cancel_label: $__("No, do not delete"),
                },
                () => {
                    const client = APIClient.preservation;
                    client.processings.delete(processing.processing_id).then(
                        success => {
                            setMessage(
                                $__("Processing %s deleted").format(
                                    processing.name
                                ),
                                true
                            );
                            client.processings.getAll().then(
                                result => {
                                    processings.value = result;
                                },
                                error => {}
                            );
                        },
                        error => {
                            // FIXME We need a better way to do that
                            if (error.toString().match(/409/)) {
                                setError(
                                    $__(
                                        "This processing cannot be deleted, it is already in used."
                                    )
                                );
                            }
                        }
                    );
                }
            );
        };

        onMounted(() => {
            const client = APIClient.preservation;
            client.processings.getAll().then(
                result => {
                    processings.value = result;
                },
                error => {}
            );
        });

        return {
            setConfirmationDialog,
            setMessage,
            setError,
            processings,
            deleteProcessing,
        };
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
