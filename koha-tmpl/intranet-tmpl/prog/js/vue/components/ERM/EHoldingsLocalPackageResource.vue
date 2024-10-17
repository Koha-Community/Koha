<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resource_name: "erm_package",
                name_attr: "name",
                id_attr: "package_id",
                show_component: "EHoldingsLocalPackagesShow",
                list_component: "EHoldingsLocalPackagesList",
                add_component: "EHoldingsLocalPackagesFormAdd",
                edit_component: "EHoldingsLocalPackagesFormAddEdit",
                api_client: APIClient.erm.localPackages,
                resource_table_url:
                    APIClient.erm._baseURL + "eholdings/local/packages",
                i18n: {
                    display_name: __("Local package"),
                },
            }),
            //EHoldingsLocalPackageResource specific setup here
        };
    },
    methods: {},
    name: "EHoldingsLocalPackageResource",
};
</script>
