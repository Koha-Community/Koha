<template>
    <BaseResource
        :routeAction="routeAction"
        :instancedResource="this"
    ></BaseResource>
</template>
<script>
import { inject } from "vue";
import BaseResource from "../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    props: {
        routeAction: String,
    },

    setup(props) {
        const ILLStore = inject("ILLStore");
        const { config } = ILLStore;

        const baseResource = useBaseResource({
            resourceName: "iso18626_requesting_agency",
            nameAttr: "name",
            idAttr: "iso18626_requesting_agency_id",
            components: {
                show: "RequestingAgenciesShow",
                list: "RequestingAgenciesList",
                add: "RequestingAgenciesFormAdd",
                edit: "RequestingAgenciesFormAddEdit",
            },
            apiClient: APIClient.ill.requesting_agencies,
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this requesting agency?"
                ),
                deleteSuccessMessage: $__("Requesting agency %s deleted"),
                displayName: $__("Requesting agency"),
                editLabel: $__("Edit requesting agency #%s"),
                emptyListMessage: $__(
                    "There are no requesting agencies defined"
                ),
                newLabel: $__("New requesting agency"),
            },
            table: {
                resourceTableUrl:
                    APIClient.ill.httpClient._baseURL +
                    "iso18626_requesting_agencies",
            },
            resourceAttrs: [
                {
                    name: "iso18626_requesting_agency_id",
                    label: $__("ID"),
                    type: "text",
                    hideIn: ["Form"],
                    group: $__("Details"),
                },
                {
                    name: "patron_id",
                    type: "patronAutoComplete",
                    label: $__("ILL partner"),
                    placeholder: $__("Search for an ILL partner"),
                    patronAutoCompleteOptions: {
                        "additional-filters": {
                            "me.category_id": config.settings.ILLPartnerCode,
                        },
                    },
                    patronEmbedName: "ill_partner",
                    required: true,
                    group: $__("Details"),
                },
                {
                    name: "name",
                    label: $__("Name"),
                    required: true,
                    type: "text",
                    group: $__("Details"),
                },
                {
                    name: "type",
                    label: $__("Type"),
                    required: true,
                    type: "select",
                    options: [
                        {
                            value: "DNUCNI",
                            description: $__("DNUCNI"),
                        },
                        {
                            value: "ICOLC",
                            description: $__("ICOLC"),
                        },
                        {
                            value: "ISIL",
                            description: $__("ISIL"),
                        },
                    ],
                    requiredKey: "value",
                    selectLabel: "description",
                    group: $__("Details"),
                },
                {
                    name: "account_id",
                    label: $__("Account ID"),
                    required: true,
                    type: "text",
                    group: $__("ISO18626 authentication"),
                },
                {
                    name: "securityCode",
                    label: $__("Security code"),
                    required: true,
                    type: "text",
                    hideIn: ["List"],
                    group: $__("ISO18626 authentication"),
                },
                {
                    name: "callback_endpoint",
                    label: $__("Callback endpoint"),
                    placeholder: $__(
                        "http://localhost:8081/api/v1/contrib/iso18626/supplying_agency_message"
                    ),
                    type: "text",
                    hideIn: ["List"],
                    group: $__("Details"),
                },
            ],
            moduleStore: "ILLStore",
            props: props,
        });

        const tableOptions = {
            url: () => tableUrl(),
            options: {
                embed: "ill_partner",
            },
            actions: {
                0: ["show"],
                1: ["show"],
                "-1": ["edit", "delete"],
            },
        };

        const onFormSave = (e, requestingAgencyToSave) => {
            e.preventDefault();

            let iso18626_requesting_agency = JSON.parse(
                JSON.stringify(requestingAgencyToSave)
            ); // copy
            let iso18626_requesting_agency_id =
                iso18626_requesting_agency.iso18626_requesting_agency_id;

            delete iso18626_requesting_agency.iso18626_requesting_agency_id;
            delete iso18626_requesting_agency.ill_partner;

            if (iso18626_requesting_agency_id) {
                return baseResource.apiClient
                    .update(
                        iso18626_requesting_agency,
                        iso18626_requesting_agency_id
                    )
                    .then(
                        requesting_agency => {
                            baseResource.setMessage(
                                $__("Requesting agency updated")
                            );
                            return requesting_agency;
                        },
                        error => {}
                    );
            } else {
                return baseResource.apiClient
                    .create(iso18626_requesting_agency)
                    .then(
                        requesting_agency => {
                            baseResource.setMessage(
                                $__("Requesting agency created")
                            );
                            return requesting_agency;
                        },
                        error => {}
                    );
            }
        };
        const tableUrl = filters => {
            return baseResource.getResourceTableUrl();
        };

        return {
            ...baseResource,
            tableOptions,
            onFormSave,
            tableUrl,
        };
    },
    emits: ["select-resource"],
    name: "RequestingAgencyResource",
    components: {
        BaseResource,
    },
};
</script>
