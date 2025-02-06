<template>
    <ResourceList
        v-if="routeAction === 'list'"
        v-bind="{
            ...passCommonProps(),
            ...optionalResourceProps,
        }"
        @select-resource="$emit('select-resource', $event)"
    >
        <template #filters="{ table }">
            <ResourceListFilters
                v-if="optionalResourceProps.resourceListFiltersRequired"
                :tableFilters="tableFilters"
                :embedded="optionalResourceProps.embedded"
                :filterTable="filterTable"
                :getFilters="getFilters"
                :table="table"
            />
        </template>
    </ResourceList>
    <ResourceShow
        v-if="routeAction === 'show'"
        v-bind="{
            ...passCommonProps(),
            ...optionalResourceProps,
        }"
    />
    <ResourceFormAdd
        v-if="['add', 'edit'].includes(routeAction)"
        v-bind="{
            ...passCommonProps(),
            resource: newResource,
            onSubmit,
            ...optionalResourceProps,
        }"
    />
</template>

<script>
import { inject } from "vue";
import { build_url } from "../composables/datatables";
import ResourceListFilters from "./ResourceListFilters.vue";
import ResourceShow from "./ResourceShow.vue";
import ResourceFormAdd from "./ResourceFormAdd.vue";
import ResourceList from "./ResourceList.vue";

