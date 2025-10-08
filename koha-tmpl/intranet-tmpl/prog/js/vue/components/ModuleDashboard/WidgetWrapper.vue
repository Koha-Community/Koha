<!-- WidgetWrapper.vue -->
<template>
    <template v-if="display === 'picker'">
        <WidgetPickerWrapper
            :id="id"
            :alreadyAdded="alreadyAdded"
            @added="handleAddWidget"
            @removed="handleRemoveWidget"
            :name="name"
            :icon="icon"
            :description="description"
        />
    </template>

    <template v-else-if="display === 'dashboard'">
        <WidgetDashboardWrapper
            @removed="handleRemoveWidget"
            @moveWidget="handleMoveWidget"
            :id="id"
            :settings="settings"
            :settings_definitions="settings_definitions"
            :loading="loading"
            :dashboardColumn="dashboardColumn"
            :dashboardTopRow="dashboardTopRow"
            :name="name"
            :icon="icon"
        >
            <slot />
        </WidgetDashboardWrapper>
    </template>
</template>

<script>
import { inject, toRefs } from "vue";
import WidgetDashboardWrapper from "./WidgetDashboardWrapper.vue";
import WidgetPickerWrapper from "./WidgetPickerWrapper.vue";

export default {
    name: "WidgetWrapper",
    components: {
        WidgetDashboardWrapper,
        WidgetPickerWrapper,
    },
    props: {
        display: {
            type: String,
            required: true,
        },
        alreadyAdded: {
            type: Boolean,
            default: false,
        },
        dashboardColumn: {
            type: String,
        },
        dashboardTopRow: {
            type: Boolean,
        },
        id: {
            type: String,
            required: true,
        },
        name: {
            type: String,
            required: true,
        },
        icon: {
            type: String,
        },
        description: {
            type: String,
            required: true,
        },
        loading: {
            type: Boolean,
        },
        settings: {
            type: Object,
        },
        settings_definitions: {
            type: Array,
        },
    },
    setup(props) {
        // Destructure props so they are all reactive refs
        const {
            display,
            alreadyAdded,
            dashboardColumn,
            dashboardTopRow,
            id,
            name,
            icon,
            description,
            loading,
            settings,
            settings_definitions,
        } = toRefs(props);

        const addWidget = inject("addWidget");
        const removeWidget = inject("removeWidget");
        const moveWidget = inject("moveWidget");

        const handleAddWidget = () => {
            if (addWidget) addWidget();
        };

        const handleRemoveWidget = () => {
            if (removeWidget) removeWidget();
        };

        const handleMoveWidget = direction => {
            if (moveWidget) moveWidget(direction);
        };

        return {
            display,
            alreadyAdded,
            dashboardColumn,
            dashboardTopRow,
            id,
            name,
            icon,
            description,
            loading,
            settings,
            settings_definitions,
            handleAddWidget,
            handleRemoveWidget,
            handleMoveWidget,
        };
    },
};
</script>

<style>
.widget-title {
    margin-top: 0;
    font-weight: bold;
    font-size: 1.2rem;
}
</style>
