<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resourceName: "license",
                nameAttr: "name",
                idAttr: "license_id",
                showComponent: "LicensesShow",
                listComponent: "LicensesList",
                addComponent: "LicensesFormAdd",
                editComponent: "LicensesFormAddEdit",
                apiClient: APIClient.erm.licenses,
                resourceTableUrl: APIClient.erm._baseURL + "licenses",
                i18n: {
                    displayName: __("License"),
                },
            }),
            //LicenseResource specific setup here
        };
    },
    methods: {},
    name: "LicenseResource",
};
</script>
