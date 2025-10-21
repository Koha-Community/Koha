<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${instancedResource.resourceNamePlural}_add`">
        <h2 v-if="resourceToSave[instancedResource.idAttr]">
            {{
                instancedResource.i18n.editLabel.format(
                    resourceToSave[instancedResource.idAttr]
                )
            }}
        </h2>
        <h2 v-else>{{ instancedResource.i18n.newLabel }}</h2>
        <slot
            name="toolbar"
            :componentPropData="{
                ...$props,
                ...$data,
                resourceForm,
                saveDropdownButtonActions,
            }"
        />
        <form
            @submit="saveAndNavigate($event, resourceToSave)"
            ref="resourceForm"
        >
            <TabsWrapper
                v-if="instancedResource.formGroupsDisplayMode == 'tabs'"
                :tabList="instancedResource.getFieldGroupings('Form')"
            >
                <template #tabContent="{ tabGroup }">
                    <fieldset class="rows">
                        <legend v-if="tabGroup.name">
                            {{ tabGroup.name }}
                        </legend>
                        <ol>
                            <li
                                v-for="(attr, index) in tabGroup.fields"
                                v-bind:key="index"
                            >
                                <FormElement
                                    :resource="resourceToSave"
                                    :attr="attr"
                                    :index="index"
                                />
                            </li>
                        </ol>
                    </fieldset>
                </template>
            </TabsWrapper>
            <AccordionWrapper
                v-else-if="
                    instancedResource.formGroupsDisplayMode == 'accordion'
                "
                :accordionList="instancedResource.getFieldGroupings('Form')"
            >
                <template #accordionContent="{ accordionGroup }">
                    <ol>
                        <li
                            v-for="(attr, index) in accordionGroup.fields"
                            v-bind:key="index"
                        >
                            <FormElement
                                :resource="resourceToSave"
                                :attr="attr"
                                :index="index"
                            />
                        </li>
                    </ol>
                </template>
            </AccordionWrapper>
            <div v-else>
                <fieldset
                    v-for="(
                        group, counter
                    ) in instancedResource.getFieldGroupings('Form')"
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
                                :resource="resourceToSave"
                                :attr="attr"
                                :index="index"
                            />
                        </li>
                    </ol>
                </fieldset>
            </div>
            <fieldset
                class="action"
                v-if="
                    !instancedResource.stickyToolbar ||
                    (instancedResource.stickyToolbar &&
                        !instancedResource.stickyToolbar.includes('Form'))
                "
            >
                <DropdownButtons
                    :dropdownButtons="saveDropdownButtonActions"
                    :cssClass="'btn-primary'"
                >
                    <ButtonSubmit :title="$__('Save')" />
                </DropdownButtons>
                <router-link
                    :to="{ name: instancedResource.components.list }"
                    role="button"
                    class="cancel"
                    >{{ $__("Cancel") }}</router-link
                >
            </fieldset>
        </form>
    </div>
</template>

<script>
import { computed, onBeforeMount, reactive, ref, useTemplateRef } from "vue";
import FormElement from "./FormElement.vue";
import ButtonSubmit from "./ButtonSubmit.vue";
import DropdownButtons from "./DropdownButtons.vue";
import TabsWrapper from "./TabsWrapper.vue";
import AccordionWrapper from "./AccordionWrapper.vue";
import { $__ } from "@koha-vue/i18n";

export default {
    inheritAttrs: false,
    setup(props) {
        const initialized = ref(false);
        const resource = ref(null);
        const editMode = ref(false);

        const resourceToSave = computed(() => {
            return (
                resource.value || reactive(props.instancedResource.newResource)
            );
        });

        const resourceForm = computed({
            get() {
                return useTemplateRef("resourceForm");
            },
            set(value) {
                return value;
            },
        });

        onBeforeMount(() => {
            if (
                props.instancedResource.route.params[
                    props.instancedResource.idAttr
                ]
            ) {
                editMode.value = true;
                props.instancedResource.getResource(
                    props.instancedResource.route.params[
                        props.instancedResource.idAttr
                    ],
                    {
                        resource,
                        initialized,
                        instancedResource: props.instancedResource,
                    },
                    "form"
                );
            } else {
                initialized.value = true;
            }
        });

        const saveAndNavigate = ($event, resourceToSave) => {
            const {
                components,
                navigationOnFormSave,
                onFormSave,
                router,
                idAttr,
            } = props.instancedResource;
            // Default to show
            const navigationAction =
                saveOptionSelected.value ||
                navigationOnFormSave ||
                components.show;
            const idParamRequired =
                navigationAction === components.show ||
                navigationAction === components.edit;
            onFormSave($event, resourceToSave).then(resource => {
                if (resource) {
                    router.push({
                        name: navigationAction,
                        ...(idParamRequired && {
                            params: {
                                [idAttr]: resource[idAttr],
                            },
                        }),
                    });
                }
            });
        };

        const saveOptionSelected = ref(
            props.instancedResource.navigationOnFormSave
        );
        const saveDropdownButtonActions = computed(() => {
            const { components, navigationOnFormSave } =
                props.instancedResource;
            const formToSubmit = resourceForm.value;
            const buttonOptions = {
                list: {
                    title: $__("Save and return to list"),
                    action: "submit",
                    cssClass: "btn btn-default",
                    callback: () => {
                        saveOptionSelected.value = components.list;
                        if (
                            props.instancedResource.stickyToolbar &&
                            props.instancedResource.stickyToolbar.includes(
                                "Form"
                            )
                        ) {
                            formToSubmit.value.requestSubmit();
                        }
                    },
                },
                show: {
                    title: $__("Save and show"),
                    action: "submit",
                    cssClass: "btn btn-default",
                    callback: () => {
                        saveOptionSelected.value = components.show;
                        if (
                            props.instancedResource.stickyToolbar &&
                            props.instancedResource.stickyToolbar.includes(
                                "Form"
                            )
                        ) {
                            formToSubmit.value.requestSubmit();
                        }
                    },
                },
                edit: {
                    title: $__("Save and continue editing"),
                    action: "submit",
                    cssClass: "btn btn-default",
                    callback: () => {
                        saveOptionSelected.value = components.edit;
                        if (
                            props.instancedResource.stickyToolbar &&
                            props.instancedResource.stickyToolbar.includes(
                                "Form"
                            )
                        ) {
                            formToSubmit.value.requestSubmit();
                        }
                    },
                },
            };
            return Object.keys(buttonOptions).reduce((acc, key) => {
                if (!components[key]) return acc;
                if (key === "show" && !navigationOnFormSave) return acc;
                if (components[key] === navigationOnFormSave) return acc;
                return [buttonOptions[key], ...acc];
            }, []);
        });

        return {
            initialized,
            resource,
            resourceToSave,
            resourceForm,
            saveAndNavigate,
            editMode,
            saveDropdownButtonActions,
        };
    },
    props: {
        instancedResource: Object,
    },
    components: {
        ButtonSubmit,
        FormElement,
        TabsWrapper,
        AccordionWrapper,
        DropdownButtons,
    },
    name: "ResourceFormSave",
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
