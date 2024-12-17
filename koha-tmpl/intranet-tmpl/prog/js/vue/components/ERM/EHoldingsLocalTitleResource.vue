<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resourceName: "title",
                nameAttr: "publication_title",
                idAttr: "title_id",
                showComponent: "EHoldingsLocalTitlesShow",
                listComponent: "EHoldingsLocalTitlesList",
                addComponent: "EHoldingsLocalTitlesFormAdd",
                editComponent: "EHoldingsLocalTitlesFormAddEdit",
                apiClient: APIClient.erm.localTitles,
                resourceTableUrl:
                    APIClient.erm._baseURL + "eholdings/local/titles",
                i18n: {
                    displayName: __("Local title"),
                },
            }),
            //EHoldingsLocalTitleResource specific setup here
        };
    },
    methods: {},
    name: "EHoldingsLocalTitleResource",
};
</script>
