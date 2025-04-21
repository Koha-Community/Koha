import { computed, inject } from "vue";
import { useRouter } from "vue-router";
import { $__ } from "../i18n";
import { build_url } from "../composables/datatables";

export function useBaseResource(context) {
    const router = useRouter();
    const { setConfirmationDialog, setMessage, setError, setWarning } =
        inject("mainStore");

    const AVStore = inject("AVStore");
    const { get_lib_from_av, map_av_dt_filter } = AVStore;

    const format_date = $date;
    const patron_to_html = $patron_to_html;

    const instancedResource = {
        ...Object.keys(context).reduce((acc, key) => {
            acc[key] = context[key];
            return acc;
        }, {}),
    };

    /**
     * Navigates to the creation page of the given resource.
     *
     * @return {void}
     */
    const goToResourceAdd = () => {
        router.push({
            name: instancedResource.addComponent,
        });
    };

    /**
     * Navigates to the edit page of the given resource.
     *
     * @param {Object} resource - The resource to navigate to (optional)
     * @return {void}
     */
    const goToResourceEdit = resource => {
        router.push({
            name: instancedResource.editComponent,
            params: {
                [instancedResource.idAttr]: resource
                    ? resource[instancedResource.idAttr]
                    : instancedResource.newResource[instancedResource.idAttr],
            },
        });
    };

    /**
     * Return the URL for the resource table.
     *
     * @return {string}
     */
    const getResourceTableUrl = () => {
        return instancedResource.resourceTableUrl;
    };

    /**
     * Generates the URL for the show page of the given resource.
     *
     * @param {Object} resource - The resource to generate the URL for
     * @return {string} The URL for the show page of the given resource
     */
    const getResourceShowURL = id => {
        return router.resolve({
            name: instancedResource.showComponent,
            params: { [instancedResource.idAttr]: id },
        }).href;
    };

    /**
     * Navigates to the show page of the given resource.
     *
     * @param {Object} [resource] - The resource to navigate to
     * @param {DataTable} [dt] - The DataTable (optional)
     * @param {Event} [event] - The event to prevent default handling of (optional)
     * @return {void}
     */
    const goToResourceShow = (resource, dt, event) => {
        event?.preventDefault();
        router.push({
            name: instancedResource.showComponent,
            params: {
                [instancedResource.idAttr]: resource[instancedResource.idAttr],
            },
        });
    };

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
    const getFilterValues = (query, filterData) => {
        const filters = filterData
            ? filterData
            : instancedResource.tableFilters
              ? instancedResource.tableFilters
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
    };

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
    const getFilters = (query, filterData) => {
        const filters = filterData
            ? filterData
            : instancedResource.tableFilters
              ? instancedResource.tableFilters
              : [];
        const filterOptions = filters.reduce((acc, filter) => {
            acc[filter.name] = filter.value;
            return acc;
        }, {});
    };

    /**
     * Gets the list of default buttons to add to the toolbar, for each view: list, show, edit
     * It can be overridden at the resource level if the default buttons are not required
     *
     * @return {Object} keys must be "list", "show" or "edit", values are functions.
     */
    const defaultToolbarButtons = (resource, i18n) => {
        return {
            list: [
                {
                    action: "add",
                    onClick: () => goToResourceAdd(),
                    title: i18n.newLabel,
                    index: 0,
                },
            ],
            show: [
                {
                    action: "edit",
                    onClick: () => goToResourceEdit(resource),
                    title: __("Edit"),
                    index: 0,
                },
                {
                    action: "delete",
                    onClick: () => doResourceDelete(resource),
                    title: __("Delete"),
                    index: 1,
                },
            ],
        };
    };

    /**
     * Returns a default empty set of additional buttons
     * Additional buttons should be added in the resource specific component
     *
     * @returns {Object}
     */
    const additionalToolbarButtons = () => {
        return {
            list: [],
            show: [],
        };
    };

    const appendToShow = () => {
        return null;
    };

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
    const getFieldGroupings = (component, resource) => {
        const displayProperty = `hideIn${component}`;
        const attributesToConsider = instancedResource.resourceAttrs.filter(
            ra => !ra.hasOwnProperty(displayProperty) || !ra[displayProperty]
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
        // FIXME - if no group is defined in accordion mode then the section doesn't have the dropdown applied
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
                        resource[field.name] != null &&
                        (field.type !== "relationshipWidget" ||
                            resource[field.name].length > 0)
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
    };

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
    const populateAttributesWithAuthorisedValues = attrs => {
        if (!attrs) return;
        attrs.forEach(attr => {
            if (attr.type === "select" && typeof attr.avCat === "string") {
                const avKey = attr.avCat;
                const avArray = instancedResource[avKey].value;
                attr.options = avArray;
                attr.requiredKey = "value";
                attr.selectLabel = "description";
            }
            if (attr.type == "relationship" && attr.componentProps) {
                Object.keys(attr.componentProps).forEach(key => {
                    if (attr.componentProps[key].type == "av") {
                        attr.componentProps[key].av = instancedResource[key];
                    }
                });
            }
            if (attr.relationshipFields?.length) {
                populateAttributesWithAuthorisedValues(attr.relationshipFields);
            }
        });
    };

    const created = () => {
        if (instancedResource.resourceAttrs) {
            populateAttributesWithAuthorisedValues(
                instancedResource.resourceAttrs
            );
        }
    };

    const getResource = async (resourceId, componentData, caller) => {
        instancedResource.apiClient.get(resourceId).then(
            resource => {
                //TODO: Rename this 'resource' to 'fetchedResource'. Needs to also be renamed in ResourceFormAdd and ResourceShow
                // This is to make it clear that this is the fetchedResource (data), not the resource component class
                componentData.resource = resource;
                if (instancedResource.afterResourceFetch) {
                    instancedResource.afterResourceFetch(
                        componentData,
                        resource,
                        caller
                    );
                }
                componentData.initialized = true;
            },
            error => {}
        );
    };

    /**
     * Navigates to the list page of the given resource.
     *
     * @return {void}
     */
    const goToResourceList = () => {
        router.push({
            name: instancedResource.listComponent,
        });
    };

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
    const doResourceDelete = (resource, callback) => {
        let resourceId = resource
            ? resource[instancedResource.idAttr]
            : instancedResource.newResource[instancedResource.idAttr];
        let resourceName = resource
            ? resource[instancedResource.nameAttr]
            : instancedResource.newResource[instancedResource.nameAttr];

        setConfirmationDialog(
            {
                title: instancedResource.i18n.deleteConfirmationMessage,
                message: resourceName,
                accept_label: $__("Yes, delete"),
                cancel_label: $__("No, do not delete"),
            },
            () => {
                instancedResource.apiClient.delete(resourceId).then(
                    success => {
                        setMessage(
                            instancedResource.i18n.deleteSuccessMessage.format(
                                resourceName
                            ),
                            true
                        );
                        if (typeof callback === "function") {
                            callback();
                        } else {
                            if (
                                instancedResource.props.routeAction === "list"
                            ) {
                                callback.ajax.reload();
                            } else {
                                goToResourceList();
                            }
                        }
                    },
                    error => {}
                );
            }
        );
    };

    /**
     * Emits the 'select-resource' event with the id of the provided resource.
     *
     * @param {Object} resource - The resource object containing the id attribute.
     * @param {Object} dt - DataTables instance (not used in this function).
     * @param {Event} event - The event object (not used in this function).
     */

    const doResourceSelect = (resource, dt, event) => {
        this.$emit("select-resource", resource[instancedResource.idAttr]);
    };

    /**
     * Updates the extended_attributes property of the provided resource
     *
     * @param {Array} additionalFieldValues - Array of objects with
     *        name and value properties.
     * @param {Object} resource - The resource object whose
     *        extended_attributes property is updated.
     */
    const additionalFieldsChanged = (additionalFieldValues, resource) => {
        resource.extended_attributes = additionalFieldValues;
    };

    /**
     * Gets the label to display before the filters
     *
     * @return {String} The label
     */
    const getTableFilterFormElementsLabel = () => {
        return "";
    };

    /**
     * Gets the array of filters for the table, if required.
     * This is a default method that returns an empty array.
     * It can be overridden at the resource level if filters are required
     *
     * @return {Array} The array of filters for the table.
     */
    const getTableFilterFormElements = () => {
        return [];
    };

    const refreshTemplateState = () => {
        this.refreshTemplate = !this.refreshTemplate;
    };

    /**
     * A function that returns a set of buttons to display in the toolbar, based on the current resource and component.
     * The function takes three arguments: the resource, the component and the i18n object.
     * It returns an array of buttons. The buttons are a combination of the default buttons and the additional buttons.
     * The default buttons are defined in the defaultToolbarButtons function and the additional buttons are defined in the
     * additionalToolbarButtons function at the resource level.
     *
     * @param {Object} resource The current resource
     * @param {String} component The current component
     * @param {Object} i18n The i18n object
     * @return {Array<Object>} An array of buttons
     */
    const toolbarButtons = computed(() => {
        return (resource, component, i18n, componentData) => {
            const defaultButtons = defaultToolbarButtons(resource, i18n);
            const additionalButtons = additionalToolbarButtons(
                resource,
                componentData
            );

            //FIXME: we need to check that no indexes match between the default buttons and additional buttons
            // If we add to the default buttons in future it could mess up indexing

            return [
                ...(defaultButtons[component] || []),
                ...(additionalButtons[component] || []).filter(
                    button => Object.keys(button).length > 0
                ),
            ].sort((a, b) => a.index - b.index);
        };
    });

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
    const newResource = computed(() => {
        instancedResource.resourceToBeGenerated =
            instancedResource.resourceAttrs.reduce((acc, attr) => {
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
            }, {});
        instancedResource.resourceToBeGenerated[instancedResource.idAttr] =
            null;
        return instancedResource.resourceToBeGenerated;
    });

    /**
     * Returns the plural form of the resource name.
     *
     * This method checks if the `resourceName` ends with 's'. If it does not,
     * it appends 's' to create the plural form. Otherwise returns `resourceName`.
     *
     * @return {String} The plural form of the resource name.
     */
    const resourceNamePlural = computed(() => {
        if (!instancedResource.resourceName.endsWith("s"))
            return instancedResource.resourceName + "s";
        return instancedResource.resourceName;
    });

    /**
     * Determines if the resource has additional fields.
     *
     * @return {Boolean} true if the resource has additional fields, false otherwise.
     */
    const hasAdditionalFields = computed(() => {
        return instancedResource.resourceAttrs.some(
            attr => attr.name === "additional_fields"
        );
    });

    return {
        ...instancedResource,
        getFilterValues,
        getFilters,
        toolbarButtons,
        defaultToolbarButtons,
        additionalToolbarButtons,
        goToResourceAdd,
        getFieldGroupings,
        created,
        getResourceTableUrl,
        getResourceShowURL,
        goToResourceEdit,
        getResource,
        goToResourceShow,
        goToResourceList,
        appendToShow,
        doResourceSelect,
        doResourceDelete,
        additionalFieldsChanged,
        getTableFilterFormElementsLabel,
        getTableFilterFormElements,
        refreshTemplateState,
        resourceNamePlural,
        hasAdditionalFields,
        newResource,
        setConfirmationDialog,
        setMessage,
        setError,
        setWarning,
        format_date,
        patron_to_html,
        map_av_dt_filter,
        get_lib_from_av,
        build_url,
    };
}
