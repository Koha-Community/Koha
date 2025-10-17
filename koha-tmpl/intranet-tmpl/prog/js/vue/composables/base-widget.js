// composables/useBaseWidget.js
import { ref, computed, watch, provide, onMounted, onBeforeMount } from "vue";

export function useBaseWidget(widgetConfig, emit) {
    const loading = ref(
        widgetConfig.loading !== undefined ? widgetConfig.loading : true
    );
    const settings = ref(widgetConfig.settings || {});
    const settings_definitions = ref(widgetConfig.settings_definitions || []);
    const removeWidget = () => emit("removed", widgetConfig);
    const addWidget = () => emit("added", widgetConfig);
    const moveWidget = direction => {
        emit("moveWidget", {
            widgetComponentName: widgetConfig.id,
            currentColumn: widgetConfig.dashboardColumn,
            direction: direction,
        });
    };

    provide("removeWidget", removeWidget);
    provide("addWidget", addWidget);
    provide("moveWidget", moveWidget);

    const widgetWrapperProps = computed(() => ({
        id: widgetConfig.id,
        display: widgetConfig.display,
        alreadyAdded: widgetConfig.alreadyAdded,
        dashboardColumn: widgetConfig.dashboardColumn,
        dashboardTopRow: widgetConfig.dashboardTopRow,
        name: widgetConfig.name,
        icon: widgetConfig.icon,
        loading: loading.value,
        description: widgetConfig.description,
        settings: settings.value,
        settings_definitions: settings_definitions.value,
    }));

    const getWidgetSavedSettings = () => {
        const savedSettings = localStorage.getItem(
            "widget-" + widgetConfig.id + "-settings"
        );
        return savedSettings || null;
    };

    onBeforeMount(() => {
        if (widgetConfig.display === "dashboard") {
            const savedSettings = getWidgetSavedSettings();
            if (savedSettings) {
                settings.value = savedSettings;
            }
        }
    });

    /**
     * Lifecycle method that runs when the widget is mounted on the dashboard.
     * Use this to e.g. fetch data
     *
     * Sample usage from ERMCounts.vue:
     *
     *   baseWidget.onDashboardMounted(() => {
     *     getCounts();
     *   });
     */
    function onDashboardMounted(callback) {
        onMounted(() => {
            if (widgetConfig.display === "dashboard") {
                callback?.();
            }
        });
    }

    watch(
        settings,
        newSettings => {
            if (widgetConfig.display === "dashboard" && newSettings !== null) {
                localStorage.setItem(
                    "widget-" + widgetConfig.id + "-settings",
                    JSON.stringify(newSettings)
                );
            }
        },
        { deep: true }
    );

    return {
        ...widgetConfig,
        loading,
        display: widgetConfig.display,
        settings,
        settings_definitions,
        widgetWrapperProps,
        removeWidget,
        addWidget,
        moveWidget,
        onDashboardMounted,
    };
}
