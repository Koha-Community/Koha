<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${resourceNamePlural}_add`">
        <h2 v-if="resourceToAddOrEdit[idAttr]">
            {{ i18n.editLabel.format(resourceToAddOrEdit[idAttr]) }}
        </h2>
        <h2 v-else>{{ i18n.newLabel }}</h2>
        <ul
            v-if="formGroupsDisplayMode == 'tabs'"
            class="nav nav-tabs"
            role="tablist"
        >
            <li
                v-for="(tab, counter) in getFieldGroupings('Form')"
                class="nav-item"
                :key="`tab${counter}`"
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
            <div v-else-if="formGroupsDisplayMode == 'accordion'">
                <div
                    v-for="(group, counter) in getFieldGroupings('Form')"
                    v-bind:key="counter"
                    class="accordion"
                >
                    <fieldset class="accordion-item">
                        <legend
                            v-if="group.name"
                            type="button"
                            data-bs-toggle="collapse"
                            :data-bs-target="`#collapse-${counter}`"
                            aria-expanded="true"
                            :aria-controls="`collapse-${counter}`"
                        >
                            <i
                                class="fa fa-caret-down"
                                title="Collapse this section"
                            ></i>
                            {{ group.name }}
                        </legend>
                        <div
                            :id="`collapse-${counter}`"
                            class="accordion-collapse collapse show"
                            :aria-labelledby="`heading-${counter}`"
                            data-bs-parent="#formAccordion"
                        >
                            <fieldset class="accordion-body rows">
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
    inheritAttrs: false,
    data() {
        return {
            initialized: false,
            resource: null,
        };
    },
    props: {
        idAttr: String,
        apiClient: Object,
        i18n: Object,
        resourceAttrs: Array,
        listComponent: String,
        newResource: Object,
        onSubmit: Function,
        resourceNamePlural: String,
        getFieldGroupings: Function,
        formGroupsDisplayMode: String,
        getResource: Function,
    },
    created() {
        if (this.$route.params[this.idAttr]) {
            this.getResource(this.$route.params[this.idAttr], this, "form");
        } else {
            this.initialized = true;
        }
    },
    computed: {
        resourceToAddOrEdit() {
            return this.resource || this.newResource;
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
.accordion fieldset legend {
    border: 1px solid #fff;
    margin-bottom: 0rem;
    margin-left: -0.5em;
    margin-top: -0.5em;
    padding: 0.7em;
}
.accordion fieldset legend.collapsed {
    margin-bottom: -0.5em;
}
.accordion fieldset legend:hover {
    border: 1px solid #6faf44;
    cursor: pointer;
}
.accordion fieldset legend i {
    color: #4c7aa8;
    font-size: 80%;
    padding-right: 0.2rem;
}
.accordion legend.collapsed i.fa.fa-caret-down::before {
    content: "\f0da";
}
.accordion fieldset.rows ol {
    padding: 0;
}
</style>
