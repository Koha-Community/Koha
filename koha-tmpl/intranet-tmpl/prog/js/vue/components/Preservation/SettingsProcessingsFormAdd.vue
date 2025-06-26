<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="processings_add">
        <h2 v-if="processing.processing_id">
            {{ $__("Edit processing #%s").format(processing.processing_id) }}
        </h2>
        <h2 v-else>{{ $__("New processing") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label class="required" for="processing_name"
                                >{{ $__("Processing name") }}:</label
                            >
                            <input
                                id="processing_name"
                                v-model="processing.name"
                                :placeholder="$__('Processing name')"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="letter_code"
                                >{{
                                    $__("Letter template for printing slip")
                                }}:</label
                            >
                            <v-select
                                id="letter_code"
                                label="name"
                                v-model="processing.letter_code"
                                :options="notice_templates"
                                :reduce="n => n.code"
                            />
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="rows">
                    <legend>{{ $__("Attributes") }}</legend>
                    <div
                        v-if="processing.processing_id"
                        id="alert-removal"
                        class="alert alert-info"
                    >
                        {{
                            $__(
                                "Be careful when removing attributes from this processing: the items using it will be impacted as well!"
                            )
                        }}
                    </div>
                    <fieldset
                        :id="`attribute_${counter}`"
                        class="rows"
                        v-for="(attribute, counter) in processing.attributes"
                        v-bind:key="counter"
                    >
                        <legend>
                            {{ $__("Attribute %s").format(counter + 1) }}
                            <a
                                href="#"
                                @click.prevent="deleteAttribute(counter)"
                                ><i class="fa fa-trash"></i>
                                {{ $__("Remove this attribute") }}</a
                            >
                        </legend>
                        <ol>
                            <li>
                                <label
                                    :for="`attribute_name_${counter}`"
                                    class="required"
                                    >{{ $__("Name") }}:
                                </label>
                                <input
                                    :id="`attribute_name_${counter}`"
                                    type="text"
                                    :name="`attribute_name_${counter}`"
                                    v-model="attribute.name"
                                    required
                                />
                                <span class="required">{{
                                    $__("Required")
                                }}</span>
                            </li>
                            <li>
                                <label
                                    :for="`attribute_type_${counter}`"
                                    class="required"
                                    >{{ $__("Type") }}:
                                </label>
                                <v-select
                                    :id="`attribute_type_${counter}`"
                                    v-model="attribute.type"
                                    :options="attribute_types"
                                    :reduce="o => o.code"
                                    @option:selected="
                                        attribute.option_source = null
                                    "
                                >
                                    <template #search="{ attributes, events }">
                                        <input
                                            :required="!attribute.type"
                                            class="vs__search"
                                            v-bind="attributes"
                                            v-on="events"
                                        />
                                    </template>
                                </v-select>
                                <span class="required">{{
                                    $__("Required")
                                }}</span>
                            </li>
                            <li v-if="attribute.type == 'authorised_value'">
                                <label
                                    :for="`attribute_option_${counter}`"
                                    class="required"
                                    >{{ $__("Options") }}:
                                </label>
                                <v-select
                                    :id="`attribute_option_${counter}`"
                                    v-model="attribute.option_source"
                                    :options="authorised_value_categories"
                                    :getOptionLabel="
                                        c =>
                                            authorised_value_categories.find(
                                                cc => cc == c
                                            )
                                                ? c
                                                : '%s (%s)'.format(
                                                      c,
                                                      $__('DOES NOT EXIST!')
                                                  )
                                    "
                                >
                                    <template #search="{ attributes, events }">
                                        <input
                                            :required="!attribute.option_source"
                                            class="vs__search"
                                            v-bind="attributes"
                                            v-on="events"
                                        />
                                    </template>
                                </v-select>
                                <span class="required">{{
                                    $__("Required")
                                }}</span>
                            </li>
                            <li v-if="attribute.type == 'db_column'">
                                <label
                                    :for="`attribute_option_${counter}`"
                                    class="required"
                                    >{{ $__("Options") }}:
                                </label>
                                <v-select
                                    :id="`attribute_option_${counter}`"
                                    v-model="attribute.option_source"
                                    :options="db_column_options"
                                    :reduce="o => o.code"
                                >
                                    <template #search="{ attributes, events }">
                                        <input
                                            :required="!attribute.option_source"
                                            class="vs__search"
                                            v-bind="attributes"
                                            v-on="events"
                                        />
                                    </template>
                                </v-select>
                                <span class="required">{{
                                    $__("Required")
                                }}</span>
                            </li>
                        </ol>
                    </fieldset>
                    <a class="btn btn-default" @click="addAttribute"
                        ><font-awesome-icon icon="plus" />
                        {{ $__("Add new attribute") }}</a
                    >
                </fieldset>

                <fieldset class="action">
                    <input
                        type="submit"
                        class="btn btn-primary"
                        :value="$__('Submit')"
                    />
                    <router-link
                        :to="{ name: 'Settings' }"
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
import { inject, onMounted, ref } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import { useRoute, useRouter } from "vue-router";
import { $__ } from "@k/i18n";

export default {
    setup() {
        const route = useRoute();
        const router = useRouter();
        const { setMessage, setWarning } = inject("mainStore");

        const db_column_options = Object.keys(db_columns).map(function (c) {
            return { label: "%s (%s)".format(db_columns[c], c), code: c };
        });

        const processing = ref({
            processing_id: null,
            name: "",
            attributes: [],
        });
        const attribute_types = ref([
            {
                label: $__("Authorized value"),
                code: "authorised_value",
            },
            {
                label: $__("Free text"),
                code: "free_text",
            },
            {
                label: $__("Database column"),
                code: "db_column",
            },
        ]);
        const initialized = ref(false);

        const onSubmit = e => {
            e.preventDefault();

            let processingClone = JSON.parse(JSON.stringify(processing.value)); // copy
            let processing_id = processingClone.processing_id;
            delete processingClone.processing_id;

            processingClone.attributes = processingClone.attributes.map(
                ({ processing_id, ...keepAttrs }) => keepAttrs
            );

            const client = APIClient.preservation;
            if (processing_id) {
                client.processings.update(processingClone, processing_id).then(
                    success => {
                        setMessage($__("Processing updated"));
                        router.push({ name: "Settings" });
                    },
                    error => {}
                );
            } else {
                client.processings.create(processingClone).then(
                    success => {
                        setMessage($__("Processing created"));
                        router.push({ name: "Settings" });
                    },
                    error => {}
                );
            }
        };
        const addAttribute = () => {
            processing.value.attributes.push({
                name: "",
                type: null,
                option_source: null,
            });
        };
        const deleteAttribute = counter => {
            processing.value.attributes.splice(counter, 1);
        };
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

        onMounted(async () => {
            if (route.params.processing_id) {
                processing.value = await getProcessing(
                    route.params.processing_id
                );
            } else {
                initialized.value = true;
            }
        });
        return {
            setMessage,
            setWarning,
            authorised_value_categories,
            db_column_options,
            notice_templates,
            processing,
            attribute_types,
            initialized,
            onSubmit,
            addAttribute,
            deleteAttribute,
        };
    },
    components: {},
    name: "SettingsProcessingsFormAdd",
};
</script>

<style>
#alert-removal {
    margin: 0;
}
</style>
