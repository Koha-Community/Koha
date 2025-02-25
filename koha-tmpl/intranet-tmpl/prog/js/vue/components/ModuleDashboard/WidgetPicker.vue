<template>
    <div v-for="widget in availableWidgets" :key="widget" class="widget-item">
        <component
            display="picker"
            :is="widget"
            :alreadyAdded="alreadyOnDashboard(widget)"
            @removed="removeWidget(widget)"
            @added="addWidget(widget)"
        ></component>
    </div>
</template>

<script>
export default {
    props: {
        availableWidgets: {
            type: Array,
            required: true,
        },
        selectedWidgetsLeft: {
            type: Array,
            required: true,
        },
        selectedWidgetsRight: {
            type: Array,
            required: true,
        },
    },

    setup(props, { emit }) {
        const availableWidgets = props.availableWidgets;
        const selectedWidgetsLeft = props.selectedWidgetsLeft;
        const selectedWidgetsRight = props.selectedWidgetsRight;

        const removeWidget = widget => {
            emit("removed", widget);
        };
        const addWidget = widget => {
            emit("added", widget);
        };

        const alreadyOnDashboard = widget => {
            return (
                selectedWidgetsLeft.includes(widget) ||
                selectedWidgetsRight.includes(widget)
            );
        };

        return {
            ...props,
            addWidget,
            alreadyOnDashboard,
            removeWidget,
        };
    },
    emits: ["added", "removed"],
    name: "WidgetPicker",
};
</script>
