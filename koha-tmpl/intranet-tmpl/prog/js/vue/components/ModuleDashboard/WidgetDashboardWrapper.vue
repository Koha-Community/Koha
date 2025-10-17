<template>
    <div class="widget" :id="id">
        <div class="widget-header">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="widget-title m-0">
                        <i v-if="icon" :icon="icon" :class="icon"></i>
                        {{ name }}
                    </h1>
                </div>
                <div class="col-md-6 text-end">
                    <div class="dropdown">
                        <button
                            class="btn btn-default"
                            type="button"
                            id="dropdownMenuButton"
                            data-bs-toggle="dropdown"
                            aria-expanded="false"
                        >
                            <font-awesome-icon icon="ellipsis-vertical" />
                        </button>
                        <ul
                            class="dropdown-menu"
                            aria-labelledby="dropdownMenuButton"
                        >
                            <li>
                                <button
                                    v-if="
                                        Object.keys(settings_definitions).length
                                    "
                                    class="dropdown-item toggle-settings"
                                    @mousedown="toggleSettings"
                                    :title="$__('Settings')"
                                >
                                    <font-awesome-icon icon="cog" />
                                    {{ $__("Settings") }}
                                </button>
                            </li>
                            <li v-if="!dashboardTopRow">
                                <button
                                    class="dropdown-item move-up"
                                    @mousedown="moveWidget('up')"
                                    :title="$__('Move up')"
                                >
                                    <font-awesome-icon icon="arrow-up" />
                                    {{ $__("Move up") }}
                                </button>
                            </li>
                            <li v-if="dashboardColumn === 'left'">
                                <button
                                    class="dropdown-item move-right"
                                    @mousedown="moveWidget('right')"
                                    :title="$__('Move to right')"
                                >
                                    <font-awesome-icon icon="arrow-right" />
                                    {{ $__("Move to right") }}
                                </button>
                            </li>
                            <li v-if="dashboardColumn === 'right'">
                                <button
                                    class="dropdown-item move-left"
                                    @mousedown="moveWidget('left')"
                                    :title="$__('Move to left')"
                                >
                                    <font-awesome-icon icon="arrow-left" />
                                    {{ $__("Move to left") }}
                                </button>
                            </li>
                            <li v-if="dashboardTopRow">
                                <button
                                    class="dropdown-item move-down"
                                    @mousedown="moveWidget('down')"
                                    :title="$__('Move down')"
                                >
                                    <font-awesome-icon icon="arrow-down" />
                                    {{ $__("Move down") }}
                                </button>
                            </li>
                            <li>
                                <button
                                    class="dropdown-item remove-widget"
                                    @mousedown="removeWidget"
                                    :title="$__('Remove')"
                                >
                                    <font-awesome-icon icon="trash" />
                                    {{ $__("Remove") }}
                                </button>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <div v-if="showSettings" class="widget-settings">
            <h3 class="widget-title">{{ $__("Settings") }}</h3>
            <form>
                <fieldset class="rows">
                    <ol>
                        <li
                            v-for="(setting, index) in settings_definitions"
                            v-bind:key="index"
                        >
                            <FormElement
                                :resource="settings"
                                :attr="setting"
                                :index="index"
                            />
                        </li>
                    </ol>
                </fieldset>
            </form>
            <div class="text-end">
                <button
                    type="button"
                    class="btn btn-default"
                    @click="toggleSettings"
                >
                    {{ $__("Close settings") }}
                </button>
            </div>
        </div>
        <div class="widget-content">
            <div v-if="loading" class="text-center">
                {{ $__("Loading...") }}
            </div>
            <slot v-else></slot>
        </div>
    </div>
</template>

<script>
import { ref } from "vue";
import FormElement from "../FormElement.vue";
export default {
    props: {
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
            required: false,
        },
        loading: {
            type: Boolean,
        },
        settings: {
            type: Object,
            default: () => ({}),
        },
        settings_definitions: {
            type: Object,
            default: () => ({}),
        },
        dashboardColumn: {
            type: String,
            required: false,
        },
        dashboardTopRow: {
            type: Boolean,
            required: true,
        },
    },
    setup(props, { emit }) {
        const showSettings = ref(false);

        const removeWidget = () => {
            emit("removed", props);
        };

        const moveWidget = direction => {
            emit("moveWidget", direction);
        };

        function toggleSettings() {
            showSettings.value = !showSettings.value;
        }

        return {
            showSettings,
            toggleSettings,
            removeWidget,
            moveWidget,
        };
    },
    emits: ["removed", "moveWidget"],
    components: {
        FormElement,
    },
};
</script>

<style scoped>
.widget {
    background-color: #fff;
    border: 1px solid #ccc;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 12px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.widget-header {
    background-color: #f7f7f7;
    border-bottom: 1px solid #ccc;
    border-top-left-radius: 8px;
    border-top-right-radius: 8px;
}

.widget-settings {
    border-bottom: 1px solid #ccc;
    border-top-left-radius: 8px;
    border-top-right-radius: 8px;
}

.widget-settings fieldset.rows ol {
    padding: 0;
}

.widget-settings form:after {
    content: "";
    display: table;
    clear: both;
}

.widget-content,
.widget-settings,
.widget-header {
    padding: 6px 12px;
    margin-bottom: 6px;
}
</style>
