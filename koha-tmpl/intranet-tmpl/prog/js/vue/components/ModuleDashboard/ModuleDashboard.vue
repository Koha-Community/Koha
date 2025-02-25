<template>
    <div>
        <div id="dashboard-header">
            <p>
                {{ $__("Customize your dashboard by adding widgets.") }}
                <a href="#" id="open-widget-picker" @click="toggleWidgetPicker">
                    {{ $__("Open Widget Picker") }}
                </a>
            </p>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6 dashboard-left-col">
            <draggable
                :ghost="true"
                @drag="handleDrag"
                class="dragArea list-group w-full"
                :list="selectedWidgetsLeft"
                group="widgets"
            >
                <component
                    v-for="(widget, index) in selectedWidgetsLeft"
                    :key="widget.name"
                    :is="widget"
                    display="dashboard"
                    dashboardColumn="left"
                    @moveWidget="moveWidget"
                    @removed="removeWidget(widget)"
                ></component>
            </draggable>
        </div>
        <div class="col-md-6 dashboard-right-col">
            <draggable
                :ghost="true"
                @drag="handleDrag"
                class="dragArea list-group w-full"
                :list="selectedWidgetsRight"
                group="widgets"
            >
                <component
                    v-for="(widget, index) in selectedWidgetsRight"
                    :key="widget.name"
                    :is="widget"
                    display="dashboard"
                    dashboardColumn="right"
                    @moveWidget="moveWidget"
                    @removed="removeWidget(widget)"
                ></component>
            </draggable>
        </div>
    </div>
</template>

<script>
import { onMounted, ref, watch, inject } from "vue";
import WidgetPicker from "./WidgetPicker.vue";
import VueCookies from "vue-cookies";
import { $__ } from "@koha-vue/i18n";
import { VueDraggableNext } from "vue-draggable-next";

export default {
    setup(props) {
        const availableWidgets = props.availableWidgets;
        const selectedWidgetsLeft = ref([]);
        const selectedWidgetsRight = ref([]);

        const { setComponentDialog } = inject("mainStore");

        const handleDrag = event => {
            const dropContext = event.relatedContext;
            if (dropContext) {
                const dropElement = dropContext.element;
                dropElement.style.border = "2px dotted #ccc";
                event.onDragEnd(() => {
                    dropElement.style.border = "";
                });
            }
        };

        function removeWidget(widget) {
            const indexLeft = selectedWidgetsLeft.value.indexOf(widget);
            const indexRight = selectedWidgetsRight.value.indexOf(widget);
            if (indexLeft > -1) {
                selectedWidgetsLeft.value.splice(indexLeft, 1);
            } else if (indexRight > -1) {
                selectedWidgetsRight.value.splice(indexRight, 1);
            }
        }

        function addWidget(widget) {
            if (
                !selectedWidgetsLeft.value.includes(widget) &&
                !selectedWidgetsRight.value.includes(widget)
            ) {
                if (
                    selectedWidgetsLeft.value.length <=
                    selectedWidgetsRight.value.length
                ) {
                    selectedWidgetsLeft.value.unshift(widget);
                } else {
                    selectedWidgetsRight.value.unshift(widget);
                }
            }
        }

        function moveWidget(widget) {
            if (
                selectedWidgetsLeft.value.some(
                    element => element.name === widget.componentName
                )
            ) {
                selectedWidgetsRight.value.unshift(
                    selectedWidgetsLeft.value.find(
                        element => element.name === widget.componentName
                    )
                );
                selectedWidgetsLeft.value = selectedWidgetsLeft.value.filter(
                    element => element.name !== widget.componentName
                );
            } else if (
                selectedWidgetsRight.value.some(
                    element => element.name === widget.componentName
                )
            ) {
                selectedWidgetsLeft.value.unshift(
                    selectedWidgetsRight.value.find(
                        element => element.name === widget.componentName
                    )
                );
                selectedWidgetsRight.value = selectedWidgetsRight.value.filter(
                    element => element.name !== widget.componentName
                );
            }
        }

        const toggleWidgetPicker = e => {
            setComponentDialog({
                title: $__("Customize your dashboard widgets"),
                cancel_label: $__("Close"),
                componentPath:
                    "@koha-vue/components/ModuleDashboard/WidgetPicker.vue",
                componentProps: {
                    selectedWidgetsLeft: selectedWidgetsLeft.value,
                    selectedWidgetsRight: selectedWidgetsRight.value,
                    availableWidgets: availableWidgets,
                },
                componentListeners: {
                    added: widget => addWidget(widget),
                    removed: widget => removeWidget(widget),
                },
            });
        };

        onMounted(() => {
            const storedWidgets = VueCookies.get("dashboard-widgets");
            if (storedWidgets) {
                const { left, right } = storedWidgets;
                left.forEach(widgetName => {
                    const widget = availableWidgets.find(
                        widget => widget.name === widgetName
                    );
                    if (widget) {
                        selectedWidgetsLeft.value.push(widget);
                    }
                });
                right.forEach(widgetName => {
                    const widget = availableWidgets.find(
                        widget => widget.name === widgetName
                    );
                    if (widget) {
                        selectedWidgetsRight.value.push(widget);
                    }
                });
            } else {
                availableWidgets.forEach(widget => addWidget(widget));
            }
        });

        watch(
            [selectedWidgetsLeft, selectedWidgetsRight],
            ([left, right]) => {
                const leftWidgetNames = left.map(widget => widget.name);
                const rightWidgetNames = right.map(widget => widget.name);
                VueCookies.set(
                    "dashboard-widgets",
                    JSON.stringify({
                        left: leftWidgetNames,
                        right: rightWidgetNames,
                    }),
                    "30d"
                );
            },
            { deep: true }
        );

        return {
            ...props,
            selectedWidgetsLeft,
            selectedWidgetsRight,
            addWidget,
            handleDrag,
            removeWidget,
            moveWidget,
            toggleWidgetPicker,
        };
    },
    components: {
        WidgetPicker,
        draggable: VueDraggableNext,
    },
    name: "ModuleDashboard",
};
</script>
<style>
.sortable-ghost {
    height: 50px !important;
}

.sortable-ghost.sortable-chosen > * {
    visibility: hidden;
}
</style>
