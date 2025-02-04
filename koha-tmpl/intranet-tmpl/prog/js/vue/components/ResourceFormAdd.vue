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
        <ul
            v-if="formGroupsDisplayMode == 'tabs'"
            class="nav nav-tabs"
            role="tablist"
        >
            <li
                v-for="(tab, counter) in getFieldGroupings('Form')"
                class="nav-item"
            >
                <a
                    href="#"
                    :class="['nav-link', { active: counter == 0 }]"
                    data-bs-toggle="tab"
                    :data-bs-target="'#' + tab.name?.replace(/\s/g, '_')"
                    role="tab"
                    :aria-controls="tab.name?.replace(/\s/g, '_')"
                    :data-content="tab.name"
                    >{{ tab.name }}</a
                >
            </li>
        </ul>
        <form @submit="onSubmit($event, resourceToAddOrEdit)">
            <div v-if="formGroupsDisplayMode == 'tabs'" class="tab-content">
                <div
                    v-for="(group, counter) in getFieldGroupings('Form')"
                    v-bind:key="counter"
                    :id="group.name?.replace(/\s/g, '_')"
                    role="tabpanel"
                    :aria-labelledby="group.name?.replace(/\s/g, '_') + '-tab'"
                    :class="[
                        'tab-pane',
                        'rows',
                        { show: counter == 0 },
                        { active: counter == 0 },
                    ]"
                >
                    <fieldset class="rows">
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
                </div>
            </div>
            <div v-else>
                <fieldset
                    v-for="(group, counter) in getFieldGroupings('Form')"
                    v-bind:key="counter"
                    class="rows"
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
            </div>
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
        getFieldGroupings: Function,
        formGroupsDisplayMode: String,
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

<style scoped>
div.rows li {
    border-bottom: none;
}
div.rows + div.rows {
    margin-top: 0em;
}
</style>
