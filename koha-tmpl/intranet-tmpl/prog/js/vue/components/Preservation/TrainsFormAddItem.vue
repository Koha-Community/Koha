<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="trains_add_item">
        <h2 v-if="train_item && train_item.train_item_id">
            {{ $__("Edit item #%s").format(train_item.item_id) }}
        </h2>
        <h2 v-else>{{ $__("Add new item to %s").format(train.name) }}</h2>
        <div v-if="train_item">
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label for="itemnumber"
                                >{{ $__("Itemnumber") }}:</label
                            >
                            <span>{{ train_item.item_id }}</span>
                        </li>
                        <li>
                            <label for="processing"
                                >{{ $__("Processing") }}:
                            </label>
                            <v-select
                                id="processing"
                                label="name"
                                v-model="train_item.processing_id"
                                @option:selected="refreshAttributes(1)"
                                :reduce="p => p.processing_id"
                                :options="processings"
                                :clearable="false"
                            />
                        </li>
                        <li
                            class="attribute"
                            v-for="(attribute, counter) in attributes"
                            v-bind:key="counter"
                        >
                            <label :for="`attribute_${counter}`"
                                >{{ attribute.name }}:
                            </label>
                            <span v-if="attribute.type == 'authorised_value'">
                                <v-select
                                    :id="`attribute_${counter}`"
                                    v-model="attribute.value"
                                    label="description"
                                    :reduce="av => av.value"
                                    :options="
                                        av_options[attribute.option_source]
                                    "
                                    taggable
                                    :create-option="
                                        attribute => ({
                                            value: attribute,
                                            description: attribute,
                                        })
                                    "
                                />
                            </span>
                            <span v-else-if="attribute.type == 'free_text'">
                                <input
                                    :id="`attribute_${counter}`"
                                    v-model="attribute.value"
                                />
                            </span>
                            <span v-else-if="attribute.type == 'db_column'">
                                <input
                                    :id="`attribute_${counter}`"
                                    v-model="attribute.value"
                                />
                            </span>
                            <a
                                v-if="
                                    attributes.length == counter + 1 ||
                                    attributes[counter + 1]
                                        .processing_attribute_id !=
                                        attribute.processing_attribute_id
                                "
                                class="btn btn-link"
                                @click="
                                    addAttribute(
                                        attribute.processing_attribute_id
                                    )
                                "
                                ><font-awesome-icon icon="plus" />
                                {{ $__("Add") }}</a
                            >
                            <a
                                v-else
                                class="btn btn-link"
                                @click="removeAttribute(counter)"
                                ><font-awesome-icon icon="minus" />
                                {{ $__("Remove") }}</a
                            >
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
        <div v-else>
            <form @submit="getItemFromWaitingList($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label class="required" for="barcode"
                                >{{ $__("Barcode") }}:</label
                            >
                            <input
                                id="barcode"
                                v-model="barcode"
                                :placeholder="$__('Enter item barcode')"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
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
                        :to="{
                            name: 'TrainsShow',
                            params: { train_id: train.train_id },
                        }"
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
import { inject, onBeforeMount, ref } from "vue";
import { APIClient } from "../../fetch/api-client";
import { useRoute, useRouter } from "vue-router";
import { $__ } from "@k/i18n";

