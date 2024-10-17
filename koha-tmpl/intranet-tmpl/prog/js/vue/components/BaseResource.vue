<script>
import { inject } from "vue";

export default {
    setup(props) {
        //global setup for all resource (list and show for now, but maybe others?) components here
        const { setConfirmationDialog, setMessage, setError, setWarning } =
            inject("mainStore");
        return {
            ...props,
            setConfirmationDialog,
            setMessage,
            setError,
            setWarning,
        };
    },
    methods: {
        /**
         * Navigates to the show page of the given resource.
         *
         * @param {Object} resource - The resource to navigate to
         * @return {void}
         */
        goToResourceShow: function (resource) {
            this.$router.push({
                name: this.show_component,
                params: { [this.id_attr]: resource[this.id_attr] },
            });
        },

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
        /**
         * Navigates to the list page of the given resource.
         *
         * @return {void}
         */
        goToResourceList: function () {
            this.$router.push({
                name: this.list_component,
            });
        },
        /**
         * Resource deletion handler.
         * Accepts an optional callback function to run after deletion.
         * If no callback is provided, does the following:
         * - If deleting from show component, navigates to resource list component.
         * - If deleting from resource list component, redraws the table.
         *
         * @param {Object} resource - The resource to delete (optional)
         * @param {Object} callback - Callback to call after deletion (optional)
         * @return {void}
         */
        doResourceDelete: function (resource, callback) {
            let resource_id = resource
                ? resource[this.id_attr]
                : this[this.resource_name][this.id_attr];
            let resource_name = resource
                ? resource[this.name_attr]
                : this[this.resource_name][this.name_attr];

            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this %s?"
                    ).format(this.i18n.display_name.toLowerCase()),
                    message: resource_name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    this.api_client.delete(resource_id).then(
                        success => {
                            this.setMessage(
                                this.$__("%s %s deleted").format(
                                    this.i18n.display_name,
                                    resource_name
                                ),
                                true
                            );
                            if (typeof callback === "function") {
                                callback();
                            } else {
                                if (
                                    this.$options.name === this.list_component
                                ) {
                                    this.$refs.table.redraw(
                                        this.getResourceTableUrl()
                                    );
                                } else if (
                                    this.$options.name === this.show_component
                                ) {
                                    this.goToResourceList();
                                }
                            }
                        },
                        error => {}
                    );
                }
            );
        },
        /**
         * Return the URL for the resource table.
         *
         * @return {string}
         */
        getResourceTableUrl: function () {
            return this.resource_table_url;
        },
    },
    name: "BaseResource",
    props: {
        resource_name: String,
        id_attr: String,
        show_component: String,
        add_component: String,
        edit_component: String,
    },
};
</script>
