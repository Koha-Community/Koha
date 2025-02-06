<template>
    <v-select
        :id="id"
        v-model="model"
        :label="label"
        :options="paginationRequired ? paginated : data"
        :reduce="item => item[dataIdentifier]"
        @open="onOpen"
        @close="onClose"
        @option:selected="onSelected"
        @search="searchFilter($event)"
        ref="select"
    >
        <template v-if="required" #search="{ attributes, events }">
            <input
                :required="!model"
                class="vs__search"
                v-bind="attributes"
                v-on="events"
            />
        </template>
        <template #selected-option="option">
            {{ selectedOptionLabel }}
        </template>
        <template #list-footer>
            <li v-show="hasNextPage && !this.search" ref="load">
                {{ $__("Loading more options...") }}
            </li>
        </template>
    </v-select>
</template>

<script>
import { APIClient } from "../fetch/api-client.js";

export default {
    props: {
        id: String,
        selectedData: Object,
        dataType: String,
        modelValue: Number,
        dataIdentifier: String,
        label: String,
        required: Boolean,
    },
    emits: ["update:modelValue"],
    data() {
        return {
            observer: null,
            limit: null,
            search: "",
            scrollPage: null,
            data: [this.selectedData],
            paginationRequired: false,
            selectedOptionLabel: this.selectedData[this.label],
        };
    },
    computed: {
        model: {
            get() {
                return this.modelValue;
            },
            set(value) {
                this.$emit("update:modelValue", value);
            },
        },
        filtered() {
            return this.data.filter(item =>
                item[this.label].includes(this.search)
            );
        },
        paginated() {
            return this.filtered.slice(0, this.limit);
        },
        hasNextPage() {
            return this.paginated.length < this.filtered.length;
        },
    },
    mounted() {
        this.observer = new IntersectionObserver(this.infiniteScroll);
    },
    methods: {
        async fetchInitialData(dataType) {
            const client = APIClient.erm;
            await client[dataType]
                .getAll(
                    {},
                    {
                        _page: 1,
                        _per_page: 20,
                        _match: "contains",
                    }
                )
                .then(
                    items => {
                        this.data = items;
                        this.search = "";
                        this.limit = 19;
                        this.scrollPage = 1;
                    },
                    error => {}
                );
        },
        async searchFilter(e) {
            if (e) {
                this.paginationRequired = false;
                this.observer.disconnect();
                this.data = [];
                this.search = e;
                const client = APIClient.erm;
                const attribute = "me." + this.label;
                const q = {};
                q[attribute] = { like: `%${e}%` };
                await client[this.dataType]
                    .getAll(q, {
                        _per_page: -1,
                    })
                    .then(
                        items => {
                            this.data = [...items];
                        },
                        error => {}
                    );
            } else {
                this.resetSelect();
            }
        },
        async onOpen() {
            this.paginationRequired = true;
            await this.fetchInitialData(this.dataType);
            if (this.hasNextPage) {
                await this.$nextTick();
                this.observer.observe(this.$refs.load);
            }
        },
        onClose() {
            this.observer.disconnect();
        },
        onSelected(option) {
            this.selectedOptionLabel = option[this.label];
        },
        async infiniteScroll([{ isIntersecting, target }]) {
            setTimeout(async () => {
                if (isIntersecting) {
                    const ul = target.offsetParent;
                    const scrollTop = target.offsetParent.scrollTop;
                    this.limit += 20;
                    this.scrollPage++;
                    await this.$nextTick();
                    const client = APIClient.erm;
                    ul.scrollTop = scrollTop;
                    await client[this.dataType]
                        .getAll(
                            {},
                            {
                                _page: this.scrollPage,
                                _per_page: 20,
                                _match: "contains",
                            }
                        )
                        .then(
                            items => {
                                const existingData = [...this.data];
                                this.data = [...existingData, ...items];
                            },
                            error => {}
                        );
                    ul.scrollTop = scrollTop;
                }
            }, 250);
        },
        async resetSelect() {
            if (this.$refs.select.open) {
                await this.fetchInitialData(this.dataType);
                if (this.hasNextPage) {
                    await this.$nextTick();
                    this.observer.observe(this.$refs.load);
                }
            } else {
                this.paginationRequired = false;
            }
        },
    },
    name: "InfiniteScrollSelect",
};
</script>