export default {
    setup() {
        const router = useRouter();
        const route = useRoute();
        const { setMessage, setWarning, loading, loaded } = inject("mainStore");

        const train = ref({
            train_id: null,
            name: "",
            description: "",
        });
        const item = ref({
            item_id: null,
        });
        const train_item = ref(null);
        const barcode = ref("");
        const processings = ref([]);
        const processing = ref(null);
        const initialized = ref(false);
        const av_options = ref({});
        const default_values = ref({});
        const attributes = ref([]);

        const getTrain = async train_id => {
            const client = APIClient.preservation;
            await client.trains.get(train_id).then(
                result => {
                    train.value = result;
                },
                error => {}
            );
        };
        const getTrainItem = async (train_id, train_item_id) => {
            const client = APIClient.preservation;
            await client.train_items.get(train_id, train_item_id).then(
                result => {
                    train_item.value = result;
                    item.value = result.catalogue_item;
                },
                error => {}
            );
        };
        const getItemFromWaitingList = async e => {
            e.preventDefault();
            const client = APIClient.preservation;
            client.waiting_list_items.get_from_barcode(barcode.value).then(
                result => {
                    if (!result) {
                        setWarning(
                            $__(
                                "Cannot find item with this barcode. It must be in the waiting list."
                            )
                        );
                        return;
                    }
                    item.value = result;
                    train_item.value = {
                        item_id: result.item_id,
                        processing_id: train.value.default_processing_id,
                    };
                    refreshAttributes(1);
                },
                error => {}
            );
        };
        const refreshAttributes = async apply_default_value => {
            loading();

            const client = APIClient.preservation;
            await client.processings.get(train_item.value.processing_id).then(
                result => (processing.value = result),
                error => {}
            );
            updateDefaultValues();
            attributes.value = [];
            processing.value.attributes.forEach(attribute => {
                let values = [];
                if (!apply_default_value) {
                    train_item.value.attributes
                        .filter(
                            a =>
                                a.processing_attribute_id ==
                                attribute.processing_attribute_id
                        )
                        .forEach(a => values.push(a.value));
                } else if (attribute.type == "db_column") {
                    values.push(
                        default_values.value[attribute.processing_attribute_id]
                    );
                } else {
                    values.push("");
                }
                values.forEach(value =>
                    attributes.value.push({
                        processing_attribute_id:
                            attribute.processing_attribute_id,
                        name: attribute.name,
                        type: attribute.type,
                        option_source: attribute.option_source,
                        value,
                    })
                );
            });
            const client_av = APIClient.authorised_values;
            let av_cat_array = processing.value.attributes
                .filter(attribute => attribute.type == "authorised_value")
                .map(attribute => attribute.option_source);

            client_av.values
                .getCategoriesWithValues([
                    ...new Set(av_cat_array.map(av_cat => '"' + av_cat + '"')),
                ]) // unique
                .then(av_categories => {
                    av_cat_array.forEach(av_cat => {
                        let av_match = av_categories.find(
                            element => element.category_name == av_cat
                        );
                        av_options.value[av_cat] = av_match
                            ? av_match.authorised_values
                            : [];
                    });
                })
                .then(() => loaded());
        };
        const columnApiMapping = db_column => {
            let table_col = db_column.split(".");
            let table = table_col[0];
            let col = table_col[1];
            let api_attribute = api_mappings[table][col] || col;
            return table == "biblio" || table == "biblioitems"
                ? item.value.biblio[api_attribute]
                : item.value[api_attribute];
        };
        const updateDefaultValues = () => {
            processing.value.attributes
                .filter(attribute => attribute.type == "db_column")
                .forEach(attribute => {
                    default_values.value[attribute.processing_attribute_id] =
                        columnApiMapping(attribute.option_source);
                });
        };
        const addAttribute = processing_attribute_id => {
            let last_index = attributes.value.findLastIndex(
                attribute =>
                    attribute.processing_attribute_id == processing_attribute_id
            );
            let new_attribute = (({ value, ...keepAttrs }) => keepAttrs)(
                attributes.value[last_index]
            );
            attributes.value.splice(last_index + 1, 0, new_attribute);
        };
        const removeAttribute = counter => {
            attributes.value.splice(counter, 1);
        };
        const onSubmit = e => {
            e.preventDefault();

            let train_item_id = train_item.value.train_item_id;
            let trainItem = {
                item_id: train_item.value.item_id,
                processing_id: train_item.value.processing_id,
                attributes: attributes.value.map(a => ({
                    processing_attribute_id: a.processing_attribute_id,
                    value: a.value,
                })),
            };

            const client = APIClient.preservation;
            if (train_item_id) {
                client.train_items
                    .update(trainItem, train.value.train_id, train_item_id)
                    .then(
                        success => {
                            setMessage($__("Item updated"));
                            router.push({
                                name: "TrainsShow",
                                params: { train_id: train.value.train_id },
                            });
                        },
                        error => {}
                    );
            } else {
                client.train_items.create(trainItem, train.value.train_id).then(
                    success => {
                        setMessage($__("Item added to train"));
                        router.push({
                            name: "TrainsShow",
                            params: { train_id: train.value.train_id },
                        });
                    },
                    error => {}
                );
            }
        };

        onBeforeMount(() => {
            const client = APIClient.preservation;
            client.processings
                .getAll()
                .then(result => (processings.value = result));

            if (route.params.train_item_id) {
                train.value = getTrain(route.params.train_id).then(() =>
                    getTrainItem(
                        route.params.train_id,
                        route.params.train_item_id
                    ).then(() =>
                        refreshAttributes().then(
                            () => (initialized.value = true)
                        )
                    )
                );
            } else {
                train.value = getTrain(route.params.train_id).then(
                    () => (initialized.value = true)
                );
            }
        });
        return {
            setMessage,
            setWarning,
            loading,
            loaded,
            api_mappings,
            train,
            item,
            train_item,
            barcode,
            processings,
            processing,
            initialized,
            av_options,
            default_values,
            attributes,
            addAttribute,
            removeAttribute,
            onSubmit,
            getItemFromWaitingList,
        };
    },
    components: {},
    name: "TrainsFormAdd",
};
</script>
