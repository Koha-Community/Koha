<script>
import BaseResource from "./../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    props: {
        routeAction: String,
    },
    setup(props) {
        return {
            ...BaseResource.setup({
                resourceName: "system_preference_override",
                nameAttr: "variable",
                idAttr: "sip_system_preference_override_id",
                showComponent: "SIP2SystemPreferenceOverridesShow",
                listComponent: "SIP2SystemPreferenceOverridesList",
                addComponent: "SIP2SystemPreferenceOverridesFormAdd",
                editComponent: "SIP2SystemPreferenceOverridesFormAddEdit",
                apiClient: APIClient.sip2.system_preference_overrides,
                resourceTableUrl:
                    APIClient.sip2._baseURL + "system_preference_overrides",
                i18n: {
                    displayName: __("System preference override"),
                    displayNameLowerCase: __("system preference override"),
                    displayNamePlural: __("system preference overrides"),
                },
            }),
        };
    },
    data() {
        return {
            resourceAttrs: [
                {
                    name: "variable",
                    required: true,
                    type: "text",
                    label: __("Variable"),
                },
                {
                    name: "value",
                    required: true,
                    type: "text",
                    label: __("Value"),
                },
            ],
            tableOptions: {
                columns: this.getTableColumns(),
                url: () => this.resourceTableUrl,
                table_settings: this.system_preference_overrides_table_settings,
                actions: {
                    0: ["show"],
                    "-1": this.embedded
                        ? [
                              {
                                  select: {
                                      text: this.$__("Select"),
                                      icon: "fa fa-check",
                                  },
                              },
                          ]
                        : ["edit", "delete"],
                },
            },
        };
    },
    methods: {
        getTableColumns: function () {
            return [
                {
                    title: __("Variable"),
                    data: "variable",
                    searchable: true,
                    orderable: true,
                },
                {
                    title: __("Value"),
                    data: "value",
                    searchable: true,
                    orderable: true,
                },
            ];
        },
        onSubmit(e, systemPreferenceOverrideToSave) {
            e.preventDefault();

            let system_preference_override = JSON.parse(
                JSON.stringify(systemPreferenceOverrideToSave)
            ); // copy
            let sip_system_preference_override_id =
                system_preference_override.sip_system_preference_override_id;

            delete system_preference_override.sip_system_preference_override_id;

            const client = APIClient.sip2;
            if (sip_system_preference_override_id) {
                client.system_preference_overrides
                    .update(
                        system_preference_override,
                        sip_system_preference_override_id
                    )
                    .then(
                        success => {
                            this.setMessage(
                                this.$__("System preference override updated")
                            );
                            this.$router.push({
                                name: "SIP2SystemPreferenceOverridesList",
                            });
                        },
                        error => {}
                    );
            } else {
                client.system_preference_overrides
                    .create(system_preference_override)
                    .then(
                        success => {
                            this.setMessage(
                                this.$__("System preference override created")
                            );
                            this.$router.push({
                                name: "SIP2SystemPreferenceOverridesList",
                            });
                        },
                        error => {}
                    );
            }
        },
    },
    name: "SIP2SystemPreferenceOverrideResource",
};
</script>
