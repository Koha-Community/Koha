<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resourceName: "erm_package",
                nameAttr: "name",
                idAttr: "package_id",
                showComponent: "EHoldingsLocalPackagesShow",
                listComponent: "EHoldingsLocalPackagesList",
                addComponent: "EHoldingsLocalPackagesFormAdd",
                editComponent: "EHoldingsLocalPackagesFormAddEdit",
                apiClient: APIClient.erm.localPackages,
                resourceTableUrl:
                    APIClient.erm._baseURL + "eholdings/local/packages",
                i18n: {
                    displayName: __("Local package"),
                },
            }),
            //EHoldingsLocalPackageResource specific setup here
        };
    },
    methods: {},
    name: "EHoldingsLocalPackageResource",
};
</script>
