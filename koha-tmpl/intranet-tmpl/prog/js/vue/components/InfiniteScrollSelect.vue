<template>
    <v-select
        v-bind:id="id"
        v-model="model"
        :label="queryProperty"
        :options="search ? data : paginated"
        :reduce="item => item[dataIdentifier]"
        @open="onOpen"
        @close="onClose"
        @search="searchFilter($event)"
    >
        <template #list-footer>
            <li v-show="hasNextPage && !this.search" ref="load">
                {{ $__("Loading more options...") }}
            </li>
        </template>
    </v-select>
</template>

<script>
import { APIClient } from "../fetch/api-client.js"

export default {
    created() {
        this.fetchInitialData(this.dataType)
        switch (this.dataType) {
            case "vendors":
                this.dataIdentifier = "id"
                this.queryProperty = "name"
                break
            case "agreements":
                this.dataIdentifier = "agreement_id"
                this.queryProperty = "name"
                break
            case "licenses":
                this.dataIdentifier = "license_id"
                this.queryProperty = "name"
                break
            case "localPackages":
                this.dataIdentifier = "package_id"
                this.queryProperty = "name"
                break
            default:
                break
        }
    },
    props: {
        id: String,
        dataType: String,
        modelValue: Number,
        required: Boolean,
    },
    emits: ["update:modelValue"],
    data() {
        return {
            observer: null,
            dataIdentifier: null,
            queryProperty: null,
            limit: null,
            search: "",
            scrollPage: null,
            data: [],
        }
    },
    computed: {
        model: {
            get() {
                return this.modelValue
            },
            set(value) {
                this.$emit("update:modelValue", value)
            },
        },
        filtered() {
            return this.data.filter(item =>
                item[this.queryProperty].includes(this.search)
            )
        },
        paginated() {
            return this.filtered.slice(0, this.limit)
        },
        hasNextPage() {
            return this.paginated.length < this.filtered.length
        },
    },
    mounted() {
        this.observer = new IntersectionObserver(this.infiniteScroll)
    },
    methods: {
        async fetchInitialData(dataType) {
            const client = APIClient.erm
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
                        this.data = items
                        this.search = ""
                        this.limit = 19
                        this.scrollPage = 1
                    },
                    error => {}
                )
        },
        async searchFilter(e) {
            if (e) {
                this.observer.disconnect()
                this.data = []
                this.search = e
                const client = APIClient.erm
                const attribute = "me." + this.queryProperty
                const q = {}
                q[attribute] = { like: `%${e}%` }
                await client[this.dataType]
                    .getAll(q, {
                        _per_page: -1,
                    })
                    .then(
                        items => {
                            this.data = items
                        },
                        error => {}
                    )
            } else {
                await this.fetchInitialData(this.dataType)
                await this.resetSelect()
            }
        },
        async onOpen() {
            await this.fetchInitialData(this.dataType)
            if (this.hasNextPage) {
                await this.$nextTick()
                this.observer.observe(this.$refs.load)
            }
        },
        onClose() {
            this.observer.disconnect()
            this.search = ""
        },
        async infiniteScroll([{ isIntersecting, target }]) {
            if (isIntersecting) {
                const ul = target.offsetParent
                const scrollTop = target.offsetParent.scrollTop
                this.limit += 20
                this.scrollPage++
                await this.$nextTick()
                const client = APIClient.erm
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
                            const existingData = [...this.data]
                            this.data = [...existingData, ...items]
                        },
                        error => {}
                    )
                ul.scrollTop = scrollTop
            }
        },
        async resetSelect() {
            if (this.hasNextPage) {
                await this.$nextTick()
                this.observer.observe(this.$refs.load)
            }
        },
    },
    name: "InfiniteScrollSelect",
}
</script>
