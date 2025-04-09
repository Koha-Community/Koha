<template>
    <v-select
        :getOptionLabel="
            relatedResource => relatedResource[relationshipOptionLabelAttr]
        "
        :id="name"
        :reduce="relatedResource => relatedResource[relationshipRequiredKey]"
        :options="relatedResourcesOptions"
        :multiple="allowMultipleChoices"
        :filter-by="filterRelatedResourcesOptions"
        v-model="resource[name]"
        :disabled="shouldBeDisabled"
        :placeholder="!relatedResourcesLoaded ? $__('Loading...') : ''"
    >
        <template v-slot:option="relatedResource">
            {{ relatedResource[relationshipOptionLabelAttr] }}
        </template>
    </v-select>
</template>

<script>
export default {
    props: {
        relationshipOptionLabelAttr: String | null,
        relationshipAPIClient: Object | null,
        resource: Object | null,
        name: String | null,
        allowMultipleChoices: Boolean | null,
        relationshipRequiredKey: String | null,
        disabled: Boolean | false,
    },
    data() {
        return {
            relatedResources: null,
            relatedResourcesLoaded: false,
        };
    },
    created() {
        const relatedResources = this.relationshipAPIClient;
        relatedResources.getAll().then(
            relatedResources => {
                this.relatedResources = relatedResources;
                this.relatedResourcesLoaded = true;
            },
            error => {}
        );
    },
    computed: {
        relatedResourcesOptions() {
            return this.relatedResources?.map(resource => ({
                ...resource,
                full_search: resource[this.relationshipOptionLabelAttr],
            }));
        },
        shouldBeDisabled() {
            return this.disabled || !this.relatedResourcesLoaded;
        },
    },
    methods: {
        filterRelatedResourcesOptions(resource, label, search) {
            return (
                (resource.full_search || "")
                    .toLocaleLowerCase()
                    .indexOf(search.toLocaleLowerCase()) > -1
            );
        },
    },
};
</script>
