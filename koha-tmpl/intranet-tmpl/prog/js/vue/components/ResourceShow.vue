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
            :tabList="instancedResource.getFieldGroupings('Show', resource)"
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
        <div v-else>
            <fieldset
                class="rows"
                v-for="(group, counter) in instancedResource.getFieldGroupings(
                    'Show',
                    resource
                )"
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
            <fieldset
                class="rows"
                v-for="(item, counter) in instancedResource.appendToShow(this)"
                v-bind:key="counter"
            >
                <legend v-if="item.name">{{ item.name }}</legend>
                <ShowElement
                    :resource="resource"
                    :attr="item"
                    :instancedResource="instancedResource"
                />
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
import { onBeforeMount, ref } from "vue";
import TabsWrapper from "./TabsWrapper.vue";

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

        return {
            initialized,
            resource,
            additionalProps,
        };
    },
    props: {
        instancedResource: Object,
    },
    components: { Toolbar, ShowElement, TabsWrapper },
    name: "ResourceShow",
};
</script>
