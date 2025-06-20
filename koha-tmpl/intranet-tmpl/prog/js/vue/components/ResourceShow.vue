<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${instancedResource.resourceNamePlural}_show`">
        <slot
            name="toolbar"
            :resource="resource"
            :componentPropData="{ ...$props, ...$data }"
        />
        <h2>
            {{
                instancedResource.i18n.displayName +
                " #" +
                resource[instancedResource.idAttr]
            }}
        </h2>
        <TabsWrapper
            v-if="instancedResource.formGroupsDisplayMode == 'tabs'"
            :tabList="fieldList"
        >
            <template #tabContent="{ tabGroup }">
                <fieldset class="rows">
                    <legend v-if="tabGroup.name">{{ tabGroup.name }}</legend>
                    <ol>
                        <li
                            v-for="(attr, index) in tabGroup.fields"
                            v-bind:key="index"
                        >
                            <ShowElement
                                :resource="resource"
                                :attr="attr"
                                :instancedResource="instancedResource"
                            />
                        </li>
                    </ol>
                </fieldset>
            </template>
        </TabsWrapper>
        <AccordionWrapper
            v-else-if="instancedResource.formGroupsDisplayMode == 'accordion'"
            :accordionList="fieldList"
        >
            <template #accordionContent="{ accordionGroup }">
                <ol>
                    <li
                        v-for="(attr, index) in accordionGroup.fields"
                        v-bind:key="index"
                    >
                        <ShowElement
                            :resource="resource"
                            :attr="attr"
                            :instancedResource="instancedResource"
                        />
                    </li>
                </ol>
            </template>
        </AccordionWrapper>
        <div v-else>
            <fieldset
                class="rows"
                v-for="(group, counter) in fieldList"
                v-bind:key="counter"
            >
                <legend v-if="group.name">{{ group.name }}</legend>
                <ol>
                    <li
                        v-for="(attr, index) in group.fields"
                        v-bind:key="index"
                    >
                        <ShowElement
                            :resource="resource"
                            :attr="attr"
                            :instancedResource="instancedResource"
                        />
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    :to="{ name: instancedResource.listComponent }"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import Toolbar from "./Toolbar.vue";
import ShowElement from "./ShowElement.vue";
import { computed, onBeforeMount, ref } from "vue";
import TabsWrapper from "./TabsWrapper.vue";
import AccordionWrapper from "./AccordionWrapper.vue";

export default {
    inheritAttrs: false,
    setup(props) {
        const initialized = ref(false);
        const resource = ref(null);
        const additionalProps = ref({});

        onBeforeMount(() => {
            props.instancedResource.getResource(
                props.instancedResource.route.params[
                    props.instancedResource.idAttr
                ],
                {
                    resource,
                    initialized,
                    instancedResource: props.instancedResource,
                    additionalProps,
                },
                "show"
            );
        });

        const fieldList = computed(() => {
            const fieldGroupings = props.instancedResource.getFieldGroupings(
                "Show",
                resource.value
            );
            const fieldsToAppend = props.instancedResource
                .appendToShow({
                    ...props,
                    resource: resource.value,
                    additionalProps: additionalProps.value,
                })
                ?.filter(field => field.hidden(resource.value))
                .map(field => {
                    return {
                        name: field.name,
                        fields: [field],
                    };
                });

            return [
                ...fieldGroupings,
                ...(fieldsToAppend ? fieldsToAppend : []),
            ];
        });

        return {
            initialized,
            resource,
            additionalProps,
            fieldList,
        };
    },
    props: {
        instancedResource: Object,
    },
    components: { Toolbar, ShowElement, TabsWrapper, AccordionWrapper },
    name: "ResourceShow",
};
</script>
