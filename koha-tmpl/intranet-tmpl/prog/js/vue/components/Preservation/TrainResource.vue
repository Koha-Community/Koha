<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resourceName: "train",
                nameAttr: "name",
                idAttr: "train_id",
                showComponent: "TrainsShow",
                listComponent: "TrainsList",
                addComponent: "TrainsFormAdd",
                editComponent: "TrainsFormAddEdit",
                apiClient: APIClient.preservation.trains,
                resourceTableUrl: APIClient.preservation._baseURL + "trains",
                i18n: {
                    displayName: __("Train"),
                },
            }),
            //TrainResource specific setup here
        };
    },
    methods: {},
    name: "TrainResource",
};
</script>
