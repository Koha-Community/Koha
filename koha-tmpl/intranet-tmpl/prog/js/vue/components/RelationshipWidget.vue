<template>
    <fieldset class="rows" :id="`${name + '_' + 'relationship'}`">
        <legend v-if="title">{{ title }}</legend>
        <fieldset
            :id="`${name + '_' + counter}`"
            class="rows"
            v-for="(resourceRelationship, counter) in resourceRelationships"
            v-bind:key="counter"
        >
            <legend>
                {{ relationshipI18n.nameUpperCase + " " + (counter + 1) }}
                <a href="#" @click.prevent="deleteResourceRelationship(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ relationshipI18n.removeThisMessage }}</a
                >
            </legend>
            <ol>
                <li
                    v-for="(attr, index) in relationshipFields"
                    v-bind:key="index"
                >
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
            class="btn btn-default add-new-relationship"
            @click="addResourceRelationship"
            ><font-awesome-icon icon="plus" />
            {{ relationshipI18n.addNewMessage }}</a
        >
        <span v-else-if="resourceRelationshipCount == 0">
            {{ relationshipI18n.noneCreatedYetMessage }}
        </span>
    </fieldset>
</template>

<script>
import { onBeforeMount, provide, ref } from "vue";
import FormElement from "./FormElement.vue";

export default {
    name: "RelationshipWidget",
    setup(props) {
        const initialized = ref(false);
        const noCountRequired = ref(false);
        const resourceRelationshipCount = ref(null);
        const options = ref(null);

        provide("resourceRelationships", props.resourceRelationships);

        const addResourceRelationship = () => {
            props.resourceRelationships.push({
                ...props.newRelationshipDefaultAttrs,
            });
        };
        const deleteResourceRelationship = counter => {
            props.resourceRelationships.splice(counter, 1);
        };
        const getSelectOptions = filters => {
            const searchFilters = filters ? filters : {};
            props.apiClient.getAll(searchFilters).then(response => {
                options.value = response;
                resourceRelationshipCount.value = response.length;
                initialized.value = true;
            });
        };
        const handleOptions = () => {
            if (!options.value) return {};
            return { options: options.value };
        };

        onBeforeMount(() => {
            if (props.apiClient) {
                props.apiClient.count().then(
                    count => {
                        if (props.fetchOptions) {
                            getSelectOptions(props.filters);
                        } else {
                            resourceRelationshipCount.value = count;
                            initialized.value = true;
                        }
                    },
                    error => {}
                );
            } else {
                noCountRequired.value = true;
                initialized.value = true;
            }
        });
        return {
            noCountRequired,
            resourceRelationshipCount,
            options,
            addResourceRelationship,
            deleteResourceRelationship,
            handleOptions,
            initialized,
        };
    },
    props: {
        resourceRelationships: Array,
        relationshipFields: Array,
        relationshipI18n: Object,
        title: String,
        apiClient: Object,
        newRelationshipDefaultAttrs: Object,
        filters: Object,
        fetchOptions: Boolean,
        name: String,
    },
    components: {
        FormElement,
    },
};
</script>

<style scoped>
.add-new-relationship {
    margin-top: 0.5em;
}
</style>
