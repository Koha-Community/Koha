<template>
    <BaseResource :routeAction="routeAction" :instancedResource="this" />
</template>

<script>
import { inject } from "vue";
import BaseResource from "./../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "SIP2InstitutionResource",
    components: {
        BaseResource,
    },
    props: {
        routeAction: String,
    },
    emits: ["select-resource"],
    setup(props) {
        const baseResource = useBaseResource({
            resourceName: "institution",
            nameAttr: "name",
            idAttr: "sip_institution_id",
            components: {
                show: "SIP2InstitutionsShow",
                list: "SIP2InstitutionsList",
                add: "SIP2InstitutionsFormAdd",
                edit: "SIP2InstitutionsFormAddEdit",
            },
            apiClient: APIClient.sip2.institutions,
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this institution?"
                ),
                deleteSuccessMessage: $__("Institution %s deleted"),
                displayName: $__("Institution"),
                editLabel: $__("Edit institution #%s"),
                emptyListMessage: $__("There are no institutions defined"),
                newLabel: $__("New institution"),
            },
            table: {
                resourceTableUrl:
                    APIClient.sip2.httpClient._baseURL + "institutions",
            },
            resourceAttrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("Name"),
                    showInTable: true,
                    group: "Details",
                    toolTip: __(
                        "Name of the institution. Should match a library's branch code."
                    ),
                },
                {
                    name: "implementation",
                    required: true,
                    type: "text",
                    label: __("Implementation"),
                    showInTable: true,
                    group: "Details",
                    placeholder: "ILS",
                    defaultValue: "ILS",
                    toolTip: __(
                        "Use 'ILS' unless you have a specific implementation name"
                    ),
                },
                {
                    name: "checkin",
                    type: "boolean",
                    label: __("Checkin"),
                    showInTable: true,
                    group: "Policy",
                    toolTip: __(
                        "Are the self service terminals permitted to check items in?"
                    ),
                },
                {
                    name: "checkout",
                    type: "boolean",
                    label: __("Checkout"),
                    showInTable: true,
                    group: "Policy",
                    toolTip: __(
                        "Are the self service terminals permitted to check items out to patrons?"
                    ),
                },
                {
                    name: "offline",
                    type: "boolean",
                    label: __("Offline"),
                    showInTable: true,
                    group: "Policy",
                    toolTip: __(
                        "Does the ILS allow self-check units to operate when unconnected to the ILS?  That is, can a self-check unit check out items to patrons without checking the status of the items and patrons in real time?"
                    ),
                },
                {
                    name: "renewal",
                    type: "boolean",
                    label: __("Renewal"),
                    showInTable: true,
                    group: "Policy",
                    toolTip: __(
                        "Are the self service terminals permitted to renew items?"
                    ),
                },
                {
                    name: "retries",
                    required: true,
                    type: "number",
                    label: __("Retries"),
                    show_in_table: true,
                    group: "Policy",
                    showInTable: true,
                    defaultValue: 5,
                    toolTip: __(
                        "Number of times the system will attempt to connect"
                    ),
                },
                {
                    name: "status_update",
                    required: true,
                    type: "boolean",
                    label: __("Status update"),
                    showInTable: true,
                    group: "Policy",
                    toolTip: __(
                        "Are the self service terminals permitted to update patron status information. For example, can terminals block patrons?"
                    ),
                },
                {
                    name: "timeout",
                    required: true,
                    type: "number",
                    label: __("Timeout"),
                    showInTable: true,
                    group: "Policy",
                    defaultValue: 100,
                    toolTip: __(
                        "Time, in seconds, that the system will wait for a response from the ILS before timing out the request."
                    ),
                },
            ],
            props: props,
        });

        const tableOptions = {
            url: () => baseResource.getResourceTableUrl(),
            table_settings: institutions_table_settings,
            actions: {
                0: ["show"],
                "-1": ["edit", "delete"],
            },
        };

        const onFormSave = async (e, institutionToSave) => {
            e.preventDefault();

            let institution = JSON.parse(JSON.stringify(institutionToSave));
            const sip_institution_id = institution.sip_institution_id;
            delete institution.sip_institution_id;

            try {
                if (sip_institution_id) {
                    await baseResource.apiClient.update(
                        institution,
                        sip_institution_id
                    );
                    baseResource.setMessage(__("Institution updated"));
                } else {
                    await baseResource.apiClient.create(institution);
                    baseResource.setMessage(__("Institution created"));
                }
                baseResource.router.push({ name: "SIP2InstitutionsList" });
            } catch (error) {
                // Handle error here if needed
            }
        };

        return {
            ...baseResource,
            tableOptions,
            onFormSave,
        };
    },
};
</script>
