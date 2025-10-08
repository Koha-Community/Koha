<template>
    <WidgetWrapper v-bind="widgetWrapperProps">
        <template #default>
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                :key="JSON.stringify(tableOptions)"
            />
        </template>
    </WidgetWrapper>
</template>

<script>
import { inject, ref, computed } from "vue";
import { storeToRefs } from "pinia";
import WidgetWrapper from "../WidgetWrapper.vue";
import KohaTable from "../../KohaTable.vue";
import { useBaseWidget } from "../../../composables/base-widget.js";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "ERMLicensesNeedingAction",
    components: { WidgetWrapper, KohaTable },
    props: {
        display: String,
        dashboardColumn: String,
    },
    emits: ["removed", "added", "moveWidget"],
    setup(props, { emit }) {
        const ERMStore = inject("ERMStore");
        const { get_lib_from_av } = ERMStore;
        const { authorisedValues } = storeToRefs(ERMStore);
        const av_license_statuses = authorisedValues.value.av_license_statuses;

        const table = ref();
        const default_settings = {
            status: ["in_negotiation", "not_yet_active", "rejected"],
            per_page: 5,
        };
        const settings = ref(default_settings);
        const settings_definitions = ref([
            {
                name: "status",
                type: "select",
                label: __("Status"),
                showInTable: true,
                options: av_license_statuses.map(status => ({
                    value: status.value,
                    description: status.description,
                })),
                allowMultipleChoices: true,
                requiredKey: "value",
                selectLabel: "description",
            },
            {
                name: "ended_on",
                type: "select",
                label: __("Ends in the next"),
                showInTable: true,
                options: [
                    { value: "week", description: __("Week") },
                    { value: "two_weeks", description: __("Two weeks") },
                    { value: "month", description: __("Month") },
                    { value: "two_months", description: __("Two months") },
                ],
                requiredKey: "value",
                selectLabel: "description",
            },
            {
                name: "per_page",
                type: "select",
                label: __("Show"),
                showInTable: true,
                options: [
                    { value: 5, description: "5" },
                    { value: 10, description: "10" },
                    { value: 20, description: "20" },
                ],
                requiredKey: "value",
                selectLabel: "description",
            },
        ]);

        function settingsToQueryParams(settings) {
            const params = {};

            if (settings.status && settings.status.length > 0) {
                params["me.status"] = {
                    "-in": settings.status,
                };
            }

            if (settings.ended_on) {
                const now = new Date();
                let limitDate;

                switch (settings.ended_on) {
                    case "week":
                        limitDate = new Date(now.setDate(now.getDate() + 7));
                        break;
                    case "two_weeks":
                        limitDate = new Date(now.setDate(now.getDate() + 14));
                        break;
                    case "month":
                        limitDate = new Date(now.setMonth(now.getMonth() + 1));
                        break;
                    case "two_months":
                        limitDate = new Date(now.setMonth(now.getMonth() + 2));
                        break;
                }

                if (limitDate) {
                    params["me.ended_on"] = { "<=": limitDate };
                }
            }

            return params;
        }

        const tableOptions = computed(() => ({
            columns: [
                {
                    title: __("Name"),
                    data: "name",
                    searchable: true,
                    orderable: true,
                    render(data, type, row) {
                        const name = escape_str(row.name);
                        const shortName =
                            name.length > 25
                                ? name.substring(0, 22) + "..."
                                : name;
                        return `<a href="/cgi-bin/koha/erm/licenses/${row.license_id}" class="show">${shortName}</a>`;
                    },
                },
                {
                    title: __("Type"),
                    data: "type",
                    searchable: true,
                    orderable: true,
                    render(data, type, row) {
                        return escape_str(
                            get_lib_from_av("av_license_types", row.type)
                        );
                    },
                },
                {
                    title: __("Status"),
                    data: "status",
                    searchable: true,
                    orderable: true,
                    render(data, type, row) {
                        return escape_str(
                            get_lib_from_av("av_license_statuses", row.status)
                        );
                    },
                },
                {
                    title: __("Ends on"),
                    data: "ended_on",
                    searchable: true,
                    orderable: true,
                    render(data, type, row) {
                        return $date(row.ended_on);
                    },
                },
            ],
            options: {
                dom: "t",
                embed: "vendor,extended_attributes,+strings",
                pageLength: settings.value.per_page || 5,
            },
            url: "/api/v1/erm/licenses",
            default_filters: settingsToQueryParams(settings.value),
        }));

        const baseWidget = useBaseWidget(
            {
                id: "ERMLicensesNeedingAction",
                name: $__("Licenses needing action"),
                icon: "fa fa-gavel",
                description: $__(
                    "Show licenses that need action. It filters licenses by status and end date. This widget is configurable."
                ),
                loading: false,
                settings: settings,
                settings_definitions: settings_definitions,
                ...props,
            },
            emit
        );

        return {
            ...baseWidget,
            table,
            tableOptions,
        };
    },
};
</script>
