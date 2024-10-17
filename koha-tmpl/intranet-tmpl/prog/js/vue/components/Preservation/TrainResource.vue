<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resource_name: "train",
                name_attr: "name",
                id_attr: "train_id",
                show_component: "TrainsShow",
                list_component: "TrainsList",
                add_component: "TrainsFormAdd",
                edit_component: "TrainsFormAddEdit",
                api_client: APIClient.preservation.trains,
                resource_table_url: APIClient.preservation._baseURL + "trains",
                i18n: {
                    display_name: __("Train"),
                },
            }),
            //TrainResource specific setup here
        };
    },
    methods: {},
    name: "TrainResource",
};
</script>
