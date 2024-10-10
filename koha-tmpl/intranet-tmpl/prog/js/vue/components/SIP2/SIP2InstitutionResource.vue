<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
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
                    show_in_table: true,
                },
                {
                    name: "implementation",
                    required: true,
                    type: "text",
                    label: __("Implementation"),
                    show_in_table: true,
                },
                {
                    name: "checkin",
                    type: "boolean",
                    label: __("Checkin"),
                    show_in_table: true,
                },
                {
                    name: "checkout",
                    type: "boolean",
                    label: __("Checkout"),
                    show_in_table: true,
                },
                {
                    name: "offline",
                    type: "boolean",
                    label: __("Offline"),
                    show_in_table: true,
                    group: "Policy",
                },
                {
                    name: "renewal",
                    type: "boolean",
                    label: __("Renewal"),
                    show_in_table: true,
                },
                {
                    name: "retries",
                    required: true,
                    type: "text",
                    label: __("Retries"),
                    show_in_table: true,
                },
                {
                    name: "status_update",
                    required: true,
                    type: "boolean",
                    label: __("Status update"),
                    show_in_table: true,
                },
                {
                    name: "timeout",
                    required: true,
                    type: "text",
                    label: __("Timeout"),
                    show_in_table: true,
                },
            ],
        };
    },
    methods: {},
    name: "SIP2InstitutionResource",
};
</script>
