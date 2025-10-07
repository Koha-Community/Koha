<template>
    <BaseResource :routeAction="routeAction" :instancedResource="this" />
</template>
<script>
import { computed } from "vue";
import BaseResource from "./../BaseResource.vue";
import { useBaseResource } from "../../composables/base-resource.js";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export default {
    name: "SIP2SystemPreferenceOverrideResource",
    components: {
        BaseResource,
    },
    props: {
        routeAction: String,
    },
    setup(props) {
        const baseResource = useBaseResource({
            resourceName: "system_preference_override",
            nameAttr: "variable",
            idAttr: "sip_system_preference_override_id",
            components: {
                show: "SIP2SystemPreferenceOverridesShow",
                list: "SIP2SystemPreferenceOverridesList",
                add: "SIP2SystemPreferenceOverridesFormAdd",
                edit: "SIP2SystemPreferenceOverridesFormAddEdit",
            },
            apiClient: APIClient.sip2.system_preference_overrides,
            table: {
                resourceTableUrl:
                    APIClient.sip2.httpClient._baseURL +
                    "system_preference_overrides",
            },
            i18n: {
                deleteConfirmationMessage: $__(
                    "Are you sure you want to remove this system preference override?"
                ),
                deleteSuccessMessage: $__(
                    "System preference override %s deleted"
                ),
                displayName: $__("System preference override"),
                editLabel: $__("Edit system preference override #%s"),
                emptyListMessage: $__(
                    "There are no system preference overrides defined"
                ),
                newLabel: $__("New system preference override"),
            },
            resourceAttrs: [
                {
                    name: "variable",
                    required: true,
                    type: "text",
                    label: $__("Variable"),
                },
                {
                    name: "value",
                    required: true,
                    type: "text",
                    label: $__("Value"),
                },
            ],
            props: props,
        });

        const onFormSave = async (e, systemPreferenceOverrideToSave) => {
            e.preventDefault();

            let system_preference_override = JSON.parse(
                JSON.stringify(systemPreferenceOverrideToSave)
            ); // copy
            let sip_system_preference_override_id =
                system_preference_override.sip_system_preference_override_id;

            delete system_preference_override.sip_system_preference_override_id;

            try {
                if (sip_system_preference_override_id) {
                    await baseResource.apiClient.update(
                        system_preference_override,
                        sip_system_preference_override_id
                    );
                    baseResource.setMessage(
                        $__("System preference override updated")
                    );
                } else {
                    await baseResource.apiClient.create(
                        system_preference_override
                    );
                    baseResource.setMessage(
                        $__("System preference override created")
                    );
                }
                baseResource.router.push({
                    name: "SIP2SystemPreferenceOverridesList",
                });
            } catch (error) {
                // Handle error here if needed
            }
        };

        const tableOptions = computed(() => ({
            url: () => baseResource.getResourceTableUrl(),
            table_settings: system_preference_overrides_table_settings,
            actions: {
                0: ["show"],
                "-1": ["edit", "delete"],
            },
        }));
        return {
            ...baseResource,
            tableOptions,
            onFormSave,
        };
    },
};
</script>
