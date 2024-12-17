<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resourceName: "usage_data_provider",
                nameAttr: "name",
                idAttr: "erm_usage_data_provider_id",
                showComponent: "UsageStatisticsDataProvidersShow",
                listComponent: "UsageStatisticsDataProvidersList",
                addComponent: "UsageStatisticsDataProvidersFormAdd",
                editComponent: "UsageStatisticsDataProvidersFormAddEdit",
                apiClient: APIClient.erm.usage_data_providers,
                resourceTableUrl:
                    APIClient.erm._baseURL + "usage_data_providers",
                i18n: {
                    displayName: __("Data provider"),
                },
            }),
            //UsageStatisticsDataProviderResource specific setup here
        };
    },
    methods: {},
    name: "UsageStatisticsDataProviderResource",
};
</script>
