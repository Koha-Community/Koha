<template>
    <fieldset v-if="instancedResource.tableFilters?.length > 0" class="filters">
        <template v-if="instancedResource.getTableFilterFormElementsLabel()"
            >{{ instancedResource.getTableFilterFormElementsLabel()
            }}{{ " " }}</template
        >
        <template
            v-for="(filter, index) in instancedResource.tableFilters"
            v-bind:key="index"
        >
            <FormElement :resource="filters" :attr="filter" :index="index" />
        </template>
        <input
            @click="
                instancedResource.filterTable(
                    filters,
                    table,
                    instancedResource.embedded
                )
            "
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
        instancedResource: Object,
        table: Object,
    },
    data() {
        return {
            filters: this.instancedResource.getFilterValues
                ? this.instancedResource.getFilterValues(this.$route.query)
                : {},
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
