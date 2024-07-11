<script>
import BaseResource from "../BaseResource.vue";

export default {
    extends: BaseResource,
    setup(props) {
        return {
            ...BaseResource.setup({
                resource_name: "agreement",
                id_attr: "agreement_id",
                add_component: "AgreementsFormAdd",
                edit_component: "AgreementsFormAddEdit",
            }),
            //AgreementResource specific setup here
        };
    },
    methods: {},
    name: "AgreementResource",
};
</script>
