<script>
import { inject } from "vue";
import { build_url } from "../composables/datatables";

export default {
    props: {
        routeAction: String,
        resourceName: String,
        idAttr: String,
        showComponent: String,
        addComponent: String,
        editComponent: String,
    },
    setup(props) {
        const { setConfirmationDialog, setMessage, setError, setWarning } =
            inject("mainStore");

        const AVStore = inject("AVStore");
        const { get_lib_from_av, map_av_dt_filter } = AVStore;

        const format_date = $date;
        const patron_to_html = $patron_to_html;

        return {
            ...props,
            setConfirmationDialog,
            setMessage,
            setError,
            setWarning,
            format_date,
            patron_to_html,
            ...(typeof logged_in_user !== "undefined" && { logged_in_user }),
            escape_str,
            get_lib_from_av,
            map_av_dt_filter,
            build_url,
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
                name: this.showComponent,
                params: { [this.idAttr]: resource[this.idAttr] },
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
                name: this.editComponent,
                params: {
                    [this.idAttr]: resource
                        ? resource[this.idAttr]
                        : this[this.resourceName][this.idAttr],
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
                name: this.addComponent,
            });
        },
        /**
         * Navigates to the list page of the given resource.
         *
         * @return {void}
         */
        goToResourceList: function () {
            this.$router.push({
                name: this.listComponent,
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
            let resourceId = resource
                ? resource[this.idAttr]
                : this[this.resourceName][this.idAttr];
            let resourceName = resource
                ? resource[this.nameAttr]
                : this[this.resourceName][this.nameAttr];

            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this %s?"
                    ).format(this.i18n.displayName.toLowerCase()),
                    message: resourceName,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    this.apiClient.delete(resourceId).then(
                        success => {
                            this.setMessage(
                                this.$__("%s %s deleted").format(
                                    this.i18n.displayName,
                                    resourceName
                                ),
                                true
                            );
                            if (typeof callback === "function") {
                                callback();
                            } else {
                                if (this.$props.routeAction === "list") {
                                    callback.ajax.reload();
                                } else {
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
            return this.resourceTableUrl;
        },
        doResourceSelect: function (resource, dt, event) {
            this.$emit("select-resource", resource[this.idAttr]);
        },
        populateAttributesWithAuthorisedValues(attrs) {
            if (!attrs) return;
            attrs.forEach(attr => {
                if (attr.type === "select" && typeof attr.avCat === "string") {
                    const avKey = attr.avCat;
                    attr.options = this[avKey];
                    attr.requiredKey = "value";
                    attr.selectLabel = "description";
                }
                if (attr.type == "relationship" && attr.componentProps) {
                    Object.keys(attr.componentProps).forEach(key => {
                        if (attr.componentProps[key].type == "av") {
                            attr.componentProps[key].av = this[key];
                        }
                    });
                }
                if (attr.relationshipFields?.length) {
                    this.populateAttributesWithAuthorisedValues(
                        attr.relationshipFields
                    );
                }
            });
        },
        additionalFieldsChanged(additionalFieldValues, resource) {
            resource.extended_attributes = additionalFieldValues;
        },
        getFilters(query, filterData) {
            const filters = filterData
                ? filterData
                : this.tableFilters
                  ? this.tableFilters
                  : [];
            const filterOptions = filters.reduce((acc, filter) => {
                acc[filter.name] = filter.value;
                return acc;
            }, {});

            Object.keys(query).forEach(key => {
                if (
                    filterOptions.hasOwnProperty(key) &&
                    query[key] !== filterOptions[key]
                ) {
                    filterOptions[key] = query[key];
                }
                if (!filterOptions.hasOwnProperty(key)) {
                    filterOptions[key] = query[key];
                }
            });
            return filterOptions;
        },
        getFieldGroupings(component, resource) {
            const displayProperty = `hideIn${component}`;
            const attributesToConsider = this.resourceAttrs.filter(
                ra =>
                    !ra.hasOwnProperty(displayProperty) || !ra[displayProperty]
            );
            const groupings = attributesToConsider.reduce((acc, attr) => {
                if (
                    attr.hasOwnProperty("group") &&
                    attr.group !== null &&
                    !acc.includes(attr.group)
                ) {
                    return [...acc, attr.group];
                }
                if (!attr.hasOwnProperty("group")) {
                    attr.group = "noGroupFound";
                    if (!acc.includes("noGroupFound")) {
                        return [...acc, "noGroupFound"];
                    }
                }
                return acc;
            }, []);
            if (groupings.length === 0) {
                return [
                    {
                        name: null,
                        fields: attributesToConsider,
                    },
                ];
            }
            return groupings.reduce((acc, group) => {
                const groupFields = attributesToConsider.filter(
                    ra => ra.group === group
                );
                const groupInfo = {
                    name: group === "noGroupFound" ? null : group,
                    fields: groupFields,
                    hasDataToDisplay: false,
                };
                if (component === "Show" && resource) {
                    groupFields.forEach(field => {
                        if (
                            resource.hasOwnProperty(field.name) &&
                            resource[field.name] &&
                            resource[field.name]?.length > 0
                        ) {
                            groupInfo.hasDataToDisplay = true;
                        }
                    });
                    if (!groupInfo.hasDataToDisplay) {
                        return [...acc];
                    }
                }
                return [...acc, groupInfo];
            }, []);
        },
    },
    computed: {
        newResource() {
            return this[this.resourceName];
        },
        hasAdditionalFields() {
            return this.resourceAttrs.some(
                attr => attr.name === "additional_fields"
            );
        },
    },
    created() {
        this.populateAttributesWithAuthorisedValues(this.resourceAttrs);
    },
    name: "BaseResource",
};
</script>
