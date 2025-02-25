<template>
    <WidgetWrapper v-bind="widgetWrapperProps">
        <template #default>
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                :key="JSON.stringify(tableOptions)"
                @view="viewJob"
            />
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
    name: "ERMLatestSUSHIJobs",
    components: { WidgetWrapper, KohaTable },
    props: {
        display: String,
    },
    emits: ["removed", "added", "moveWidget"],
    setup(props, { emit }) {
        const baseWidget = useBaseWidget(
            {
                id: "ERMLatestSUSHIJobs",
                name: $__("Latest SUSHI Counter jobs"),
                icon: "fa-solid fa-gears",
                description: $__("Show latest SUSHI Counter background jobs."),
                loading: false,
                ...props,
            },
            emit
        );

        const table = ref();

        const job_statuses = [
            { _id: "new", _str: $__("New") },
            { _id: "cancelled", _str: $__("Cancelled") },
            { _id: "finished", _str: $__("Finished") },
            { _id: "started", _str: $__("Started") },
            { _id: "running", _str: $__("Running") },
            { _id: "failed", _str: $__("Failed") },
        ];

        function get_job_status(status) {
            const status_lib = job_statuses.find(s => s._id === status);
            return status_lib ? status_lib._str : status;
        }

        function getTableColumns() {
            return [
                {
                    title: $__("Status"),
                    data: "status",
                    searchable: true,
                    orderable: true,
                    render(data, type, row) {
                        return get_job_status(row.status).escapeHtml();
                    },
                },
                {
                    title: $__("Data Provider"),
                    data: "data",
                    searchable: true,
                    orderable: true,
                    render(data) {
                        return (
                            '<a href="/cgi-bin/koha/erm/eusage/usage_data_providers/' +
                            data.ud_provider_id +
                            '" class="show">' +
                            escape_str(data.ud_provider_name) +
                            "</a>"
                        );
                    },
                },
                {
                    title: $__("Started"),
                    data: "started_date",
                    searchable: true,
                    orderable: true,
                    render(data, type, row) {
                        return $datetime(row.started_date);
                    },
                },
                {
                    title: $__("Ended"),
                    data: "ended_date",
                    searchable: true,
                    orderable: true,
                    render(data, type, row) {
                        return $datetime(row.ended_date);
                    },
                },
            ];
        }

        const tableOptions = computed(() => ({
            columns: getTableColumns(),
            options: {
                dom: "t",
                pageLength: 5,
                order: [2, "desc"],
            },
            url: "/api/v1/jobs",
            default_filters: {
                only_current: 0,
                type: "erm_sushi_harvester",
            },
            actions: {
                0: ["show"],
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

        function viewJob(job, dt, event) {
            event.preventDefault();
            window.open(
                "/cgi-bin/koha/admin/background_jobs.pl?op=view&id=" +
                    encodeURIComponent(job.job_id),
                "_blank"
            );
        }

        return {
            ...baseWidget,
            table,
            tableOptions,
            viewJob,
            getTableColumns,
        };
    },
};
</script>
