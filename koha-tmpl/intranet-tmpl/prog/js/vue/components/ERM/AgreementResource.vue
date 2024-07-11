<script>
import BaseResource from "../BaseResource.vue";

export default {
    extends: BaseResource,
    setup() {
        return {
            ...BaseResource.setup(),
            //AgreementResource specific setup here
        };
    },
    methods: {
        /**
         * Navigates to the edit page of the given agreement.
         *
         * @param {Object} agreement - The agreement to navigate to (optional)
         * @return {void}
         */
        goToResourceEdit: function (agreement) {
            let agreement_id =
                agreement?.agreement_id || this.agreement.agreement_id;
            this.$router.push({
                name: "AgreementsFormAddEdit",
                params: { agreement_id: agreement_id },
            });
        },
    },
    name: "AgreementResource",
};
</script>
