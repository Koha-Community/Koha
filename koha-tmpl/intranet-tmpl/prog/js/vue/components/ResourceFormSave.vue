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
            :componentPropData="{ ...$props, ...$data, resourceForm }"
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
                <DropdownButtons :dropdownButtons="dropdownButtons" :cssClass="'btn-primary'">
                    <ButtonSubmit :title="buttonTextLeader" />
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
import { $__ } from "@koha-vue/i18n"

export default {
    inheritAttrs: false,
    setup(props) {
        const initialized = ref(false);
        const resource = ref(null);
        const editMode = ref(false);
        const buttonTextLeader = computed(() => editMode.value ? $__("Save") : $__("Submit"))

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
                editMode.value = true
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
            const { components, navigationOnFormSave, onFormSave, router, idAttr } = props.instancedResource
            // Default to show
            const navigationAction = saveOptionSelected.value || navigationOnFormSave || components.show
            const idParamRequired = navigationAction === components.show || navigationAction === components.edit
            onFormSave($event, resourceToSave).then(resource => {
                if(resource) {
                    router.push({
                        name: navigationAction,
                        ...(idParamRequired && {
                            params: {
                                [idAttr]: resource[idAttr]
                            }
                        })
                    })
                }
            })
        }

        const saveOptionSelected = ref(props.instancedResource.navigationOnFormSave)
        const dropdownButtons = computed(() => {
            const { components, navigationOnFormSave } = props.instancedResource

            const buttonOptions = {
                list: {
                    title: $__("%s and return to list").format(buttonTextLeader.value),
                    action: "submit",
                    cssClass: "btn btn-default",
                    callback: () => {
                        saveOptionSelected.value = components.list
                    }
                },
                show: {
                    title: $__("%s and show").format(buttonTextLeader.value),
                    action: "submit",
                    cssClass: "btn btn-default",
                    callback: () => {
                        saveOptionSelected.value = components.show
                    }
                },
                edit: {
                    title: $__("%s and continue editing").format(buttonTextLeader.value),
                    action: "submit",
                    cssClass: "btn btn-default",
                    callback: () => {
                        saveOptionSelected.value = components.edit
                    }
                }
            }
            return Object.keys(buttonOptions).reduce((acc, key) => {
                if(key === "show" && !navigationOnFormSave) return acc
                if(components[key] === navigationOnFormSave) return acc
                return [buttonOptions[key], ...acc]
            },[])
        })

        return {
            initialized,
            resource,
            resourceToSave,
            resourceForm,
            saveAndNavigate,
            editMode,
            dropdownButtons,
            buttonTextLeader
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
        DropdownButtons
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
