<template>
    <v-select
        v-if="relatedResources"
        :getOptionLabel="
            relatedResource => relatedResource[relationshipOptionLabelAttr]
        "
        :reduce="relatedResource => relatedResource.sip_institution_id"
        :options="relatedResourcesOptions"
        :multiple="allowMultipleChoices"
        :filter-by="filterRelatedResourcesOptions"
        v-model="resource[name]"
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
            return this.relatedResources.map(resource => ({
                ...resource,
                full_search: resource[this.relationshipOptionLabelAttr],
            }));
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
