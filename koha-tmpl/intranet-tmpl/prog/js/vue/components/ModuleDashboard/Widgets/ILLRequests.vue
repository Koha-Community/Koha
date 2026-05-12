<template>
    <WidgetWrapper v-bind="widgetWrapperProps">
        <template #default>
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                :key="JSON.stringify(tableOptions)"
                @view="viewILLRequest"
            />
            <div>
                <button
                    class="btn btn-primary"
                    type="button"
                    @click="visitOldILLModule"
                >
                    {{ $__("Visit ILL requests (previously ILL Module)") }}
                </button>
            </div>
        </template>
    </WidgetWrapper>
</template>

<script>
import { ref, computed } from "vue";
import WidgetWrapper from "../WidgetWrapper.vue";
import KohaTable from "../../KohaTable.vue";
import { useBaseWidget } from "../../../composables/base-widget.js";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "ILLRequests",
    components: { WidgetWrapper, KohaTable },
    props: {
        display: String,
        dashboardColumn: String,
    },
    emits: ["removed", "added", "moveWidget"],
    setup(props, { emit }) {
        const table = ref();
        const default_settings = {
            //TODO: Grab logged in user, filter by user branch by default
            status: [], //["NEW", "UNAUTH"],
            per_page: 5,
        };
        const settings = ref(default_settings);
        const settings_definitions = ref([
            {
                name: "status",
                type: "select",
                label: __("Status"),
                showInTable: true,
                options: settings.value.status.map(status => ({
                    value: status.value,
                    description: "my ets",
                })),
                allowMultipleChoices: true,
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

            return params;
        }

        const tableOptions = computed(() => ({
            columns: [
                {
                    title: __("ID"),
                    data: "ill_request_id",
                    searchable: true,
                    orderable: true,
                    render: function (data, type, row, meta) {
                        return (
                            '<a target="_blank" href="/cgi-bin/koha/ill/ill-requests.pl?' +
                            "op=illview&amp;illrequest_id=" +
                            encodeURIComponent(data) +
                            '">' +
                            escape_str(row.id_prefix) +
                            escape_str(data) +
                            "</a>"
                        );
                    },
                },
                {
                    title: __("Status"),
                    data: "_strings.status.str",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Library"),
                    data: "library.name",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Patron"),
                    data: "patron.firstname:patron.surname:patron.cardnumber",
                    render: function (data, type, row, meta) {
                        return row.patron
                            ? $patron_to_html(row.patron, {
                                  display_cardnumber: true,
                                  url: true,
                              })
                            : "";
                    },
                },
                {
                    title: __("Backend"),
                    data: "ill_backend_id",
                    searchable: true,
                    orderable: true,
                },
            ],
            options: {
                dom: "t",
                embed: "patron,library,extended_attributes,+strings",
                pageLength: settings.value.per_page || 5,
                processing: false,
            },
            url: "/api/v1/ill/requests",
            default_filters: settingsToQueryParams(settings.value),
            actions: {
                "-1": [
                    {
                        view: {
                            text: $__("View"),
                            icon: "fa fa-eye",
                        },
                    },
                ],
            },
        }));

        const baseWidget = useBaseWidget(
            {
                id: "ILLRequests",
                name: $__("ILL Requests"),
                icon: "fa fa-download",
                description: $__(
                    "Show ILL requests that need action. It filters requests by status and library. Provides a button to visit the ILL requests (previously ILL Module). This widget is configurable."
                ),
                loading: false,
                settings: settings,
                settings_definitions: settings_definitions,
                ...props,
            },
            emit
        );

        function viewILLRequest(req, dt, event) {
            event.preventDefault();
            window.open(
                "/cgi-bin/koha/ill/ill-requests.pl?op=illview&illrequest_id=" +
                    encodeURIComponent(req.ill_request_id),
                "_blank"
            );
        }

        function visitOldILLModule() {
            const url = "/cgi-bin/koha/ill/ill-requests.pl";
            window.location.href = url;
        }

        return {
            ...baseWidget,
            table,
            tableOptions,
            viewILLRequest,
            visitOldILLModule,
        };
    },
};
</script>
