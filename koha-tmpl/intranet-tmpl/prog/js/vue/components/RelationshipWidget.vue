<template>
    <fieldset class="rows" :id="`${resourceName + '_' + title}`">
        <legend>{{ title }}</legend>
        <fieldset
            :id="`${resourceName + '_' + title + '_' + counter}`"
            class="rows"
            v-for="(resourceRelationship, counter) in resourceRelationships"
            v-bind:key="counter"
        >
            <legend>
                {{
                    resourceName.slice(0, 1).toUpperCase() +
                    resourceName.slice(1) +
                    " " +
                    (counter + 1)
                }}
                <a href="#" @click.prevent="deleteResourceRelationship(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $__("Remove this %s").format(resourceName) }}</a
                >
            </legend>
            <ol>
                <li v-for="(attr, index) in subFields" v-bind:key="index">
                    <FormElement
                        :resource="resourceRelationship"
                        :attr="attr"
                        :index="counter"
                        v-bind="handleOptions()"
                    />
                </li>
            </ol>
        </fieldset>
        <a
            v-if="resourceRelationshipCount > 0 || noCountRequired"
            class="btn btn-default"
            @click="addResourceRelationship"
            ><font-awesome-icon icon="plus" />
            {{ $__("Add new %s").format(resourceName) }}</a
        >
        <span v-else>{{
            $__("There are no %s created yet").format(resourceName)
        }}</span>
    </fieldset>
</template>

<script>
import FormElement from "./FormElement.vue";

export default {
    name: "RelationshipWidget",
    setup() {
        return {
            noCountRequired: false,
        };
    },
    data() {
        return {
            resourceRelationshipCount: null,
            options: null,
        };
    },
    props: {
        resourceRelationships: Array,
        subFields: Array,
        resourceName: String,
        title: String,
        apiClient: Object,
        newRelationship: Object,
        filters: Object,
        fetchOptions: Boolean,
    },
    beforeCreate() {
        if (this.apiClient) {
            this.apiClient.count().then(
                count => {
                    if (this.fetchOptions) {
                        this.getSelectOptions(this.filters);
                    } else {
                        this.resourceRelationshipCount = count;
                        this.initialized = true;
                    }
                },
                error => {}
            );
        } else {
            this.noCountRequired = true;
            this.initialized = true;
        }
    },
    methods: {
        addResourceRelationship() {
            this.resourceRelationships.push(this.newRelationship);
        },
        deleteResourceRelationship(counter) {
            this.resourceRelationships.splice(counter, 1);
        },
        getSelectOptions(filters) {
            const searchFilters = filters ? filters : {};
            this.apiClient.getAll(searchFilters).then(options => {
                this.options = options;
                this.resourceRelationshipCount = options.length;
                this.initialized = true;
            });
        },
        handleOptions() {
            if (!this.options) return {};
            return { options: this.options };
        },
    },
    components: {
        FormElement,
    },
};
</script>
