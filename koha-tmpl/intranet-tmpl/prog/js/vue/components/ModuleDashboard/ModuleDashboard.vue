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
            <div
                v-if="selectedWidgetsLeft.length === 0"
                class="empty-placeholder"
            >
                {{ $__("Drop widgets here") }}
            </div>
            <draggable
                :ghost="true"
                @drag="handleDrag"
                class="dragArea list-group w-full"
                :list="selectedWidgetsLeft"
                group="widgets"
                handle=".widget-drag-handle"
                :class="[
                    'dragArea',
                    'list-group',
                    'w-full',
                    { 'empty-drag-area': selectedWidgetsLeft.length === 0 },
                ]"
            >
                <component
                    v-for="(widget, index) in selectedWidgetsLeft"
                    :key="widget.name + '-' + index"
                    :is="widget"
                    display="dashboard"
                    dashboardColumn="left"
                    :dashboardTopRow="index === 0"
                    @moveWidget="moveWidget"
                    @removed="removeWidget(widget)"
                ></component>
            </draggable>
        </div>
        <div class="col-md-6 dashboard-right-col">
            <div
                v-if="selectedWidgetsRight.length === 0"
                class="empty-placeholder"
            >
                {{ $__("Drop widgets here") }}
            </div>
            <draggable
                :ghost="true"
                @drag="handleDrag"
                class="dragArea list-group w-full"
                :list="selectedWidgetsRight"
                group="widgets"
                handle=".widget-drag-handle"
                :class="[
                    'dragArea',
                    'list-group',
                    'w-full',
                    { 'empty-drag-area': selectedWidgetsRight.length === 0 },
                ]"
            >
                <component
                    v-for="(widget, index) in selectedWidgetsRight"
                    :key="widget.name + '-' + index"
                    :is="widget"
                    display="dashboard"
                    dashboardColumn="right"
                    :dashboardTopRow="index === 0"
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
import { $__ } from "@koha-vue/i18n";
import { VueDraggableNext } from "vue-draggable-next";

export default {
    props: {
        availableWidgets: Array,
    },
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

        function moveWidget(params) {
            if (params.direction === "right") {
                selectedWidgetsRight.value.unshift(
                    selectedWidgetsLeft.value.find(
                        element => element.name === params.widgetComponentName
                    )
                );
                selectedWidgetsLeft.value = selectedWidgetsLeft.value.filter(
                    element => element.name !== params.widgetComponentName
                );
            } else if (params.direction === "left") {
                selectedWidgetsLeft.value.unshift(
                    selectedWidgetsRight.value.find(
                        element => element.name === params.widgetComponentName
                    )
                );
                selectedWidgetsRight.value = selectedWidgetsRight.value.filter(
                    element => element.name !== params.widgetComponentName
                );
            } else if (
                params.direction === "up" ||
                params.direction === "down"
            ) {
                const list =
                    params.currentColumn === "left"
                        ? selectedWidgetsLeft.value
                        : selectedWidgetsRight.value;

                const currentIndex = list.findIndex(
                    element => element.name === params.widgetComponentName
                );

                if (currentIndex === -1) return;

                const newIndex =
                    params.direction === "up"
                        ? currentIndex - 1
                        : currentIndex + 1;

                if (newIndex < 0 || newIndex >= list.length) return; // Out of bounds

                if (params.currentColumn === "left") {
                    selectedWidgetsLeft.value = (() => {
                        const arr = [...selectedWidgetsLeft.value];
                        const [item] = arr.splice(currentIndex, 1);
                        arr.splice(newIndex, 0, item);
                        return arr;
                    })();
                } else if (params.currentColumn === "right") {
                    selectedWidgetsRight.value = (() => {
                        const arr = [...selectedWidgetsRight.value];
                        const [item] = arr.splice(currentIndex, 1);
                        arr.splice(newIndex, 0, item);
                        return arr;
                    })();
                }
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
            const storedWidgets = localStorage.getItem("dashboard-widgets");
            if (storedWidgets) {
                const { left, right } = JSON.parse(storedWidgets);
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
                localStorage.setItem(
                    "dashboard-widgets",
                    JSON.stringify({
                        left: leftWidgetNames,
                        right: rightWidgetNames,
                    })
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
.dashboard-right-col,
.dashboard-left-col {
    position: relative;
}

.empty-placeholder {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    min-height: 150px;
    background-color: #fafafa;
    color: #999;
    font-style: italic;
    font-size: 1.2rem;
    pointer-events: none;
    border: 2px dotted #ccc;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    z-index: 2;
}

.empty-drag-area {
    min-height: 150px;
}
</style>
