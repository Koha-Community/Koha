<template>
    <div
        id="toolbar"
        :class="sticky ? 'btn-toolbar sticky' : 'btn-toolbar'"
        ref="toolbar"
    >
        <template v-if="toolbarButtons">
            <template
                :key="`toolbar-button-${i}`"
                v-for="(button, i) in toolbarButtons(resource, component, i18n)"
            >
                <ToolbarButton
                    :action="button.action"
                    @click="button.onClick"
                    :title="button.title"
                    :to="button.to"
                    :icon="button.icon"
                />
            </template>
        </template>
        <slot></slot>
    </div>
</template>

<script>
import ToolbarButton from "./ToolbarButton.vue";
export default {
    props: {
        toolbarButtons: Function,
        component: String,
        resource: Object,
        i18n: Object,
    },
    components: { ToolbarButton },
    name: "Toolbar",
    props: {
        sticky: {
            type: Boolean,
            default: false,
        },
    },
    data() {
        return {
            observer: null,
        };
    },
    methods: {},
    mounted() {
        if (this.sticky) {
            apply_sticky(this.$refs.toolbar);
        }
    },
};
</script>