export default {
    components: {
        ResourceListFilters,
        ResourceShow,
        ResourceFormAdd,
        ResourceList,
    },
    setup(props) {
        const { setConfirmationDialog, setMessage, setError, setWarning } =
            inject("mainStore");

        const AVStore = inject("AVStore");
        const { get_lib_from_av, map_av_dt_filter } = AVStore;

        const format_date = $date;
        const patron_to_html = $patron_to_html;

        const optionalResourceProps = {
            embedded: props.embedded || null,
            extendedAttributesResourceType:
                props.extendedAttributesResourceType || null,
            resourceListFiltersRequired:
                props.resourceListFiltersRequired || null,
        };

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
            optionalResourceProps,
        };
    },
    data() {
        return {
            resourceToBeGenerated: {},
        };
    },
    methods: {
        /**
         * Returns an object containing common props that are passed to all components
         * in this resource component hierarchy.
         *
         * @return {Object} The object containing the common props.
         */
        passCommonProps() {
            const commonProps = {
                idAttr: this.idAttr,
                apiClient: this.apiClient,
                i18n: this.i18n,
                tableOptions: this.tableOptions,
                goToResourceShow: this.goToResourceShow,
                goToResourceEdit: this.goToResourceEdit,
                doResourceDelete: this.doResourceDelete,
                goToResourceAdd: this.goToResourceAdd,
                doResourceSelect: this.doResourceSelect,
                hasAdditionalFields: this.hasAdditionalFields,
                getFieldGroupings: this.getFieldGroupings,
                resourceAttrs: this.resourceAttrs,
                listComponent: this.listComponent,
                resourceName: this.resourceName,
            };

            return commonProps;
        },
        /**
         * Navigates to the show page of the given resource.
         *
         * @param {Object} resource - The resource to navigate to
         * @return {void}
         */
        goToResourceShow(resource) {
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
        goToResourceEdit(resource) {
            this.$router.push({
                name: this.editComponent,
                params: {
                    [this.idAttr]: resource
                        ? resource[this.idAttr]
                        : this.newResource[this.idAttr],
                },
            });
        },
        /**
         * Navigates to the creation page of the given resource.
         *
         * @return {void}
         */
        goToResourceAdd() {
            this.$router.push({
                name: this.addComponent,
            });
        },
        /**
         * Navigates to the list page of the given resource.
         *
         * @return {void}
         */
        goToResourceList() {
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
        doResourceDelete(resource, callback) {
            let resourceId = resource
                ? resource[this.idAttr]
                : this.newResource[this.idAttr];
            let resourceName = resource
                ? resource[this.nameAttr]
                : this.newResource[this.nameAttr];

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
        getResourceTableUrl() {
            return this.resourceTableUrl;
        },
        /**
         * Emits the 'select-resource' event with the id of the provided resource.
         *
         * @param {Object} resource - The resource object containing the id attribute.
         * @param {Object} dt - DataTables instance (not used in this function).
         * @param {Event} event - The event object (not used in this function).
         */

        doResourceSelect(resource, dt, event) {
            this.$emit("select-resource", resource[this.idAttr]);
        },
        /**
         * Populates the resource attributes with authorised values based on their types.
         *
         * For each attribute:
         * - If the attribute type is "select" and it has an authorised value category (avCat),
         *   it sets the options from the component's corresponding property.
         * - If the attribute type is "relationship" and it has component properties,
         *   it assigns authorised values to any marked as type 'av'.
         * - If the attribute has relationship fields, the function is recursively called
         *   to populate them as well.
         *
         * @param {Array} attrs - The array of attributes to be populated with authorised values.
         */
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
        /**
         * Updates the extended_attributes property of the provided resource
         *
         * @param {Array} additionalFieldValues - Array of objects with
         *        name and value properties.
         * @param {Object} resource - The resource object whose
         *        extended_attributes property is updated.
         */
        additionalFieldsChanged(additionalFieldValues, resource) {
            resource.extended_attributes = additionalFieldValues;
        },
        /**
         * Builds an object of filter name-value pairs based on the provided
         * query object and filterData (tableFilters by default).
         *
         * Iterates over the query object keys and updates the filterOptions
         * object with the new values. If a filter name is not found in
         * filterOptions, it is added.
         *
         * @param {Object} query - The query object (taken from the URL params)containing the filter values.
         * @param {Array} filterData - The array of filter objects (optional).
         * @return {Object}
         */
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
        /**
         * Gets the array of filters for the table, if required.
         * This is a default method that returns an empty array.
         * It can be overridden at the resource level if filters are required
         *
         * @return {Array} The array of filters for the table.
         */
        getTableFilters() {
            return [];
        },
        /**
         * This method takes a component name (e.g. 'Form' or 'Show') and an optional resource object
         * and returns an array of grouped objects that determine which fields should be grouped together
         * in the relevant component. Each group object contains the name of the group and an array of the
         * field objects that belong to that group.
         *
         * It first filters the resource attributes to only include those that are not hidden
         * in the given component. Then it groups the attributes by the group name
         * (or "noGroupFound" if there is no group name). If the component is 'Show', it also
         * checks if the resource object has data to display in each group. If not,
         * the group is not included.
         *
         * @param {String} component - The component name (e.g. 'Form' or 'Show').
         * @param {Object} resource - The resource object (optional).
         * @return {Array} The array of group objects.
         */
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
        /**
         * Generates a new resource object with default values.
         *
         * This method initializes the `resourceToBeGenerated` property by iterating
         * over `resourceAttrs`, assigning default values based on attribute types.
         * - If an attribute has a `defaultValue`, it is set accordingly.
         * - For text, textarea, and select types, an empty string is assigned.
         * - For boolean and checkbox types, a false value is assigned.
         * - For additional fields or relationship widgets, an empty array is assigned
         *   to `extended_attributes` or the attribute name.
         * - If none of the above apply, a null value is assigned.
         * The `idAttr` of the resource is also initialized to null.
         *
         * @return {Object} The newly generated resource object with default values.
         */
        newResource() {
            this.resourceToBeGenerated = this.resourceAttrs.reduce(
                (acc, attr) => {
                    if (attr.hasOwnProperty("defaultValue")) {
                        acc[attr.name] = attr.defaultValue;
                        return acc;
                    }
                    if (["text", "textarea", "select"].includes(attr.type)) {
                        acc[attr.name] = "";
                        return acc;
                    }
                    if (["boolean", "checkbox"].includes(attr.type)) {
                        acc[attr.name] = false;
                        return acc;
                    }
                    if (
                        attr.name === "additional_fields" ||
                        attr.type === "relationshipWidget"
                    ) {
                        acc[
                            attr.name === "additional_fields"
                                ? "extended_attributes"
                                : attr.name
                        ] = [];
                        return acc;
                    }
                    acc[attr.name] = null;
                    return acc;
                },
                {}
            );
            this.resourceToBeGenerated[this.idAttr] = null;
            return this.resourceToBeGenerated;
        },
        /**
         * Determines if the resource has additional fields.
         *
         * @return {Boolean} true if the resource has additional fields, false otherwise.
         */
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
