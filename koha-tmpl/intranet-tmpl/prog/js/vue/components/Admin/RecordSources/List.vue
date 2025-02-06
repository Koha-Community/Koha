<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="record_sources_list">
        <Toolbar>
            <ToolbarButton
                :to="{ name: 'RecordSourcesFormAdd' }"
                icon="plus"
                :title="$__('New record source')"
            />
        </Toolbar>
        <h1>{{ title }}</h1>
        <div v-if="record_sources_count > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @edit="doEdit"
                @delete="doDelete"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{ $__("There are no record sources defined") }}
        </div>
    </div>
</template>

<script>
import Toolbar from "../../Toolbar.vue";
import ToolbarButton from "../../ToolbarButton.vue";
import { inject } from "vue";
import { APIClient } from "../../../fetch/api-client.js";
import KohaTable from "../../KohaTable.vue";

export default {
    data() {
        return {
            title: this.$__("Record sources"),
            tableOptions: {
                options: { embed: "usage_count" },
                columns: [
                    {
                        title: this.$__("ID"),
                        data: "record_source_id",
                        searchable: true,
                    },
                    {
                        title: this.$__("Name"),
                        data: "name",
                        searchable: true,
                    },
                    {
                        title: __("Can be edited"),
                        data: "can_be_edited",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(
                                row.can_be_edited ? __("Yes") : __("No")
                            );
                        },
                    },
                ],
                actions: {
                    "-1": [
                        "edit",
                        {
                            delete: {
                                text: this.$__("Delete"),
                                icon: "fa fa-trash",
                                should_display: row => row.usage_count == 0,
                            },
                        },
                    ],
                },
                url: "/api/v1/record_sources",
            },
            initialized: false,
            record_sources_count: 0,
        };
    },
    setup() {
        const { setWarning, setMessage, setError, setConfirmationDialog } =
            inject("mainStore");
        return {
            setWarning,
            setMessage,
            setError,
            setConfirmationDialog,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getRecordSourcesCount().then(() => (vm.initialized = true));
        });
    },
    methods: {
        async getRecordSourcesCount() {
            const client = APIClient.record_sources;
            await client.record_sources.count().then(
                count => {
                    this.record_sources_count = count;
                },
                error => {}
            );
        },
        newRecordSource() {
            this.$router.push({ name: "RecordSourcesFormAdd" });
        },
        doEdit: function ({ record_source_id }, dt, event) {
            this.$router.push({
                name: "RecordSourcesFormAddEdit",
                params: { record_source_id },
            });
        },
        doDelete: function (record_source, dt, event) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to delete this record source?"
                    ),
                    message: record_source.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.record_sources;
                    client.record_sources
                        .delete(record_source.record_source_id)
                        .then(
                            success => {
                                this.setMessage(
                                    this.$__(
                                        "Record source '%s' deleted"
                                    ).format(record_source.name),
                                    true
                                );
                                dt.draw();
                            },
                            error => {}
                        );
                }
            );
        },
    },
    components: {
        KohaTable,
        Toolbar,
        ToolbarButton,
    },
};
</script>
