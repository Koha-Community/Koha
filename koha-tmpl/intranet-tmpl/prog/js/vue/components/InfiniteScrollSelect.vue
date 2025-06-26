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
            <li v-show="hasNextPage && !search" ref="load">
                {{ $__("Loading more options...") }}
            </li>
        </template>
    </v-select>
</template>

<script>
import { computed, onMounted, ref, useTemplateRef } from "vue";
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
    setup(props, { emit }) {
        const observer = ref(null);
        const limit = ref(null);
        const search = ref("");
        const scrollPage = ref(null);
        const data = ref([props.selectedData]);
        const paginationRequired = ref(false);
        const selectedOptionLabel = ref(props.selectedData[props.label]);

        const model = computed({
            get() {
                return props.modelValue;
            },
            set(value) {
                emit("update:modelValue", value);
            },
        });

        const filtered = computed(() => {
            return data.value.filter(item =>
                item[props.label].includes(search.value)
            );
        });
        const paginated = computed(() => {
            return filtered.value.slice(0, limit.value);
        });
        const hasNextPage = computed(() => {
            return paginated.value.length < filtered.value.length;
        });

        const loadingBlock = useTemplateRef("load");
        const select = useTemplateRef("select");

        const fetchInitialData = async dataType => {
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
                        data.value = items;
                        search.value = "";
                        limit.value = 19;
                        scrollPage.value = 1;
                    },
                    error => {}
                );
        };
        const searchFilter = async e => {
            if (e) {
                paginationRequired.value = false;
                observer.value.disconnect();
                data.value = [];
                search.value = e;
                const client = APIClient.erm;
                const attribute = "me." + props.label;
                const q = {};
                q[attribute] = { like: `%${e}%` };
                await client[props.dataType]
                    .getAll(q, {
                        _per_page: -1,
                    })
                    .then(
                        items => {
                            data.value = [...items];
                        },
                        error => {}
                    );
            } else {
                resetSelect();
            }
        };
        const onOpen = async () => {
            paginationRequired.value = true;
            await fetchInitialData(props.dataType);
            if (hasNextPage.value) {
                await nextTick();
                observer.value.observe(loadingBlock.value);
            }
        };
        const infiniteScroll = async ([{ isIntersecting, target }]) => {
            setTimeout(async () => {
                if (isIntersecting) {
                    const ul = target.offsetParent;
                    const scrollTop = target.offsetParent.scrollTop;
                    limit.value += 20;
                    scrollPage.value++;
                    await nextTick();
                    const client = APIClient.erm;
                    ul.scrollTop = scrollTop;
                    await client[props.dataType]
                        .getAll(
                            {},
                            {
                                _page: scrollPage,
                                _per_page: 20,
                                _match: "contains",
                            }
                        )
                        .then(
                            items => {
                                const existingData = [...data.value];
                                data.value = [...existingData, ...items];
                            },
                            error => {}
                        );
                    ul.scrollTop = scrollTop;
                }
            }, 250);
        };
        const resetSelect = async () => {
            if (select.value.open) {
                await fetchInitialData(props.dataType);
                if (hasNextPage.value) {
                    await nextTick();
                    observer.value.observe(loadingBlock.value);
                }
            } else {
                paginationRequired.value = false;
            }
        };
        const onClose = () => {
            observer.value.disconnect();
        };
        const onSelected = option => {
            selectedOptionLabel.value = option[props.label];
        };
        onMounted(() => {
            observer.value = new IntersectionObserver(infiniteScroll);
        });

        return {
            observer,
            limit,
            search,
            scrollPage,
            data,
            paginationRequired,
            selectedOptionLabel,
            model,
            filtered,
            paginated,
            hasNextPage,
            searchFilter,
            onOpen,
            onClose,
            onSelected,
            resetSelect,
            fetchInitialData,
        };
    },
    name: "InfiniteScrollSelect",
};
</script>
