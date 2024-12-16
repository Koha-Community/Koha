<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="resources_add">
        <h2 v-if="resourceToAddOrEdit.resource_id">
            {{
                $__("Edit") +
                " " +
                i18n.display_name +
                " #" +
                resourceToAddOrEdit.resource_id
            }}
        </h2>
        <h2 v-else>{{ $__("New") + " " + i18n.display_name }}</h2>
        <div>
            <form @submit="onSubmit($event, resourceToAddOrEdit)">
                <fieldset
                    class="rows"
                    v-for="(group, counter) in getFieldGroupings()"
                    v-bind:key="counter"
                >
                    <legend v-if="group.name">{{ group.name }}</legend>
                    <ol>
                        <li
                            v-for="(attr, index) in group.fields"
                            v-bind:key="index"
                        >
                            <FormElement
                                :resource="resourceToAddOrEdit"
                                :attr="attr"
                                :index="index"
                            />
                        </li>
                    </ol>
                </fieldset>
                <template
                    v-for="(attr, index) in resource_attrs.filter(
                        attr => attr.type === 'relationship'
                    )"
                    v-bind:key="'rel-' + index"
                >
                    <FormElement :resource="resourceToAddOrEdit" :attr="attr" />
                </template>
                <fieldset class="action">
                    <ButtonSubmit />
                    <router-link
                        :to="{ name: list_component }"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import FormElement from "./FormElement.vue";
import ButtonSubmit from "./ButtonSubmit.vue";

export default {
    data() {
        return {
            initialized: false,
            resourceToEdit: null,
        };
    },
    props: {
        id_attr: String,
        api_client: Object,
        i18n: Object,
        resource_attrs: Array,
        list_component: String,
        resource: Object,
        onSubmit: Function,
    },
    created() {
        if (this.$route.params[this.id_attr]) {
            this.getResource(this.$route.params[this.id_attr]);
        } else {
            this.initialized = true;
        }
    },
    methods: {
        async getResource(resource_id) {
            this.api_client.get(resource_id).then(
                resource => {
                    this.resourceToEdit = resource;
                    this.initialized = true;
                },
                error => {}
            );
        },
        getFieldGroupings() {
            const nonRelationalFields = this.resource_attrs.filter(
                attr => attr.type !== "relationship"
            );
            const groupings = nonRelationalFields.reduce((acc, attr) => {
                if (
                    attr.hasOwnProperty("group") &&
                    attr.group !== null &&
                    !acc.includes(attr.group)
                ) {
                    return [...acc, attr.group];
                }
                return acc;
            }, []);
            if (groupings.length === 0) {
                return [
                    {
                        name: null,
                        fields: nonRelationalFields,
                    },
                ];
            }
            return groupings.reduce((acc, group) => {
                const groupFields = this.resource_attrs.filter(
                    ra => ra.group === group
                );
                const groupInfo = {
                    name: group,
                    fields: groupFields,
                };
                return [...acc, groupInfo];
            }, []);
        },
    },
    computed: {
        resourceToAddOrEdit() {
            if (this.resourceToEdit) {
                return this.resourceToEdit;
            }
            return this.resource;
        },
    },
    components: {
        ButtonSubmit,
        FormElement,
    },
    name: "ResourceFormAdd",
};
</script>
