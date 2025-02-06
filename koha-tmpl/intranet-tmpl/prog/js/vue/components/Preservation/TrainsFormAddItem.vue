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
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client";

export default {
    setup() {
        const { setMessage, setWarning, loading, loaded } = inject("mainStore");
        return {
            setMessage,
            setWarning,
            loading,
            loaded,
            api_mappings,
        };
    },
    data() {
        return {
            train: {
                train_id: null,
                name: "",
                description: "",
            },
            item: { item_id: null },
            train_item: null,
            barcode: "",
            processings: [],
            processing: null,
            initialized: false,
            av_options: {},
            default_values: {},
            attributes: [],
        };
    },
    beforeCreate() {
        const client = APIClient.preservation;
        client.processings
            .getAll()
            .then(processings => (this.processings = processings));
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.train_item_id) {
                vm.train = vm
                    .getTrain(to.params.train_id)
                    .then(() =>
                        vm
                            .getTrainItem(
                                to.params.train_id,
                                to.params.train_item_id
                            )
                            .then(() =>
                                vm
                                    .refreshAttributes()
                                    .then(() => (vm.initialized = true))
                            )
                    );
            } else {
                vm.train = vm
                    .getTrain(to.params.train_id)
                    .then(() => (vm.initialized = true));
            }
        });
    },
    methods: {
        async getTrain(train_id) {
            const client = APIClient.preservation;
            await client.trains.get(train_id).then(
                train => {
                    this.train = train;
                },
                error => {}
            );
        },
        async getTrainItem(train_id, train_item_id) {
            const client = APIClient.preservation;
            await client.train_items.get(train_id, train_item_id).then(
                train_item => {
                    this.train_item = train_item;
                    this.item = train_item.catalogue_item;
                },
                error => {}
            );
        },
        async getItemFromWaitingList(e) {
            e.preventDefault();
            const client = APIClient.preservation;
            client.waiting_list_items.get_from_barcode(this.barcode).then(
                item => {
                    if (!item) {
                        this.setWarning(
                            this.$__(
                                "Cannot find item with this barcode. It must be in the waiting list."
                            )
                        );
                        return;
                    }
                    this.item = item;
                    this.train_item = {
                        item_id: item.item_id,
                        processing_id: this.train.default_processing_id,
                    };
                    this.refreshAttributes(1);
                },
                error => {}
            );
        },
        columnApiMapping(db_column) {
            let table_col = db_column.split(".");
            let table = table_col[0];
            let col = table_col[1];
            let api_attribute = this.api_mappings[table][col] || col;
            return table == "biblio" || table == "biblioitems"
                ? this.item.biblio[api_attribute]
                : this.item[api_attribute];
        },
        updateDefaultValues() {
            this.processing.attributes
                .filter(attribute => attribute.type == "db_column")
                .forEach(attribute => {
                    this.default_values[attribute.processing_attribute_id] =
                        this.columnApiMapping(attribute.option_source);
                });
        },
        async refreshAttributes(apply_default_value) {
            this.loading();

            const client = APIClient.preservation;
            await client.processings.get(this.train_item.processing_id).then(
                processing => (this.processing = processing),
                error => {}
            );
            this.updateDefaultValues();
            this.attributes = [];
            this.processing.attributes.forEach(attribute => {
                let values = [];
                if (!apply_default_value) {
                    this.train_item.attributes
                        .filter(
                            a =>
                                a.processing_attribute_id ==
                                attribute.processing_attribute_id
                        )
                        .forEach(a => values.push(a.value));
                } else if (attribute.type == "db_column") {
                    values.push(
                        this.default_values[attribute.processing_attribute_id]
                    );
                } else {
                    values.push("");
                }
                values.forEach(value =>
                    this.attributes.push({
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
            let av_cat_array = this.processing.attributes
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
                        this.av_options[av_cat] = av_match
                            ? av_match.authorised_values
                            : [];
                    });
                })
                .then(() => this.loaded());
        },
        addAttribute(processing_attribute_id) {
            let last_index = this.attributes.findLastIndex(
                attribute =>
                    attribute.processing_attribute_id == processing_attribute_id
            );
            let new_attribute = (({ value, ...keepAttrs }) => keepAttrs)(
                this.attributes[last_index]
            );
            this.attributes.splice(last_index + 1, 0, new_attribute);
        },
        removeAttribute(counter) {
            this.attributes.splice(counter, 1);
        },
        onSubmit(e) {
            e.preventDefault();

            let train_item_id = this.train_item.train_item_id;
            let train_item = {
                item_id: this.train_item.item_id,
                processing_id: this.train_item.processing_id,
                attributes: this.attributes.map(a => ({
                    processing_attribute_id: a.processing_attribute_id,
                    value: a.value,
                })),
            };

            const client = APIClient.preservation;
            if (train_item_id) {
                client.train_items
                    .update(train_item, this.train.train_id, train_item_id)
                    .then(
                        success => {
                            this.setMessage(this.$__("Item updated"));
                            this.$router.push({
                                name: "TrainsShow",
                                params: { train_id: this.train.train_id },
                            });
                        },
                        error => {}
                    );
            } else {
                client.train_items.create(train_item, this.train.train_id).then(
                    success => {
                        this.setMessage(this.$__("Item added to train"));
                        this.$router.push({
                            name: "TrainsShow",
                            params: { train_id: this.train.train_id },
                        });
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
