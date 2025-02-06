<template>
    <fieldset v-if="tableFilters?.length > 0" class="filters">
        <template v-for="(filter, index) in tableFilters" v-bind:key="index">
            <FormElement :resource="filters" :attr="filter" :index="index" />
        </template>
        <input
            @click="filterTable(filters, table, embedded)"
            id="filterTable"
            type="button"
            :value="$__('Filter')"
        />
    </fieldset>
</template>

<script>
import FormElement from "./FormElement.vue";
export default {
    components: { FormElement },
    props: {
        embedded: Boolean,
        tableFilters: { type: Array, default: [] },
        getFilters: Function,
        filterTable: Function | null,
        table: Object,
    },
    data() {
        return {
            filters: this.getFilters ? this.getFilters(this.$route.query) : {},
        };
    },
};
</script>

<style scoped>
.filters > input[type="checkbox"],
.filters > input[type="button"] {
    margin-left: 1rem;
}
</style>
