<template>
    <div
        id="toolbar"
        :class="sticky ? 'btn-toolbar sticky' : 'btn-toolbar'"
        ref="toolbar"
    >
        <template v-if="sticky">
            <fieldset class="action" style="padding: 0; margin-bottom: 0">
                <DropdownButtons
                    :dropdownButtons="
                        componentPropData.saveDropdownButtonActions
                    "
                    :cssClass="'btn-primary'"
                >
                    <ButtonSubmit
                        :title="$__('Save')"
                        :callback="
                            () =>
                                componentPropData.resourceForm.value.requestSubmit()
                        "
                    />
                </DropdownButtons>
                <router-link
                    :to="{
                        name: componentPropData.instancedResource.components
                            .list,
                    }"
                    role="button"
                    class="cancel"
                    >{{ $__("Cancel") }}</router-link
                >
            </fieldset>
        </template>
        <template v-if="toolbarButtons">
            <template
                :key="`toolbar-button-${i}`"
                v-for="(button, i) in toolbarButtons(
                    resource,
                    component,
                    componentPropData
                )"
            >
                <DropdownButtons
                    v-if="button.dropdownButtons"
                    v-bind="{ ...button }"
                />
                <ToolbarButton v-else v-bind="{ ...button }" />
            </template>
        </template>
        <slot></slot>
    </div>
</template>

<script>
import { computed, useTemplateRef, watch } from "vue";
import ToolbarButton from "./ToolbarButton.vue";
import DropdownButtons from "./DropdownButtons.vue";
import ButtonSubmit from "./ButtonSubmit.vue";
export default {
    props: {
        toolbarButtons: Function,
        component: String,
        resource: Object,
        componentPropData: Object,
        sticky: {
            type: Boolean,
            default: false,
        },
    },
    components: { ToolbarButton, DropdownButtons, ButtonSubmit },
    name: "Toolbar",
    setup(props) {
        const toolbar = computed(() => {
            return useTemplateRef("toolbar");
        });
        watch(toolbar.value, newValue => {
            if (newValue && props.sticky) {
                apply_sticky(newValue);
            }
        });
    },
};
</script>
