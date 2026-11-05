<template>
    <BaseResource
        :routeAction="routeAction"
        :instancedResource="this"
    ></BaseResource>
</template>
<script>
import BaseResource from "../../BaseResource.vue";
import { useBaseResource } from "../../../composables/base-resource.js";
import { APIClient } from "../../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        routeAction: String,
    },
    setup(props) {
        const baseResource = useBaseResource({
            resourceName: "record_source",
            nameAttr: "name",
            idAttr: "record_source_id",
            components: {
                show: null,
                list: "RecordSourcesList",
                add: "RecordSourcesFormAdd",
                edit: "RecordSourcesFormAddEdit",
            },
            apiClient: APIClient.record_sources.record_sources,
            table: {
                resourceTableUrl: APIClient.record_sources.httpClient._baseURL,
            },
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this record source?"
                ),
                deleteSuccessMessage: $__("Record source %s deleted"),
                displayName: $__("Record source"),
                editLabel: $__("Edit record source #%s"),
                emptyListMessage: $__("There are no record sources defined"),
                newLabel: $__("New record source"),
            },
            props,
            navigationOnFormSave: "RecordSourcesList",
            resourceAttrs: [
                {
                    name: "record_source_id",
                    required: true,
                    type: "text",
                    label: $__("ID"),
                    hideIn: ["Form"],
                },
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: $__("Name"),
                },
                {
                    name: "can_be_edited",
                    type: "checkbox",
                    label: $__("Can be edited"),
                    defaultValue: false,
                },
                {
                    name: "library_groups",
                    type: "relationshipSelect",
                    label: $__("Editable by library groups"),
                    relationshipAPIClient:
                        APIClient.library_groups.library_groups,
                    relationshipOptionLabelAttr: "title",
                    relationshipRequiredKey: "library_group_id",
                    allowMultipleChoices: true,
                    query: { is_record_source_editing_group: true },
                    hideIn: ["List"],
                },
            ],
        });

        const tableOptions = {
            options: { embed: "usage_count" },
            url: baseResource.getResourceTableUrl(),
            actions: {
                "-1": [
                    "edit",
                    {
                        delete: {
                            text: $__("Delete"),
                            icon: "fa fa-trash",
                            should_display: row => row.usage_count == 0,
                        },
                    },
                ],
            },
        };

        const afterResourceFetch = (componentData, resource, caller) => {
            componentData.resource.value.library_groups = (
                resource.library_groups || []
            ).map(group => group.library_group_id);
        };

        const onFormSave = (e, recordSourceToSave) => {
            e.preventDefault();
            const recordSource = JSON.parse(JSON.stringify(recordSourceToSave)); // copy
            const recordSourceId = recordSource.record_source_id;

            delete recordSource.record_source_id;
            recordSource.library_groups = (
                recordSource.library_groups || []
            ).map(library_group_id => ({ library_group_id }));

            if (recordSourceId) {
                // update
                return baseResource.apiClient
                    .update(recordSource, recordSourceId)
                    .then(
                        recordResource => {
                            baseResource.setMessage(
                                $__("Record source updated!")
                            );
                            return recordResource;
                        },
                        error => {}
                    );
            } else {
                return baseResource.apiClient.create(recordSource).then(
                    recordResource => {
                        baseResource.setMessage($__("Record source created!"));
                        return recordResource;
                    },
                    error => {}
                );
            }
        };

        return {
            ...baseResource,
            tableOptions,
            afterResourceFetch,
            onFormSave,
        };
    },
    name: "RecordSourcesResource",
    emits: ["select-resource"],
    components: {
        BaseResource,
    },
};
</script>
