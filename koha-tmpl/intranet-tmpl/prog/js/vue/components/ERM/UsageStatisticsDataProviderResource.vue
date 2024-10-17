<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resource_name: "usage_data_provider",
                name_attr: "name",
                id_attr: "erm_usage_data_provider_id",
                show_component: "UsageStatisticsDataProvidersShow",
                list_component: "UsageStatisticsDataProvidersList",
                add_component: "UsageStatisticsDataProvidersFormAdd",
                edit_component: "UsageStatisticsDataProvidersFormAddEdit",
                api_client: APIClient.erm.usage_data_providers,
                resource_table_url:
                    APIClient.erm._baseURL + "usage_data_providers",
                i18n: {
                    display_name: __("Data provider"),
                },
            }),
            //UsageStatisticsDataProviderResource specific setup here
        };
    },
    methods: {},
    name: "UsageStatisticsDataProviderResource",
};
</script>
