<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="processing_show">
        <Toolbar>
            <ToolbarButton
                :to="{
                    name: 'SettingsProcessingsFormEdit',
                    params: { processing_id: processing.processing_id },
                }"
                icon="pencil"
                :title="$__('Edit')"
            />
            <a @click="doDelete()" class="btn btn-default"
                ><font-awesome-icon icon="trash" /> {{ $__("Delete") }}</a
            >
        </Toolbar>

        <h2>
            {{ $__("Processing #%s").format(processing.processing_id) }}
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("Processing name") }}:</label>
                        <span>
                            {{ processing.name }}
                        </span>
                    </li>
                    <li v-if="notice_template">
                        <label
                            >{{
                                $__("Letter template for printing slip")
                            }}:</label
                        >
                        <span>
                            {{ notice_template.name }}
                            <a
                                :href="`/cgi-bin/koha/tools/letter.pl?op=add_form&module=preservation&code=${notice_template.code}`"
                                ><i class="fa fa-edit"></i>
                                {{ $__("Edit this template") }}</a
                            >
                        </span>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="rows">
                <legend>{{ $__("Attributes") }}</legend>
                <ol v-if="processing.attributes.length">
                    <li
                        v-for="(attribute, counter) in processing.attributes"
                        v-bind:key="counter"
                    >
                        <label>{{ attribute.name }}</label>
                        <span v-if="attribute.type == 'authorised_value'">{{
                            $__("Authorized value")
                        }}</span>
                        <span v-else-if="attribute.type == 'free_text'">{{
                            $__("Free text")
                        }}</span>
                        <span v-else-if="attribute.type == 'db_column'">{{
                            $__("Database column")
                        }}</span>
                        <span v-else
                            >{{ $__("Unknown") }} - {{ attribute.type }}</span
                        >
                    </li>
                </ol>
                <span v-else>
                    {{
                        $__(
                            "There are no attributes defined for this processing."
                        )
                    }}
                </span>
            </fieldset>
            <fieldset class="action">
                <router-link
                    :to="{ name: 'Settings' }"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { computed, inject, onBeforeMount, ref } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import { onBeforeRouteUpdate, useRoute, useRouter } from "vue-router";
import { $__ } from "../../i18n";

export default {
    setup() {
        const route = useRoute();
        const router = useRouter();
        const { setConfirmationDialog, setMessage } = inject("mainStore");

        const processing = ref({
            processing_id: null,
            letter_code: null,
            name: "",
            attributes: [],
        });
        const initialized = ref(false);

        const notice_template = computed(() => {
            return notice_templates.find(
                n => n.id == processing.value.letter_code
            );
        });

        const getProcessing = async processing_id => {
            const client = APIClient.preservation;
            await client.processings.get(processing_id).then(
                result => {
                    processing.value = result;
                    initialized.value = true;
                },
                error => {}
            );
        };

        const doDelete = () => {
            setConfirmationDialog(
                {
                    title: $__(
                        "Are you sure you want to remove this processing?"
                    ),
                    message: processing.value.name,
                    accept_label: $__("Yes, delete"),
                    cancel_label: $__("No, do not delete"),
                },
                () => {
                    const client = APIClient.preservation;
                    client.processings
                        .delete(processing.value.processing_id)
                        .then(
                            success => {
                                setMessage(
                                    $__("Processing %s deleted").format(
                                        processing.value.name
                                    ),
                                    true
                                );
                                router.push({ name: "Settings" });
                            },
                            error => {}
                        );
                }
            );
        };

        onBeforeMount(() => {
            getProcessing(route.params.processing_id);
        });

        onBeforeRouteUpdate((to, from) => {
            getProcessing(to.params.processing_id);
        });

        return {
            notice_templates,
            setConfirmationDialog,
            setMessage,
            processing,
            initialized,
            notice_template,
            doDelete,
        };
    },
    components: { Toolbar, ToolbarButton },
    name: "ProcessingsShow",
};
</script>
<style scoped></style>
