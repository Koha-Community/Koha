<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resource_name: "title",
                name_attr: "publication_title",
                id_attr: "title_id",
                show_component: "EHoldingsLocalTitlesShow",
                list_component: "EHoldingsLocalTitlesList",
                add_component: "EHoldingsLocalTitlesFormAdd",
                edit_component: "EHoldingsLocalTitlesFormAddEdit",
                api_client: APIClient.erm.localTitles,
                resource_table_url:
                    APIClient.erm._baseURL + "eholdings/local/titles",
                i18n: {
                    display_name: __("Local title"),
                },
            }),
            //EHoldingsLocalTitleResource specific setup here
        };
    },
    methods: {},
    name: "EHoldingsLocalTitleResource",
};
</script>
