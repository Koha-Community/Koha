import { computed, inject, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { build_url } from "../composables/datatables";
import { storeToRefs } from "pinia";
import {
    $__,
    $__x,
    $__n,
    $__nx,
    $__p,
    $__px,
    $__np,
    $__npx,
} from "@koha-vue/i18n";

/**
 * A composable that provides utilities for the resource component.
 *
 * The utilities provided by this composable are documented individually below.
 *
 * @param {Object} resourceConfig - The resource component instance.
 * This can take in the following parameters
 * REQUIRED:
 * @param {String} resourceConfig.resourceName - The name of the resource.
 * @param {String} resourceConfig.idAttr - The name of the id attribute of the resource.
 * @param {String} resourceConfig.nameAttr - The name attribute of the resource.
 * @param {String} resourceConfig.components - An object containing the names of the components ("show", "add", "list", "edit")
 * @param {Object} resourceConfig.i18n - The i18n object.
 * @param {Object} resourceConfig.apiClient - The API client for the resource.
 * @param {Object} resourceConfig.table - Contains the table configuration.
 * @param {String} resourceConfig.table.resourceTableUrl - The URL to the resource table.
 * @param {Array} resourceConfig.resourceAttrs - An array of attributes that relate to the resource's properties and how they should appear in the form/show/list components.
 * @param {Object} resourceConfig.props - The props passed to the resource component.
 * OPTIONAL:
 * @param {String} resourceConfig.moduleStore - The name of the module store that holds resource related data (authorised values, permissions etc)
 * @param {Boolean} resourceConfig.table.addAdditionalFilters - A flag to indicate whether to add filters to the list component for the datatable.
 * @param {Object} resourceConfig.table.filters - The table filters for the resource. Follows the format for the resourceAttrs parameter.
 * @param {Function} resourceConfig.afterResourceFetch - A function to call after the resource is fetched. This can be used to edit resource data or fetch additional data
 * @param {Boolean} resourceConfig.embedded - A flag to indicate whether the resource is actually being used as a child component of another resource e.g. embedding a list of agreeements into EBSCO package agreements
 * @param {String} resourceConfig.extendedAttributesResourceType - The resource type for extended attributes, if applicable.
 * @param {String} resourceConfig.extendedAttributesFieldGroup - The field group that you would like the additional fields to be displayed in.
 * @param {Function} resourceConfig.defaultToolbarButtons - A function to amend default buttons in the toolbar.
 * @param {Function} resourceConfig.additionalToolbarButtons - A function to add additional buttons to the toolbar.
 * @param {String} resourceConfig.formGroupsDisplayMode - The display mode for the form groups if not the default. Can be one of the following: "accordion", "tabs".
 * @param {Array} resourceConfig.stickyToolbar - The names of the components with a toolbar that should be sticky.
 * @param {Array} resourceConfig.navigationOnFormSave - The name of the component that should be navigated to when saving the resource creation/edit form. Defaults to the show component
 *
 * @return {Object} An object containing the utilities provided by this composable.
 */
export function useBaseResource(resourceConfig) {
    const router = useRouter();
    const route = useRoute();
    const { setConfirmationDialog, setMessage, setError, setWarning } =
        inject("mainStore");
    const navigationStore = inject("navigationStore");
    const { breadcrumbMetadata } = storeToRefs(navigationStore);

    const moduleStoreUtils = {};
    if (resourceConfig.moduleStore) {
        const moduleStore = inject(resourceConfig.moduleStore);
        const { get_lib_from_av, map_av_dt_filter, isUserPermitted } =
            moduleStore;
        const { authorisedValues, userPermissions } = storeToRefs(moduleStore);

        if (authorisedValues) {
            moduleStoreUtils.get_lib_from_av = get_lib_from_av;
            moduleStoreUtils.map_av_dt_filter = map_av_dt_filter;
            moduleStoreUtils.authorisedValues = authorisedValues.value;
        }

        if (userPermissions) {
            moduleStoreUtils.userPermissions = userPermissions.value;
            moduleStoreUtils.isUserPermitted = isUserPermitted;
        }
    }

    let i18n = resourceConfig.i18n;

    /**
     **********************************************************************
     * TOOLBAR RELATED METHODS
     **********************************************************************
     */

    /**
     * A function that returns a set of buttons to display in the toolbar, based on the current resource and component.
     * The function takes two arguments: the resource and the component.
     * It returns an array of buttons. The buttons are a combination of the default buttons and the additional buttons.
     * The default buttons are defined in the defaultToolbarButtons function and the additional buttons are defined in the
     * additionalToolbarButtons function at the resource level.
     *
     * @param {Object} resource The current resource
     * @param {String} component The current component
     * @return {Array<Object>} An array of buttons
     */
    const toolbarButtons = computed(() => {
        return (resource, component, componentData) => {
            let defaultButtons = defaultToolbarButtons(resource);
            defaultButtons = resourceConfig.hasOwnProperty(
                "defaultToolbarButtons"
            )
                ? resourceConfig.defaultToolbarButtons(
                      defaultButtons,
                      resource || {}
                  )
                : defaultButtons;
            const additionalButtons = resourceConfig.hasOwnProperty(
                "additionalToolbarButtons"
            )
                ? resourceConfig.additionalToolbarButtons(
                      resource || {},
                      componentData
                  )
                : additionalToolbarButtons(resource, componentData);

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
     * Gets the list of default buttons to add to the toolbar, for each view: list, show, edit
     * It can be overridden at the resource level if the default buttons are not required
     *
     * @return {Object} keys must be "list", "show" or "edit", values are functions.
     */
    const defaultToolbarButtons = resource => {
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
                    title: $__("Edit"),
                    index: 0,
                },
                {
                    action: "delete",
                    onClick: () => doResourceDelete(resource),
                    title: $__("Delete"),
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

    /**
     * Navigates to the creation page of the given resource.
     *
     * @return {void}
     */
    const goToResourceAdd = () => {
        router.push({
            name: resourceConfig.components.add,
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
            name: resourceConfig.components.edit,
            params: {
                [resourceConfig.idAttr]: resource
                    ? resource[resourceConfig.idAttr]
                    : resourceConfig.newResource[resourceConfig.idAttr],
            },
        });
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
            name: resourceConfig.components.show,
            params: {
                [resourceConfig.idAttr]: resource[resourceConfig.idAttr],
            },
        });
    };

    /**
     * Navigates to the list page of the given resource.
     *
     * @return {void}
     */
    const goToResourceList = () => {
        router.push({
            name: resourceConfig.components.list,
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
            ? resource[resourceConfig.idAttr]
            : resourceConfig.newResource[resourceConfig.idAttr];
        let resourceName = resource
            ? resource[resourceConfig.nameAttr]
            : resourceConfig.newResource[resourceConfig.nameAttr];

        setConfirmationDialog(
            {
                title: i18n.deleteConfirmationMessage,
                message: resourceName,
                accept_label: $__("Yes, delete"),
                cancel_label: $__("No, do not delete"),
            },
            () => {
                resourceConfig.apiClient.delete(resourceId).then(
                    success => {
                        setMessage(
                            i18n.deleteSuccessMessage.format(resourceName),
                            true
                        );
                        if (typeof callback === "function") {
                            callback();
                        } else {
                            if (resourceConfig.props.routeAction === "list") {
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
        resourceConfig.$emit(
            "select-resource",
            resource[resourceConfig.idAttr]
        );
    };

    /*
     **********************************************************************
     * DATATABLES RELATED METHODS
     **********************************************************************
     */

    /**
     * Return the URL for the resource table.
     *
     * @return {string}
     */
    const getResourceTableUrl = () => {
        return resourceConfig.table.resourceTableUrl;
    };

    /**
     * Generates the URL for the show page of the given resource.
     *
     * @param {Object} resource - The resource to generate the URL for
     * @return {string} The URL for the show page of the given resource
     */
    const getResourceShowURL = id => {
        return router.resolve({
            name: resourceConfig.components.show,
            params: { [resourceConfig.idAttr]: id },
        }).href;
    };

    /**
     * Builds an object of filter name-value pairs based on the provided
     * query object and filterData ('filters' by default).
     *
     * Iterates over the query object keys and updates the filterOptions
     * object with the new values. If a filter name is not found in
     * filterOptions, it is added.
     *
     * @param {Object} query - The query object (taken from the URL params)containing the filter values.
     * @param {Array} filterData - The array of filter objects (optional).
     * @return {Object}
     */
    const getFilterValues = (query, filterData = []) => {
        const filters = filterData.length
            ? filterData
            : resourceConfig.table.additionalFilters
              ? resourceConfig.table.additionalFilters
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
     * Gets the label to display before the filters in the List component
     * This is a default method that returns an empty string.
     * It can be overridden at the resource level if filters are required
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

    /*
     **********************************************************************
     * RESOURCE DISPLAY RELATED METHODS
     **********************************************************************
     */

    /**
     * A function that can be used to add additional content to the show view
     * of a resource. The function should return an array of attributes such as those in 'resourceAttrs' in the module specific resources
     *
     * @returns {Array}
     */
    const appendToShow = () => {
        return [];
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
        const attributesToConsider = resourceConfig.resourceAttrs.reduce(
            (acc, ra) => {
                if (ra.type === "relationshipWidget") {
                    ra.relationshipFields.forEach(relationshipField => {
                        relationshipField.relationshipName = ra.name;
                    });
                }
                const shouldFieldBeHidden = ra.hideIn && typeof ra.hideIn === "function" ? ra.hideIn() : ra.hideIn
                if (shouldFieldBeHidden && !shouldFieldBeHidden.includes(component)) {
                    return [...acc, ra];
                }
                if (shouldFieldBeHidden && shouldFieldBeHidden.includes(component)) {
                    return acc;
                }
                return [...acc, ra];
            },
            []
        );
        if (resourceConfig.extendedAttributesResourceType) {
            attributesToConsider.push({
                name: "additional_fields",
                type: "additional_fields",
                extended_attributes_resource_type:
                    resourceConfig.extendedAttributesResourceType,
                ...(resourceConfig.extendedAttributesFieldGroup && {
                    group: resourceConfig.extendedAttributesFieldGroup,
                }),
            });
        }
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
            if (
                component === "Show" &&
                resourceConfig.showGroupsDisplayMode === "splitScreen" &&
                resourceConfig.splitScreenGroupings.length > 0
            ) {
                const splitScreenGrouping =
                    resourceConfig.splitScreenGroupings.find(
                        g => g.name === group
                    );
                if (splitScreenGrouping) {
                    groupInfo.splitPane = splitScreenGrouping.pane;
                } else {
                    // Default to first pane
                    groupInfo.splitPane = 1;
                }
            }
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
     * Retrieves a resource by id and assigns it to the component data.
     * If the resource component has an 'afterResourceFetch' method, it is called
     * with the component data, the fetched resource and the caller as arguments.
     * When the resource is retrieved, the 'initialized' flag is set to true.
     * @param {String} resourceId - The id of the resource to retrieve.
     * @param {Object} componentData - The component data to assign the resource to.
     * @param {String} caller - The name of the caller that requested the resource
     *                         (e.g. 'form', 'list', 'show').
     */
    const getResource = async (resourceId, componentData, caller) => {
        resourceConfig.apiClient.get(resourceId).then(
            resource => {
                //TODO: Rename this 'resource' to 'fetchedResource'. Needs to also be renamed in ResourceFormSave and ResourceShow
                // This is to make it clear that this is the fetchedResource (data), not the resource component class
                componentData.resource.value = resource;
                breadcrumbMetadata.value = resource;
                if (componentData.instancedResource.afterResourceFetch) {
                    componentData.instancedResource.afterResourceFetch(
                        componentData,
                        resource,
                        caller
                    );
                }
                componentData.initialized.value = true;
            },
            error => {}
        );
    };

    /**
     * Returns the plural form of the resource name.
     *
     * This method checks if the `resourceName` ends with 's'. If it does not,
     * it appends 's' to create the plural form. Otherwise returns `resourceName`.
     *
     * @return {String} The plural form of the resource name.
     */
    const resourceNamePlural = computed(() => {
        if (!resourceConfig.resourceName.endsWith("s"))
            return resourceConfig.resourceName + "s";
        return resourceConfig.resourceName;
    });

    /*
     **********************************************************************
     * RESOURCE CREATION RELATED METHODS
     **********************************************************************
     */

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
        resourceConfig.resourceToBeGenerated =
            resourceConfig.resourceAttrs.reduce((acc, attr) => {
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
                if (attr.type === "relationshipWidget") {
                    acc[attr.name] = [];
                    return acc;
                }
                acc[attr.name] = null;
                return acc;
            }, {});
        if (resourceConfig.extendedAttributesResourceType) {
            resourceConfig.resourceToBeGenerated.extended_attributes = [];
        }
        resourceConfig.resourceToBeGenerated[resourceConfig.idAttr] = null;
        return resourceConfig.resourceToBeGenerated;
    });

    /*
     **********************************************************************
     * RESOURCE UTILITY METHODS
     **********************************************************************
     */

    /**
     * Determines if the resource has additional fields.
     *
     * @return {Boolean} true if the resource has additional fields, false otherwise.
     */
    const hasAdditionalFields = computed(() => {
        return !!resourceConfig.extendedAttributesResourceType;
    });

    const refreshTemplate = ref(0);
    /**
     * Toggle the refreshTemplate flag of the resource.
     * This flag is used to force a reload of the template by Vue.
     * It is typically used when the data of the resource has been updated.
     *
     * @return {void}
     */
    const refreshTemplateState = () => {
        refreshTemplate.value++;
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
        const { authorisedValues } = moduleStoreUtils;
        if (!attrs) return;
        attrs.forEach(attr => {
            if (attr.type === "select" && typeof attr.avCat === "string") {
                const avKey = attr.avCat;
                const avArray = authorisedValues[avKey];
                if ((!avArray || !avArray.length) && attr.fallbackType) {
                    attr.type = attr.fallbackType;
                } else {
                    attr.options = avArray;
                    attr.requiredKey = "value";
                    attr.selectLabel = "description";
                }
            }
            if (attr.relationshipFields?.length) {
                populateAttributesWithAuthorisedValues(attr.relationshipFields);
            }
        });
    };

    /**
     * Initializes the component by populating resource attributes
     * with their respective authorised values. This ensures that
     * any select or relationship attributes have the correct options
     * or authorised values assigned before the component is used.
     */
    const created = () => {
        if (resourceConfig.resourceAttrs) {
            populateAttributesWithAuthorisedValues(
                resourceConfig.resourceAttrs
            );
        }
    };

    created();

    return {
        ...resourceConfig,
        ...moduleStoreUtils,
        getFilterValues,
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
        refreshTemplate,
        resourceNamePlural,
        hasAdditionalFields,
        newResource,
        setConfirmationDialog,
        setMessage,
        setError,
        setWarning,
        build_url,
        route,
        router,
        i18n,
    };
}
