<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resource_name: "license",
                name_attr: "name",
                id_attr: "license_id",
                show_component: "LicensesShow",
                list_component: "LicensesList",
                add_component: "LicensesFormAdd",
                edit_component: "LicensesFormAddEdit",
                api_client: APIClient.erm.licenses,
                resource_table_url: APIClient.erm._baseURL + "licenses",
                i18n: {
                    display_name: __("License"),
                },
            }),
            //LicenseResource specific setup here
        };
    },
    methods: {},
    name: "LicenseResource",
};
</script>
