<script>
import BaseResource from "../BaseResource.vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resource_name: "agreement",
                name_attr: "name",
                id_attr: "agreement_id",
                show_component: "AgreementsShow",
                list_component: "AgreementsList",
                add_component: "AgreementsFormAdd",
                edit_component: "AgreementsFormAddEdit",
                api_client: APIClient.erm.agreements,
                resource_table_url: APIClient.erm._baseURL + "agreements",
                i18n: {
                    display_name: __("Agreement"),
                },
            }),
            //AgreementResource specific setup here
        };
    },
    methods: {},
    name: "AgreementResource",
};
</script>
