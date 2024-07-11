<script>
import { inject } from "vue";

export default {
    setup(props) {
        //global setup for all resource (list and show for now, but maybe others?) components here
        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore");
        return { ...props, setConfirmationDialog, setMessage, setError };
    },
    methods: {
        /**
         * Navigates to the edit page of the given resource.
         *
         * @param {Object} resource - The resource to navigate to (optional)
         * @return {void}
         */
        goToResourceEdit: function (resource) {
            this.$router.push({
                name: this.edit_component,
                params: {
                    [this.id_attr]: resource
                        ? resource[this.id_attr]
                        : this[this.resource_name][this.id_attr],
                },
            });
        },
        /**
         * Navigates to the creation page of the given resource.
         *
         * @return {void}
         */
        goToResourceAdd: function () {
            this.$router.push({
                name: this.add_component,
            });
        },
    },
    name: "BaseResource",
    props: {
        resource_name: String,
        id_attr: String,
        add_component: String,
        edit_component: String,
    },
};
</script>
