<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${resourceName}_add`">
        <h2 v-if="resourceToAddOrEdit[idAttr]">
            {{
                $__("Edit") +
                " " +
                i18n.displayName +
                " #" +
                resourceToAddOrEdit[idAttr]
            }}
        </h2>
        <h2 v-else>{{ $__("New") + " " + i18n.displayName }}</h2>
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
                <fieldset class="action">
                    <ButtonSubmit />
                    <router-link
                        :to="{ name: listComponent }"
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
        idAttr: String,
        apiClient: Object,
        i18n: Object,
        resourceAttrs: Array,
        listComponent: String,
        resource: Object,
        onSubmit: Function,
        resourceName: String,
    },
    created() {
        if (this.$route.params[this.idAttr]) {
            this.getResource(this.$route.params[this.idAttr]);
        } else {
            this.initialized = true;
        }
    },
    methods: {
        async getResource(resourceId) {
            this.apiClient.get(resourceId).then(
                resource => {
                    this.resourceToEdit = resource;
                    this.initialized = true;
                },
                error => {}
            );
        },
        getFieldGroupings() {
            const groupings = this.resourceAttrs.reduce((acc, attr) => {
                if (
                    attr.hasOwnProperty("group") &&
                    attr.group !== null &&
                    !acc.includes(attr.group)
                ) {
                    return [...acc, attr.group];
                }
                if (!attr.hasOwnProperty("group")) {
                    attr.group = "noGroupFound";
                    if (!acc.includes("noGroupFound")) {
                        return [...acc, "noGroupFound"];
                    }
                }
                return acc;
            }, []);
            if (groupings.length === 0) {
                return [
                    {
                        name: null,
                        fields: this.resourceAttrs,
                    },
                ];
            }
            return groupings.reduce((acc, group) => {
                const groupFields = this.resourceAttrs.filter(
                    ra => ra.group === group
                );
                const groupInfo = {
                    name: group === "noGroupFound" ? null : group,
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
