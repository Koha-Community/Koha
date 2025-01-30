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
                resourceName: "institution",
                nameAttr: "name",
                idAttr: "sip_institution_id",
                showComponent: "SIP2InstitutionsShow",
                listComponent: "SIP2InstitutionsList",
                addComponent: "SIP2InstitutionsFormAdd",
                editComponent: "SIP2InstitutionsFormAddEdit",
                apiClient: APIClient.sip2.institutions,
                resourceTableUrl: APIClient.sip2._baseURL + "institutions",
                i18n: {
                    displayName: __("Institution"),
                    displayNameLowerCase: __("institution"),
                    displayNamePlural: __("institutions"),
                },
            }),
        };
    },
    data() {
        return {
            resourceAttrs: [
                {
                    name: "name",
                    required: true,
                    type: "text",
                    label: __("Name"),
                    showInTable: true,
                    group: "Details",
                },
                {
                    name: "implementation",
                    required: true,
                    type: "text",
                    label: __("Implementation"),
                    showInTable: true,
                    group: "Details",
                },
                {
                    name: "checkin",
                    type: "boolean",
                    label: __("Checkin"),
                    showInTable: true,
                    group: "Policy",
                },
                {
                    name: "checkout",
                    type: "boolean",
                    label: __("Checkout"),
                    showInTable: true,
                    group: "Policy",
                },
                {
                    name: "offline",
                    type: "boolean",
                    label: __("Offline"),
                    showInTable: true,
                    group: "Policy",
                },
                {
                    name: "renewal",
                    type: "boolean",
                    label: __("Renewal"),
                    showInTable: true,
                    group: "Policy",
                },
                {
                    name: "retries",
                    required: true,
                    type: "text",
                    label: __("Retries"),
                    show_in_table: true,
                    group: "Policy",
                    showInTable: true,
                    defaultValue: 5,
                },
                {
                    name: "status_update",
                    required: true,
                    type: "boolean",
                    label: __("Status update"),
                    showInTable: true,
                    group: "Policy",
                },
                {
                    name: "timeout",
                    required: true,
                    type: "text",
                    label: __("Timeout"),
                    showInTable: true,
                    group: "Policy",
                    defaultValue: 100,
                },
            ],
            tableOptions: {
                columns: this.getTableColumns(),
                url: () => this.resourceTableUrl,
                table_settings: this.institutions_table_settings,
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
        onSubmit(e, institutionToSave) {
            e.preventDefault();

            let institution = JSON.parse(JSON.stringify(institutionToSave)); // copy
            let sip_institution_id = institution.sip_institution_id;

            delete institution.sip_institution_id;

            const client = APIClient.sip2;
            if (sip_institution_id) {
                client.institutions
                    .update(institution, sip_institution_id)
                    .then(
                        success => {
                            this.setMessage(this.$__("Institution updated"));
                            this.$router.push({ name: "SIP2InstitutionsList" });
                        },
                        error => {}
                    );
            } else {
                client.institutions.create(institution).then(
                    success => {
                        this.setMessage(this.$__("Institution created"));
                        this.$router.push({ name: "SIP2InstitutionsList" });
                    },
                    error => {}
                );
            }
        },
    },
    name: "SIP2InstitutionResource",
};
</script>
