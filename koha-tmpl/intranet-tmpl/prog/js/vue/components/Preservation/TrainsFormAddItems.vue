<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="trains_add_items">
        <h2>{{ $__("Add new items to %s").format(train.name) }}</h2>
        <form @submit="onSubmit($event)">
            <fieldset class="rows">
                <ol>
                    <li>
                        <label for="itemnumbers"
                            >{{ $__("Itemnumbers") }}:</label
                        >
                        <span>{{ items.map(i => i.item_id).join(", ") }}</span>
                    </li>
                    <li>
                        <label for="processing"
                            >{{ $__("Processing") }}:
                        </label>
                        <v-select
                            id="processing"
                            label="name"
                            v-model="processing_id"
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
                                :options="av_options[attribute.option_source]"
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
                            {{
                                $__(
                                    "Cannot be edited now, the value will be retrieved from %s"
                                ).format(attribute.option_source)
                            }}
                        </span>
                        <a
                            v-if="
                                attribute.type != 'db_column' &&
                                (attributes.length == counter + 1 ||
                                    attributes[counter + 1]
                                        .processing_attribute_id !=
                                        attribute.processing_attribute_id)
                            "
                            class="btn btn-link"
                            @click="
                                addAttribute(attribute.processing_attribute_id)
                            "
                            ><font-awesome-icon icon="plus" />
                            {{ $__("Add") }}</a
                        >
                        <a
                            v-else-if="attribute.type != 'db_column'"
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
            items: [],
            train_items: [],
            processings: [],
            processing: null,
            processing_id: null,
            initialized: false,
            av_options: {},
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
            vm.train = vm
                .getTrain(to.params.train_id)
                .then(() =>
                    vm
                        .getItems(to.params.item_ids.split(","))
                        .then(() =>
                            vm
                                .refreshAttributes()
                                .then(() => (vm.initialized = true))
                        )
                );
        });
    },
    methods: {
        async getTrain(train_id) {
            const client = APIClient.preservation;
            await client.trains.get(train_id).then(
                train => {
                    this.train = train;
                    this.processing_id = train.default_processing_id;
                },
                error => {}
            );
        },
        async getItems(item_ids) {
            const client = APIClient.item;
            let q = { "me.item_id": item_ids };
            await client.items.getAll(q, {}, { "x-koha-embed": "biblio" }).then(
                items => {
                    this.items = items;
                },
                error => {}
            );
        },
        columnApiMapping(item, db_column) {
            let table_col = db_column.split(".");
            let table = table_col[0];
            let col = table_col[1];
            let api_attribute = this.api_mappings[table][col] || col;
            return table == "biblio" || table == "biblioitems"
                ? item.biblio[api_attribute]
                : item[api_attribute];
        },
        async refreshAttributes() {
            this.loading();

            const client = APIClient.preservation;
            await client.processings.get(this.processing_id).then(
                processing => (this.processing = processing),
                error => {}
            );
            this.attributes = [];
            this.processing.attributes.forEach(attribute => {
                this.attributes.push({
                    processing_attribute_id: attribute.processing_attribute_id,
                    name: attribute.name,
                    type: attribute.type,
                    option_source: attribute.option_source,
                    value: "",
                });
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
                        this.av_options[av_cat] = av_match.authorised_values;
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

            let train_items = this.items.map(item => {
                return {
                    item_id: item.item_id,
                    processing_id: this.processing_id,
                    attributes: this.attributes.map(a => {
                        let value =
                            a.type == "db_column"
                                ? this.columnApiMapping(item, a.option_source)
                                : a.value;
                        return {
                            processing_attribute_id: a.processing_attribute_id,
                            value,
                        };
                    }),
                };
            });

            const client = APIClient.preservation;
            client.train_items.createAll(train_items, this.train.train_id).then(
                result => {
                    if (result.length) {
                        this.setMessage(
                            this.$__(
                                "%s items have been added to train %s."
                            ).format(result.length, this.train.train_id)
                        );
                        this.$router.push({
                            name: "TrainsShow",
                            params: { train_id: this.train.train_id },
                        });
                    } else {
                        this.setMessage(
                            this.$__("No items have been added to the train.")
                        );
                    }
                },
                error => {}
            );
        },
    },
    components: {},
    name: "TrainsFormAddItems",
};
</script>
